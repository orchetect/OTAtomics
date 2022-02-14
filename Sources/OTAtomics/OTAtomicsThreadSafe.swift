//
//  OTAtomicsThreadSafe.swift
//  OTAtomics • https://github.com/orchetect/OTAtomics
//

import Darwin

/// `OTAtomicsThreadSafe`: A property wrapper that ensures thread-safe atomic access to a value.
/// Multiple read accesses can potentially read at the same time, just not during a write.
///
/// By using `pthread` to do the locking, this safer than using a `DispatchQueue/barrier` as there isn't a chance of priority inversion.
///
/// This is safe to use on collection types (`Array`, `Dictionary`, etc.)
@propertyWrapper
public final class OTAtomicsThreadSafe<T> {
    
    @inline(__always)
    private var value: T
    
    @inline(__always)
    private let lock: ThreadLock = RWThreadLock()
    
    @inline(__always)
    public init(wrappedValue value: T) {
        
        self.value = value
        
    }
    
    @inline(__always)
    public var wrappedValue: T {
        
        get {
            self.lock.readLock()
            defer { self.lock.unlock() }
            return self.value
        }
        
        set {
            self.lock.writeLock()
            value = newValue
            self.lock.unlock()
        }
        
        // _modify { } is an internal Swift computed setter, similar to set { }
        // however it gives in-place exclusive mutable access
        // which allows get-then-set operations such as collection subscripts
        // to be performed in a single thread-locked operation
        _modify {
            self.lock.writeLock()
            yield &value
            self.lock.unlock()
        }
        
    }
    
}
