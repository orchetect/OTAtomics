//
//  RWThreadLock.swift
//  OTAtomics • https://github.com/orchetect/OTAtomics
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Darwin

internal final class RWThreadLock: ThreadLock {
    @inline(__always)
    private var lock = pthread_rwlock_t()
    
    @inline(__always)
    init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            preconditionFailure("Unable to initialize the lock")
        }
    }
    
    @inline(__always)
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    @inline(__always)
    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }
    
    @inline(__always)
    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }
    
    @inline(__always)
    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
}
