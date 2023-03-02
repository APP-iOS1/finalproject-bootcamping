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
