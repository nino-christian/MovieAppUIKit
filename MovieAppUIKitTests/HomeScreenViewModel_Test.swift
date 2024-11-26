//
//  HomeScreenViewModel_Test.swift
//  MovieAppUIKitTests
//
//  Created by Niño Christian Amahan on 11/25/24.
//

import XCTest
import Combine
@testable import MovieAppUIKit

final class HomeScreenViewModel_Test: XCTestCase {

    var mockMoviesService: HomeScreenServiceProtocol!
    var mockFavoriteManager: MockFavoriteMoviesManager!
    
    override func setUpWithError() throws {
//        mockMoviesService = MockHomeScreenService()
//        mockFavoriteManager = MockFavoriteMoviesManager()
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_HomeScreenViewModel_SearchMovie_Success() throws {
        let expectation = self.expectation(description: "Search movie success")
        
        
        let mockService = MockHomeScreenService()
        let mockFavoriteManager = MockFavoriteMoviesManager()
        let mockMoviesResponse = MovieResponse(resultCount: 1, results: [MovieModel(trackId: <#T##Int#>, trackName: <#T##String#>, artworkUrl100: <#T##String#>, trackPrice: <#T##Double?#>, trackHdPrice: <#T##Double?#>, primaryGenreName: <#T##String?#>, longDescription: <#T##String?#>)])
        
        let viewModel = HomeScreenViewModel(homeScreenService: mockService, favoriteMoviesManager: mockFavoriteManager)
        
        viewModel.searchMovie(keywordSearchText: "test")
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

final class MockHomeScreenService: HomeScreenServiceProtocol {
    var mockMoviesResponse: Result<MovieResponse, Error>?
    
    func searchMovie(keywordSearchText: String,
                     countrySearchText: String,
                     mediaSearchText: String) -> AnyPublisher<MovieResponse, Error> {
        if let mockMoviesResponse = mockMoviesResponse {
            return Future { promise in
                promise(mockMoviesResponse)
            }
            .eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

final class MockFavoriteMoviesManager: FavoriteMoviesManager {
    var mockFavoriteMovies: [MovieModel] = []
    var searchMovieResult: Bool = false
    
    override func fetchFavoriteMovies() throws -> [MovieModel] {
        return mockFavoriteMovies
    }
    
    override func searchMovie(trackId: Int) -> Bool {
        return searchMovieResult
    }
    
    override func addMovie(add favoriteMovie: MovieModel) {
        mockFavoriteMovies.append(favoriteMovie)
    }
    
    override func deleteMovie(delete favoriteMovie: MovieModel) {
        mockFavoriteMovies.removeAll { $0.trackId == favoriteMovie.trackId }
    }
}
