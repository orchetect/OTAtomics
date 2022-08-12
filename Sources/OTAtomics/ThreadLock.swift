//
//  ThreadLock.swift
//  OTAtomics • https://github.com/orchetect/OTAtomics
//

import Darwin

/// Defines a basic signature to which all locks conform.
internal protocol ThreadLock {
    init()
    
    /// Lock a resource for writing. So only one thing can write, and nothing else can read or write.
    func writeLock()
    
    /// Lock a resource for reading. Other things can also lock for reading at the same time, but nothing else can write at that time.
    func readLock()
    
    /// Unlock a resource
    func unlock()
}
