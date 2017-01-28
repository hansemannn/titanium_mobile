//
// Appcelerator Titanium Mobile
// Copyright (c) 2009-Present by Appcelerator, Inc. All Rights Reserved.
// Licensed under the terms of the Apache Public License
// Please see the LICENSE included with this distribution for details.
//

import Foundation
import CoreSpotlight

@available(iOS 10.0, *)
class TiAppiOSSearchQueryProxy : TiProxy {
    var query: CSSearchQuery!
    var queryString: String!
    var attributes: Array<String>!
    
    // MARK: - Proxy Lifecycle
    
    func _init(withPageContext context: TiEvaluator!, arguments: Dictionary<String, Any>!) -> TiAppiOSSearchQueryProxy! {
        super._init(withPageContext: context)
        
        queryString = arguments["queryString"] as? String
        attributes = arguments["attributes"] as? Array<String>
        
        return self;
    }
    
    func searchQuery() -> CSSearchQuery {
        if query == nil {
            query = CSSearchQuery(queryString: self.queryString, attributes: self.attributes)
            query.foundItemsHandler = { (items: [CSSearchableItem]) -> Void in
                
                var result: [TiAppiOSSearchableItemProxy] = []
                
                for item in items {
                    result.append(TiAppiOSSearchableItemProxy(uniqueIdentifier: item.uniqueIdentifier, withDomainIdentifier: item.domainIdentifier, with: item.attributeSet))
                }
                
                self.fireEvent("foundItems", with: ["items": result, "foundItemsCound": self.query.foundItemCount])
            }
            query.completionHandler = { (error : Error?) -> Void in
                let dict: NSMutableDictionary = ["success": error == nil, "foundItemCount": self.query.foundItemCount]
                
                if error != nil {
                    dict.setObject(error!.localizedDescription, forKey: "error" as NSCopying)
                }
                
                self.fireEvent("completed", with: dict)
            }
        }
        
        return query
    }
    
    // MARK: - Public APIs
    
    func start(_: Any) {
        searchQuery().start()
    }
    
    func cancel(_: Any) {
        searchQuery().cancel()
    }
    
    func isCancelled(_: Any) -> NSNumber {
        return searchQuery().isCancelled as NSNumber
    }
    
    // MARK: - ObjC Getter / Setter PoC
    func setMyProperty(_ value: Any) {
        self.replaceValue(value, forKey: "myProperty", notification: false)
        
        // Can be accessed as both searchQuery.myProperty = "sss" and searchQuery.setMyProperty("sss")
        // TODO: Could we use computed properties as well? Problem: Required signature is different
    }
    
    func myProperty() -> String {
        return "Test"

        // Can be accessed as both searchQuery.myProperty and searchQuery.getMyProperty()
    }
}
