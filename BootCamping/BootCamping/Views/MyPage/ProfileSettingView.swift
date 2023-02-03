//
//  ProfileSettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

// FIXME: 현재 기획한 UserInfo 데이터 모델에 따라서 텍스트 필드 변경 필요
/// 현재 기획 모델 그대로 가면 닉네임이랑 이메일, 비밀번호 변경하는 걸로 바꿔야 할 것 같습니다
struct ProfileSettingView: View {
    var user: User
//    @EnvironmentObject var authStore: AuthStore
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
//    @EnvironmentObject var kakaoAuthStore: KakaoAuthStore
    
    @State private var updateNickname: String = ""
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordCheck: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: UIScreen.screenHeight * 0.03){
                HStack{
                    Spacer()
                    photoPicker
                    Spacer()
                }
                updateUserNameTextField
                updatePasswordTextField
                    .padding(.bottom)
                ///이러면 또 질문이 있는데 14pro에서 키보드 올리면 키보드 위에 그린버튼이 살짝 걸치거든용, 키보드 치다가 그린버튼 눌려서 빡치는 상황이 나올수도 있겠다 싶네용...
                editButton
                
                
            }
        }
        
        //        .padding(.vertical, UIScreen.screenHeight * 0.05)
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
    }
    
}

extension ProfileSettingView {
    // MARK: -View : PhotoPicker
    private var photoPicker : some View {
        VStack{
            ZStack{
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                }
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        ZStack{
                            Image(systemName: "circlebadge.fill")
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                                .colorInvert()
                                .offset(x: 40, y: 40)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "pencil.circle")
                                .font(.title)
                                .foregroundColor(.bcBlack)
                                .offset(x: 40, y: 40)
                                .frame(width: 100, height: 100)
                            
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset in the form of Data
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: -View : updateUserNameTextField
    private var updateUserNameTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("닉네임")
                .font(.title3)
                .bold()
            TextField("닉네임", text: $updateNickname,prompt: Text("\(user.nickName)"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
    }
    
    //MARK: -View: 비밀번호 수정
    private var updatePasswordTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("비밀번호")
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
    }

}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView(user: User(id: "", profileImage: "", nickName: "chasomin", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: []))
    }
}
