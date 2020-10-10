//
//  ViewController.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation
import UIKit
import Kingfisher

class MovieController: UIViewController {
    private var goToTopButton: UIButton?
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var displayMode: UIBarButtonItem!
    var activityIndicatorView: UIActivityIndicatorView!
    
    private enum goToTopButtonConstants {
        static let trailingValue: CGFloat = 15.0
        static let leadingValue: CGFloat = 15.0
        static let buttonHeight: CGFloat = 55.0
        static let buttonWidth: CGFloat = 55.0
    }
    
    public var movies: [MovieItem] = []
    var expandedIndexSet: IndexSet = []
    
    required init?(coder: NSCoder) {
        //                movies = MovieCellCreator().movies
        //                print(movies)
        super.init(coder: coder)
    }
    
    @IBAction func switchDisplayMode(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if overrideUserInterfaceStyle != .dark {
                overrideUserInterfaceStyle = .dark
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                displayMode.image = UIImage(systemName: "sun.max.fill")
            }
            else {
                overrideUserInterfaceStyle = .light
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                displayMode.image = UIImage(systemName: "powersleep")
            }
        } else {
            // Fallback on earlier versions
            print("Cannot enable dark mode")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        //        fetchMovies()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        tableView.backgroundView = activityIndicatorView
        createFloatingButton()
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
    
    private func createFloatingButton() {
        goToTopButton = UIButton(type: .custom)
        goToTopButton?.translatesAutoresizingMaskIntoConstraints = false
        constrainGoToTopButtonToWindow()
        goToTopButton?.layer.cornerRadius = 30
        goToTopButton?.layer.masksToBounds = true
        goToTopButton?.setImage(UIImage(named: "top"), for: .normal)
        goToTopButton?.addTarget(self, action: #selector(scrollToTop(_:)), for: .touchUpInside)
    }
    
    private func constrainGoToTopButtonToWindow() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
                  let floatingButton = self.goToTopButton else { return }
            keyWindow.addSubview(floatingButton)
            keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                                constant: goToTopButtonConstants.trailingValue).isActive = true
            keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                              constant: goToTopButtonConstants.leadingValue).isActive = true
            floatingButton.widthAnchor.constraint(equalToConstant:
                                                    goToTopButtonConstants.buttonWidth).isActive = true
            floatingButton.heightAnchor.constraint(equalToConstant:
                                                    goToTopButtonConstants.buttonHeight).isActive = true
        }
    }
    
    @IBAction private func scrollToTop(_ sender: Any) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
            //                        sleep(2)
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
            movieCell.title.numberOfLines = 0
            movieCell.overview.adjustsFontSizeToFitWidth = true
        } else {
            movieCell.overview.numberOfLines = 1
            movieCell.title.numberOfLines = 2
            movieCell.overview.adjustsFontSizeToFitWidth = false
        }
    }
    
    private func configureImage(for movieCell: MovieCell, with movie: MovieItem) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/original" + movie.posterPath) else {
            fatalError("Could not parse url")
        }
        //        let processor = DownsamplingImageProcessor(size: movieCell.poster.sizeThatFits(CGSize(width: 180,height: 130)))
        //            |> RoundCornerImageProcessor(cornerRadius: 10)
        //        let processor = DownsamplingImageProcessor(size: movieCell.poster.intrinsicContentSize)
        //            |> RoundCornerImageProcessor(cornerRadius: 10)
        let processor = DownsamplingImageProcessor(size: movieCell.poster.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 10)
        movieCell.poster.kf.indicatorType = .activity
        movieCell.poster.kf.setImage(
            with: url,
            options: [
                .onFailureImage(UIImage(named: "movieImage")),
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage,
            ]
            //            , completionHandler:
            //                {
            //                    result in
            //                    switch result {
            //                    case .success(let value):
            //                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
            //                        print(value)
            //                        print(value.cacheType)
            //                    case .failure(let error):
            //                        print("Job failed: \(error.localizedDescription)")
            //                    }
            //                }
        )
    }
}

extension MovieController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieItem3", for: indexPath)
        let movie = movies[indexPath.row]
        
        configureCell(for: cell, with: movie,at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == movies.count - 1 {
            print("Last cell displayed")
            print(indexPath.row)
            let page = Int((indexPath.row + 1) / 20) + 1
            fetchMovies(for: page)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleExpandedIndexSet(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func toggleExpandedIndexSet(at indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            print("Cell \(indexPath.row) contracted")
            expandedIndexSet.remove(indexPath.row)
        } else {
            print("Cell \(indexPath.row) expanded")
            expandedIndexSet.insert(indexPath.row)
        }
    }
}

extension MovieController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}
