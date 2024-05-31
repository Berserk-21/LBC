//
//  ProductsViewController.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

/// Use this protocol to communicate with the controller from the viewModel.
protocol ProductsViewControllerInterface: AnyObject {
    func presentAlert(with error: NetworkServiceError)
}

final class ProductsViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var collectionView: ProductsCollectionView = {
        let cv = ProductsCollectionView(viewModel: viewModel)
        cv.productDelegate = self
        return cv
    }()
        
    private let viewModel: ProductsViewModel
    
    private var sidePadding: CGFloat = 16.0
    
    // MARK: - Life Cycle
    
    init() {
        self.viewModel = ProductsViewModel()
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
        // Do any additional setup after loading the view.
        
        setupBindings()
        start()
    }
    
    // MARK: - Setup Views
    
    private func setupLayout() {
        
        view.backgroundColor = .white
        navigationItem.title = Constants.ProductViewController.Navigation.title
        navigationController?.navigationBar.tintColor = .black
    }
    
    /// Binds viewModel and Views.
    private func setupBindings() {
        
        // Make sure references are weak.
        viewModel.collectionView = collectionView
        collectionView.viewModel = viewModel
        viewModel.productsViewControllerDelegate = self
    }
    
    private func start() {
        
        viewModel.start()
    }
    
    /// Adds views, creates and activates constraints.
    private func setupConstraints() {
        
        view.addSubview(collectionView)
        let collectionViewConstraints = collectionView.anchors(leading: view.safeAreaLayoutGuide.leadingAnchor, leadingConstant: sidePadding, trailing: view.safeAreaLayoutGuide.trailingAnchor, trailingConstant: -sidePadding, top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - ProductsCollectionViewDelegate

extension ProductsViewController: ProductsCollectionViewDelegate {
    
    func didSelectItemAt(indexPath: IndexPath) {
        
        guard indexPath.row < viewModel.products.count else { return }
        
        let detailVC = ProductDetailViewController(viewModel: ProductDetailViewModel(product: viewModel.products[indexPath.row]))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - ProductsViewControllerInterface

extension ProductsViewController: ProductsViewControllerInterface {
    
    func presentAlert(with error: NetworkServiceError) {
        
        let alertController = UIAlertController(title: Constants.ProductViewController.Alert.errorTitle, message: Constants.ProductViewController.Alert.errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.ProductViewController.Alert.okTitle, style: .default))
        present(alertController, animated: true)
    }
}
