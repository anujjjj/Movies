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
    
    func fetchMovies(for page: Int = 1, completionBlock: @escaping (Results) -> Void) -> Void {
        guard let url =  URL(string:Constants.url + String(page)) else {
            return completionBlock(Results(withError: "Unable to parse url" as! Error))
        }
        
        var result = Results()
        URLSession.shared.dataTask(with: url) { data, response, taskError in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                result.error = taskError
                completionBlock(result)
                return
            }
            result.data = data
            completionBlock(result)
        }.resume()
    }
}
