//
//  ProductsCollectionView.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

/// Use this protocol to communicate with the viewModel.
protocol ProductCollectionViewInterface: AnyObject {
    func updateData()
}

/// Use this protocol to communicate with the viewController.
protocol ProductsCollectionViewDelegate: AnyObject {
    func didSelectItemAt(indexPath: IndexPath)
}

final class ProductsCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    weak var viewModel: ProductsViewModel?
    weak var productDelegate: ProductsCollectionViewDelegate?
    
    private var interItemSpacing = 16.0
    
    // MARK: - Life Cycle
    
    init(viewModel: ProductsViewModel? = nil) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupCollectionView()
        observeDeviceOrientation()
    }
    
    // This should not be done in the view. Move later if enough time.
    private func observeDeviceOrientation() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        
        delegate = self
        dataSource = self
        register(ProductsCollectionViewCell.self, forCellWithReuseIdentifier: ProductsCollectionViewCell.identifier)
    }
    
    // MARK: - Actions
    
    @objc private func didChangeDeviceOrientation() {
        
        collectionViewLayout.invalidateLayout()
    }

}

// MARK: - UICollectionViewDataSource

extension ProductsCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.products.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: ProductsCollectionViewCell.identifier, for: indexPath) as? ProductsCollectionViewCell else {
            fatalError("Make sure this does not happen")
        }
        
        if let productModel = viewModel?.products[indexPath.row] {
            cell.configure(viewModel: ProductDetailViewModel(product: productModel))
        }
        
        return cell
    }
}

extension ProductsCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        productDelegate?.didSelectItemAt(indexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProductsCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let model = viewModel?.products[indexPath.row] else { return .zero }
        
        let availableWidth = collectionView.frame.width
        let numberOfColumns: Int
        
        // Setup an arbitrary dynamic width depending on device width.
        switch availableWidth {
        case 0..<500:
            numberOfColumns = 2
        case 500..<750:
            numberOfColumns = 3
        case 750..<1000:
            numberOfColumns = 4
        default:
            numberOfColumns = 5
        }
        
        let totalInterItemSpacing = ((numberOfColumns - 1) * Int(interItemSpacing))
        
        let itemWidth = (availableWidth - CGFloat(totalInterItemSpacing)) / CGFloat(numberOfColumns)
        
        let imageHeight: CGFloat = itemWidth * Constants.HomeCollectionViewCell.imageRatio
                
        var itemHeight: CGFloat = imageHeight
        
        itemHeight += heightForLabel(text: model.title, font: ProductsCollectionViewCell.titleLabelFont, width: itemWidth, maxLines: 2)
        itemHeight += heightForLabel(text: "\(model.price)€", font: ProductsCollectionViewCell.titleLabelFont, width: itemWidth)
        
        if let unwrappedCategory = model.category {
            itemHeight += heightForLabel(text: unwrappedCategory, font: ProductsCollectionViewCell.categoryLabelFont, width: itemWidth)
        }
        
        itemHeight += heightForLabel(text: model.creationDate, font: ProductsCollectionViewCell.creationDateLabelFont, width: itemWidth)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    /// Use this method to calculate the max height of a label.
    private func heightForLabel(text: String, font: UIFont, width: CGFloat, maxLines: Int = 1) -> CGFloat {
        
        let label = UILabel()
        label.numberOfLines = maxLines
        label.text = "Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height. Just a long text to get the max height."
        label.font = font
        let estimatedSize = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        return ceil(estimatedSize.height) + Constants.HomeCollectionViewCell.stackViewSpacing
    }
}

// MARK: - HomeCollectionViewInterface

extension ProductsCollectionView: ProductCollectionViewInterface {
    
    func updateData() {
        reloadData()
    }
    
}
