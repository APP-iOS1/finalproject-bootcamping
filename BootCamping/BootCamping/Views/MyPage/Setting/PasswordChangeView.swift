//
//  PasswordChangeView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/06.
//

import SwiftUI

struct PasswordChangeView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordCheck: String = ""
    
    var body: some View {
        VStack{
            passwordTextField
                .padding(.bottom)
            editButton
            Spacer()
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)

    }
}

extension PasswordChangeView {
    // MARK: -View : 현재 비밀번호, 새로운 비밀번호 입력 필드
    private var passwordTextField: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("비밀번호 재설정")
                .font(.title3)
                .bold()
            SecureField("비밀번호", text: $currentPassword, prompt: Text("현재 비밀번호를 입력해주세요"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("비밀번호", text: $newPassword,prompt: Text("새로운 비밀번호를 입력해주세요"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("비밀번호", text: $newPasswordCheck,prompt: Text("새로운 비밀번호를 다시 입력해주세요"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)

            Text("* 영어 + 숫자 + 특수문자 최소 8자 이상")
                .font(.footnote).foregroundColor(.secondary)
        }
    }
    
    // MARK: -View : editButton
    private var editButton : some View {
        Button {
            // TODO: UserInfo 수정하기
            
        } label: {
            Text("수정")
                .modifier(GreenButtonModifier())
        }
        .disabled(currentPassword == "" || newPassword == "" || newPasswordCheck == "")
    }
}

struct PasswordChangeView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangeView()
    }
}
