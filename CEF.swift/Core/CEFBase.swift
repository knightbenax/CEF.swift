//
//  CEFBase.swift
//  cef
//
//  Created by Tamas Lustyik on 2015. 07. 10..
//
//

import Foundation

protocol Lock {
    mutating func lock()
    mutating func unlock()
}

extension pthread_mutex_t: Lock {
    mutating func lock() {
        pthread_mutex_lock(&self)
    }
    
    mutating func unlock() {
        pthread_mutex_unlock(&self)
    }
}


public protocol CEFObject: DefaultInitializable {
    var base: cef_base_t { get set }
}

protocol CEFRefCounting: class {
    func addRef()
    func release() -> Bool
    func hasOneRef() -> Bool
}


public class CEFProxy<T : CEFObject>: CEFRefCounting {
    typealias ObjectType = T
    typealias ObjectPtrType = UnsafeMutablePointer<T>
    
    private let _cefPtr: UnsafeMutablePointer<T>
    var cefObjectPtr: UnsafeMutablePointer<ObjectType> { return _cefPtr }
    var cefObject: ObjectType { return _cefPtr.pointee }
    
    init?(ptr: UnsafeMutablePointer<T>?) {
        guard let ptr = ptr else {
            return nil
        }
        
        _cefPtr = ptr
    }
    
    deinit {
        release()
    }

    func addRef() {
        _cefPtr.withMemoryRebound(to: cef_base_t.self, capacity: 1) { basePtr in
            _cefPtr.pointee.base.add_ref(basePtr)
        }
    }
    
    func release() -> Bool {
        return _cefPtr.withMemoryRebound(to: cef_base_t.self, capacity: 1) { basePtr in
            return _cefPtr.pointee.base.release(basePtr) != 0
        }
    }
    
    func hasOneRef() -> Bool {
        return _cefPtr.withMemoryRebound(to: cef_base_t.self, capacity: 1) { basePtr in
            return _cefPtr.pointee.base.has_one_ref(basePtr) != 0
        }
    }

    func toCEF() -> UnsafeMutablePointer<ObjectType> {
        addRef()
        return cefObjectPtr
    }
}

