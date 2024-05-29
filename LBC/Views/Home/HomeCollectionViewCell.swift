//
//  HomeCollectionViewCell.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "HomeCollectionViewCell"
    
    private var thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = .black
        return iv
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    private var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .heavy)
        return label
    }()

    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        return label
    }()
    
    private var creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    func setupConstraints() {
        
//        let stackView = UIStackView(arrangedSubviews: [])
    }
    
    func configure(model: HomeViewModel) {
        
        titleLabel.text = "Dummy title"
        priceLabel.text = "5000€"
        categoryLabel.text = "Vehicule"
        creationDateLabel.text = "10 septembre 2021"
        
        
    }
}
