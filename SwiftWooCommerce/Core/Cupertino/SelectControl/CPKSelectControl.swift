//
//  CPKSelectControl.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import SwiftUI

protocol CPKSelectControlDelegate {
    func didTapOption(_ option: CPKSelectOptionModel)
}

struct CPKSelectControl: View {
    
    @State var options: [CPKSelectOptionModel]
    @State var tintColor: UIColor
    @State var isOpen: Bool
    
    private let height = UIScreen.main.bounds.height
    
    var delegate: CPKSelectControlDelegate?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
            List(options) { option in
                CPKSelectOptionView(optionModel: option, tintColor: self.tintColor)
                    .onTapGesture {
                        self.delegate?.didTapOption(option)
                }
            }
            .border(Color.blue, width: 2)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue, lineWidth: 2))
            .edgesIgnoringSafeArea(.bottom)
            .listStyle(GroupedListStyle())
            .padding(.top, height - 400)
        }
    }
}



