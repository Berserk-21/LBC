//
//  HomeCollectionViewCell.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit
import Combine

final class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "HomeCollectionViewCell"
    
    private var viewModel: ItemViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "leboncoin_placeholder")
        iv.contentMode = .scaleAspectFill
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
    
    private var isUrgentImageView: UIImageView = {
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
    
    private var isUrgentPadding: CGFloat = 8.0
    private var isUrgentImageViewWidth: CGFloat = 20.0
    private var isUrgentBackgroundViewWidth: CGFloat = 30.0
    
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
    
    func configure(model: ProductModel) {
        
        viewModel = ItemViewModel(product: model)
        
        titleLabel.text = model.title
        priceLabel.text = viewModel?.formattedPrice
        categoryLabel.text = model.category
        creationDateLabel.text = viewModel?.formattedDate
        isUrgentBackgroundView.isHidden = !model.isUrgent
        
        viewModel?.$imageData.sink(receiveValue: { [weak self] data in
            
            if let imageData = data, let image = UIImage(data: imageData) {
                self?.thumbImageView.image = image
            }
        })
        .store(in: &cancellables)
        
        viewModel?.loadImage()
    }
}
