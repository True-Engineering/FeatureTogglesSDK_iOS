import Foundation

final class ThreadSafe<A> {
    
    // MARK: - Properties
    
    private var _value: A
    private let queue = DispatchQueue(label: "ThreadSafe")
    
    var value: A {
        return queue.sync { _value }
    }
    
    // MARK: - Init
    
    init(_ value: A) {
        self._value = value
    }
    
    // MARK: - Public methods

    func atomically(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
    
}
