//
//  ProductsViewController.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit
import Combine

final class ProductsViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var collectionView: ProductsCollectionView = {
        let cv = ProductsCollectionView(viewModel: viewModel)
        cv.productDelegate = self
        return cv
    }()
        
    private let viewModel: ProductsViewModelInterface
    
    private var cancellables = Set<AnyCancellable>()
    
    private var sidePadding: CGFloat = 16.0
    
    // MARK: - Life Cycle
    
    init(viewModel: ProductsViewModelInterface = ProductsViewModel()) {
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
        
        setupErrorBinding()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewModel.viewWillLayoutSubviews()
    }
    
    private func start() {
        
        viewModel.fetchData()
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

// MARK: - Reactive Bindings

extension ProductsViewController {
    
    private func setupErrorBinding() {
        viewModel.didFetchDataWithErrorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ $0 })
            .sink { [weak self] error in
                guard let self = self else { return }
                self.presentError(title: error.title, message: error.message, on: self)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ErrorPresenter

extension ProductsViewController: ErrorPresenterInterface {
    // Override method for customizations
}

// Vérifier que les objets qui héritent d'un protocol utilisent toutes ses méthodes/propriétés.
