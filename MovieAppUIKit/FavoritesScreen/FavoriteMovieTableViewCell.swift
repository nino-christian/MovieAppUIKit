//
//  FavoriteMovieTableViewCell.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import UIKit

class FavoriteMovieTableViewCell: UITableViewCell {
    
    static let identifier: String = "FavoriteMovieTableViewCell"

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moviePosterThumbnail: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupViews(title: String, posterUrl: String) {
        movieTitleLabel.text = title
        fetchImage(from: posterUrl)
    }
    
    func fetchImage(from url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.moviePosterThumbnail.image = UIImage(data: data)
                }
            } else {
                
            }
        }
    }
    
}
