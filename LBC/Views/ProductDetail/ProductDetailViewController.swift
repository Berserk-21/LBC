//
//  ProductDetailViewController.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit
import Combine

final class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ProductDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let containerView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 12.0
        return sv
    }()
    
    private let productImageView: UIImageView = {
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
        label.font = Constants.HomeCollectionViewCell.titleLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.priceLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.descriptionLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.categoryLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.creationDateLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let isUrgentLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.isUrgentLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let verticalSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let siretLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.HomeCollectionViewCell.siretLabelFont
        return label
    }()
    
    private var sidePadding: CGFloat = 16.0
    private var imageViewWidthMultiplier: CGFloat = 0.5
    private var stackViewSpacing: CGFloat = 8.0
    
    // MARK: - Life Cycle
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        setupConstraints()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Setup Views
    
    /// Adds views to hierarchy, creates and activates constraints.
    private func setupConstraints() {
        
        var constraints = [NSLayoutConstraint]()
        
        // ScrollView
        view.addSubview(scrollView)
        constraints.append(contentsOf: scrollView.anchors(leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor))
        
        // ContainerView
        scrollView.addSubview(containerView)
        constraints.append(contentsOf: containerView.anchors(leading: scrollView.leadingAnchor, trailing: scrollView.trailingAnchor, top: scrollView.topAnchor, bottom: scrollView.bottomAnchor))
        constraints.append(containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor))
        
        // SmallImageView
        containerView.addSubview(productImageView)
        constraints.append(contentsOf: productImageView.anchors(leading: containerView.leadingAnchor, leadingConstant: sidePadding, trailing: nil, top: containerView.topAnchor, bottom: nil))
        constraints.append(productImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: imageViewWidthMultiplier))
        constraints.append(productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 1.0))
        
        // TopRight StackView
        let topRightStackView = UIStackView(arrangedSubviews: [titleLabel, priceLabel, categoryLabel, UIView()])
        topRightStackView.axis = .vertical
        topRightStackView.spacing = 8.0
        
        containerView.addSubview(topRightStackView)
        constraints.append(contentsOf: topRightStackView.anchors(leading: productImageView.trailingAnchor, leadingConstant: sidePadding, trailing: containerView.trailingAnchor, trailingConstant: -sidePadding, top: containerView.topAnchor, topConstant: sidePadding, bottom: productImageView.bottomAnchor, bottomConstant: -sidePadding))
        
        // Vertical Separator
        constraints.append(verticalSeparator.widthAnchor.constraint(equalToConstant: 1.0))
        
        // Bottom StackView
        let dateUrgencyStackView = UIStackView(arrangedSubviews: [creationDateLabel, verticalSeparator, isUrgentLabel, UIView()])
        dateUrgencyStackView.axis = .horizontal
        dateUrgencyStackView.spacing = stackViewSpacing
        
        let bottomStackView = UIStackView(arrangedSubviews: [descriptionLabel, dateUrgencyStackView, siretLabel])
        bottomStackView.axis = .vertical
        bottomStackView.spacing = stackViewSpacing
        containerView.addSubview(bottomStackView)
        
        constraints.append(contentsOf: bottomStackView.anchors(leading: containerView.leadingAnchor, leadingConstant: sidePadding, trailing: containerView.trailingAnchor, trailingConstant: -sidePadding, top: productImageView.bottomAnchor, topConstant: sidePadding, bottom: containerView.bottomAnchor, bottomConstant: -sidePadding))
        
        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Setup layout and populate content to views.
    private func setupLayout() {
        
        view.backgroundColor = .white
        
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.formattedPrice
        descriptionLabel.text = viewModel.description
        categoryLabel.text = viewModel.category
        creationDateLabel.text = viewModel.formattedDate
        
        isUrgentLabel.text = viewModel.isUrgent ? "URGENT" : nil
        isUrgentLabel.isHidden = !viewModel.isUrgent
        verticalSeparator.isHidden = isUrgentLabel.isHidden
        
        siretLabel.text = viewModel.formattedSiret
        siretLabel.isHidden = viewModel.formattedSiret == nil
        
        viewModel.$imageData
            .sink { [weak self] data in
                if let imageData = data, let image = UIImage(data: imageData) {
                    self?.productImageView.image = image
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadImage()
    }
    
}
