//
//  StatusMessageSizeCalculator.swift
//  ChatApp
//
//  Created by Mac  on 27/01/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

open class StatusMessageSizeCalculator: MessageSizeCalculator {

    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        return CGSize(width: maxWidth, height: 44)
    }
}
