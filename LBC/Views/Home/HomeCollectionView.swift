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
        super.init(frame: .zero, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCollectionView: HomeCollectionViewInterface {
    
    
}
