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
  
  var query: CSSearchQuery?
  var queryString: String?
  var attributes: [String]?
  
  /// MARK: - Proxy Lifecycle
  
  @objc(_initWithPageContext:andArguments:)
  func _init(withPageContext context: TiEvaluator!, arguments: Dictionary<String, Any>!) -> TiAppiOSSearchQueryProxy! {
    super._init(withPageContext: context)
    
    queryString = arguments["queryString"] as? String
    attributes = arguments["attributes"] as? Array<String>
    
    return self;
  }
  
  /// MARK: Internal
  
  private func searchQuery() -> CSSearchQuery? {
    guard query == nil else { return query }
    guard let queryString = queryString else { return nil }
    
    query = CSSearchQuery(queryString: queryString, attributes: self.attributes)
    
    guard let query = query else { return nil }
    
    query.foundItemsHandler = { (items: [CSSearchableItem]) -> Void in
      
      var result: [TiAppiOSSearchableItemProxy] = []
      
      for item in items {
        result.append(TiAppiOSSearchableItemProxy(uniqueIdentifier: item.uniqueIdentifier, withDomainIdentifier: item.domainIdentifier, with: item.attributeSet))
      }
      
      self.fireEvent("foundItems", with: ["items": result, "foundItemsCound": query.foundItemCount])
    }
    query.completionHandler = { (error : Error?) -> Void in
      let dict: NSMutableDictionary = ["success": error == nil, "foundItemCount": query.foundItemCount]
      
      if let error = error {
        dict.setObject(error.localizedDescription, forKey: "error" as NSCopying)
      }
      
      self.fireEvent("completed", with: dict)
    }
    
    return query
  }
  
  /// MARK: - Public APIs
  
  @objc(start:)
  func start(_: Any) {
    guard let searchQuery = searchQuery() else { return }
    searchQuery.start()
  }
  
  @objc(cancel:)
  func cancel(_: Any) {
    guard let searchQuery = searchQuery() else { return }
    searchQuery.cancel()
  }
  
  @objc(isCancelled:)
  func isCancelled(_: Any) -> NSNumber {
    guard let searchQuery = searchQuery() else { return false }
    return searchQuery.isCancelled as NSNumber
  }
  
  /// MARK: - ObjC Getter / Setter PoC
  
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

