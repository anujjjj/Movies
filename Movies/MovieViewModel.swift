//
//  MovieViewModel.swift
//  Movies
//
//  Created by Anuj Pande on 22/10/20.
//

import Foundation

class MovieViewModel {
    var movies: Array<MovieItem> = []
    var expandedIndex: Int?
    var shouldDisplayPlaceholderImage = false
    
    func numberOfRowsInSection() -> Int {
        return movies.count
    }
    
    
}
