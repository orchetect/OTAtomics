//
//  OTAtomicsThreadSafe Tests.swift
//  OTAtomics • https://github.com/orchetect/OTAtomics
//

#if shouldTestCurrentPlatform

import XCTest
import OTAtomics

class OTAtomicsThreadSafeTests: XCTestCase {
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    func testAtomic() {
        // baseline read/write functionality test on a variety of types
        
        class Bar {
            var nonAtomicInt: Int = 100
        }
        
        class Foo {
            @OTAtomicsThreadSafe var bool: Bool = true
            @OTAtomicsThreadSafe var int: Int = 5
            @OTAtomicsThreadSafe var string: String = "a string"
            @OTAtomicsThreadSafe var dict: [String: Int] = ["Key": 1]
            @OTAtomicsThreadSafe var array: [String] = ["A", "B", "C"]
            @OTAtomicsThreadSafe var barClass = Bar()
        }
        
        let foo = Foo()
        
        // read value
        
        XCTAssertEqual(foo.bool, true)
        XCTAssertEqual(foo.int, 5)
        XCTAssertEqual(foo.string, "a string")
        XCTAssertEqual(foo.dict, ["Key": 1])
        XCTAssertEqual(foo.array, ["A", "B", "C"])
        XCTAssertEqual(foo.barClass.nonAtomicInt, 100)
        
        // replace value
        
        foo.bool = false
        XCTAssertEqual(foo.bool, false)
        
        foo.int = 10
        XCTAssertEqual(foo.int, 10)
        
        foo.string = "a new string"
        XCTAssertEqual(foo.string, "a new string")
        
        foo.dict = ["KeyA": 10, "KeyB": 20]
        XCTAssertEqual(foo.dict, ["KeyA": 10, "KeyB": 20])
        
        foo.array = ["1", "2"]
        XCTAssertEqual(foo.array, ["1", "2"])
        
        foo.barClass.nonAtomicInt = 50
        XCTAssertEqual(foo.barClass.nonAtomicInt, 50)
        
        // mutate value (collections)
        
        foo.dict["KeyB"] = 30
        XCTAssertEqual(foo.dict, ["KeyA": 10, "KeyB": 30])
        
        foo.array[1] = "3"
        XCTAssertEqual(foo.array, ["1", "3"])
    }
    
    func testAtomic_BruteForce_ConcurrentMutations() {
        class Foo {
            @OTAtomicsThreadSafe var dict: [String: Int] = [:]
            @OTAtomicsThreadSafe var array: [String] = []
        }
        
        let foo = Foo()
        
        let iterations = 10000
        
        // append operations
        
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            foo.dict["\(index)"] = index
            foo.array.append("\(index)")
        }
        
        XCTAssertEqual(foo.dict.count, iterations)
        for index in 0 ..< iterations {
            XCTAssertEqual(foo.dict["\(index)"], index)
        }
        
        XCTAssertEqual(foo.array.count, iterations)
        
        // remove operations
        
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            foo.dict["\(index)"] = nil
            foo.array.remove(at: 0)
        }
        
        XCTAssertEqual(foo.dict.count, 0)
        XCTAssertEqual(foo.array.count, 0)
    }
    
    /// Write sequential values while reading random values.
    /// This test is more useful with Thread Sanitizer on.
    @available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13.0, watchOS 6.0, *)
    func testAtomic_BruteForce_ConcurrentWriteRandomReads() {
        class Foo {
            @OTAtomicsThreadSafe var dict: [String: Int] = [:]
            @OTAtomicsThreadSafe var array: [String] = []
        }
        
        let readQueue = DispatchQueue(
            label: "com.orchetect.OTAtomics.AtomicTest",
            qos: .default,
            attributes: [],
            autoreleaseFrequency: .inherit,
            target: nil
        )
        
        let foo = Foo()
        
        let timer = readQueue.schedule(
            after: DispatchQueue.SchedulerTimeType(.now()),
            interval: .microseconds(1),
            tolerance: .zero,
            options: nil
        ) {
            // dict read
            if !foo.dict.isEmpty {
                let dictIndex = Int.random(in: 0 ..< foo.dict.count)
                _ = foo.dict["\(dictIndex)"]
            }
            // array read
            if !foo.array.isEmpty {
                let arrayIndex = Int.random(in: 0 ..< foo.array.count)
                _ = foo.array[arrayIndex]
            }
        }
        
        let iterations = 100_000
        
        // append operations
        
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            foo.dict["\(index)"] = index
            foo.array.append("\(index)")
        }
        
        timer.cancel()
    }
    
    /// Write and read sequential values concurrently.
    /// This test is more useful with Thread Sanitizer on.
    func testAtomic_BruteForce_ConcurrentWriteAndRead() {
        let completionTimeout = expectation(description: "Test Completion Timeout")
        
        class Foo {
            @OTAtomicsThreadSafe var dict: [String: Int] = [:]
            @OTAtomicsThreadSafe var array: [String] = []
        }
        
        let foo = Foo()
        foo.dict["key"] = 1
        foo.array.append("1")
        
        let writeGroup = DispatchGroup()
        let readGroup = DispatchGroup()
        
        let iterations = 100_000
        
        for index in 0 ..< iterations {
            writeGroup.enter()
            DispatchQueue.global().async {
                foo.dict["key"] = index
                foo.array[0] = "\(index)"
                writeGroup.leave()
            }
        }
        
        for _ in 0 ..< iterations {
            readGroup.enter()
            DispatchQueue.global().async {
                _ = foo.dict["key"]
                if !foo.array.isEmpty { _ = foo.array[0] }
                readGroup.leave()
            }
        }
        
        DispatchQueue.global().async {
            writeGroup.wait()
            readGroup.wait()
            completionTimeout.fulfill()
        }
        
        wait(for: [completionTimeout], timeout: 10)
    }
    
    // this test doesn't do much; could be removed. was added on a hunch.
    func testMemory() {
        class Foo {
            @OTAtomicsThreadSafe var dict: [String: Int] = [:]
            @OTAtomicsThreadSafe var array: [String] = []
        }
        
        var foo: Foo? = Foo()
        foo?.dict["key"] = 1
        foo?.array.append("1")
        
        foo = nil
    }
}

#endif
