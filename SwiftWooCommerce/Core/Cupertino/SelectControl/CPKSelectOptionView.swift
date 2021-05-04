//
//  CPKSelectOptionView.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import SwiftUI

struct CPKSelectOptionModel: Identifiable {
    var title: String
    var selected: Bool

    var id: String {
        return title
    }
}

struct CPKCheckMarkView: View {
    @State var tintColor: UIColor

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("check-simple-icon")
                .renderingMode(.template)
                .background(Color(tintColor))
                .accentColor(Color.white)
        }
        .clipShape(Circle())
    }
}

struct CPKSelectOptionView: View {
    @State var optionModel: CPKSelectOptionModel
    @State var tintColor: UIColor

    var body: some View {
        HStack(alignment: .center, spacing: 100) {
            Text(optionModel.title)
            if (optionModel.selected) {
                CPKCheckMarkView(tintColor: tintColor)
            }
        }
    }
}

struct CPKSelectOptionView_Previews: PreviewProvider {
    static var previews: some View {
        let model = CPKSelectOptionModel(title: "In Transit", selected: true)
        return CPKSelectOptionView(optionModel: model, tintColor: .blue)
    }
}
