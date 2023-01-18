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
            .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.07)
            .foregroundColor(.white)
            .background(Color("BCGreen"))
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



/* 예시
 struct BodyTextModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Medium", size: 14))
     }
 }

 struct CategoryTextModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Bold", size: 20))
     }
 }

 struct TitleModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Bold", size: 28))
     }
 }


 // MARK: -Modifier : LoginView 버튼 속성
 struct ButtonModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Bold", size: 18))
             .frame(width: 280, height: 50)
             .foregroundColor(.black)
             .background(Color.accentColor)
             .cornerRadius(15)
     }
 }

 // MARK: -Modifier : 네비게이션 타이틀, 모드 속성
 struct NavigationTitleModifier : ViewModifier {
     let title : String
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Bold", size: 18))
             .navigationTitle(title)
             .navigationBarTitleDisplayMode(.inline)
     }
 }

 // MARK: -Modifier : 기본 버튼 속성
 /// 오늘의 바텐더의 답변 버튼에 주로 사용됩니다.
 struct BasicButtonModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-Bold", size: 18))
             .foregroundColor(Color.white)
             .frame(width:218, height: 43)
             .background(Color(.systemGray3))
             .cornerRadius(10)
             .padding(.bottom, 10)
     }
 }

 // MARK: -Modifier : LoginView 텍스트필드 속성
 struct LoginTextFieldModifier : ViewModifier {
     func body(content: Content) -> some View {
         content
             .font(.custom("Pretendard-SemiBold", size: 18))
             .frame(width: 300, height: 20)
             .textInputAutocapitalization(.never)
             .foregroundColor(.white)
             .overlay(Rectangle().frame(height: 2).padding(.top, 40))
             .foregroundColor(Color.accentColor)
     }
 }


 // MARK: -Modifier : RegisterView 텍스트필드 속성
 struct RegisterTextFieldModifier : ViewModifier {
     @Binding var targetField : String
     
     func body(content: Content) -> some View {
         content
             .frame(maxWidth : .infinity)
             .frame(height : 20)
             .font(.custom("Pretendard-SemiBold", size: 18))
             .textInputAutocapitalization(.never)
             .foregroundColor(.white)
             .overlay(Rectangle().frame(height: 2).padding(.top, 40))
             .foregroundColor(Color.accentColor)
             .overlay(alignment : .trailing) {
                 Button {
                     targetField = ""
                 } label: {
                     Image(systemName: "xmark.circle")
                 }
             }
     }
 }

 */
