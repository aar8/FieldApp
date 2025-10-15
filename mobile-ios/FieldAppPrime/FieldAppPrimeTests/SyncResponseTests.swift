import XCTest
@testable import FieldAppPrime

class SyncResponseTests: XCTestCase {

    func testDecodingSyncResponseFromJSON() throws {
        // This test assumes that 'response.json' has been added to the
        // 'FieldAppPrimeTests' target in Xcode.

        // 1. Get the URL for the file within the test bundle.
        guard let url = Bundle(for: type(of: self)).url(forResource: "response", withExtension: "json") else {
            XCTFail("Missing file: response.json in test bundle. Please ensure it's added to the FieldAppPrimeTests target.")
            return
        }

        // 2. Load the data from the file.
        let data = try Data(contentsOf: url)

        // 3. Set up the JSONDecoder with the correct date strategy.
        let decoder = JSONDecoder()
        // The dates in the JSON can have fractional seconds, so .iso8601 is appropriate.
        decoder.dateDecodingStrategy = .iso8601

        // 4. Decode the data and assert that it doesn't throw an error.
        var syncResponse: SyncResponse?
        XCTAssertNoThrow(syncResponse = try decoder.decode(SyncResponse.self, from: data), "Decoding the sync response should not throw an error.")

        // 5. Assert that the decoded object is not nil and contains the expected data.
        XCTAssertNotNil(syncResponse)
        XCTAssertEqual(syncResponse?.data.customers.count, 100, "Should decode 100 customers.")
        XCTAssertEqual(syncResponse?.data.jobs.count, 500, "Should decode 500 jobs.")
        XCTAssertEqual(syncResponse?.data.customers.first?.data.name, "Winfield McClure", "The first customer's name should match.")
    }
}
