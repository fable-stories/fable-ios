//
//  RealmManager.swift
//  Fable
//
//  Created by Andrew Aquino on 7/30/19.
//

import Foundation
import RealmSwift
import ReactiveSwift

public enum RealmDatabaseError: Error {
  case write
  case delete
}

// Migrating Realm - https://stackoverflow.com/questions/33363508/rlmexception-migration-is-required-for-object-type

public class RealmManager {

  internal let realm: Realm!
  
  private let uuid: String
  
  public init(uuid: String) {
    self.uuid = uuid
    Realm.Configuration.defaultConfiguration = Realm.Configuration(
      deleteRealmIfMigrationNeeded: true
    )
    do {
      self.realm = try Realm()
    } catch let error {
      print(error)
      self.realm = nil
    }

    print(realm.configuration.fileURL!)
  }
  
  // MARK: WRITE
  
  public func batchUpsert(_ writeBlock: @escaping () -> [Object]) -> SignalProducer<Void, RealmDatabaseError> {
    return SignalProducer { [weak self] observer, _ in
      guard let self = self else { return observer.sendCompleted() }
      self.realm.beginWrite()
      let objects = writeBlock()
      self.realm.add(objects, update: .modified)
      guard let _ = try? self.realm.commitWrite() else { return observer.send(error: .write) }
      observer.send(value: ())
      observer.sendCompleted()
    }
  }
  
  public func upsert<T: Object>(_ object: T?) -> SignalProducer<Void, RealmDatabaseError> {
    return SignalProducer { [weak self] observer, _ in
      guard let self = self, let object = object else { return observer.sendCompleted() }
      self.realm.beginWrite()
      self.realm.add(object, update: .modified)
      guard let _ = try? self.realm.commitWrite() else { return observer.send(error: .write) }
      observer.send(value: ())
      observer.sendCompleted()
    }
  }
  
  public func upsert<T: Object>(_ objects: [T]?) -> SignalProducer<Void, RealmDatabaseError> {
    return SignalProducer { [weak self] observer, _ in
      guard let self = self, let objects = objects else { return observer.sendCompleted() }
      self.realm.beginWrite()
      self.realm.add(objects, update: .modified)
      guard let _ = try? self.realm.commitWrite() else { return observer.send(error: .write) }
      observer.send(value: ())
      observer.sendCompleted()
    }
  }
  
  // MARK: - READ
  
  public func query<T: Object>(_ objectType: T.Type) -> Results<T> {
    let objects = self.realm.objects(objectType)
    return objects
  }

  public func query<T: Object>(_ objectType: T.Type, predicateString: String) -> [T] {
    let objects = self.realm.objects(objectType).filter(predicateString)
    return Array(objects)
  }
  
  public func query<T: Object>(_ objectType: T.Type, prediate: NSPredicate) -> [T] {
    let objects = self.realm.objects(objectType).filter(prediate)
    return Array(objects)
  }
  
  public func query<T: Object>(_ objectType: T.Type, primaryKey: String) -> T? {
    let object = self.realm.object(ofType: objectType, forPrimaryKey: primaryKey)
    return object
  }
  
  public func bulkQuery<T: Object>(_ objectType: T.Type, primaryKeys: [String]) -> Results<T> {
    guard let primaryKey = objectType.primaryKey() else {
      // return an empty results object
      return self.realm.objects(objectType.self).filter(NSPredicate(value: false))
    }
    let objects = self.realm.objects(objectType.self).filter("\(primaryKey) IN %@", primaryKeys)
    return objects
  }
  
  // MARK: - Delete
  
  public func bulkDeleteAll<T: Object>(_ objectType: T.Type) -> SignalProducer<Void, RealmDatabaseError> {
    return SignalProducer { [weak self] observer, _ in
      guard let self = self else { return observer.sendCompleted() }
      let objects = self.realm.objects(objectType.self)
      do {
        self.realm.beginWrite()
        self.realm.delete(objects)
        try self.realm.commitWrite()
        observer.send(value: ())
        observer.sendCompleted()
      } catch {
        observer.send(error: .delete)
      }
    }
  }
  
  public func bulkDelete<T: Object>(_ objectType: T.Type, primaryKeys: [String]) -> SignalProducer<Void, RealmDatabaseError> {
    return SignalProducer { [weak self] observer, _ in
      guard let self = self else { return observer.sendCompleted() }
      guard let primaryKey = objectType.primaryKey() else { return observer.sendCompleted() }
      let objects = self.realm.objects(objectType.self).filter("\(primaryKey) IN %@", primaryKeys)
      do {
        self.realm.beginWrite()
        self.realm.delete(objects)
        try self.realm.commitWrite()
        observer.send(value: ())
        observer.sendCompleted()
      } catch {
        observer.send(error: .delete)
      }
    }
  }

  // MARK: - Reactive
  
  private var tokens: [String: NotificationToken] = [:]

  public func observeChanges<T: Object>(_ objectType: T.Type) -> ReactiveSwift.Property<Results<T>> {
    let identifier = String(describing: objectType) + ":" + UUID().uuidString
    let producer = SignalProducer<Results<T>, Never> { [weak self] observer, _ in
      guard let self = self else { return observer.sendCompleted() }
      let token = self.realm.objects(objectType).observe { changes in
        switch changes {
        case let .initial(collection):
          observer.send(value: collection)
        case let .update(collection, _, _, _):
          observer.send(value: collection)
        case .error:
          break
        }
      }
      self.tokens[identifier] = token
    }
      .on(terminated: { [weak self] in
        self?.tokens[identifier]?.invalidate()
        self?.tokens[identifier] = nil
      })
    return ReactiveSwift.Property<Results<T>>(
      initial: realm.objects(objectType),
      then: producer
    )
  }
}


