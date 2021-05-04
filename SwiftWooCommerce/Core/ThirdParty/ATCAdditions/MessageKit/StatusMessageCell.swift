//
//  StatusMessageCell.swift
//  ChatApp
//
//  Created by Mac  on 27/01/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

open class StatusMessageCell: MessageContentCell {

    // MARK: - Methods

    private let facepileCellClass = ATCFacepileView.self

    open var seenersFacepileCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 20, height: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        return collectionView
    }()

    var seenersProfilePictureURLs: [String] = []
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        seenersFacepileCollectionView.delegate = self
        seenersFacepileCollectionView.dataSource = self
        let cellNib = UINib(nibName: String(describing: facepileCellClass), bundle: nil)
        seenersFacepileCollectionView.register(cellNib,
                                               forCellWithReuseIdentifier: String(describing: facepileCellClass))
        self.addSubview(seenersFacepileCollectionView)
        self.avatarView.isHidden = true
        self.messageContainerView.isHidden = true
        setupConstraints()
    }

    open func setupConstraints() {
        seenersFacepileCollectionView.snp.makeConstraints { (maker) in
            maker.leading.trailing.top.bottom.equalTo(self)
            maker.height.equalTo(20)
        }
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard messagesCollectionView.messagesDisplayDelegate != nil else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        switch message.kind {
        case .status(let seenersProfilePictureURLs):
            self.seenersProfilePictureURLs = seenersProfilePictureURLs
            self.seenersFacepileCollectionView.reloadData()
        default:
            break
        }
    }
    
}

extension StatusMessageCell: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seenersProfilePictureURLs.count < 15 ? seenersProfilePictureURLs.count : 15
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: facepileCellClass), for: indexPath) as? ATCFacepileView else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        cell.seenerFacepile.kf.setImage(with: URL(string: seenersProfilePictureURLs[indexPath.row]))
        cell.backgroundColor = UIColor.gray
        return cell
    }
}
