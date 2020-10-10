//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by Anuj Pande on 10/10/20.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var id: Int64
    @NSManaged public var totalVotes: Int64
    @NSManaged public var title: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var rating: Double
    @NSManaged public var overview: String?

}
