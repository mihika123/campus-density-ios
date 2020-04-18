//
//  MenuCell.swift
//  Campus Density
//
//  Created by Ashneel Das on 11/10/19.
//  Copyright © 2019 Cornell DTI. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {

    // MARK: - View vars
    var menuCollectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        menuCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        menuCollectionView.register(MenuInteriorCell.self, forCellWithReuseIdentifier: MenuInteriorCell.identifier)
        menuCollectionView.backgroundColor = .white
        menuCollectionView.isPagingEnabled = true
        menuCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(menuCollectionView)
    }

    func setupConstraints() {
        menuCollectionView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    func configure(dataSource: UICollectionViewDataSource, selected: Int, delegate: UICollectionViewDelegate) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        menuCollectionView.collectionViewLayout = layout
        menuCollectionView.dataSource = dataSource
        menuCollectionView.delegate = delegate
        setupConstraints()
        menuCollectionView.contentOffset.x = self.frame.width * CGFloat(selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}