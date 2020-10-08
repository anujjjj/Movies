//
//  ViewController.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import UIKit

class MovieController: UITableViewController {

    private var movies: [MovieItem] = []
    
    required init?(coder: NSCoder) {
        movies = MovieCellCreator().movies
        print(movies)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        // Do any additional setup after loading the view.
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
        confiureCell(for: cell, with: movie)
        return cell
    }
    
    private func confiureCell(for cell: UITableViewCell, with movie: MovieItem) {
        guard let movieCell = cell as? MovieCell else {
            return
        }
        movieCell.rating.text = String(movie.rating)
        movieCell.title.text = movie.title
        movieCell.totalVotes.text = String(movie.totalVotes)
        
    }
}
