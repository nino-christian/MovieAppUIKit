//
//  MovieDetailViewController.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/19/24.
//

import UIKit
import Foundation

class MovieDetailViewController: UIViewController {

    var movieObject: MovieModel
    
    @IBOutlet weak var favoriteStatusImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieGenreLabel: UILabel!
    @IBOutlet weak var movieDescription: UITextView!
    @IBOutlet weak var movieLargePosterImageView: UIImageView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    @IBOutlet weak var buyHdButton: UIButton!
    @IBOutlet weak var buyStandardButton: UIButton!
    
    var favoriteIconCallback: (() -> Void)?
    
    var isFavorite = false
    var favoriteMoviesManager: FavoriteMoviesManager
    
    init(movieObject: MovieModel,
         favoriteMoviesManager: FavoriteMoviesManager = FavoriteMoviesManager()
    ) {
        self.favoriteMoviesManager = favoriteMoviesManager
        self.movieObject = movieObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupBackgroundImageShape()
    }

    private func setupViews() {
        fetchImage(from: movieObject.artworkUrl100)
        
        moviePosterImageView.layer.cornerRadius = 10
        moviePosterImageView.clipsToBounds = true
        
        movieTitleLabel.text = movieObject.trackName
        movieGenreLabel.text = movieObject.primaryGenreName
        movieDescription.text = movieObject.longDescription
        buyHdButton.setTitle("$\(movieObject.trackHdPrice ?? 0.0)", for: .normal)
        buyStandardButton.setTitle("$\(movieObject.trackPrice ?? 0.0)", for: .normal)
        
        isFavorite = favoriteMoviesManager.searchMovie(trackId: movieObject.trackId)
        if isFavorite {
            favoriteStatusImageView.tintColor = .yellow
            favoriteStatusImageView.image = UIImage(systemName: "star.fill")
        } else {
            favoriteStatusImageView.tintColor = .gray
            favoriteStatusImageView.image = UIImage(systemName: "star")
        }
        favoriteStatusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteIconTapped)))
        favoriteStatusImageView.isUserInteractionEnabled = true
    }
    
    
    @objc func favoriteIconTapped() {
        print("favoriteImageTapped")
        favoriteIconCallback?()
        if favoriteMoviesManager.searchMovie(trackId: movieObject.trackId) {
            favoriteStatusImageView.tintColor = .gray
            favoriteStatusImageView.image = UIImage(systemName: "star")
            favoriteMoviesManager.deleteMovie(delete: movieObject)
        } else {
            favoriteStatusImageView.tintColor = .yellow
            favoriteStatusImageView.image = UIImage(systemName: "star.fill")
            favoriteMoviesManager.addMovie(add: movieObject)
        }
    }
    
    private func fetchImage(from url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.moviePosterImageView.image = UIImage(data: data)
                    self?.movieLargePosterImageView.image = self?.blurImage(image: UIImage(data: data)!)
                }
            } else {
                
            }
        }
    }
    
    private func setupBackgroundImageShape() {
        let rect = movieLargePosterImageView.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.70))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        movieLargePosterImageView.layer.mask = shapeLayer
    }
    
    private func blurImage(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
            
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(10, forKey: kCIInputRadiusKey)
            
            guard let outputImage = filter?.outputImage else { return nil }
            
            let context = CIContext()
            
            let rect = ciImage.extent
            guard let cgImage = context.createCGImage(outputImage, from: rect) else { return nil }
            
            return UIImage(cgImage: cgImage)
    }
    
}


