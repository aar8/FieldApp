public enum FieldUpdate<T> {
    case noUpdate
    case updated(T)

    func merged(with other: FieldUpdate<T>) -> FieldUpdate<T> {
        switch other {
        case .noUpdate:
            return self
        case .updated:
            return other
        }
    }
}