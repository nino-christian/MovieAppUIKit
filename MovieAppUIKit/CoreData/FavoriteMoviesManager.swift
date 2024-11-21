//
//  FavoriteMoviesManager.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import Foundation
import CoreData

enum FavoriteMoviesError: Error {
    case noFavoriteMovies
    case noExistingMovie
}

protocol FavoriteMoviesManagerProtocol {
    func fetchFavoriteMovies() throws -> [MovieModel]
    func searchMovie(trackId: Int) -> Bool
    func addMovie(add favoriteMovie: MovieModel)
    func deleteMovie(delete favoriteMovie: MovieModel)
  
}

class FavoriteMoviesManager: FavoriteMoviesManagerProtocol {
    
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    init(backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext,
         mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        self.backgroundContext = backgroundContext
        self.mainContext = mainContext
    }
    
    func fetchFavoriteMovies() throws -> [MovieModel] {
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        var movies: [MovieModel]?

        do {
          let result = try mainContext.fetch(fetchRequest)
          movies = result.map { movieEntity in
            movieEntity.convertToDataModel()
          }
        } catch {
            throw FavoriteMoviesError.noFavoriteMovies
        }

        return movies ?? []
    }
    
    func searchMovie(trackId: Int) -> Bool {
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "trackId == %d", trackId)
        
        do {
            let count = try backgroundContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking existing movie: \(error.localizedDescription)")
            return false
        }
    }
    
    func addMovie(add favoriteMovie: MovieModel) {
        let movieExist =  searchMovie(trackId: favoriteMovie.trackId)
        if !movieExist {
            backgroundContext.performAndWait {
                let movieEntity = NSEntityDescription.insertNewObject(forEntityName: "MovieEntity", into: backgroundContext) as! MovieEntity
                movieEntity.trackName = favoriteMovie.trackName
                movieEntity.trackPrice = favoriteMovie.trackPrice ?? 0.0
                movieEntity.trackHdPrice = favoriteMovie.trackHdPrice ?? 0.0
                movieEntity.artworkPoster = favoriteMovie.artworkUrl100
                movieEntity.primaryGenre = favoriteMovie.primaryGenreName
                movieEntity.longDescription = favoriteMovie.longDescription
                movieEntity.trackId = Int64(favoriteMovie.trackId)
                movieEntity.creationDate = Date()
                
                do {
                    try backgroundContext.save()
                    try mainContext.save()
                } catch {
                    print("error in saving : \(error.localizedDescription)")
                }
                print("movie added to favorites")
            }
        } else {
            print("movie already exist in favorites")
        }
        
    }
    
    func deleteMovie(delete favoriteMovie: MovieModel) {
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "trackId == %d", favoriteMovie.trackId)
        
        backgroundContext.performAndWait {
            do {
                let movieEntity = try backgroundContext.fetch(fetchRequest).first
                if let movieEntity {
                    let movieEntityInContext = try backgroundContext.existingObject(with: movieEntity.objectID)
                    backgroundContext.delete(movieEntityInContext)
                    try backgroundContext.save()
                    try mainContext.save()
                    print("Movie removed from favorites")
                }
            } catch {
                print("Cannot perform deletion: \(error.localizedDescription)")
            }
        }
    }
}
