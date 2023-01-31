//
//  LoginPasswordView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI

struct LoginPasswordView: View {
    
    @State var userEmail: String = ""
    @State var password: String = ""
    
    @Binding var isSignIn: Bool
    
    @EnvironmentObject var authStore: AuthStore
    
    var body: some View {
        VStack {
            
            emailTextField
            
            passwordTextField
            
            loginButton
            
            signUpButton
            
            Spacer()
        }
        .foregroundColor(.bcBlack)
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
        .padding(.vertical, 10)
    }
}

extension LoginPasswordView {
    // 이메일 입력 필드
    var emailTextField: some View {
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
    }
    
    // 비밀번호 입력 필드
    var passwordTextField: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray)
            .frame(width: UIScreen.screenWidth * 0.8, height: 44)
            .overlay {
                SecureField("비밀번호", text: $password)
                    .textCase(.lowercase)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
            }
    }
    
    // 최종 로그인 버튼
    var loginButton: some View {
        Button {
            Task {
                try await authStore.authSignIn(userEmail: userEmail, password: password)
                if authStore.isLogin {
                    isSignIn = true
                } else {
                    print("Login Failed")
                }
            }
        } label: {
            Text("계속")
                .modifier(GreenButtonModifier())
        }
    }
    
    var signUpButton: some View {
        NavigationLink {
            AuthSignUpView()
        } label: {
            Text("회원가입")
                .underline()
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct LoginPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPasswordView(userEmail: "", isSignIn: .constant(true))
    }
}
