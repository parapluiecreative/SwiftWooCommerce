//
//  ATCValidator.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import Foundation

class ATCPasswordValidator: ObservableObject {
    
    @Published var firstValidation: Bool = false
    @Published var secondValidation: Bool = false
    @Published var thirdValidation: Bool = false
    
    var password: String = "" {
        didSet {
            validate(password)
        }
    }
    
    private func validate(_ password: String) {
        // Check if password is longer than 8 characters
        firstValidation = password.count > 8
        
        // Check if password contains uppercase
        secondValidation = NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*")
                              .evaluate(with: password)
        
        // Check if password contains special characters
        thirdValidation = NSPredicate(format:"SELF MATCHES %@", ".*[!&^%$#@()/]+.*")
                              .evaluate(with: password)
    }
}
