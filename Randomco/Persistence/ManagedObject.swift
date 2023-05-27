//
//  ManagedObject.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import CoreData

protocol ManagedObject: NSFetchRequestResult { }

extension ManagedObject where Self: NSManagedObject {

    static var entityName: String {
        let nameMO = String(describing: Self.self)
        let suffixIndex = nameMO.index(nameMO.endIndex, offsetBy: -2)
        return String(nameMO[..<suffixIndex])
    }

    static func insertNew(in context: NSManagedObjectContext) -> Self {
        return NSEntityDescription
            .insertNewObject(forEntityName: entityName, into: context) as! Self
    }

    static func newFetchRequest() -> NSFetchRequest<Self> {
        return .init(entityName: entityName)
    }
}

extension UserMO: ManagedObject {}
extension UserMO {
    func store(user: User) {
        guard let context = managedObjectContext else { return }

        self.phone = user.phone
        self.email = user.email

        self.name = NameMO.insertNew(in: context)
        self.name?.store(name: user.name)

        self.picture = PictureMO.insertNew(in: context)
        self.picture?.store(picture: user.picture)
    }
}

extension NameMO: ManagedObject {}
extension NameMO {
    func store(name: User.Name) {
        self.title = name.title
        self.first = name.first
        self.last = name.last
    }
}

extension PictureMO: ManagedObject {}
extension PictureMO {
    func store(picture: User.Picture) {
        self.thumbnail = picture.thumbnail
        self.medium = picture.medium
        self.large = picture.large
    }
}
