//
//  ATCRoundImageCollectionViewCell.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
protocol ProfileImageTapDelegate: class {
    func profileImageDidTap(cell: ATCRoundImageCollectionViewCell)
}
protocol ProfileImageTapCollectionViewDelegate: class {
    func profileImageDidTap(cell: ATCRoundImageCollectionViewCell)
}

class ATCRoundImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    weak var delegate: ProfileImageTapDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap() {
        delegate?.profileImageDidTap(cell: self)
    }
}
