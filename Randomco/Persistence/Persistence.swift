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

    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error>
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error>
    func map<T, V>(values: [T], _ map: @escaping (T) throws -> V) -> AnyPublisher<[V], Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}

struct CoreDataStack: PersistentStore {

    private let container: NSPersistentContainer
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    private let bgQueue = DispatchQueue(label: "coredata")

    static let shared = CoreDataStack()

    init() {
        container = NSPersistentContainer(name: "Randomco")

        bgQueue.sync { [weak isStoreLoaded, weak container] in
            container?.loadPersistentStores { (storeDescription, error) in
                if let error = error {
                    isStoreLoaded?.send(completion: .failure(error))
                } else {
                    container?.viewContext.undoManager = nil
                    container?.viewContext.mergePolicy = NSRollbackMergePolicy
                    container?.viewContext.shouldDeleteInaccessibleFaults = true
                    container?.viewContext.automaticallyMergesChangesFromParent = true

                    isStoreLoaded?.send(true)
                }
            }
        }
    }

    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> {
        return onStoreIsReady
            .flatMap { [weak container] in
                Future<Int, Error> { promise in
                    do {
                        let count = try container?.viewContext.count(for: fetchRequest) ?? 0
                        promise(.success(count))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error> {
        let fetch = Future<[T], Error> { [weak container] promise in
            guard let context = container?.viewContext else { return }
            context.performAndWait {
                do {
                    let results = try context.fetch(fetchRequest)
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()
    }

    func map<T, V>(values: [T], _ map: @escaping (T) throws -> V) -> AnyPublisher<[V], Error> {
        let fetch = Future<[V], Error> { [weak container] promise in
            guard let context = container?.viewContext else { return }
            context.performAndWait {
                do {
                    let results = try values.map(map)
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()

    }

    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        let update = Future<Result, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async {
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
                        promise(.success(result))
                    } catch {
                        context.reset()
                        promise(.failure(error))
                    }
                }
            }
        }

        return onStoreIsReady
            .flatMap { update }
            .eraseToAnyPublisher()
    }

    private var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
