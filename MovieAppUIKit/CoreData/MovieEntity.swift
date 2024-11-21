//
//  MovieEntity.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import CoreData

@objc(MovieEntity)
public class MovieEntity: NSManagedObject {
    
    func convertToDataModel() -> MovieModel {
        return MovieModel(trackId: Int(self.trackId),
                          trackName: self.trackName ?? "",
                          artworkUrl100: self.artworkPoster ?? "",
                          trackPrice: self.trackPrice,
                          trackHdPrice: self.trackHdPrice,
                          primaryGenreName: self.primaryGenre,
                          longDescription: self.longDescription)
    }
}
