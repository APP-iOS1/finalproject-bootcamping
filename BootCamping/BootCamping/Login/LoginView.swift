//
//  LoginView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @State var userEmail: String = ""
    
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
                NavigationLink {
                    if authStore.testFunc(test: userEmail) != "" {
                        LoginPasswordView(userEmail: userEmail)
                    } else {
                        AuthSignUpView(userEmail: userEmail)
                    }
                } label: {
                    Text("계속")
                        .modifier(GreenButtonModifier())
                }
                
                Divider()
                    .padding(.horizontal, UIScreen.screenWidth * 0.05)
                    .padding(.vertical, 10)
                
                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                        .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                        .overlay {
                            Text("카카오로 로그인하기")
                        }
                }
                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                        .frame(width: UIScreen.screenWidth * 0.8, height: 44)
                        .overlay {
                            Text("Google로 로그인하기")
                        }
                }
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
                Spacer()
            }
            .foregroundColor(Color("BCBlack"))
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthStore())
    }
}
