//
//  Persistence.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 26/5/23.
//

import CoreData
import Combine

protocol PersistentStore {
    typealias DBOperation<Result> = (NSManagedObjectContext) throws -> Result

    func count<T>(_ fetchRequest: NSFetchRequest<T>) async throws -> Int
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) async throws -> [T]
    func map<T, V>(values: [T], _ map: @escaping (T) throws -> V?) async throws -> [V]
    func update<Result>(_ operation: @escaping DBOperation<Result>) async throws -> Result
}

struct CoreDataStack: PersistentStore {
    private let container: NSPersistentContainer

    static let shared = CoreDataStack()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Randomco")
        if inMemory {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))]
        }
        container.loadPersistentStores { [container] (storeDescription, error) in
            if let error {
                fatalError(error.localizedDescription)
            }

            container.viewContext.undoManager = nil
            container.viewContext.mergePolicy = NSRollbackMergePolicy
            container.viewContext.shouldDeleteInaccessibleFaults = true
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }

    func count<T>(_ fetchRequest: NSFetchRequest<T>) async throws -> Int {
        try container.viewContext.count(for: fetchRequest)
    }

    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) async throws -> [T] {
        try await withCheckedThrowingContinuation { [weak container] continuation in
            guard let context = container?.viewContext else { return }

            context.performAndWait {
                do {
                    let results = try context.fetch(fetchRequest)
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func map<T, V>(values: [T], _ map: @escaping (T) throws -> V?) async throws -> [V] {
        try await withCheckedThrowingContinuation { [weak container] continuation in
            guard let context = container?.viewContext else { return }

            context.performAndWait {
                do {
                    let results = try values.compactMap(map)
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func update<Result>(_ operation: @escaping DBOperation<Result>) async throws -> Result {
        try await withCheckedThrowingContinuation { [weak container] continuation in
            guard let context = container?.newBackgroundContext() else { return }
            context.mergePolicy = NSOverwriteMergePolicy
            context.undoManager = nil

            context.performAndWait {
                do {
                    let result = try operation(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    context.reset()
                    continuation.resume(returning: result)
                } catch {
                    context.reset()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
