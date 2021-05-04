//
//  ATCContactsTableViewCell.swift
//  ChatApp
//
//  Created by Osama Naeem on 21/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCContactsTableViewCell: UITableViewCell {
    
    var imageViewSize: CGFloat = 30
    let friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let friendName: UILabel = {
        let friendName = UILabel()
        friendName.text = "Osama Naeem"
        friendName.translatesAutoresizingMaskIntoConstraints = false
        return friendName
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutViews()
    }
    
    
    func layoutViews(){
        addSubview(friendImageView)
        friendImageView.layer.cornerRadius = imageViewSize / 2
        friendImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        friendImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        friendImageView.heightAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        friendImageView.widthAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        
        addSubview(friendName)
        friendName.leftAnchor.constraint(equalTo: friendImageView.rightAnchor, constant: 12).isActive = true
        friendName.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 11).isActive = true
        friendName.heightAnchor.constraint(equalToConstant: 24).isActive = true
        friendName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 12).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
