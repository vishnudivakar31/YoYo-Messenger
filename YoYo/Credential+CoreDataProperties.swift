//
//  Credential+CoreDataProperties.swift
//  
//
//  Created by Vishnu Divakar on 2/11/21.
//
//

import Foundation
import CoreData


extension Credential {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Credential> {
        return NSFetchRequest<Credential>(entityName: "Credential")
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?

}
