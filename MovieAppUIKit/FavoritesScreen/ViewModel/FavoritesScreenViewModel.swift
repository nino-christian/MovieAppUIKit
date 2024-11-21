//
//  FavoritesScreenViewModel.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//
import CoreData

class FavoritesScreenViewModel {
    
    @Published var favoriteMovies: [MovieModel] = []
    
    var favoriteMoviesManager: FavoriteMoviesManager
    
    init(favoriteMoviesManager: FavoriteMoviesManager = FavoriteMoviesManager()) {
        self.favoriteMoviesManager = favoriteMoviesManager
        
        fetchFavoriteMovies()
    }
    
    func fetchFavoriteMovies() {
        do {
            self.favoriteMovies = try favoriteMoviesManager.fetchFavoriteMovies()
        } catch {
            
        }
    }
}
