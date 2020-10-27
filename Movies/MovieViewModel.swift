//
//  MovieViewModel.swift
//  Movies
//
//  Created by Anuj Pande on 22/10/20.
//

import Foundation
import CoreData
import UIKit

class MovieViewModel {
    
//    var movies: Array<MovieItem> = []
    var expandedIndex: Int?
    var shouldDisplayPlaceholderImage = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedRC: NSFetchedResultsController<Movie>!
    
    func numberOfRowsInSection() -> Int {
//        return movies.count
        guard let sections = fetchedRC.sections, let objs = sections[0].objects else {
            return 0
        }
        return objs.count
    }
    
    func saveMoviesToCoreData(_ movies: [MovieItem]) {
        for movie in movies {
            let movieModel = Movie(entity: Movie.entity(), insertInto: self.context)
            movieModel.id = Int64(movie.id)
            movieModel.title = movie.title
            movieModel.overview = movie.overview
            movieModel.posterPath = movie.posterPath
            movieModel.rating = movie.rating
            movieModel.popularity = movie.popularity
        }
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func refresh() {
        let request = Movie.fetchRequest() as NSFetchRequest<Movie>
        do {
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Movie.popularity), ascending: false)]
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func loadFromCoreData() {
        refresh()
        guard let movieModels = fetchedRC.fetchedObjects else {
            return
        }
        print(movieModels[0])
//        for movieModel in  movieModels {
//            let movie = MovieItem()
//            movie.id = Int(movieModel.id)
//            movie.title = movieModel.title ?? ""
//            movie.overview = movieModel.overview ?? ""
//            movie.posterPath = movieModel.posterPath ?? ""
//            movie.rating = movieModel.rating
//            movie.popularity = movieModel.popularity
//            movies.append(movie)
//        }
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
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(MediaResponse.self, from: data) else {
                return
            }
            self.saveMoviesToCoreData(response.results)
            self.loadFromCoreData()
            result.data = response.results
            completionBlock(result)
        }.resume()
    }
    
    func getNumberOfMovies() -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
}
