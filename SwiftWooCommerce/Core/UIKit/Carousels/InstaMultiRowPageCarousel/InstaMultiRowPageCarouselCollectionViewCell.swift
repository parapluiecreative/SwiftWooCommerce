//
//  InstaMultiRowPageCarouselCollectionViewCell.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class InstaMultiRowPageCarouselCollectionViewCell: UICollectionViewCell, ATCGenericCollectionViewScrollDelegate {
    @IBOutlet var containerView: UIView!
    @IBOutlet var carouselTitleLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var carouselContainerView: UIView!

    func genericScrollView(_ scrollView: UIScrollView, didScrollToPage page: Int) {
        pageControl.currentPage = page
    }
    
    func genericScrollViewDidScroll(_ scrollView: UIScrollView) {}
}
