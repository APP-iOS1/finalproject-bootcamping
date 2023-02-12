//
//  DiaryAddView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import PhotosUI
import Firebase
import Photos

// 키보드 다음 버튼 눌렀을 때 다음 텍스트 필드로 넘어가기 위해 필요해요
enum CurrentField{
    case field1
    case field2
}

struct DiaryAddView: View {
    
    @State var field1 = ""
    @State var field2 = ""
    @FocusState var activeState: CurrentField?
    
    // 탭 했을 때 작성하기 버튼 숨기기 위해서
    @State var isTapTextField = false
    
    @State private var diaryTitle: String = ""
    @State private var locationInfo: String = ""
    @State private var visitDate: String = ""
    @State private var diaryIsPrivate: Bool = false //false가 공개
    @State private var diaryContent: String = ""
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @Environment(\.dismiss) private var dismiss
    
    //키보드 dismiss 변수
    @FocusState private var inputFocused: Bool
    
    @State private var campingSpotItem: Item = CampingSpotStore().campingSpot
    @State private var campingSpot: String = ""
    
    //글 작성 유저 닉네임 변수
    var userNickName: String? {
        get {
            for user in wholeAuthStore.userList {
                if user.id == Auth.auth().currentUser?.uid {
                    return user.nickName
                }
            }
            return nil
        }
    }
    
    //MARK: - DatePicker 변수
    @State private var selectedDate: Date = .now
    
    //이미지 피커
    @State private var imagePickerPresented = false // 이미지 피커를 띄울 변수
    @State private var selectedImages: [PhotosPickerItem] = []   // 이미지 피커에서 선택한 이미지저장.
    @State private var diaryImages: [Data] = []         // selectedImages를 [Data] 타입으로 저장
    
    var images: [UIImage] = [UIImage()]
    
    var body: some View {
        VStack {
            ScrollView{
                VStack(alignment: .leading) {
                    imagePicker
                    Divider()
                    addViewLocationInfo
                    Divider()
                    
                    addViewVisitDate
                    Divider()
                    
                    addViewIsPrivate
                    Divider()
                    
                    Group{
                        addViewTitle
                        addViewDiaryContent
                        Spacer()
                    }
                    addViewAddButton
                }
            }
        }
        .padding(.horizontal, UIScreen.screenWidth*0.03)
        .navigationTitle(Text("캠핑 일기 쓰기"))
        .onTapGesture {
            dismissKeyboard()
        }
        .disableAutocorrection(true) //자동 수정 비활성화
        .textInputAutocapitalization(.never) //첫 글자 대문자 비활성화
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    submit()
                    isTapTextField = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .task {
            campingSpot = campingSpotItem.facltNm
            locationInfo = campingSpotItem.contentId
        }
    }
}


private extension DiaryAddView {
    
    //MARK: 이미지 피커
    private var imagePicker: some View {
        HStack(alignment:.top){
            VStack{
                PhotosPicker(
                    selection: $selectedImages,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .not(.videos)])) {
                        Image(systemName: "plus")
                            .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                            .background {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .stroke(.gray, lineWidth: 1)
                            }
                            .padding(UIScreen.screenWidth * 0.005)
                        
                    }
                    .onChange(of: selectedImages) { newValue in
                        Task {
                            diaryImages = []
                            for value in newValue {
                                if let imageData = try? await value.loadTransferable(type: Data.self) {
                                    diaryImages.append(imageData)
                                }
                            }
                        }
                    }
                
                Text("\(diaryImages.count) / 10")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    if diaryImages == [] {
                        Text(diaryImages.isEmpty ? "사진을 추가해주세요" : "")
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                            .frame(height: UIScreen.screenWidth * 0.2)
                            .padding(.leading, UIScreen.screenWidth * 0.05)
                        
                    } else{
                        ForEach(Array(zip(0..<(diaryImages.count), diaryImages)), id: \.0) { index, image in
                            Image(uiImage: UIImage(data: image)!)
                                .resizeImageData(data: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                                .clipped()
                                .overlay(alignment: .topLeading) {
                                    VStack {
                                        Text("대표 이미지")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color.bcGreen)
                                                    .padding(-0.5)
                                                
                                            )
                                            .padding(2.5)
                                    }
                                    .opacity(index == 0 ? 1 : 0)
                                }
                        }
                    }
                }
                .padding(.vertical ,UIScreen.screenWidth * 0.005)
            }
        }
        
        .padding(.vertical)
    }
    
    
    //MARK: - 위치 등록하기
    //TODO: - 캠핑장 연동하기
    var addViewLocationInfo: some View {
        VStack {
            if campingSpot == "" {
                NavigationLink {
                    SearchByCampingSpotNameView(campingSpot: $campingSpotItem)
                } label: {
                    HStack{
                        Text("방문한 캠핑장 등록하러 가기")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.padding(.vertical)
                }
                .focused($inputFocused)
            } else {
                HStack {
                    Text("\(campingSpot)")
                        .lineLimit(1)
                    Spacer()
                    Button {
                        campingSpot = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.bcBlack)
                    }
                }
            }
        }
    }
    
    //MARK: - 방문일자 등록하기
    var addViewVisitDate: some View {
        Section {
            DatePicker("방문일자 등록하기",
                       selection: $selectedDate,
                       displayedComponents: [.date])
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .environment(\.calendar, Calendar(identifier: .gregorian))
            .environment(\.timeZone, TimeZone(abbreviation: "KST")!)
            .padding(.vertical)
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
                        .animation(.none)
                        .padding(.trailing, diaryIsPrivate ? 1.5 : 0)
                        .opacity(0)
                    
                    
                    Text(diaryIsPrivate ? "비공개": "공개")
                        .animation(.none)
                        .font(.caption2)
                        .padding(.trailing, diaryIsPrivate ? 0 : 5)
                    
                }
                
            }
            .foregroundColor(.bcBlack)
            .overlay{
                Image(systemName: diaryIsPrivate ? "lock" : "lock.open" )
                    .animation(.none)
                    .padding(.trailing, diaryIsPrivate ? 1.5 : 0)
                    .padding(.bottom, 15)
            }
        }
        .padding(.vertical)
        
    }
    
    // MARK: 제목
    var addViewTitle: some View {
        Section {
            TextField("제목을 입력해주세요(최대 20자)", text: $diaryTitle)
                .font(.title3)
                .padding(.vertical)
                .submitLabel(.next)
                .onChange(of: diaryTitle) { newValue in             // 제목 20글자까지 가능
                    if newValue.count > 20 {
                        diaryTitle = String(newValue.prefix(20))
                    }
                }
        }
        .focused($inputFocused)
        .onSubmit{
            activeState = .field2
        }
        .onTapGesture {
            isTapTextField = true
        }
    }
    
    //MARK: - 일기 작성 뷰
    var addViewDiaryContent: some View {
        VStack {
            
            TextField("일기를 작성해주세요", text: $diaryContent, axis: .vertical)
                .focused($inputFocused)
                .onTapGesture {
                    isTapTextField = true
                }
                .focused($activeState, equals: .field2)
        }
    }

    
    //MARK: - 추가버튼
    var addViewAddButton: some View {
        HStack {
            Spacer()
            Button {
                diaryStore.createDiaryCombine(diary: Diary(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid ?? "", diaryUserNickName: userNickName ?? "닉네임", diaryTitle: diaryTitle, diaryAddress: locationInfo, diaryContent: diaryContent, diaryImageNames: [], diaryImageURLs: [], diaryCreatedDate: Timestamp(), diaryVisitedDate: selectedDate, diaryLike: [], diaryIsPrivate: diaryIsPrivate), images: diaryImages)
            } label: {
                Text(diaryTitle.isEmpty || diaryContent.isEmpty ? "내용을 작성해주세요" : "일기 쓰기")
                    .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07) // 이거 밖에 있으면 글씨 부분만 버튼 적용됨
            }
            .font(.headline)
            .foregroundColor(.white)
            .background(diaryTitle.isEmpty || diaryContent.isEmpty ? .secondary : Color.bcGreen)
            .cornerRadius(10)
            .disabled(diaryTitle.isEmpty || diaryContent.isEmpty)
            Spacer()
            
        }
        .padding(.bottom, 10)
        
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


struct DiaryAddView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryAddView()
            .environmentObject(WholeAuthStore())
            .environmentObject(DiaryStore())
        
        DiaryAddView()
            .environmentObject(WholeAuthStore())
            .environmentObject(DiaryStore())
            .previewDevice("iPhone 11")
        DiaryAddView()
            .environmentObject(WholeAuthStore())
            .environmentObject(DiaryStore())
            .previewDevice("iPhone SE (3rd generation)")
    }
}
