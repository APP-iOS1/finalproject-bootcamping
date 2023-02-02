//
//  DiaryAddView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import PhotosUI
import Firebase

struct DiaryAddView: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Data]()
    @State private var diaryTitle: String = ""
    @State private var locationInfo: String = ""
    @State private var visitDate: String = ""
    @State private var diaryIsPrivate: Bool = false //false가 공개
    @State private var diaryContent: String = ""
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss
    
    //키보드 dismiss 변수
    @FocusState private var inputFocused: Bool
    
    //TODO: - 닉네임 안대여..고치기
    //글 작성 유저 닉네임 변수
    var userNickName: String? {
        get {
            for user in authStore.userList {
                if user.id == Auth.auth().currentUser?.uid {
                    return user.nickName
                }
            }
            return nil
        }
    }
    
    //MARK: - DatePicker 변수
    @State private var selectedDate: Date = .now
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    photoPicker
                    addViewTitle
                    addViewLocationInfo
                    addViewVisitDate
                    addViewIsPrivate
                    Divider()
                    addViewDiaryContent
                    addViewAddButton
                }
                
            }
            //MARK: - 키보드 옵션입니다.
            .disableAutocorrection(true) //자동 수정 비활성화
            .textInputAutocapitalization(.never) //첫 글자 대문자 비활성화
            .submitLabel(.done) //작성 완료하면 키보드 return 버튼이 파란색 done으로 바뀜
        .onSubmit(of: .text, submit)
        .padding(.horizontal, UIScreen.screenWidth*0.1)
        } //done 누르면 submit 함수가 실행됨
    }
}


private extension DiaryAddView {
    //MARK: - 포토 피커
    var photoPicker: some View {
            HStack {
                VStack{
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .any(of: [.images, .not(.videos)])) {
                            ZStack {
                                Image(systemName: "plus")
                                VStack{
                                    Spacer()
                                    Text("\(selectedImages.count) / 10")
                                        .padding(.bottom, 5)
                                }
                            }
                            .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(.gray, lineWidth: 2)
                            }
                        }
                        .onChange(of: selectedItems) { newValue in
                            Task {
                                selectedItems = []
                                for value in newValue {
                                    if let imageData = try? await value.loadTransferable(type: Data.self) {
                                        selectedImages.append(imageData)
                                    }
                                }
                            }
                        }
                }

                Text(selectedImages.isEmpty ? "사진을 추가해주세요" : "")
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                    .padding(.leading, UIScreen.screenWidth * 0.05)
                
                if selectedImages.count > 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: UIImage(data: image)!)
                                    .resizable()
                                    .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                            }
                        }
                    }
                }
                
            }
            .padding()
        
    }
    
    //MARK: - 제목 작성
    var addViewTitle: some View {
        Section {
            TextField("제목을 입력해주세요(최대 10자)", text: $diaryTitle)
                .padding(6)
                .background {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(.gray, lineWidth: 2)
                }
                .padding(.horizontal)
                .padding(.bottom)
        } header: {
            Text("제목")
                .padding(.horizontal)
        }
        .focused($inputFocused)
    }
    
    //MARK: - 위치 등록하기
    //TODO: - 캠핑장 연동하기
    var addViewLocationInfo: some View {
        Section {
            TextField("위치를 등록해주세요", text: $locationInfo)
                .padding(6)
                .background {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(.gray, lineWidth: 2)
                }
                .padding(.horizontal)
                .padding(.bottom)
        } header: {
            Text("위치 등록하기")
                .padding(.horizontal)
        }
        .focused($inputFocused)
    }
    
    //MARK: - 방문일자 등록하기
    var addViewVisitDate: some View {
        Section {
            DatePicker("방문일자 등록하기",
                       selection: $selectedDate,
                       displayedComponents: [.date])
//            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    //MARK: - 글 공개 여부
    var addViewIsPrivate: some View {
        HStack {
            Text("공개설정")
            Spacer()
            Button {
                diaryIsPrivate.toggle()
            } label: {
                VStack {
                    Image(systemName: diaryIsPrivate ? "lock" : "lock.open" )
                    Text(diaryIsPrivate ? "비공개": "공개")
                }
            }
            .foregroundColor(.bcBlack)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    //MARK: - 일기 작성 뷰
    var addViewDiaryContent: some View {
        ZStack {
            TextEditor(text: $diaryContent)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 180)
                .focused($inputFocused)
            Text(diaryContent == "" ? "일기를 작성해주세요" : "")
                .foregroundColor(.secondary)
                .opacity(0.5)
                .position(x: 73, y: 19)
        }
        .padding()
    }

    //MARK: - 추가버튼
    //TODO: - disable 시 회색버튼으로 만들기
    var addViewAddButton: some View {
        HStack {
            Spacer()
            Button {
                diaryStore.createDiaryCombine(diary: Diary(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid ?? "", diaryUserNickName: userNickName ?? "닉네임", diaryTitle: diaryTitle, diaryAddress: locationInfo, diaryContent: diaryContent, diaryImageNames: [], diaryImageURLs: [], diaryCreatedDate: Timestamp(), diaryVisitedDate: selectedDate, diaryLike: "", diaryIsPrivate: diaryIsPrivate), images: selectedImages)
                dismiss()
            } label: {
                Text("일기 작성하기")
            }
            .modifier(GreenButtonModifier())
            .disabled(selectedImages.isEmpty)
            Spacer()
        }
    }

    //MARK: - 키보드 dismiss 함수입니다.
    func submit() {
        resignKeyboard()
    }
    //iOS 15 아래버전은 유킷연동 함수 사용
    func resignKeyboard() {
        if #available(iOS 15, *) {
            inputFocused = false
        } else {
            dismissKeyboard()
        }
    }
}
//MARK: - 키보드 dismiss extension함수입니다.
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DiaryAddView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryAddView()
            .environmentObject(AuthStore())
            .environmentObject(DiaryStore())
    }
}
