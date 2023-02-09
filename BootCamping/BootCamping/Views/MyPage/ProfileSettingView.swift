//
//  ProfileSettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileSettingView: View {
    
    //이미지 피커
    @State private var imagePickerPresented = false // 이미지 피커를 띄울 변수
    @State private var selectedImage: UIImage?      // 이미지 피커에서 선택한 이미지저장. UIImage 타입
    @State private var profileImage: Data?          // selectedImage를 Data 타입으로 저장
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    @State private var updateNickname: String = ""
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: UIScreen.screenHeight * 0.03){
                HStack{
                    Spacer()
                    imagePicker
                    Spacer()
                }
                updateUserNameTextField
                    .padding(.bottom)
                editButton
            }
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
}

extension ProfileSettingView {
    
    // MARK: View: 이미지피커
    private var imagePicker: some View {
        Button(action: {
            imagePickerPresented.toggle()
        }, label: {
            let image = UIImage(data: profileImage ?? Data()) == nil ? UIImage(systemName: "person.fill") : UIImage(data: profileImage ?? Data()) ?? UIImage(systemName: "person.fill")
            Image(uiImage: (image ?? UIImage(systemName: "person.fill"))!)
                .resizable()
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .overlay{
                    ZStack{
                        Image(systemName: "circlebadge.fill")
                            .font(.largeTitle)
//                            .frame(width: 25, height: 25)
                            .foregroundColor(.primary)
                            .colorInvert()
                            .offset(x: 40, y: 40)
                        
                        Image(systemName: "pencil.circle")
                            .font(.title)
//                            .frame(width: 25, height: 25)
                            .foregroundColor(.bcBlack)
                            .offset(x: 40, y: 40)
                    }
                }
        })
        .sheet(isPresented: $imagePickerPresented,
               onDismiss: loadData,
               content: { ImagePicker(image: $selectedImage) })
    }
    // selectedImage: UIImage 타입을 Data타입으로 저장하는 함수
    func loadData() {
        guard let selectedImage = selectedImage else { return }
        profileImage = selectedImage.jpegData(compressionQuality: 0.8)
        
    }
    
    
    // MARK: -View : updateUserNameTextField
    private var updateUserNameTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("닉네임")
                .font(.title3)
                .bold()
            TextField("닉네임", text: $updateNickname,prompt: Text("\(wholeAuthStore.currnetUserInfo!.nickName)"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
    }
    
    
    // MARK: -View : editButton
    private var editButton : some View {
        Button {
            // TODO: UserInfo 수정하기
            wholeAuthStore.updateUserCombine(image: profileImage, user: User(id: wholeAuthStore.currnetUserInfo!.id, profileImageName: wholeAuthStore.currnetUserInfo!.profileImageName, profileImageURL: wholeAuthStore.currnetUserInfo!.profileImageURL, nickName: updateNickname, userEmail: wholeAuthStore.currnetUserInfo!.userEmail, bookMarkedDiaries: wholeAuthStore.currnetUserInfo!.bookMarkedDiaries, bookMarkedSpot: wholeAuthStore.currnetUserInfo!.bookMarkedSpot))
            dismiss()
        } label: {
            Text("수정")
                .modifier(GreenButtonModifier())
        }
        .disabled(updateNickname == "")
    }
    
}


//MARK: 이미지피커, 한 장 고르기
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var mode
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else { return }
            self.parent.image = image
            self.parent.mode.wrappedValue.dismiss()
        }
    }
}

//struct ProfileSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileSettingView(user: User(id: "", profileImageName: "", profileImageURL: "", nickName: "chasomin", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: []))
//            .environmentObject(WholeAuthStore())
//    }
//}
