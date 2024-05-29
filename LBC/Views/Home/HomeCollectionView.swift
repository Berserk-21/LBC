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
        
        if let model = viewModel?.products[indexPath.row] {
            cell.configure(model: model)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
        
        let cellWidth = (availableWidth - CGFloat(totalInterItemSpacing)) / CGFloat(numberOfColumns)
        
        return CGSize(width: cellWidth, height: cellWidth * 4/3)
    }
}

// MARK: - HomeCollectionViewInterface

extension HomeCollectionView: HomeCollectionViewInterface {
    
    func updateData() {
        reloadData()
    }
    
}
