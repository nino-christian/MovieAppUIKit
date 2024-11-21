//
//  HomeScreenService.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/19/24.
//

import Combine
import Foundation

protocol HomeScreenServiceProtocol {
    func searchMovie(keywordSearchText: String,
                     countrySearchText: String,
                     mediaSearchText: String) -> AnyPublisher<MovieResponse, Error>
}

class HomeScreenService: HomeScreenServiceProtocol {

    func searchMovie(keywordSearchText: String,
                     countrySearchText: String = "us",
                     mediaSearchText: String = "movie") -> AnyPublisher<MovieResponse, Error> {
        
        var urlComponents = URLComponents(string: Endpoints.baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "term", value: keywordSearchText),
            URLQueryItem(name: "country", value: countrySearchText),
            URLQueryItem(name: "media", value: mediaSearchText)
        ]
        
        var urlString: String = ""
        
        if let url = urlComponents?.url {
            urlString = url.absoluteString + "&;all"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                                      200..<300 ~= httpResponse.statusCode else {
                                    throw URLError(.badServerResponse)
                                }
                                return data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
