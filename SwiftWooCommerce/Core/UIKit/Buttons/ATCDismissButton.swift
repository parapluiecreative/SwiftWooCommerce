//
//  ATCDismissButton.swift
//  ChatApp
//
//  Created by Osama Naeem on 29/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDismissButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        setImage(UIImage(named: "dismissIcon-1"), for: .normal)
    }
}
