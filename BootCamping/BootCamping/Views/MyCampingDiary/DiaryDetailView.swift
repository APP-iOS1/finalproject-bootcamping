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

struct DiaryDetailView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore
    @EnvironmentObject var reportStore: ReportStore
    @Environment(\.dismiss) private var dismiss

    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    @StateObject var scrollViewHelper: ScrollViewHelper = ScrollViewHelper()
    
    var diaryCampingSpot: [CampingSpot] {
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
    
    // 현재 게시물의 신고 상태를 나타낼 변수
    @State private var reportState = ReportState.notReported
    
    @State private var isShowingAcceptedToast = false
    @State private var isShowingBlockedToast = false
    
    //자동 스크롤
    @Namespace var topID
    @Namespace var bottomID
    @Namespace var commentButtonID
    
    //키보드 포커싱
    @FocusState private var inputFocused: Bool
    
    //버튼 클릭시 캠핑장 상세뷰로 이동.
    @State var tag:Int? = nil
    
    var item: UserInfoDiary
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading) {
                        diaryUserProfile.id(topID)
                        
                        Group {
                            diaryDetailTitle
                            
                            diaryDetailContent
                            
                            if !campingSpotStore.campingSpotList.isEmpty {
                                diaryCampingLink
                            }
                            //좋아요, 댓글, 타임스탬프
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
                    .task {
                        //이전화면에서 댓글버튼 눌렀다면 바로 키보드 나오게
                        if diaryStore.isCommentButtonClicked {
                            self.inputFocused = true
                            proxy.scrollTo(commentButtonID, anchor: .top)
                            diaryStore.isCommentButtonClicked = false
                        } else {
                            withAnimation {
                                proxy.scrollTo(topID)
                            }
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
                                proxy.scrollTo(commentButtonID, anchor: .top)
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
            .padding(.top)
            .padding(.bottom)
            .navigationTitle("댓글")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                commentStore.readCommentsCombine(diaryId: item.diary.id)
                diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
            }
        }
        .onTapGesture {
            dismissKeyboard()
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
                        Rectangle().foregroundColor(.secondary) .skeletonAnimation()
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
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
            
            Text(item.diary.diaryUserNickName)
                .font(.callout)
            Spacer()
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    // MARK: - 다이어리 공개 여부를 나타내는 이미지
    private var isPrivateImage: some View {
        Image(systemName: "lock")
            .foregroundColor(Color.secondary)
    }
    
    
    // MARK: -View : 다이어리 제목
    var diaryDetailTitle: some View {
        Text(item.diary.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.top, 10)
            .padding(.bottom, 5)
            .multilineTextAlignment(.leading)
    }
    
    // MARK: -View : 다이어리 내용
    var diaryDetailContent: some View {
        Text(item.diary.diaryContent)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 25)
    }
    
        //MARK: - 방문한 캠핑장 링크
        var diaryCampingLink: some View {
    
            HStack {
                NavigationLink(destination: CampingSpotDetailView(campingSpot: campingSpotStore.campingSpotList.first ?? campingSpotStore.campingSpot), tag: 1, selection: $tag) {
                    EmptyView()
                }
    
                Button {
                    self.tag = 1
                    dismissKeyboard()
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
                        
                        Spacer()
    
                    Image(systemName: "chevron.right.2")
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
                .padding(.bottom, 10)
                .foregroundColor(.clear)
            }
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
                    //탭틱
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
                diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
            } label: {
                Image(systemName: diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? "flame.fill" : "flame")
                
                    .foregroundColor(diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? .red : .secondary)
            }
            Text("\(diaryLikeStore.diaryLikeList.count)")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.leading, -2)
                .frame(width: 20, alignment: .leading)
            
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
            Analytics.logEvent("ViewDiary", parameters: [
                "DiaryID" : "\(item.diary.id)",
                "Visitor" : "\(String(describing: Auth.auth().currentUser?.email))"
            ])
        }
    }
    
}

