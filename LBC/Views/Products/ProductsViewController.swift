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
        
        viewModel.didFetchDataWithErrorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ $0 })
            .sink { [weak self] error in
                self?.presentAlert(with: error)
            }
            .store(in: &cancellables)
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

// MARK: - ErrorPresenter

extension ProductsViewController: ErrorPresenter {
    // Override method for customizations
}

// Vérifier que les objets qui héritent d'un protocol utilisent toutes ses méthodes/propriétés.
