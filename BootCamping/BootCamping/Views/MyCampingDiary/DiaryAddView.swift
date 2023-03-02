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
import AlertToast


// 키보드 다음 버튼 눌렀을 때 다음 텍스트 필드로 넘어가기 위해 필요해요
enum CurrentField{
    case field2
}

struct DiaryAddView: View {
    // 대표 이미지 말고 다른 이미지들도 보는 버튼 bool 값
    @State var isImageView = false
    
    // 키보드 다음 버튼 눌렀을 때 다음 텍스트 필드로 넘어가기 위해 필요해요
    @FocusState var activeState: CurrentField?
    
    // 탭 했을 때 작성하기 버튼 숨기기 위해서
//    @State var isTapTextField = false
    
    @State private var diaryTitle: String = ""
    @State private var locationInfo: String = ""
    @State private var diaryIsPrivate: Bool = false //false가 공개
    @State private var diaryContent: String = ""
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @Environment(\.dismiss) private var dismiss
    
    //키보드 dismiss 변수
    @FocusState private var inputFocused: Bool
    
    @State private var campingSpotItem: Item = CampingSpotStore().campingSpot
    
    // 캠핑 스팟을 골랐을 때, 안 골랐을 때 뷰 다르게 그림.
    @State private var campingSpot: String = ""
    
    //MARK: - DatePicker 변수
    @State private var selectedDate: Date = .now
    
    //이미지 피커
    @State private var selectedImages: [PhotosPickerItem] = []   // 이미지 피커에서 선택한 이미지저장.
    @State private var diaryImages: [Data] = []                  // selectedImages를 [Data] 타입으로 저장
    
    @State private var isProcessing: Bool = false
    
    //텍스트필드 포커싱
    @Namespace var title
    @Namespace var content
    @Namespace var under
    @Namespace var bottom
    @Namespace var top
    @State var value: CGFloat = 0
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                VStack {
                    ScrollView{
                        VStack(alignment: .leading) {
                            Group {
                                imagePicker.id(top)
                                Divider()
                                addViewLocationInfo
                                    .padding(.vertical, 10)
                                Divider()
                                
                                addViewVisitDate
                                Divider()
                                
                                addViewIsPrivate
                                Divider()
                                    .padding(.bottom, 10)
                            }
                            .font(.subheadline)
                            
                            // 제목
                            TextField("제목을 입력해주세요(최대 20자)", text: $diaryTitle)
                                .font(.headline)
                                .padding(.vertical, 5)
                                .submitLabel(.next)
                                .onChange(of: diaryTitle) { newValue in             // 제목 20글자까지 가능
                                    if newValue.count > 20 {
                                        diaryTitle = String(newValue.prefix(20))
                                    }
                                }
                                .focused($inputFocused)
                                .onSubmit{
                                    activeState = .field2   // 키보드 다음 버튼 누르면 다음 텍스트필드로 이동
                                    proxy.scrollTo(under, anchor: .bottom)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo(title, anchor: .bottom)
                                    }
                                }
                            
                            Divider()
                            EmptyView()
                                .id(title)
                            
                            // 일기 내용
                            TextField("일기를 작성해주세요", text: $diaryContent, axis: .vertical)
                                .frame(minHeight: UIScreen.screenHeight / 4, alignment: .top)
                                .lineLimit(10)
                                .focused($inputFocused)
                                .focused($activeState, equals: .field2)
                                .onChange(of: diaryContent.count, perform: { _ in
                                    proxy.scrollTo(under, anchor: .bottom)
                                })
                            
                            
                            Text("").id(under)
                            
                        }
                        .padding(.horizontal, UIScreen.screenWidth*0.03)
                    }
                    
                    
                    if inputFocused == false {
                        withAnimation {
                            addViewAddButton
                                .id(bottom)
                        }
                    }
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName:UIResponder.keyboardWillShowNotification,object:
                                                            nil, queue: .main) { (noti) in
                        let value = noti.userInfo! [UIResponder .keyboardFrameEndUserInfoKey] as! CGRect
                        let height = value.height
                        self.value = height
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object:
                                                            nil, queue: .main) { (noti) in
                        self.value = 0
                    }
                }
                
                .navigationTitle(Text("캠핑 일기 쓰기"))
                .onTapGesture {
                    inputFocused = false
                }
                .disableAutocorrection(true)            // 자동 수정 비활성화
                .textInputAutocapitalization(.never)    // 첫 글자 대문자 비활성화
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            submit()                // 키보드 내림
                            inputFocused = false    // 작성완료 버튼 나옴
                            proxy.scrollTo(top, anchor: .top)
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
            isProcessing ? Color.black.opacity(0.3) : Color.clear
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .sheet(isPresented: $isImageView) { // 대표이미지 말고 다른 이미지도 볼 수 있는 시트
            DiaryAddDetailImageView(diaryImages: $diaryImages, isImageView: $isImageView)
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
                            isProcessing = true
                            diaryImages = []    // 사진 다시 고를 경우 기존에 있는 거 비워줌
                            for value in newValue {
                                if let imageData = try? await value.loadTransferable(type: Data.self) {
                                    let uiImage = UIImage(data: imageData)
                                    diaryImages.append((uiImage?.jpegData(compressionQuality: 0.1))!)
                                }
                            }
                            isProcessing = false
                        }
                    }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    if diaryImages == [] {  // 사진을 안 골랐을 경우
                        Text(diaryImages.isEmpty ? "사진을 추가해주세요 (최대 10장)" : "")
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                            .frame(height: UIScreen.screenWidth * 0.2)
                            .padding(.leading, UIScreen.screenWidth * 0.05)
                        
                    } else {                // 사진 고른 경우
                        Button {
                            isImageView = true  // 버튼 누르면 사진 여러장 볼 수 있음
                        } label: {
                            Image(uiImage: UIImage(data: diaryImages.first!)!) // 대표이미지
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                                .clipped()
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "hand.tap")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.bcGreen)
                                                .padding(-0.5)
                                        )
                                        .padding(2.5)
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
    var addViewLocationInfo: some View {
        VStack {
            if campingSpot == "" {
                NavigationLink {
                    SearchByCampingSpotNameView(campingSpot: $campingSpotItem)
                } label: {
                    HStack{
                        Text("방문한 캠핑장 등록하러 가기")
                            .foregroundColor(.bcBlack)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.bcBlack)
                    }
                }
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
        }
    }
    
    //MARK: - 글 공개 여부
    var addViewIsPrivate: some View {
        HStack {
            Text("공개설정")
            Spacer()
            Button {
                diaryIsPrivate.toggle()
                //탭틱
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } label: {
                VStack {
                    Image(systemName: diaryIsPrivate ? "lock" : "lock.open" )
                        .animation(.none)
                        .padding(.trailing, diaryIsPrivate ? 1.5 : 0)
                        .opacity(0) // 투명하게 만들고 overlay로 덮었음
                        // 안그러면 계속 약간 애니메이션 걸려있움 ;;;;;
                    
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
    }
    
    //MARK: - 추가버튼
    var addViewAddButton: some View {
        HStack {
            Spacer()
            Button {
                diaryStore.isProcessing = true
                diaryStore.createDiaryCombine(diary: Diary(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid ?? "", diaryUserNickName: wholeAuthStore.currnetUserInfo?.nickName ?? "BootCamper", diaryTitle: diaryTitle, diaryAddress: locationInfo, diaryContent: diaryContent, diaryImageNames: [], diaryImageURLs: [], diaryCreatedDate: Timestamp(), diaryVisitedDate: selectedDate, diaryLike: [], diaryIsPrivate: diaryIsPrivate), images: diaryImages)
                //탭틱
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                dismiss()
            } label: {
                Text(diaryTitle.isEmpty || diaryContent.isEmpty ? "내용을 작성해주세요" : "일기 쓰기")
                    .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07) // 이거 밖에 있으면 글씨 부분만 버튼 적용됨
            }
            .font(.headline)
            .foregroundColor(.white)
            .background(diaryTitle.isEmpty || diaryContent.isEmpty || diaryImages.isEmpty ? .secondary : Color.bcGreen)
            .cornerRadius(10)
            .disabled(diaryTitle.isEmpty || diaryContent.isEmpty || diaryImages.isEmpty)
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
