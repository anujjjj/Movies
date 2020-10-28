//
//  ViewController.swift
//  Movies
//
//  Created by Anuj Pande on 08/10/20.
//

import Foundation
import UIKit
import Kingfisher
import CoreData

class MovieController: UIViewController {
    
    var refreshControl = UIRefreshControl()
    private weak var imageView : UIImageView?
    private var goToTopButton: UIButton?
    private var placeholderImage: UIImage?
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var displayMode: UIBarButtonItem!
    var activityIndicatorView: UIActivityIndicatorView!
    
    private enum goToTopButtonConstants {
        static let trailingValue: CGFloat = 15.0
        static let leadingValue: CGFloat = 15.0
        static let buttonHeight: CGFloat = 55.0
        static let buttonWidth: CGFloat = 55.0
    }
    
    public var movieViewModel: MovieViewModel = MovieViewModel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func switchDisplayMode(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if overrideUserInterfaceStyle != .dark {
                overrideUserInterfaceStyle = .dark
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                displayMode.image = UIImage(systemName: "sun.max.fill")
            } else {
                overrideUserInterfaceStyle = .light
                let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                displayMode.image = UIImage(systemName: "powersleep")
            }
        } else {
            print("Cannot enable dark mode")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MovieCell2", bundle: nil), forCellReuseIdentifier: "MovieCell6")
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = .singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        movieViewModel.loadFromCoreData()
            activityIndicatorView.startAnimating()
            tableView.separatorStyle = .none
            fetchMovies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func displayPlaceholderImage() {
        let placeholderImage = UIImage(named: "movieImage")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = placeholderImage
        imageView.center = view.center
        imageView.tag = 11
        self.imageView = imageView
        view.addSubview(imageView)
    }
    
    @objc private func refreshHandler() {
        movieViewModel.deleteAllData()
        fetchMovies()
        self.refreshControl.endRefreshing()
    }
    
    private func showNoNetworkAlert() {
        let alert = UIAlertController(title: "Could not connect to network", message: "Please check your internet connection", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
                  let goToTopButton = self.goToTopButton else { return }
            keyWindow.addSubview(goToTopButton)
            keyWindow.trailingAnchor.constraint(equalTo: goToTopButton.trailingAnchor,
                                                constant: goToTopButtonConstants.trailingValue).isActive = true
            keyWindow.bottomAnchor.constraint(equalTo: goToTopButton.bottomAnchor,
                                              constant: goToTopButtonConstants.leadingValue).isActive = true
            goToTopButton.widthAnchor.constraint(equalToConstant:
                                                    goToTopButtonConstants.buttonWidth).isActive = true
            goToTopButton.heightAnchor.constraint(equalToConstant:
                                                    goToTopButtonConstants.buttonHeight).isActive = true
        }
    }
    
    @IBAction private func scrollToTop(_ sender: Any) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func fetchMovies(for page: Int = 1) {
        movieViewModel.fetchMovies(for: page) { [weak self] (result) in
            if let taskError = result.error {
                DispatchQueue.main.async {
                    if -1009 == taskError._code {
                        self?.showNoNetworkAlert()
                    }
                    self?.activityIndicatorView.stopAnimating()
                    if self?.movieViewModel.getNumberOfMovies() == 0 && !(self?.movieViewModel.shouldDisplayPlaceholderImage ?? false){
                        self?.displayPlaceholderImage()
                        self?.movieViewModel.shouldDisplayPlaceholderImage = true
                    }
                }
            } else if result.data != nil {
                DispatchQueue.main.async {
                    if ((self?.movieViewModel.shouldDisplayPlaceholderImage) != nil) {
                        self?.imageView?.removeFromSuperview()
                        self?.imageView = nil;
                        self?.movieViewModel.shouldDisplayPlaceholderImage = false
                    }
                    self?.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                if self?.movieViewModel.getNumberOfMovies() ?? 0 > 0 {
                    self?.createFloatingButton()
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension MovieController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell6", for: indexPath)
        let movieModel = movieViewModel.fetchedRC.object(at: indexPath)
        let movie = movieViewModel.transformToMovieItem(movieModel)
        let movieCell = cell as! MovieCell2
        movieCell.resetPosterConstraint()
        movieCell.configureCell(for: cell, with: movie,at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let movieModel = movieViewModel.fetchedRC.object(at: indexPath)
        let movie = movieViewModel.transformToMovieItem(movieModel)
        return MovieCell2.heightOfCell(model: movie, width: tableView.frame.size.width, expanded: movieViewModel.expandedIndex == indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == movieViewModel.getNumberOfMovies() - 1 {
            let page = Int((indexPath.row + 1) / 20) + 1
            let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            spinner.frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 70)
            spinner.startAnimating()
            tableView.tableFooterView = spinner
            fetchMovies(for: page)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let expandedIndex = movieViewModel.expandedIndex {
            let previousExpandedIndexPath = IndexPath(row: expandedIndex, section: 0)
            toggleExpandedIndexSet(at: indexPath)
            if ((tableView.indexPathsForVisibleRows?.contains(previousExpandedIndexPath)) != nil) {
                tableView.reloadRows(at: [previousExpandedIndexPath, indexPath], with: .automatic)
            } else {
                tableView.reloadRows(at: [ indexPath], with: .automatic)
            }
        } else {
            toggleExpandedIndexSet(at: indexPath)
            tableView.reloadRows(at: [ indexPath], with: .automatic)
        }
    }
    
    private func toggleExpandedIndexSet(at indexPath: IndexPath) {
        if movieViewModel.expandedIndex == indexPath.row {
            movieViewModel.expandedIndex = nil
        } else {
            movieViewModel.expandedIndex = indexPath.row
        }
    }
}

// MARK: - UITableViewDataSource
extension MovieController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieViewModel.numberOfRowsInSection()
    }
}
