//
//  ReplyMessageCell.swift
//  ChatApp
//
//  Created by Duy Bui on 9/2/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit
class InReplyTextMessageCell: TextMessageCell {
    open override func setupSubviews() {
        super.setupSubviews()
        let inReplyContentView = UIView()
        self.contentView.addSubview(inReplyContentView)
        inReplyContentView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalTo(messageLabel)
            maker.bottom.equalTo(messageLabel.snp.top).offset(-5)
            maker.height.equalTo(20)
        }
    }
}
