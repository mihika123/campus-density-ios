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
    var menuLabel: UILabel!
    var headerLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        headerLabel = UILabel()
        headerLabel.text = "Menus"
        headerLabel.textColor = .grayishBrown
        headerLabel.textAlignment = .left
        headerLabel.font = .thirtyBold
        addSubview(headerLabel)
        
        menuLabel = UILabel()
        menuLabel.textColor = .warmGray
        menuLabel.textAlignment = .left
        menuLabel.numberOfLines = 0
        menuLabel.font = .eighteenBold
        addSubview(menuLabel)

    }

    func setupConstraints() {
        
        headerLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(Constants.smallPadding)
            make.left.equalToSuperview().offset(Constants.smallPadding)
            let headerLabelTextHeight = "Menus".height(withConstrainedWidth: frame.width - Constants.smallPadding * 2, font: headerLabel.font)
            make.height.equalTo(headerLabelTextHeight)
        }
        
        menuLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(Constants.smallPadding * 3.5)
            make.left.equalToSuperview().offset(Constants.smallPadding)

//            make.left.equalToSuperview().offset(Constants.smallPadding)
        }
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
    
    func configure(with menu: DayMenus, selectedMeal: Meal) {
        menuLabel.attributedText = getMenuString(todaysMenu: menu, selectedMeal: selectedMeal)
        if (menuLabel.text == "No menus available") {
            menuLabel.font = .eighteenBold
        }
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
