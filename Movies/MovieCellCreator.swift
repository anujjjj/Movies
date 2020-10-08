//
//  MovieCellCreator.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation

class MovieCellCreator {
    var movies: [MovieItem] = []
    
    init() {
        movies.append(returnMovie())
//        movies.append(returnMovie())
//        movies.append(returnMovie())
    }
    
    private func returnMovie() -> MovieItem {
        let movie = MovieItem()
        return movie
    }
}
