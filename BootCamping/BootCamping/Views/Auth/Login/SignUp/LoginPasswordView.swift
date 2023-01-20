//
//  LoginPasswordView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI

struct LoginPasswordView: View {
    
    @EnvironmentObject var authStore: AuthStore
    var userEmail: String
    @State var password: String = ""
    @Binding var isSignIn: Bool
    
    var body: some View {
        VStack {
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
            Spacer()
        }
        .foregroundColor(Color("BCBlack"))
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
        .padding(.vertical, 10)
    }
}

struct LoginPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPasswordView(userEmail: "", isSignIn: .constant(true))
    }
}
