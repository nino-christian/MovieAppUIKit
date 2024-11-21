//
//  FavoritesScreenViewController.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import UIKit

class FavoritesScreenViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var favoritesScreenViewModel: FavoritesScreenViewModel
    
    init(favoritesScreenViewModel: FavoritesScreenViewModel = FavoritesScreenViewModel()) {
        self.favoritesScreenViewModel = favoritesScreenViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

}

extension FavoritesScreenViewController {
    func setupViews() {
        self.title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FavoriteMovieTableViewCell", bundle: nil), forCellReuseIdentifier: FavoriteMovieTableViewCell.identifier)
    }
}

extension FavoritesScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesScreenViewModel.favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMovieTableViewCell.identifier, for: indexPath) as? FavoriteMovieTableViewCell else { return UITableViewCell() }
        let movie = favoritesScreenViewModel.favoriteMovies[indexPath.row]
        cell.setupViews(title: movie.trackName, posterUrl: movie.artworkUrl100)
        return cell
    }
    
    
}

extension FavoritesScreenViewController {
    // TODO: HANDLE MOVIE TO DETAIL VIEW AND DELETE
}
