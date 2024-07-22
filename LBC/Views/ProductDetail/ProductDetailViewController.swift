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
    
    private let viewModel: ProductDetailViewModelInterface
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
        label.font = ProductsCollectionViewCell.titleLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.priceLabelFont
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.descriptionLabelFont
        label.numberOfLines = 0
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
    
    private let isUrgentLabel: UILabel = {
        let label = UILabel()
        label.font = ProductsCollectionViewCell.isUrgentLabelFont
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
        label.font = ProductsCollectionViewCell.siretLabelFont
        return label
    }()
    
    private lazy var topRightStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = stackViewSpacing
        return sv
    }()
    
    private lazy var dateUrgencyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = stackViewSpacing
        return sv
    }()
    
    
    private lazy var bottomStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = stackViewSpacing
        return sv
    }()
    
    private lazy var buyButton: UIButton = {
        let button = UIButton()
        // Cheat with some empty spaces to help self sizing width.
        let attributedString = NSAttributedString(string: "   " + Constants.ProductDetailViewController.buyButtonTitle + "   ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white])
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.isEnabled = false
        return button
    }()
    
    private let comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.ProductDetailViewController.comingSoon
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    private let sidePadding: CGFloat = 16.0
    private let imageViewWidthMultiplier: CGFloat = 0.5
    private let stackViewSpacing: CGFloat = 8.0
    
    private let buttonWidth: CGFloat = 120.0
    private let buttonHeight: CGFloat = 40.0
    
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
        
        setupViewsHierarchy()
        setupLayout()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        start()
    }
    
    func start() {
        
        viewModel.loadImage()
    }
    
    // MARK: - Setup Bindings
    
    private func setupBindings() {
        
        viewModel.imageDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let imageData = data, let image = UIImage(data: imageData) {
                    self?.productImageView.image = image
                }
            }
            .store(in: &cancellables)
        
        viewModel.imageDataErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                self.presentError(error, on: self)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup Views
    
    /// Creates and activates views constraints.
    private func setupConstraints() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        topRightStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        comingSoonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: sidePadding),
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: sidePadding),
            productImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: imageViewWidthMultiplier),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            topRightStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: sidePadding),
            topRightStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -sidePadding),
            topRightStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: sidePadding),
            topRightStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -sidePadding),
            
            verticalSeparator.widthAnchor.constraint(equalToConstant: 1.0),
            
            bottomStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: sidePadding),
            bottomStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -sidePadding),
            bottomStackView.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: sidePadding),
            
            buyButton.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: sidePadding*2),
            buyButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -sidePadding*2),
            buyButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buyButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            comingSoonLabel.trailingAnchor.constraint(equalTo: buyButton.trailingAnchor),
            comingSoonLabel.leadingAnchor.constraint(equalTo: buyButton.leadingAnchor),
            comingSoonLabel.topAnchor.constraint(equalTo: buyButton.bottomAnchor)
        ])
    }
    
    /// Adds views to hierarchy.
    private func setupViewsHierarchy() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(productImageView)
        containerView.addSubview(topRightStackView)
        containerView.addSubview(bottomStackView)
        containerView.addSubview(buyButton)
        containerView.addSubview(comingSoonLabel)
        
        // Top Right StackView
        topRightStackView.addArrangedSubview(titleLabel)
        topRightStackView.addArrangedSubview(priceLabel)
        topRightStackView.addArrangedSubview(categoryLabel)
        topRightStackView.addArrangedSubview(UIView())
        
        // Date Urgency StackView
        dateUrgencyStackView.addArrangedSubview(creationDateLabel)
        dateUrgencyStackView.addArrangedSubview(verticalSeparator)
        dateUrgencyStackView.addArrangedSubview(isUrgentLabel)
        dateUrgencyStackView.addArrangedSubview(UIView())
        
        // Bottom StackView
        bottomStackView.addArrangedSubview(descriptionLabel)
        bottomStackView.addArrangedSubview(dateUrgencyStackView)
        bottomStackView.addArrangedSubview(siretLabel)
    }
    
    /// Setup layout and populate content to views.
    private func setupLayout() {
        
        view.backgroundColor = .white
        
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.price
        descriptionLabel.text = viewModel.description
        categoryLabel.text = viewModel.category
        creationDateLabel.text = viewModel.date
        
        isUrgentLabel.text = viewModel.isUrgent ? "URGENT" : nil
        isUrgentLabel.isHidden = !viewModel.isUrgent
        verticalSeparator.isHidden = isUrgentLabel.isHidden
        
        siretLabel.text = viewModel.siret
        siretLabel.isHidden = viewModel.siret == nil
    }
}

// MARK: - Error Handling

extension ProductDetailViewController: ErrorPresenterInterface {
    // Override to customize.
}
