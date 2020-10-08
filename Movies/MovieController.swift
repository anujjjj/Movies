//
//  ViewController.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import UIKit

class MovieController: UITableViewController {

    public var movies: [MovieItem] = []
    
    required init?(coder: NSCoder) {
//        movies = MovieCellCreator().movies
//        print(movies)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        print("View Loaded")
        fetchMovies()
        // Do any additional setup after loading the view.
    }
    
    func fetchMovies() {
      guard let url =  URL(string:"https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=8eac22f4c24d01c480e4d99fef2edfc3") else {
        return
      }
      
      URLSession.shared.dataTask(with: url) { data, response, taskError in
        guard let httpResponse = response as? HTTPURLResponse,
          (200..<300).contains(httpResponse.statusCode),
          let data = data else {
            fatalError()
        }
        let decoder = JSONDecoder()
        guard let response = try? decoder.decode(MediaResponse.self, from: data) else {
          return
        }
        print("Response")
        let mvs = response.results
        print(mvs.count)
        print(mvs[0].title)
        DispatchQueue.main.async {
          self.movies = response.results
          self.tableView.reloadData()
        }
      }.resume()
      
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieItem", for: indexPath)
        let movie = movies[indexPath.row]
        configureCell(for: cell, with: movie)
        return cell
    }
    
    private func configureCell(for cell: UITableViewCell, with movie: MovieItem) {
        guard let movieCell = cell as? MovieCell else {
            return
        }
        movieCell.rating.text = String(movie.rating)
        movieCell.title.text = movie.title
        movieCell.totalVotes.text = String(movie.totalVotes)
    }
}
