//
//  FavoriteMoviesManager_Tests.swift
//  MovieAppUIKitTests
//
//  Created by Niño Christian Amahan on 11/25/24.
//

import XCTest
import CoreData
@testable import MovieAppUIKit

final class FavoriteMoviesManager_Tests: XCTestCase {
    
    var sut: FavoriteMoviesManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = FavoriteMoviesManager()
        super.setUp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try sut.mainContext.execute(deleteRequest)
                
        sut = nil
        super.tearDown()
    }
    
    func test_FavoriteMoviesManager_testFetchFavoriteMovies_WithMovies() throws {
        // Given
        let movieEntity = MovieEntity(context: sut.mainContext)
        movieEntity.trackId = 1
        movieEntity.trackName = "Sample track"
        try sut.mainContext.save()
        // When
        let movies = try sut.fetchFavoriteMovies()
        
        // Then
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.trackId, 1)
    }
    
    func test_FavoriteMoviesManager_testFetchFavoriteMovies_NoMovies() throws {
        // Given
        
        // When
        let movies = try sut.fetchFavoriteMovies()
        
        // Then
        XCTAssertEqual(movies.count, 0)
        
    }
    
    func test_FavoriteMoviesManager_testSearchMovie_ExistingMovie() throws {
        // Given
        let movieEntity = MovieEntity(context: sut.mainContext)
        movieEntity.trackId = 1
        movieEntity.trackName = "Sample track"
        try sut.mainContext.save()
        
        // When
        let isExisting = sut.searchMovie(trackId: 1)
        
        // Then
        XCTAssertTrue(isExisting, "Movie is found")
    }

    func test_FavoriteMoviesManager_testSearchMovie_NonExistingMovie() throws {
        // Given
        
        // When
        let isExisting = sut.searchMovie(trackId: 1)
        
        // Then
        XCTAssertFalse(isExisting, "Movie should not be found")
    }
    
    func test_FavoriteMoviesManager_testAddMovie_Success() throws {
        // Given
        let movie: MovieModel = MovieModel(isFavorite: true, trackId: 1,
                                           trackName: "Test",
                                           artworkUrl100: "test url",
                                           trackPrice: 5.75,
                                           trackHdPrice: 8.75,
                                           primaryGenreName: "test genre",
                                           longDescription: "test description")
        
        // When
        sut.addMovie(add: movie)
        
        // Then
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        let movies = try sut.mainContext.fetch(fetchRequest)
        
        XCTAssertEqual(movies.count, 1, "There should be one movie in the list")
        XCTAssertEqual(movies.first?.trackId, 1)
    }
    
    func test_FavoriteMoviesManager_testDeletedMovie_Success() throws {
        // Given
        let movie: MovieModel = MovieModel(trackId: 1,
                                           trackName: "Test",
                                           artworkUrl100: "test url",
                                           trackPrice: 5.75,
                                           trackHdPrice: 8.75,
                                           primaryGenreName: "test genre",
                                           longDescription: "test description")
        
        sut.addMovie(add: movie)
        
        // When
        sut.deleteMovie(delete: movie)
        
        // Then
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        let movies = try sut.mainContext.fetch(fetchRequest)
        
        XCTAssertEqual(movies.count, 0, "There should be no movie in the list")
    }
    
    func test_FavoriteMoviesManager_testAddAndDeleteMovie_Success() throws {
        // Given
        let movie: MovieModel = MovieModel(trackId: 1,
                                           trackName: "Test",
                                           artworkUrl100: "test url",
                                           trackPrice: 5.75,
                                           trackHdPrice: 8.75,
                                           primaryGenreName: "test genre",
                                           longDescription: "test description")
        
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        
    
        // When
        sut.addMovie(add: movie)
        let movies = try sut.mainContext.fetch(fetchRequest)
        // Then
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.trackId, 1)
        
        // When
        sut.deleteMovie(delete: movie)
        let newMovies = try sut.mainContext.fetch(fetchRequest)
        // Then
        XCTAssertEqual(newMovies.count, 0, "There should be no movie in the list")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
