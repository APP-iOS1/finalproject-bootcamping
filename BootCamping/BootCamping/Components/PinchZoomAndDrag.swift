//
//  CustomImagesView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/13.
//

import SwiftUI

//https://gist.github.com/ingconti/124d549e2671fd91d86144bc222d171a
// Handle dragging
struct PinchZoomAndDrag: ViewModifier {
    
    
    @GestureState private var scaleState: CGFloat = 1
    @GestureState private var offsetState = CGSize.zero
    
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1
    @State private var currentAmount: CGFloat = 0
    
    func resetStatus(){
        self.offset = CGSize.zero
        self.scale = 1
    }
    
    init(){
        resetStatus()
    }
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($scaleState) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                //기존 코드
//                scale *= value
                //손 놨을때 원래 크기로 돌아오도록 //애니메이션 안되네..
                withAnimation(.spring()) {
                    scale = 1
                }
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($offsetState) { currentState, gestureState, _ in
                gestureState = currentState.translation
            }.onEnded { value in
                offset.height += value.translation.height
                offset.width += value.translation.width
            }
    }
    
    var doubleTapGesture : some Gesture {
        TapGesture(count: 2).onEnded { value in
            resetStatus()
        }
    }
    
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(self.scale * scaleState)
            .offset(x: offset.width + offsetState.width, y: offset.height + offsetState.height)
            .gesture(SimultaneousGesture(zoomGesture, dragGesture))
            .gesture(doubleTapGesture)
            .zIndex(1) //화면 가장 위로 오게
            .ignoresSafeArea()
    }

}

// Wrap `draggable()` in a View extension to have a clean call site
extension View {
  func pinchZoomAndDrag() -> some View {
    return modifier(PinchZoomAndDrag())
  }
}
