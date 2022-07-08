//
//  Covert.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation

public protocol Convertor {
    func toDictionary() -> [String : Any]
}

extension Convertor {
    public func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (key:String?, value:Any) -> (String, Any)? in
            guard let key = key else { return nil }
            return (key, value)
        }).compactMap { $0 })
        return dict
    }
    
    public func toMuDictionary() -> [String : Any] {
        let reflect = Mirror(reflecting: self)
        let children = reflect.children
        let dictionary = toAnyHashable(elements: children)
        return dictionary
    }
    
    public func toAnyHashable(elements: AnyCollection<Mirror.Child>) -> [String : Any] {
        var dictionary: [String : Any] = [:]
        for element in elements {
            if let key = element.label {
                
                if let collectionValidHashable = element.value as? [AnyHashable] {
                    dictionary[key] = collectionValidHashable
                }
                
                if let validHashable = element.value as? AnyHashable {
                    dictionary[key] = validHashable
                }
                
                if let convertor = element.value as? Convertor {
                    dictionary[key] = convertor.toDictionary()
                }
                
                if let convertorList = element.value as? [Convertor] {
                    dictionary[key] = convertorList.map({ e in
                        e.toMuDictionary()
                    })
                }
            }
        }
        return dictionary
    }
}
