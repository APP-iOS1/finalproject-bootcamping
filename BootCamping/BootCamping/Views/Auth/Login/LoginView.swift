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
import AuthenticationServices


struct LoginView: View {
    @AppStorage("login") var isSignIn: Bool?
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var kakaoAuthStore: KakaoAuthStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bcGreen
                VStack(spacing: 10) {
                    
                    Spacer()
                    
                    loginIcon
                    
                    Spacer()
                    
                    appleLoginButton
                    
                    kakaoLoginButton
                    
                    googleLoginButton
                    
                    emailSignUpButton
                        .padding(.vertical, UIScreen.screenHeight * 0.05)
                    
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
            wholeAuthStore.kakaoLogInCombine()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.yellow)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "message.fill").padding(.trailing, -12)
                        Text("  카카오로 로그인하기")
                        Spacer()
                    }
                }
        }

    }
    
    // 구글 로그인 버튼
    var googleLoginButton: some View {
        Button {
            wholeAuthStore.googleSignIn()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "g.circle.fill").padding(.trailing, -5)
                        Text("Google로 로그인하기")
                        Spacer()
                    }
                }
        }
    }
    
    // 애플 로그인 버튼
    var appleLoginButton: some View {
        SignInWithAppleButton { (request) in
            // requesting paramertes from apple login...
            wholeAuthStore.nonce = randomNonceString()
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(wholeAuthStore.nonce)
        } onCompletion: { (result) in
            switch result {
            case .success(let user):
                print("success")
                // do login with firebase...
                guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                    print("error with firebase")
                    return
                }
                wholeAuthStore.appleLogin(credential: credential)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: 44)
        .cornerRadius(10)
    }
    
    // 이메일로 회원가입 버튼
    var emailSignUpButton: some View {
        NavigationLink {
            LoginPasswordView()
        } label: {
            Text("이메일로 로그인  |  회원가입")
                .underline()
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthStore())
    }
}
