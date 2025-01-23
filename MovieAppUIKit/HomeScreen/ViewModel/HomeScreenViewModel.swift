//
//  HomeScreenViewModel.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/19/24.
//

import Foundation
import Combine

enum UIState<T: Equatable>: Equatable {
    case initial
    case loading
    case success(T)
    case failure(Error)
    
    static func == (lhs: UIState<T>, rhs: UIState<T>) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial):
                return true
            case (.loading, .loading):
                return true
            case (.success(let lhsValue), .success(let rhsValue)):
                return lhsValue == rhsValue
            case (.failure(let lhsError), .failure(let rhsError)):
                // You might need to define how to compare errors
                // For simplicity, we'll compare error descriptions here
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
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
        searchMovie()
    }
    
    
    @Published var moviesUIState: UIState<[MovieModel]> = .initial
    @Published var favoriteMoviesUIState: UIState<[MovieModel]> = .initial
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
    
    func isMovieInFavorites(using trackId: Int) -> Bool {
        return favoriteMoviesManager.searchMovie(trackId: trackId)
    }
    
    func addFavoriteMovie(movie: MovieModel) {
        favoriteMoviesManager.addMovie(add: movie)
    }
    
    func deleteFavoriteMovie(movie: MovieModel) {
        favoriteMoviesManager.deleteMovie(delete: movie)
    }
    
    func searchMovie(keywordSearchText: String = "") {
        self.moviesUIState = .loading
        homeScreenService.searchMovie(keywordSearchText: keywordSearchText,
                                      countrySearchText: "au",
                                      mediaSearchText: "movie")
        .receive(on: RunLoop.main)
        .removeDuplicates(by: { old, new in
            old.results == new.results
        })
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
        }
        .store(in: &cancellables)

    }
}
