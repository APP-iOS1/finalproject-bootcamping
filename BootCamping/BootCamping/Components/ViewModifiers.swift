//
//  ViewModifiers.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

// MARK: -Modifier :  메인 그린 버튼 속성
struct GreenButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(width: UIScreen.screenWidth * 0.94, height: UIScreen.screenHeight * 0.07)
            .foregroundColor(.white)
            .background(Color.bcGreen)
            .cornerRadius(10)
    }
}

struct PhotoCardModifier : ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.screenWidth * 0.75, height: UIScreen.screenHeight * 0.7)
            .shadow(radius: 3)
            .padding(10)
    }
}

//TODO: -로그인 알림
struct LogInAlertModifier : ViewModifier {
    @Binding var isShowingLoginAlert: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("로그인이 필요한 기능입니다.\n 로그인 하시겠습니까?", isPresented: $isShowingLoginAlert) {
                Button("취소", role: .cancel) {
                    isShowingLoginAlert = false
                }
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("로그인하기")
                    }
            }
    }
}


//MARK: - 스켈레톤 로딩뷰
//https://github.com/markiv/SwiftUI-Shimmer 수정

public struct Shimmer: ViewModifier {
    let animation: Animation
    @State private var phase: CGFloat = 0

    public init(animation: Animation = Self.defaultAnimation) {
        self.animation = animation
    }

    public static let defaultAnimation = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)

    public init(duration: Double = 1.5, bounce: Bool = false, delay: Double = 0) {
        self.animation = .linear(duration: duration)
            .repeatForever(autoreverses: bounce)
            .delay(delay)
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(phase: phase).animation(animation)
            )
            .onAppear { phase = 0.8 }
    }

    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }

    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.gray.opacity(0.5)
        let edgeColor = Color.gray.opacity(0.3)
        @Environment(\.layoutDirection) private var layoutDirection

        var body: some View {
            let isRightToLeft = layoutDirection == .rightToLeft
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: isRightToLeft ? .bottomTrailing : .topLeading,
                endPoint: isRightToLeft ? .topLeading : .bottomTrailing
            )
        }
    }
}

public extension View {
    @ViewBuilder func skeletonAnimation(
        active: Bool = true, duration: Double = 1.5, bounce: Bool = false, delay: Double = 0
    ) -> some View {
        if active {
            modifier(Shimmer(duration: duration, bounce: bounce, delay: delay))
        } else {
            self
        }
    }
}
