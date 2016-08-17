//
//  Queue.swift
//  NTBSwift
//
//  Created by Kåre Morstøl on 11/07/14.
//
//  Using the "Two-Lock Concurrent Queue Algorithm" from http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html#tlq, without the locks.


// should be an inner class of Queue, but inner classes and generics crash the compiler, SourceKit (repeatedly) and occasionally XCode.
private class _QueueItem<T> {
    let value: T!
    var next: _QueueItem?
    
    init(_ newvalue: T?) {
        self.value = newvalue
    }
}

///
/// A standard queue (FIFO - First In First Out). Supports simultaneous adding and removing, but only one item can be added at a time, and only one item can be removed at a time.
///
class Queue<T> {
    
    typealias Element = T
    
    private var _front: _QueueItem<Element>
    private var _back: _QueueItem<Element>
    
    private var _count: Int = 0
    
    var count: Int {
        get {
            return _count
        }
    }
    
    init () {
        // Insert dummy item. Will disappear when the first item is added.
        _back = _QueueItem(nil)
        _front = _back
    }
    
    /// Add a new item to the back of the queue.
    func enqueue (value: T) {
        _back.next = _QueueItem(value)
        _back = _back.next!
        self._count += 1
    }
    
    /// Return and remove the item at the front of the queue.
    func dequeue () -> T? {
        if let newhead = _front.next {
            self._count -= 1
            _front = newhead
            return newhead.value
        } else {
            return nil
        }
    }
    
    func isEmpty() -> Bool {
        return _front === _back
    }
    
}
