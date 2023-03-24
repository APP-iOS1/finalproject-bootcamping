//
//  CustomImagesView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/13.
//

import SwiftUI

//https://gist.github.com/ingconti/124d549e2671fd91d86144bc222d171a
// Handle dragging
//struct PinchZoomAndDrag: ViewModifier {
//
//
//    @GestureState private var scaleState: CGFloat = 1
//    @GestureState private var offsetState = CGSize.zero
//
//    @State private var offset = CGSize.zero
//    @State private var scale: CGFloat = 1
//    @State private var currentAmount: CGFloat = 0
//
//    func resetStatus(){
//        self.offset = CGSize.zero
//        self.scale = 1
//    }
//
//    init(){
//        resetStatus()
//    }
//
//    var zoomGesture: some Gesture {
//        MagnificationGesture()
//            .updating($scaleState) { currentState, gestureState, _ in
//                gestureState = currentState
//            }
//            .onEnded { value in
//                //기존 코드
////                scale *= value
//                //손 놨을때 원래 크기로 돌아오도록 //애니메이션 안되네..
//                withAnimation(.spring()) {
//                    scale = 1
//                }
//            }
//    }
//
//    var dragGesture: some Gesture {
//        DragGesture()
//            .updating($offsetState) { currentState, gestureState, _ in
//                gestureState = currentState.translation
//            }.onEnded { value in
//                offset.height += value.translation.height
//                offset.width += value.translation.width
//            }
//    }
//
//    var doubleTapGesture : some Gesture {
//        TapGesture(count: 2).onEnded { value in
//            resetStatus()
//        }
//    }
//
//
//    func body(content: Content) -> some View {
//        content
//            .scaleEffect(self.scale * scaleState)
//            .offset(x: offset.width + offsetState.width, y: offset.height + offsetState.height)
//            .gesture(SimultaneousGesture(zoomGesture, dragGesture))
//            .gesture(doubleTapGesture)
//            .zIndex(1) //화면 가장 위로 오게
//            .ignoresSafeArea()
//    }
//
//}

    //코드수정
//struct PinchZoomAndDrag: ViewModifier {
//
//
//    @GestureState private var scaleState: CGFloat = 1
//    @GestureState private var offsetState = CGSize.zero
//
//    @State private var offset = CGSize.zero
//    @State private var scale: CGFloat = 0
//    @State private var currentAmount: CGFloat = 0
//
//    @State var scalePosition: CGPoint = .zero
//    @State var opacity: Double = 0
//    @State var offsetHelper: CGPoint = .zero
//
//    @State private var lastScaleValue: CGFloat = 1.0
//    @State private var currentPosition: CGSize = .zero
//    @State private var newPosition: CGSize = .zero
//    @State private var lastPosition: CGSize = .zero
//    @SceneStorage("isZooming") var isZooming: Bool = false
//
//    func resetStatus(){
//        self.offset = CGSize.zero
//        self.scale = 1
//    }
//
//    init(){
//        resetStatus()
//    }
    
//    var zoomGesture: some Gesture {
//        MagnificationGesture()
//            .updating($scaleState) { currentState, gestureState, _ in
//                gestureState = currentState
//            }
//            .onEnded { value in
//                //기존 코드
////                scale *= value
//                //손 놨을때 원래 크기로 돌아오도록 //애니메이션 안되네..
////                withAnimation(.spring()) {
//                    scale = 1
////                }
//            }
//    }
//
//    var dragGesture: some Gesture {
//
//        DragGesture()
//            .onChanged { value in
//                self.currentPosition = CGSize(width: self.lastPosition.width + value.translation.width, height: self.lastPosition.height + value.translation.height)
//            }
//            .onEnded { value in
//                self.currentPosition = CGSize(width: self.lastPosition.width + value.translation.width, height: self.lastPosition.height + value.translation.height)
//                self.newPosition = self.currentPosition
//                self.lastPosition = self.currentPosition
//            }
//    }
//
//    var doubleTapGesture : some Gesture {
//        TapGesture(count: 2).onEnded { value in
//            resetStatus()
//        }
//    }
    
    
//    func body(content: Content) -> some View {
//            content
//            .overlay {
//                GeometryReader { proxy in
//                    let size = proxy.size
//                    ZoomGesture(size: size, scale: $scale, offset: $offsetHelper, scalePosition: $scalePosition)
//                }
//            }
//                .offset(x: offsetHelper.x, y: offsetHelper.y)
//                .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
//                .zIndex(1) //화면 가장 위로 오게
//                .ignoresSafeArea()
//    }
//
//}
//
//// Wrap `draggable()` in a View extension to have a clean call site
//extension View {
//  func pinchZoomAndDrag() -> some View {
//    return modifier(PinchZoomAndDrag())
//  }
//}
//
////그레인코드

extension View {
    /// Add Pinch to Zoom With DragGesture Modifier
    func pinchZoom(backgroundColor: Color = .black) -> some View {
        return PinchZoomContext(content: {self}, backgroundColor: backgroundColor)
            .zIndex(1)

    }
}

/// Helper 구조체
struct PinchZoomContext<Content: View>: View {
    @ViewBuilder let content:()-> Content
    
    @State var offset: CGPoint = .zero
    @State var scale: CGFloat = 0
    
    @State var scalePosition: CGPoint = .zero
    @State var opacity: Double = 0
    
    @SceneStorage("isZooming") var isZooming: Bool = false
    
    let backgroundColor: Color
    
    var body: some View{
        ZStack(alignment: .top) {
                if scale > 0 {
                    backgroundColor.ignoresSafeArea()
                        .opacity(Double(max(min(scale, 0.7), 0.3)))
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 3)
                }
                
                TabView {
                    content()
                        .overlay (
                            GeometryReader{ proxy in
                                let size = proxy.size
                                ZoomGesture(size: size, scale: $scale , offset: $offset, scalePosition: $scalePosition)
                            }
                        )
                        .offset(x: offset.x, y: offset.y)
                    // Content를 확대하는 scaleEffect부분
                        .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
                }
                .tabViewStyle(.page(indexDisplayMode: isZooming ? .never : .automatic))
                
            }

    }
}

struct ZoomGesture: UIViewRepresentable {
   
    // Scale을 계산해서 사이즈를 받는 부분
    var size: CGSize
    
    @Binding var scale: CGFloat
    @Binding var offset: CGPoint
    
    @Binding var scalePosition: CGPoint
    //
    var recognizerScale: CGFloat = 1.0
    var maxScale: CGFloat = 2.0
    var minScale: CGFloat = 1.0
    
    /// Coordinator 연결 메소드
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // 핀치 줌 제스처 추가
        let Pinchgesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender:)))
        
        view.addGestureRecognizer(Pinchgesture)
        
        // 드레그 제스처 추가
        let Pangesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(sender:)))
        
        Pangesture.delegate = context.coordinator
        
        view.addGestureRecognizer(Pinchgesture)
        view.addGestureRecognizer(Pangesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    /// 제스처에 조건을 부여하는 핸들러
    class Coordinator: NSObject,UIGestureRecognizerDelegate{
        
        var parent: ZoomGesture
        
        init(parent: ZoomGesture) {
            self.parent = parent
        }
        
        // 두개의 제스처가 동시에 인식되도록 하는 부분
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc
        func handlePan(sender: UIPanGestureRecognizer){
            
            // 최대 터치 수 정한 부분
            sender.maximumNumberOfTouches = 2
            
            // 최소 scale 은 1
            if (sender.state == .began || sender.state == .changed) && parent.scale > 0 {
               
                if let view = sender.view{
                    
                    // 드레그 제스처에 따른 offset 변화값
                    let translation = sender.translation(in: view)
                    
                    parent.offset = translation
                }
            }
            else if sender.cancelsTouchesInView {
                // 제스처 끝난 후에 원래 상태로 돌리는 부분
                withAnimation{
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            }
            
        }
        
        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            
            // Scale을 계산하는 부분
            if sender.state == .began || sender.state == .changed {
    
                // 스케일을 세팅하는 부분
                // 기본 값이 1이기 때문에 1을 제거
                parent.scale = (sender.scale - 1)
                
                // 중앙만 핀치하는것이 아니라 원하는 부분을 골라서 핀치 줌 하도록 위치를 잡는 부분
                let scalePoint = CGPoint(x: sender.location(in: sender.view).x / sender.view!.frame.size.width, y: sender.location(in: sender.view).y / sender.view!.frame.size.height)
                
                // 결과는 이런식으로 나옴((0...1), (0...1))
                // 스케일 포인트는 한번 지정된 후에 바뀌지 않게 함
                parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
            }
            else {
                // 제스처가 끝났을 때 크기를 원래로 돌려 놓는 부분
                withAnimation(.easeOut(duration: 0.1)){
                    parent.scale = -1
                    parent.scalePosition = .zero
                }
            }
        }
    }
}
