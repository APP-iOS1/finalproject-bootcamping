//
//  LoginView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser
import SwiftUI

struct LoginView: View {
    @Binding var isSignIn: Bool
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var kakaoAuthStore: KakaoAuthStore
    
    @Environment(\.window) var window: UIWindow?
    @State private var appleLoginCoordinator: AppleAuthCoordinator?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bcGreen
                VStack(spacing: 10) {
                    
                    Spacer()
                    
                    loginIcon
                    
                    Spacer()
                    
                    kakaoLoginButton
                    
                    googleLoginButton
                    
                    appleLoginButton
                    
                    emailSignUpButton
                        .padding(.vertical, 10)
                    
                }
                .foregroundColor(.black)
                .padding(UIScreen.screenWidth * 0.05)
            }.ignoresSafeArea()
        }
    }
}

extension LoginView {
    
    // 로그인 아이콘 및 앱 이름
    var loginIcon: some View {
        VStack {
            Image("loginImg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
            Image("loginName")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
    }
    
    // 카카오 로그인 버튼
    var kakaoLoginButton: some View {
        Button {
            kakaoAuthStore.handleKakaoLogin()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.yellow)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "message.fill")
                        Text("  카카오로 로그인하기")
                        Spacer()
                    }
                }
        }
    }
    
    // 구글 로그인 버튼
    var googleLoginButton: some View {
        Button {
            authStore.googleSignIn()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "g.circle.fill")
                        Text("Google로 로그인하기")
                        Spacer()
                    }
                }
        }
    }
    
    // 애플 로그인 버튼
    var appleLoginButton: some View {
        Button {
            appleLogin()
            
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.black)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "applelogo")
                        Text("  Apple로 로그인하기")
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
        }
    }
    //애풀 로그인 함수
    func appleLogin() {
      appleLoginCoordinator = AppleAuthCoordinator(window: window)
      appleLoginCoordinator?.startAppleLogin()
    }
    
    // 이메일로 회원가입 버튼
    var emailSignUpButton: some View {
        NavigationLink {
            LoginPasswordView(isSignIn: $isSignIn)
        } label: {
            Text("이메일로 로그인 | 회원가입")
                .underline()
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isSignIn: .constant(true))
            .environmentObject(AuthStore())
    }
}
