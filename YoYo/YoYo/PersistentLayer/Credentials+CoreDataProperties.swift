//
//  Credentials+CoreDataProperties.swift
//  
//
//  Created by Vishnu Divakar on 2/11/21.
//
//

import Foundation
import CoreData


extension Credentials {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Credentials> {
        return NSFetchRequest<Credentials>(entityName: "Credentials")
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?

}
