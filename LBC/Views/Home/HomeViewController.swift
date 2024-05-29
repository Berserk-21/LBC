//
//  HomeViewController.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var collectionView: HomeCollectionView = {
        let cv = HomeCollectionView()
        cv.viewModel = viewModel
        return cv
    }()
    
    let viewModel: HomeViewModel
    
    // MARK: - Life Cycle
    
    init() {
        self.viewModel = HomeViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupBindings()
    }
    
    // MARK: - Setup Views
    
    private func setupBindings() {
        
        // Make sure references are weak.
        viewModel.collectionView = collectionView
        collectionView.viewModel = viewModel
    }
    
}

