//
//  DiaryEditView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/12.
//

import SwiftUI
import Firebase

struct DiaryEditView: View {
    @FocusState var activeState: CurrentField?
    
    @State private var locationInfo: String = ""
    @State var diaryTitle: String
    @State var diaryIsPrivate: Bool
    @State var diaryContent: String
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @Environment(\.dismiss) private var dismiss
    
    //키보드 dismiss 변수
    @FocusState private var inputFocused: Bool
    
    @State var campingSpotItem: CampingSpot
    @State var campingSpot: String
    
    //텍스트필드 포커싱
    @Namespace var title
    @Namespace var content
    @Namespace var under
    @Namespace var bottom
    @Namespace var top
    @State var value: CGFloat = 0
    
    var item: UserInfoDiary
    
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
    @State var selectedDate: Date
    
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView{
                    VStack(alignment: .leading) {
                        Group {
                            addViewLocationInfo
                                .padding(.vertical, 10)
                                .id(top)
                            Divider()
                            
                            addViewVisitDate
                            Divider()
                            
                            addViewIsPrivate
                            Divider()
                        }
                        .font(.subheadline)
                        
                        TextField("제목을 입력해주세요(최대 20자)", text: $diaryTitle)
                            .font(.title3)
                            .padding(.vertical, 5)
                            .submitLabel(.next)
                            .onChange(of: diaryTitle) { newValue in             // 제목 20글자까지 가능
                                if newValue.count > 20 {
                                    diaryTitle = String(newValue.prefix(20))
                                }
                            }
                            .focused($inputFocused)
                            .onSubmit{
                                activeState = .field2
                            }
                            .onTapGesture {
                                withAnimation {
                                    proxy.scrollTo(title, anchor: .top)
                                }
                            }
                        Divider()
                        EmptyView()
                            .id(title)
                        
                        TextField("캠핑 노트를 작성해주세요", text: $diaryContent, axis: .vertical)
                            .frame(minHeight: UIScreen.screenHeight / 4, alignment: .top)
                            .lineLimit(10)
                            .focused($inputFocused)
                            .focused($activeState, equals: .field2)
                            .onChange(of: diaryContent.count, perform: { _ in
                                proxy.scrollTo(under, anchor: .bottom)
                            })

                        Text("").id(under)

                    }
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
            .padding(.horizontal, UIScreen.screenWidth*0.03)
            .navigationTitle(Text("캠핑 노트 쓰기"))
            .onTapGesture {
                dismissKeyboard()
            }
            .disableAutocorrection(true) //자동 수정 비활성화
            .textInputAutocapitalization(.never) //첫 글자 대문자 비활성화
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
                selectedDate = item.diary.diaryVisitedDate
                campingSpot = campingSpotItem.facltNm
                locationInfo = campingSpotItem.contentId
            }
        }

        
    }
}

extension DiaryEditView {
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
    

    //MARK: - 추가버튼
    var addViewAddButton: some View {
        HStack {
            Spacer()
            Button {
                diaryStore.isProcessing = true
                diaryStore.updateDiaryCombine(diary: Diary(id: item.diary.id, uid: item.diary.uid, diaryUserNickName: item.diary.diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: locationInfo, diaryContent: diaryContent, diaryImageNames: item.diary.diaryImageNames, diaryImageURLs: item.diary.diaryImageURLs, diaryCreatedDate: item.diary.diaryCreatedDate, diaryVisitedDate: selectedDate, diaryLike: item.diary.diaryLike, diaryIsPrivate: diaryIsPrivate))
                dismiss()
            } label: {
                Text(diaryTitle.isEmpty || diaryContent.isEmpty ? "내용을 작성해주세요" : "수정하기")
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
