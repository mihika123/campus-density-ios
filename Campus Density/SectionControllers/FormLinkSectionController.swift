//
//  FormLinkSectionController.swift
//  Campus Density
//
//  Created by Matthew Coufal on 3/8/19.
//  Copyright © 2019 Cornell DTI. All rights reserved.
//

import Foundation
import IGListKit

protocol FormLinkSectionControllerDelegate: class {

    func formLinkSectionControllerDidPressLinkButton(link: String)

}

class FormLinkSectionController: ListSectionController {

    // MARK: - Data vars
    var formLinkModel: FormLinkModel!
    weak var delegate: FormLinkSectionControllerDelegate?

    // MARK: - Constants
    let cellHeight: CGFloat = 20

    init(formLinkModel: FormLinkModel, delegate: FormLinkSectionControllerDelegate) {
        self.formLinkModel = formLinkModel
        self.delegate = delegate
    }

    override func sizeForItem(at index: Int) -> CGSize {
        guard let containerSize = collectionContext?.containerSize else { return .zero }
        return CGSize(width: containerSize.width, height: cellHeight)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: FormLinkCell.self, for: self, at: index) as! FormLinkCell
        cell.configure(delegate: self, link: formLinkModel.feedbackForm, lastUpdatedDate: formLinkModel.lastUpdated)
        return cell
    }

    override func didUpdate(to object: Any) {
        formLinkModel = object as? FormLinkModel
    }

}

extension FormLinkSectionController: FormLinkCellDelegate {

    func formLinkCellDidPressLinkButton(link: String) {
        delegate?.formLinkSectionControllerDidPressLinkButton(link: link)
    }

}
