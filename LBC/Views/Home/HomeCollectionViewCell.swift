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
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .black
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 8.0
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.titleLabelFont
        label.numberOfLines = 2
        return label
    }()
    
    private var priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.priceLabelFont
        label.numberOfLines = 1
        return label
    }()

    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.categoryLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private var creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.creationDateLabelFont
        label.numberOfLines = 1
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
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(thumbImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0))
        constraints.append(thumbImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 4/3))
        
        let stackView = UIStackView(arrangedSubviews: [thumbImageView, titleLabel, priceLabel, categoryLabel, creationDateLabel, UIView()])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.HomeCollectionViewCell.stackViewSpacing
        contentView.addSubview(stackView)
        let stackViewConstraints = stackView.anchors(leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, top: contentView.topAnchor, bottom: contentView.bottomAnchor)
        
        constraints.append(contentsOf: stackViewConstraints)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(model: ProductModel) {
        
        titleLabel.text = model.title
        priceLabel.text = "\(model.price)€"
        categoryLabel.text = model.category
        creationDateLabel.text = model.creationDate
    }
}
