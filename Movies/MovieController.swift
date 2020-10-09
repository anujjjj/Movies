//
//  ViewController.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation
import UIKit
import Kingfisher

class MovieController: UITableViewController {
    
    var activityIndicatorView: UIActivityIndicatorView!
    public var movies: [MovieItem] = []
    var expandedIndexSet: IndexSet = []
    
    required init?(coder: NSCoder) {
        //                movies = MovieCellCreator().movies
        //                print(movies)
        super.init(coder: coder)
    }
    
    @IBAction func switchMode(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if overrideUserInterfaceStyle != .dark {
                overrideUserInterfaceStyle = .dark
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
            }
            else {
                overrideUserInterfaceStyle = .light
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
            }
        } else {
            // Fallback on earlier versions
            print("light")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        //        fetchMovies()
        activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        tableView.backgroundView = activityIndicatorView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        if(movies.count == 0) {
            activityIndicatorView.startAnimating()
            tableView.separatorStyle = .none
            fetchMovies()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchMovies(for page: Int = 1) {
        guard let url =  URL(string:"https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=8eac22f4c24d01c480e4d99fef2edfc3&page=" + String(page)) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, taskError in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                fatalError("Could Not load data")
            }
            //            sleep(2)
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(MediaResponse.self, from: data) else {
                return
            }
            print("Response")
            let mvs = response.results
            print("Total Results \(mvs.count) ")
            print(mvs[0].title)
            DispatchQueue.main.async {
                self.movies.append(contentsOf: response.results)
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
                self.tableView.separatorStyle = .singleLine
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
        
        configureCell(for: cell, with: movie,at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleExpandedIndexSet(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func toggleExpandedIndexSet(at indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            expandedIndexSet.remove(indexPath.row)
        } else {
            expandedIndexSet.insert(indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == movies.count - 1 {
            print("Last cell displayed")
            print(indexPath.row)
            let page = Int((indexPath.row + 1) / 20) + 1
            fetchMovies(for: page)
        }
    }
    
    private func configureCell(for cell: UITableViewCell, with movie: MovieItem,at indexPath: IndexPath) {
        guard let movieCell = cell as? MovieCell else {
            return
        }
        configureImage(for: movieCell, with: movie)
        movieCell.rating.text = String(movie.rating)
        movieCell.title.text = movie.title
        movieCell.totalVotes.text = String(movie.totalVotes)
        movieCell.overview.text = movie.overview
        if expandedIndexSet.contains(indexPath.row) {
            movieCell.overview.numberOfLines = 0
            movieCell.overview.adjustsFontSizeToFitWidth = true
        } else {
            movieCell.overview.numberOfLines = 1
            movieCell.overview.adjustsFontSizeToFitWidth = false
        }
    }
    
    private func configureImage(for movieCell: MovieCell, with movie: MovieItem) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/original" + movie.posterPath) else {
            fatalError("Could not parse url")
        }
        //        let processor = DownsamplingImageProcessor(size: movieCell.poster.sizeThatFits(CGSize(width: 180,height: 130)))
        //            |> RoundCornerImageProcessor(cornerRadius: 10)
        let processor = DownsamplingImageProcessor(size: movieCell.poster.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 10)
//        let processor = DownsamplingImageProcessor(size: movieCell.poster.intrinsicContentSize)
//            |> RoundCornerImageProcessor(cornerRadius: 10)
        movieCell.poster.kf.indicatorType = .activity
        movieCell.poster.kf.setImage(
            with: url,
            //            placeholder: UIImage(named: "movieImage"),
            options: [
                .onFailureImage(UIImage(named: "movieImage")),
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage,
            ], completionHandler:
                {
                    result in
                    switch result {
                    case .success(let value):
                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        //                        print(value)
                        print(value.cacheType)
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                })
    }
}
