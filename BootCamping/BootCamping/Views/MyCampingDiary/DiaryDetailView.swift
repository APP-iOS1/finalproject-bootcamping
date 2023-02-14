//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import Firebase
import FirebaseAnalytics
import SDWebImageSwiftUI
import Introspect
import AlertToast

enum ReportState {
    case alreadyReported
    case notReported
    case nowReported
}

struct DiaryDetailView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore
    @EnvironmentObject var reportStore: ReportStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    @StateObject var scrollViewHelper: ScrollViewHelper = ScrollViewHelper()
    
    var diaryCampingSpot: [Item] {
        get {
            return campingSpotStore.campingSpotList.filter{
                $0.contentId == item.diary.diaryAddress
            }
        }
    }
    
    @State private var diaryComment: String = ""
    
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingConfirmationDialog = false
    @State private var isShowingUserReportAlert = false
    @State private var isShowingUserBlockedAlert = false
    
    @State private var reportState = ReportState.notReported
    @State private var isShowingAcceptedToast = false
    @State private var isBlocked = false
    
    //자동 스크롤
    @Namespace var topID
    @Namespace var bottomID
    
    //키보드 dismiss
    @FocusState private var inputFocused: Bool
    
    var item: UserInfoDiary
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading) {
                        diaryUserProfile.id(topID)
                        diaryDetailImage.zIndex(1) 
                        Group {
                            HStack(alignment: .center){
                                if (item.diary.uid == wholeAuthStore.currnetUserInfo!.id && item.diary.diaryIsPrivate) {
                                    isPrivateImage
                                }
                                diaryDetailTitle
                            }
                            diaryDetailContent
                            if !campingSpotStore.campingSpotList.isEmpty {
                                diaryCampingLink
                            }
                            Divider().padding(.top, 5)
                            
                            diaryDetailInfo
                            
                            Divider()
                            //댓글
                            ForEach(commentStore.commentList) { comment in
                                DiaryCommentCellView(commentStore: commentStore, scrollViewHelper: scrollViewHelper, item2: item, item: comment)
                            }
                        }
                        .padding(.horizontal, UIScreen.screenWidth * 0.03)
                        //댓글 작성시 뷰 가장 아래로
                        EmptyView()
                            .frame(height: 0.1)
                            .id(bottomID)
                        Spacer()
                    }
                   
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(topID)
                        }
                    }
                }.introspectScrollView(customize: { uiScrollView in
                    uiScrollView.delegate = scrollViewHelper
                })
                .padding(.bottom, 0.1)

                 HStack {
                    if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
                        WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                    } else {
                        Image("defaultProfileImage")
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                    TextField("댓글을 입력해 주세요.", text: $diaryComment, axis: .vertical)
                        .focused($inputFocused)
                        .font(.callout)
                        .onTapGesture {
                            withAnimation {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }

                    Button {
                        commentStore.createCommentCombine(diaryId: item.diary.id, comment: Comment(id: UUID().uuidString, diaryId: item.diary.id, uid: wholeAuthStore.currnetUserInfo?.id ?? "" , nickName: wholeAuthStore.currnetUserInfo?.nickName ?? "", profileImage: wholeAuthStore.currnetUserInfo?.profileImageURL ?? "", commentContent: diaryComment, commentCreatedDate: Timestamp()))
                        commentStore.readCommentsCombine(diaryId: item.diary.id)
                        withAnimation {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                        }
                        
                        diaryComment = ""
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.title3)
                            .foregroundColor(Color.bcDarkGray)
                    }
                    .disabled(diaryComment == "")
                    
                }
                .foregroundColor(.bcDarkGray)
                .padding(.vertical, 1)
                .padding(.horizontal, UIScreen.screenWidth * 0.03)
                
            }
            .toast(isPresenting: $isShowingAcceptedToast) {
                AlertToast(type: .regular, title: "이 게시물에 대한 신고가 접수되었습니다.")
            }
            .sheet(isPresented: $isShowingUserReportAlert) {
                if reportState == .alreadyReported {
                    WaitingView()
                        .presentationDetents([.fraction(0.3), .medium])
                } else {
                    ReportView(reportState: $reportState, reportedDiaryId: item.diary.id)
                    // 예를 들어 다음은 화면의 아래쪽 50%를 차지하는 시트를 만듭니다.
                        .presentationDetents([.fraction(0.5), .medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(.top)
            .padding(.bottom)
            .navigationTitle("BOOTCAMPING")
            .onAppear{
                commentStore.readCommentsCombine(diaryId: item.diary.id)
                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
                diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
                reportState = (reportStore.reportedDiaries.filter{ reportedDiary in reportedDiary.reportedDiaryId == item.diary.id }.count != 0) ? ReportState.alreadyReported : ReportState.notReported
            }
            .onChange(of: reportState) { newReportState in
                isShowingAcceptedToast = (reportState == ReportState.nowReported)
            }
        }
        .onTapGesture {
            submit()
        }
    }
}

private extension DiaryDetailView {
    
    //MARK: - 댓글 삭제 기능
    func delete(at offsets: IndexSet) {
        commentStore.commentList.remove(atOffsets: offsets)
    }
    
    //MARK: - 다이어리 작성자 프로필
    var diaryUserProfile: some View {
        HStack {
            if item.user.profileImageURL != "" {
                WebImage(url: URL(string: item.user.profileImageURL))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image("defaultProfileImage")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
            
            //유저 닉네임
//            Text(item.diary.diaryUserNickName)
            // 이게 맞나
            Text(item.user.nickName)
                .font(.callout)
            Spacer()
            
            //MARK: -...버튼 글 쓴 유저일때만 ...나타나도록
            if item.diary.uid == Auth.auth().currentUser?.uid {
                alertMenu
//                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
              //      .padding(.top, 5)
            }
            else {
                reportAlertMenu
//                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
              //      .padding(.top, 5)
            }
            
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    // MARK: - 다이어리 공개 여부를 나타내는 이미지
    private var isPrivateImage: some View {
        Image(systemName: "lock")
            .foregroundColor(Color.secondary)
    }
    
    //MARK: - Alert Menu 버튼
    var alertMenu: some View {
        //MARK: - ... 버튼입니다.
        Menu {
            
            
            
            NavigationLink {
                DiaryEditView(diaryTitle: item.diary.diaryTitle, diaryIsPrivate: item.diary.diaryIsPrivate, diaryContent: item.diary.diaryContent, campingSpotItem: diaryCampingSpot.first ?? campingSpotStore.campingSpot, campingSpot: diaryCampingSpot.first?.facltNm ?? "", item: item, selectedDate: item.diary.diaryVisitedDate)
            } label: {
                Text("수정하기")
            }

            
            Button {
                isShowingDeleteAlert = true
            } label: {
                Text("삭제하기")
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .frame(width: 30,height: 30)
        }
        //MARK: - 일기 삭제 알림
        .alert("일기를 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
            Button("취소", role: .cancel) {
                isShowingDeleteAlert = false
            }
            Button("삭제", role: .destructive) {
                diaryStore.deleteDiaryCombine(diary: item.diary)
            }
        }
    }
    
    //MARK: - 유저 신고 / 차단 버튼
    var reportAlertMenu: some View {
        
        //MARK: - ... 버튼입니다.
        
        Button(action: {
            isShowingConfirmationDialog.toggle()
        }) {
            Image(systemName: "ellipsis")
                .font(.title3)
                .frame(width: 30,height: 30)

        }
        .confirmationDialog("알림", isPresented: $isShowingConfirmationDialog, titleVisibility: .hidden, actions: {
            Button("신고하기", role: .destructive) {
                isShowingUserReportAlert.toggle()
            }
            Button("차단하기", role: .destructive) {
                print("차단해ㅐㅐㅐㅐ")
                isBlocked.toggle()
                if isBlocked {
                    blockedUserStore.addBlockedUserCombine(blockedUserId: item.diary.uid)
                }
                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
            }
            Button("취소", role: .cancel) {}
        })
    }

    
    // MARK: -View : 다이어리 사진
    var diaryDetailImage: some View {
        TabView{
            ForEach(item.diary.diaryImageURLs, id: \.self) { url in
                ZStack{
                    WebImage(url: URL(string: url))
                        .resizable()
                        .placeholder {
                            Rectangle().foregroundColor(.gray)
                        }
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                        .clipped()
                }
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        //사진 두번 클릭시 좋아요
        .onTapGesture(count: 2) {
            //좋아요 버튼, 카운드
            if diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") {
                //포함되있으면 아무것도 안함
            } else {
                diaryLikeStore.addDiaryLikeCombine(diaryId: item.diary.id)
            }
            //TODO: -함수 업데이트되면 넣기
            diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
            //탭틱
            let impactMed = UIImpactFeedbackGenerator(style: .soft)
            impactMed.impactOccurred()
        }
        .pinchZoomAndDrag()

    }
    
    // MARK: -View : 다이어리 제목
    var diaryDetailTitle: some View {
        Text(item.diary.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
    
    // MARK: -View : 다이어리 내용
    var diaryDetailContent: some View {
        Text(item.diary.diaryContent)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 25)
    }
    
    //MARK: - 방문한 캠핑장 링크
    //TODO: - 캠핑장 정보 연결
    var diaryCampingLink: some View {
        
        NavigationLink {
            CampingSpotDetailView(campingSpot: campingSpotStore.campingSpotList.first ?? campingSpotStore.campingSpot)
        } label: {
            HStack {
                WebImage(url: URL(string: campingSpotStore.campingSpotList.first?.firstImageUrl == "" ? campingSpotStore.noImageURL : campingSpotStore.campingSpotList.first?.firstImageUrl ?? ""))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(campingSpotStore.campingSpotList.first?.facltNm ?? "")
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                    HStack {
                        Text("\(campingSpotStore.campingSpotList.first?.doNm ?? "") \(campingSpotStore.campingSpotList.first?.sigunguNm ?? "")")
                            .padding(.vertical, 2)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                .foregroundColor(.bcBlack)
                
                HStack {
                        Text("자세히 보기")
                        Image(systemName: "chevron.right.2")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.bcDarkGray, lineWidth: 1)
                    .opacity(0.3)
            )
        }
        .foregroundColor(.clear)
    }
    
    
    
    //MARK: - 좋아요, 댓글, 타임스탬프
    var diaryDetailInfo: some View {
        HStack {
            Button {
                //좋아요 버튼, 카운드
                if diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") {
                    diaryLikeStore.removeDiaryLikeCombine(diaryId: item.diary.id)
                } else {
                    diaryLikeStore.addDiaryLikeCombine(diaryId: item.diary.id)
                }
                diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
                //탭틱
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
            } label: {
                Image(systemName: diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? "flame.fill" : "flame")
                
                    .foregroundColor(diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? .red : .secondary)
            }
            Text("\(diaryLikeStore.diaryLikeList.count)")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.leading, -2)
                .frame(width: 20, alignment: .leading)
            
            //댓글 버튼
            //            Button {
            //"댓글 작성 버튼으로 이동하려고 했는데 그냥 텍스트로~
            //            } label: {
            Image(systemName: "message")
                .font(.callout)
                .foregroundColor(.secondary)
            
            
            Text("\(commentStore.commentList.count)")
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
                .padding(.leading, -2)
            
            Spacer()
            //작성 경과시간
            Text("\(TimestampToString.dateString(item.diary.diaryCreatedDate)) 전")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
        .task {
            Analytics.logEvent("DiaryTest", parameters: [
                "DiaryID" : "\(item.diary.id)",
                "Visitor" : "\(String(describing: Auth.auth().currentUser?.email))"
            ])
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
