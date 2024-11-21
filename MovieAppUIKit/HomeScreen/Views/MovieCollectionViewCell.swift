//
//  MovieCollectionViewCell.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/18/24.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"

    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieFooter: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var favoriteIconTappedCallback: (() -> Void)?
    
    var isFavorite: Bool = false {
        didSet {
            favoriteImage.image = isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            favoriteImage.tintColor = isFavorite ? UIColor.yellow : UIColor.white
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10
        
        //setupViews()
    }
    
    func setupViews() {
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.8
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.appPrimary.cgColor
        
        
        movieTitleLabel.textColor = .white
        favoriteImage.tintColor = .white
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = movieFooter.bounds
        
        let bottomColor = UIColor.black.withAlphaComponent(0.9).cgColor
        let topColor = UIColor.black.withAlphaComponent(0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        movieFooter.layer.insertSublayer(gradientLayer, at: 0)
        
        favoriteImage.isUserInteractionEnabled = true
        favoriteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteImageTapped)))
        
    }
}

extension MovieCollectionViewCell {
    
    @objc func favoriteImageTapped() {
        favoriteIconTappedCallback?()
    }
}

extension MovieCollectionViewCell {
    func updateViews(movie: MovieModel) {
        self.movieTitleLabel.text = movie.trackName
        fetchImage(from: movie.artworkUrl100)
    }
    
    func fetchImage(from url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.moviePosterImageView.image = UIImage(data: data)
                }
            } else {
                
            }
        }
    }
}
