//
//  MovieItem.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation

class MovieItem: NSObject, Codable, Identifiable {
    let id: Int
    let totalVotes: Int
    let rating: Double
    let title: String
    let posterPath : String
    
    override init() {
        id = 123
        totalVotes = 23
        rating = 0.7
        title = "Movie Title "
        posterPath = "Asd ASD"
    }
    
    enum CodingKeys: String, CodingKey {
      case id = "id"
      case totalVotes = "vote_count"
      case rating = "vote_average"
      case title = "title"
      case posterPath = "poster_path"
    }
}
