//
//  UserData+CoreDataProperties.swift
//  TutuTestTask
//
//  Created by Phlegma on 17.12.2021.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var username: String?
    @NSManaged public var email: String?
    @NSManaged public var website: String?
    @NSManaged public var phone: String?

}

extension UserData : Identifiable {

}
