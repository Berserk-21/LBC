//
//  HomeCollectionView.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

protocol HomeCollectionViewInterface: AnyObject {
    func updateData()
}

final class HomeCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    weak var viewModel: HomeViewModel?
    
    private var interItemSpacing = 16.0
    
    // MARK: - Life Cycle
    
    init(viewModel: HomeViewModel? = nil) {
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
        register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
    }
    
    // MARK: - Actions
    
    @objc private func didChangeDeviceOrientation() {
        
        collectionViewLayout.invalidateLayout()
    }

}

// MARK: - UICollectionViewDataSource

extension HomeCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.products.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
            fatalError("Make sure this does not happen")
        }
        
        if let productModel = viewModel?.products[indexPath.row] {
            cell.configure(viewModel: ItemViewModel(product: productModel))
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeCollectionView: UICollectionViewDelegateFlowLayout {
    
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
        
        itemHeight += heightForLabel(text: model.title, font: Constants.HomeCollectionViewCell.titleLabelFont, width: itemWidth, maxLines: 2)
        itemHeight += heightForLabel(text: "\(model.price)€", font: Constants.HomeCollectionViewCell.titleLabelFont, width: itemWidth)
        
        if let unwrappedCategory = model.category {
            itemHeight += heightForLabel(text: unwrappedCategory, font: Constants.HomeCollectionViewCell.categoryLabelFont, width: itemWidth)
        }
        
        itemHeight += heightForLabel(text: model.creationDate, font: Constants.HomeCollectionViewCell.creationDateLabelFont, width: itemWidth)
        
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

extension HomeCollectionView: HomeCollectionViewInterface {
    
    func updateData() {
        reloadData()
    }
    
}
