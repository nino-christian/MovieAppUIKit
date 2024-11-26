//
//  HomeScreenViewModel.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/19/24.
//

import Foundation
import Combine

enum UIState<T> {
    case initial
    case loading
    case success(T)
    case failure(Error)
}

protocol HomeScreenViewModelProtocol: AnyObject {
    func fetchMovies()
    func searchMovie(keywordSearchText: String)
}

final class HomeScreenViewModel: HomeScreenViewModelProtocol{
    var homeScreenService: HomeScreenServiceProtocol
    var favoriteMoviesManager: FavoriteMoviesManager
    
    init(homeScreenService: HomeScreenServiceProtocol,
         favoriteMoviesManager: FavoriteMoviesManager) {
        self.homeScreenService = homeScreenService
        self.favoriteMoviesManager = favoriteMoviesManager
    }
    
    @Published var moviesUIState: UIState<[MovieModel?]> = .initial
    @Published var favoriteMoviesUIState: UIState<[MovieModel?]> = .initial
    
    @Published var moviesData: [MovieModel?] = []
    @Published var favoriteMoviesData: [MovieModel?] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetchMovies() {
        favoriteMoviesUIState = .loading
        do {
            let results = try favoriteMoviesManager.fetchFavoriteMovies()
            favoriteMoviesData = results
            favoriteMoviesUIState = .success(results)
        } catch {
            favoriteMoviesUIState = .failure(error)
        }
    }
    
    func searchMovieInFavorite(using trackId: Int) -> Bool {
        return favoriteMoviesManager.searchMovie(trackId: trackId)
    }
    
    func addFavoriteMovie(movie: MovieModel) {
        favoriteMoviesManager.addMovie(add: movie)
    }
    
    func deleteFavoriteMovie(movie: MovieModel) {
        favoriteMoviesManager.deleteMovie(delete: movie)
    }
    
    func searchMovie(keywordSearchText: String) {
        self.moviesUIState = .loading
        homeScreenService.searchMovie(keywordSearchText: keywordSearchText,
                                      countrySearchText: "au",
                                      mediaSearchText: "movie")
        .receive(on: RunLoop.main)
        .sink { completion in
            switch completion {
                case .finished:
                print("Finished")
            case .failure(let error):
                print(error)
                self.moviesUIState = .failure(error)
            }
        } receiveValue: { movieResponse in
           
            self.moviesUIState = .success(movieResponse.results)
            self.moviesData = movieResponse.results
        }
        .store(in: &cancellables)

    }
}
