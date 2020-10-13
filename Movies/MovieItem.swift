//
//  MovieItem.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation

class MovieItem: NSObject, Codable, Identifiable {
    var id: Int
    var totalVotes: Int
    var rating: Double
    var title: String
    var posterPath : String
    var overview: String
    
    override init() {
        id = 123
        totalVotes = 2322
        rating = 0.7
        title = "Movie Title "
        posterPath = "Asd ASD"
        overview = "Overview"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case totalVotes = "vote_count"
        case rating = "vote_average"
        case title = "title"
        case posterPath = "poster_path"
        case overview = "overview"
    }
}
