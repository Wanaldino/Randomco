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

        self.gender = user.gender
        self.phone = user.phone
        self.email = user.email
        self.isFavourite = user.isFavourite
        self.isHidden = user.isHidden

        self.name = NameMO.insertNew(in: context)
        self.name?.store(name: user.name)

        self.picture = PictureMO.insertNew(in: context)
        self.picture?.store(picture: user.picture)

        self.location = LocationMO.insertNew(in: context)
        self.location?.store(location: user.location)

        self.registered = RegisterMO.insertNew(in: context)
        self.registered?.store(register: user.registered)
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

extension StreetMO: ManagedObject {}
extension StreetMO {
    func store(street: User.Location.Street) {
        self.name = street.name
        self.number = Int16(street.number)
    }
}

extension LocationMO: ManagedObject {}
extension LocationMO {
    func store(location: User.Location) {
        self.city = location.city
        self.state = location.state

        self.street = StreetMO.insertNew(in: managedObjectContext!)
        self.street?.store(street: location.street)
    }
}

extension RegisterMO: ManagedObject {}
extension RegisterMO {
    func store(register: User.Register) {
        self.date = register.date
    }
}
