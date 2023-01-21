//
//  LoginView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser


struct LoginView: View {
    
    @State var userEmail: String = ""
    @State private var isLogin: Bool = true
    
    @Binding var isSignIn: Bool
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var kakaoAuthStore: KakaoAuthStore
    
    var body: some View {
        NavigationStack {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
                    .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                    .overlay {
                        TextField("이메일", text: $userEmail)
                            .textCase(.lowercase)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding()
                        
                    }
                signInAndSignUpButton
                
                Divider().padding(.horizontal, UIScreen.screenWidth * 0.05).padding(.vertical, 10)
                
                kakaoLoginButton
                
                googleLoginButton
                
                appleLoginButton
                Spacer()
            }
            .foregroundColor(Color("BCBlack"))
            .padding()
            .task {
                Task {
                    isLogin = try await authStore.checkUserEmailDuplicated(userEmail: userEmail)
                }
            }
        }
    }
    
    // 로그인 혹은 회원가입 버튼
    /// 이메일 체크 후 중복 시 로그인 페이지로
    /// 이메일 체크 후 중복 없을 시 회원가입 페이지로
    var signInAndSignUpButton: some View {
        NavigationLink {
            if isLogin {
                AuthSignUpView(userEmail: userEmail)
            } else {
                LoginPasswordView(userEmail: userEmail, isSignIn: $isSignIn)
            }
        } label: {
            Text("계속")
                .modifier(GreenButtonModifier())
        }
    }
    
    // 카카오 로그인 버튼
    var kakaoLoginButton: some View {
        Button {
            kakaoAuthStore.handleKakaoLogin()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                .overlay {
                    Text("카카오로 로그인하기")
                }
        }
    }
    
    // 구글 로그인 버튼
    var googleLoginButton: some View {
        Button {
            authStore.googleSignIn()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                .overlay {
                    Text("Google로 로그인하기")
                }
        }
    }
    
    // 애플 로그인 버튼
    var appleLoginButton: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.black)
                .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                .overlay {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Apple로 로그인하기")
                    }
                    .foregroundColor(.white)
                }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isSignIn: .constant(true))
            .environmentObject(AuthStore())
    }
}
