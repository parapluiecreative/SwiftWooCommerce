//
//  ATCSocialNetworkPostImageViewerCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 16/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSwipeToDismissImageViewDelegate: class {
    func dismissImageViewer()
}

class ATCMediaViewerImageCell: UICollectionViewCell {
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let scrollView = UIScrollView()
    var swipeToDismiss: UISwipeGestureRecognizer!
    var delegate: ATCSwipeToDismissImageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
        scrollView.panGestureRecognizer.require(toFail: swipeToDismiss)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        swipeToDismiss = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownGesture))
        swipeToDismiss.direction = .down
        scrollView.addGestureRecognizer(swipeToDismiss)
    }
    
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        scrollView.addSubview(postImageView)
        postImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 0).isActive = true
        postImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -55).isActive = true
    }
    
    //Handler
    @objc func handleSwipeDownGesture() {
        self.delegate?.dismissImageViewer()
    }
}

///MARK: - UIScrollViewDelegate
extension ATCMediaViewerImageCell : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return postImageView
    }
}
