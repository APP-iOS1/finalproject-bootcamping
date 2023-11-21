//
//  test.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/03/23.
//

import SwiftUI

struct test: View {
        @State private var scale: CGFloat = 1.0
        @State private var lastScaleValue: CGFloat = 1.0
        @State private var currentPosition: CGSize = .zero
        @State private var newPosition: CGSize = .zero
        @State private var lastPosition: CGSize = .zero

        var body: some View {
            TabView {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: currentPosition.width + newPosition.width, y: currentPosition.height + newPosition.height)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.scale = self.lastScaleValue * value.magnitude
                            }
                            .onEnded { value in
                                self.lastScaleValue = self.scale
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.currentPosition = CGSize(width: self.lastPosition.width + value.translation.width, height: self.lastPosition.height + value.translation.height)
                            }
                            .onEnded { value in
                                self.currentPosition = CGSize(width: self.lastPosition.width + value.translation.width, height: self.lastPosition.height + value.translation.height)
                                self.newPosition = self.currentPosition
                                self.lastPosition = self.currentPosition
                            }
                    )
            }
        }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
