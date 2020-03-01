//
//  MenuCell.swift
//  Campus Density
//
//  Created by Ashneel Das on 11/10/19.
//  Copyright © 2019 Cornell DTI. All rights reserved.
//

import UIKit

protocol MenuCellDelegate: class {
    func menucelldidSwipeRightOnMenus()
    func menucelldidSwipeLeftOnMenus()
}

class MenuCell: UICollectionViewCell {

    // MARK: - View vars
    var menuCollectionView: MenuCollectionView!
    var menuLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        menuCollectionView = MenuCollectionView(frame: frame, collectionViewLayout: layout)
        menuCollectionView.register(MenuInteriorCell.self, forCellWithReuseIdentifier: MenuInteriorCell.identifier)
        menuCollectionView.backgroundColor = .blue
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

    func setupViews() {
        menuLabel = UILabel()
        menuLabel.textColor = .warmGray
        menuLabel.textAlignment = .left
        menuLabel.numberOfLines = 0
        menuLabel.font = .eighteenBold
        menuLabel.isUserInteractionEnabled = true

//        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRightOnMenus(sender:)))
//        swipeRecognizerRight.direction = .right
//        menuLabel.addGestureRecognizer(swipeRecognizerRight)

//        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeftOnMenus(sender:)))
//        swipeRecognizerRight.direction = .left
//        menuLabel.addGestureRecognizer(swipeRecognizerLeft)

        addSubview(menuLabel)
    }

    func getMenuString(todaysMenu: DayMenus, selectedMeal: Meal) -> NSMutableAttributedString {
        let res = NSMutableAttributedString(string: "")
        let newLine = NSAttributedString(string: "\n")
        for meal in todaysMenu.menus {
            if (meal.description == selectedMeal.rawValue) {
                if (meal.menu.count != 0) {
                    for station in meal.menu {
                        let categoryString = NSMutableAttributedString(string: station.category)
                        categoryString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.grayishBrown, range: categoryString.mutableString.range(of: station.category))
                        res.append(categoryString)
                        res.append(newLine)
                        let itemString = NSMutableAttributedString()
                        for item in station.items {
                            itemString.append(NSAttributedString(string: item))
                            itemString.append(newLine)
                        }
                        res.append(itemString)
                        res.append(newLine)
                    }
                }
            }
        }
        return res
    }

    func configure(dataSource: UICollectionViewDataSource, selected: Int, delegate: UICollectionViewDelegate) {
//        menuLabel.attributedText = getMenuString(todaysMenu: menu, selectedMeal: selectedMeal)
//        if (menuLabel.text == "No menus available") {
//            menuLabel.font = .eighteenBold
//        }
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
