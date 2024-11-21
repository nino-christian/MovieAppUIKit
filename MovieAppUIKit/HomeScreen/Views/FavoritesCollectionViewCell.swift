//
//  FavoritesCollectionViewCell.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/19/24.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FavoritesCollectionViewCell"
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteImageViewContainer: UIView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favoriteImageViewContainer.layer.cornerRadius = favoriteImageViewContainer.frame.width / 2
        favoriteImageViewContainer.layer.borderWidth = 2
        favoriteImageViewContainer.layer.borderColor = UIColor.appPrimary.cgColor
        favoriteImageViewContainer.clipsToBounds = true
    }
    
    
    

}


extension FavoritesCollectionViewCell {
    func updateViews(title: String, posterUrl: String) {
        favoriteLabel.text = title
        fetchImage(from: posterUrl)
    }
    
    func fetchImage(from url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.favoriteImageView.image = UIImage(data: data)
                }
            } else {
                
            }
        }
    }
}
