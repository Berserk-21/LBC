//
//  HomeCollectionView.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

protocol HomeCollectionViewInterface: AnyObject {
    
}

final class HomeCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    weak var viewModel: HomeViewModel?
    
    // MARK: - Life Cycle
    
    init(viewModel: HomeViewModel? = nil) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200.0, height: 200.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        
        dataSource = self
        register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
    }

}

// MARK: - UICollectionViewDataSource

extension HomeCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
            fatalError("Make sure this does not happen")
        }
        
        cell.backgroundColor = .red
        
        return cell
    }
}

// MARK: - HomeCollectionViewInterface

extension HomeCollectionView: HomeCollectionViewInterface {
    
    
}
