//
//  CPKEmptyView.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 9/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

protocol CPKEmptyViewHandler: class {
    func didTapActionButton()
}

struct CPKEmptyView: View {
    
    @State var model: CPKEmptyViewModel
    weak var handler: CPKEmptyViewHandler?

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if model.title != nil {
                Text(model.title!)
                    .bold()
                    .font(.largeTitle)
            }
            
            if model.description != nil {
                Text(model.description!)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            if model.callToAction != nil {
                Button(action: {
                    self.handler?.didTapActionButton()
                }) {
                    Text(model.callToAction!)
                        .foregroundColor(model.callToActionTextColor)
                        .bold()
                }
                .frame(width: 300, height: 50, alignment: .center)
                .background(model.callToActionBackgroundColor)
                .cornerRadius(7)
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: model.bottomPadding, trailing: 0))
    }
}

struct CPKEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        let model = CPKEmptyViewModel(image: nil,
                                      title: "Test",
                                      description: "Description of SwiftUI empty view",
                                      callToAction: nil)
        return CPKEmptyView(model: model)
    }
}
