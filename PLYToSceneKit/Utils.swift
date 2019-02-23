//
//  Utils.swift
//  ARPointCloudRenderer
//
//  Created by Florian Bruggisser on 17.11.18.
//  Copyright © 2018 Florian Bruggisser. All rights reserved.
//

import Foundation
import QuartzCore

@discardableResult
func measure<A>(name: String = "", _ block: () -> A) -> A {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("Time: \(name) - \(timeElapsed) seconds")
    return result
}

final class ThreadSafe<A> {
    private var _value: A
    private let queue = DispatchQueue(label: "ThreadSafe")
    init(_ value: A) {
        self._value = value
    }
    
    var value: A {
        return queue.sync { _value }
    }
    
    func atomically(_ transform: (inout A) -> ()) {
        queue.sync {
            transform(&self._value)
        }
    }
}

extension Array {
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        let result = ThreadSafe(Array<B?>(repeating: nil, count: count))
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            result.atomically {
                $0[idx] = transformed
            }
        }
        return result.value.map { $0! }
        
    }
}

class Counter {
    private var queue = DispatchQueue(label: "ch.bildspur.safecounter")
    private (set) var value: Int = 0
    
    func increment() {
        queue.sync {
            value += 1
        }
    }
}