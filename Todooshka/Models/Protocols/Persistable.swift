import Foundation
import CoreData

public protocol Persistable {
  associatedtype T: NSManagedObject
  static var entityName: String { get }
  
  static var primaryAttributeName: String { get }

  var identity: String { get }

  init?(entity: T)

  func update(_ entity: T)
  func save(_ entity: T)

  /* predicate to uniquely identify the record, such as: NSPredicate(format: "code == '\(code)'") */
  func predicate() -> NSPredicate
}

public extension Persistable {
    func predicate() -> NSPredicate {
        return NSPredicate(format: "%K = %@", Self.primaryAttributeName, self.identity)
    }
}