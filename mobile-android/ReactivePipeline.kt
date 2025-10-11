package app.fieldprime.pipeline

import java.time.Instant
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flatMapConcat
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class SyncResult(
    val summary: Summary,
    val conflicts: List<SyncConflict>
) {
    @Serializable
    data class Summary(
        val appliedChanges: Int,
        val pendingChanges: Int,
        val lastSyncedAt: String
    )
}

@Serializable
data class SyncConflict(
    val entity: String,
    val entityId: String,
    val reason: String
)

sealed interface SyncError {
    data class Transport(val cause: Throwable) : SyncError
    data object Decoding : SyncError
    data class Persistence(val details: String) : SyncError
}

class SyncException(val reason: SyncError) : Exception(reason.toString())

interface SyncNetworking {
    fun requestSync(payload: ByteArray): Flow<Result<ByteArray>>
}

interface SyncPersistence {
    fun apply(snapshot: ByteArray): Flow<Result<Unit>>
}

interface DomainMapper {
    fun domainModels(): Flow<List<JobViewModel>>
}

data class JobViewModel(
    val id: String,
    val customerName: String,
    val status: String,
    val scheduledStart: Instant?,
    val scheduledEnd: Instant?
)

class FieldPrimePipeline(
    private val networking: SyncNetworking,
    private val persistence: SyncPersistence,
    private val mapper: DomainMapper,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO
) {
    fun sync(payload: ByteArray): Flow<Result<SyncResult>> {
        return networking.requestSync(payload)
            .flatMapConcat { response ->
                response.fold(
                    onSuccess = { body ->
                        deserializeSyncResult(body).fold(
                            onSuccess = { result ->
                                persistence.apply(serialize(result))
                                    .map { persistenceOutcome ->
                                        persistenceOutcome.fold(
                                            onSuccess = { Result.success(result) },
                                            onFailure = { Result.failure(mapPersistenceError(it)) }
                                        )
                                    }
                            },
                            onFailure = { error -> flow { emit(Result.failure(error)) } }
                        )
                    },
                    onFailure = { cause -> flow { emit(Result.failure(mapTransportError(cause))) } }
                )
            }
            .catch { emit(Result.failure(mapTransportError(it))) }
            .flowOn(ioDispatcher)
    }

    fun jobsStream(): Flow<List<JobViewModel>> {
        return mapper.domainModels()
            .flowOn(Dispatchers.Default)
    }

    private fun deserializeSyncResult(bytes: ByteArray): Result<SyncResult> =
        runCatching {
            Json.decodeFromString(SyncResult.serializer(), bytes.decodeToString())
        }.recoverCatching {
            throw SyncException(SyncError.Decoding)
        }

    private fun serialize(result: SyncResult): ByteArray {
        return Json.encodeToString(SyncResult.serializer(), result).encodeToByteArray()
    }

    private fun mapTransportError(cause: Throwable): Throwable = SyncException(SyncError.Transport(cause))

    private fun mapPersistenceError(cause: Throwable): Throwable =
        SyncException(
            SyncError.Persistence(details = cause.message ?: "Unknown persistence error")
        )
}
