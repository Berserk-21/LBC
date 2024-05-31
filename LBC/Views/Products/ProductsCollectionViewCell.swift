//
//  ProductsCollectionViewCell.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit
import Combine

final class ProductsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "HomeCollectionViewCell"
    
    private var viewModel: ProductDetailViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "leboncoin_placeholder")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8.0
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.titleLabelFont
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.priceLabelFont
        label.numberOfLines = 1
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.categoryLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.creationDateLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let isUrgentImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bolt.badge.clock.fill")
        iv.tintColor = .yellow
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var isUrgentBackgroundView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = isUrgentBackgroundViewWidth / 2
        v.layer.masksToBounds = true
        v.backgroundColor = .darkGray
        return v
    }()
    
    private let isUrgentPadding: CGFloat = 8.0
    private let isUrgentImageViewWidth: CGFloat = 20.0
    private let isUrgentBackgroundViewWidth: CGFloat = 30.0
    
    // Shared Fonts
    static let titleLabelFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
    static let priceLabelFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.heavy)
    static let descriptionLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    static let categoryLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
    static let creationDateLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.light)
    static let isUrgentLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    static let siretLabelFont = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.light)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = UIImage(named: "leboncoin_placeholder")
        cancellables.removeAll()
    }
    
    // MARK: - Setup Views
    
    private func setupConstraints() {
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(thumbImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0))
        constraints.append(thumbImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Constants.HomeCollectionViewCell.imageRatio))
        
        let stackView = UIStackView(arrangedSubviews: [thumbImageView, titleLabel, priceLabel, categoryLabel, creationDateLabel, UIView()])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.HomeCollectionViewCell.stackViewSpacing
        contentView.addSubview(stackView)
        let stackViewConstraints = stackView.anchors(leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, top: contentView.topAnchor, bottom: contentView.bottomAnchor)
        
        constraints.append(contentsOf: stackViewConstraints)
        
        contentView.addSubview(isUrgentBackgroundView)
        constraints.append(contentsOf: isUrgentBackgroundView.anchors(leading: nil, trailing: thumbImageView.trailingAnchor, trailingConstant: -isUrgentPadding, top: nil, bottom: thumbImageView.bottomAnchor, bottomConstant: -isUrgentPadding))
        constraints.append(isUrgentBackgroundView.widthAnchor.constraint(equalToConstant: isUrgentBackgroundViewWidth))
        constraints.append(isUrgentBackgroundView.heightAnchor.constraint(equalToConstant: isUrgentBackgroundViewWidth))
        
        isUrgentBackgroundView.addSubview(isUrgentImageView)
        constraints.append(isUrgentImageView.centerXAnchor.constraint(equalTo: isUrgentBackgroundView.centerXAnchor, constant: -2.0))
        constraints.append(isUrgentImageView.centerYAnchor.constraint(equalTo: isUrgentBackgroundView.centerYAnchor, constant: 0.0))
        
        constraints.append(isUrgentImageView.widthAnchor.constraint(equalToConstant: isUrgentImageViewWidth))
        constraints.append(isUrgentImageView.heightAnchor.constraint(equalToConstant: isUrgentImageViewWidth))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(viewModel: ProductDetailViewModel) {
                        
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.formattedPrice
        categoryLabel.text = viewModel.category
        creationDateLabel.text = viewModel.formattedDate
        isUrgentBackgroundView.isHidden = !viewModel.isUrgent
        
        viewModel.$imageData.sink(receiveValue: { [weak self] data in
            
            if let imageData = data, let image = UIImage(data: imageData) {
                self?.thumbImageView.image = image
            }
        })
        .store(in: &cancellables)
        
        viewModel.loadImage()
    }
}
