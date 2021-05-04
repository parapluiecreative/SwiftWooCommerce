//
//  ATCPhoneLoginScreenViewModel.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Foundation

struct ATCLandingScreenViewModel {
    let imageIcon: String
    let title: String
    let subtitle: String
    let loginString: String
    let signUpString: String
}

enum ContactPoint {
    case email
    case phone
    case phoneWithOtp
}

struct ATCLoginScreenViewModel {
    let contactPointField: String
    let passwordField: String
    let title: String
    let loginString: String
    let facebookString: String
    let separatorString: String
    let forgotPasswordString: String
}

struct ATCPhoneLoginScreenViewModel {
    let contactPointField: String
    let passwordField: String
    let title: String
    let loginString: String
    let sendCodeString: String
    let submitCodeString: String
    let facebookString: String
    let phoneNumberString: String
    let phoneNumberLoginString: String
    let emailLoginString: String
    let separatorString: String
    var contactPoint: ContactPoint
    var phoneCodeString: String?
    let forgotPasswordString: String
}

struct ATCSignUpScreenViewModel {
    let nameField: String
    let phoneField: String
    let emailField: String
    let passwordField: String
    let title: String
    let signUpString: String
}

struct ATCPhoneSignUpScreenViewModel {
    let firstNameField: String
    let lastNameField: String
    let phoneField: String
    let emailField: String
    let passwordField: String
    let title: String
    let signUpString: String
    let separatorString: String
    var contactPoint: ContactPoint
    let phoneNumberString: String
    let phoneNumberSignUpString: String
    let emailSignUpString: String
    let sendCodeString: String
    var phoneCodeString: String?
    let submitCodeString: String
}

struct ATCResetPasswordScreenViewModel {
    let title: String
    let emailField: String
    let resetPasswordString: String
}
