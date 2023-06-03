import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public final class Lock {
    private var backing: UnsafeMutablePointer<pthread_mutex_t>
    
    public init() {
        backing = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        backing.initialize(to: pthread_mutex_t())
        pthread_mutex_init(backing, nil)
    }
    
    deinit {
        pthread_mutex_destroy(backing)
        backing.deinitialize(count: 1)
        backing.deallocate()
    }
    
    public func locked<T>(_ block: () throws -> T) rethrows -> T {
        pthread_mutex_lock(backing)
        defer { pthread_mutex_unlock(backing) }
        return try block()
    }
    
    public func tryLocked(_ block: () throws -> Void) rethrows -> Bool {
        if pthread_mutex_trylock(backing) == 0 {
            defer { pthread_mutex_unlock(backing) }
            try block()
            return true
        } else {
            return false
        }
    }
}
