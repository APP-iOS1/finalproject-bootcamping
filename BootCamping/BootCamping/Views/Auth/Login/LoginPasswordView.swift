//
//  LoginPasswordView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI
import AlertToast

struct LoginPasswordView: View {
    
    @State var userEmail: String = ""
    @State var password: String = ""
    
    
    @AppStorage("login") var isSignIn: Bool?
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore

    var trimUserEmail: String {
        userEmail.trimmingCharacters(in: .whitespaces)
    }
    
    var trimUserPassword: String {
        password.trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        VStack {
            
            emailTextField
            
            passwordTextField
            
            loginButton
            
            signUpButton
                .padding(.vertical, 10)
            
            Spacer()
        }
        .foregroundColor(.bcBlack)
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
        .padding(.vertical, 10)
        .alert("이메일, 비밀번호를 확인하세요", isPresented: $wholeAuthStore.isError) {
            Button("확인", role: .cancel) {
                wholeAuthStore.isError = false
            }
        }
        .toast(isPresenting: $wholeAuthStore.isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

extension LoginPasswordView {
    // 이메일 입력 필드
    var emailTextField: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray)
            .frame(width: UIScreen.screenWidth * 0.9, height: 44)
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
            .frame(width: UIScreen.screenWidth * 0.9, height: 44)
            .overlay {
                SecureField("비밀번호", text: $password)
                    .textCase(.lowercase)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
            }
    }
    
    // 최종 로그인 버튼 -> 수정필요(버튼)
    var loginButton: some View {
        Button {
            Task {
                wholeAuthStore.isProcessing = true
                wholeAuthStore.authSignInCombine(userEmail: userEmail, password: password)
            }
        } label: {
            Text("계속")
                .font(.headline)
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07)
                .foregroundColor(.white)
                .background(trimUserEmail.count == 0 || trimUserPassword.count == 0  ? Color.secondary : Color.bcGreen)
                .cornerRadius(10)
        }.disabled(trimUserEmail.count == 0 || trimUserPassword.count == 0 ? true : false)
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
        LoginPasswordView(userEmail: "")
    }
}
