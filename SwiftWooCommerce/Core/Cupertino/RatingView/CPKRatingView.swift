//
//  CPKRatingView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 03/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

struct CPKRatingView: View {
    @Binding var rating: Int
    var maximumRating = 5
    var starSize: CGFloat = 26.0
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    var offColor = Color.gray
    var onColor = Color.yellow
    
    @GestureState private var dragOffset = CGSize.zero
    @State private var showAction = false
    
    var body: some View {
        HStack() {
            ForEach(1..<maximumRating + 1) { number in
                self.image(for: number)
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(number > self.rating ? self.offColor : self.onColor)
                    .onTapGesture {
                        self.rating = number
                        showAction = true
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            showAction = false
                        }
                    }
                    .scaleEffect((self.showAction && self.rating == number) ? 0.5 : 1.0)
                    .animation((self.showAction && self.rating == number) ? Animation.easeInOut(duration: 0.5) : nil)
            }
        }.gesture(
            DragGesture()
                .onChanged({ (value) in
                    self.rating = Int(value.location.x / starSize)
                })
        )
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct CPKRatingView_Previews: PreviewProvider {
    static var previews: some View {
        CPKRatingView(rating: .constant(4))
    }
}
