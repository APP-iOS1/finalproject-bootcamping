//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct DiaryDetailView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var commentStore: CommentStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var diaryLikeStore: DiaryLikeStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    
    @State private var diaryComment: String = ""
    
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingUserReportAlert = false
    @State private var isShowingUserBlockedAlert = false
    
    @State private var isBookmarked: Bool = false
    //자동 스크롤
    @Namespace var topID
    @Namespace var bottomID
    
    var item: UserInfoDiary
    
    var body: some View {
        VStack {
            CommentScrollView {
                LazyVStack(alignment: .leading) {
                    diaryUserProfile
                    diaryDetailImage
                    Group {
                        HStack(alignment: .center){
                            if item.diary.uid == wholeAuthStore.currnetUserInfo!.id {
                                isPrivateImage
                            }
                            diaryDetailTitle
                            Spacer()
                            bookmarkButton
                        }
                        diaryDetailContent
                        if !campingSpotStore.campingSpotList.isEmpty {
                            diaryCampingLink
                        }
                        diaryDetailInfo
                        Divider()
                        
                        //댓글
                        ForEach(commentStore.commentList) { comment in
                            DiaryCommentCellView(item: comment)
                        }
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                }
            }
            
            diaryCommetInputView
            
        }
        .padding(.top)
        .padding(.bottom)
        .navigationTitle("BOOTCAMPING")
        .onAppear{
            isBookmarked = bookmarkStore.checkBookmarkedDiary(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, diaryId: item.diary.id)
            commentStore.readCommentsCombine(diaryId: item.diary.id)
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
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
            //TODO: -다이어리 작성자 url 추가 (연산프로퍼티 작동 안됨)
            WebImage(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/UserImages%2F6A6EB85C-6113-4FDA-BC23-62C1285762EF?alt=media&token=ed35fe2c-4f99-4293-99e5-5c35ca14b291"))
                .resizable()
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.07)
                .clipShape(Circle())
            
            //유저 닉네임
            Text(item.diary.diaryUserNickName)
                .font(.callout)
            Spacer()
            
            //MARK: -...버튼 글 쓴 유저일때만 ...나타나도록
            if item.diary.uid == Auth.auth().currentUser?.uid {
                alertMenu
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                    .padding(.top, 5)
            }
            //TODO: -글 쓴 유저가 아닐때는 신고기능 넣기
            else {
                reportAlertMenu
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                    .padding(.top, 5)
            }
            
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    // MARK: - 다이어리 공개 여부를 나타내는 이미지
    private var isPrivateImage: some View {
        Image(systemName: (item.diary.diaryIsPrivate ? "lock" : "lock.open"))
            .foregroundColor(Color.secondary)
    }
    
    // MARK: - 북마크 버튼
    private var bookmarkButton: some View {
        Button{
            isBookmarked.toggle()
            if isBookmarked{
                bookmarkStore.addBookmarkDiaryCombine(diaryId: item.diary.id)
            } else {
                bookmarkStore.removeBookmarkDiaryCombine(diaryId: item.diary.id)
            }
            wholeAuthStore.readUserListCombine()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .bold()
                .foregroundColor(Color.accentColor)
                .opacity((item.diary.uid != wholeAuthStore.currnetUserInfo!.id ? 1 : 0))
        }
        .disabled(item.diary.uid == wholeAuthStore.currnetUserInfo!.id)
    }
    
    //MARK: - Alert Menu 버튼
    var alertMenu: some View {
        //MARK: - ... 버튼입니다.
        Menu {
            Button {
                //TODO: -수정기능 추가
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
        Menu {
            Button {
                isShowingUserReportAlert = true
            } label: {
                Text("신고하기")
            }
            
            Button {
                isShowingDeleteAlert = true
            } label: {
                Text("차단하기")
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
        }
        //MARK: - 유저 신고 알림
        .alert("유저를 신고하시겠습니까?", isPresented: $isShowingUserReportAlert) {
            Button("취소", role: .cancel) {
                isShowingUserReportAlert = false
            }
            Button("신고하기", role: .destructive) {
                //신고 컴바인..
            }
        }
        .alert("유저를 차단하시겠습니까?", isPresented: $isShowingUserBlockedAlert) {
            Button("취소", role: .cancel) {
                isShowingUserBlockedAlert = false
            }
            Button("차단하기", role: .destructive) {
                //차단 컴바인..
            }
        }
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
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
    
    // MARK: -View : 다이어리 제목
    var diaryDetailTitle: some View {
        Text(item.diary.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.vertical, 5)
    }
    
    // MARK: -View : 다이어리 내용
    var diaryDetailContent: some View {
        Text(item.diary.diaryContent)
            .multilineTextAlignment(.leading)
    }
    
    //MARK: - 방문한 캠핑장 링크
    //TODO: - 캠핑장 정보 연결
    var diaryCampingLink: some View {
        
        NavigationLink {
            CampingSpotDetailView(places: campingSpotStore.campingSpotList.first ?? campingSpotStore.campingSpot)
        } label: {
            HStack {
                WebImage(url: URL(string: campingSpotStore.campingSpotList.first?.firstImageUrl ?? "")) //TODO: -캠핑장 사진 연동
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(campingSpotStore.campingSpotList.first?.facltNm ?? "")
                        .font(.headline)
                    HStack {
                        Text(campingSpotStore.campingSpotList.first?.addr1 ?? "")
                        Spacer()
                        Group {
                            Text("자세히 보기")
                            Image(systemName: "chevron.right")
                        }
                        .font(.footnote)
                        
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .foregroundColor(.bcBlack)
            }
            .padding()
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
                    if item.diary.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") {
                        diaryLikeStore.removeDiaryLikeCombine(diaryId: item.diary.id)
                    } else {
                        diaryLikeStore.addDiaryLikeCombine(diaryId: item.diary.id)
                    }
                    diaryStore.readDiarysCombine()
                } label: {
                    Image(systemName: item.diary.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") ? "flame.fill" : "flame")
                        .foregroundColor(item.diary.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") ? .red : .bcBlack)
                }
                Text("\(item.diary.diaryLike.count)")
                    .padding(.trailing, 7)

                //댓글 버튼
                Button {
                    //"댓글 작성 버튼으로 이동"
                } label: {
                    Image(systemName: "message")
                }
                Text("\(commentStore.commentList.count)")
                    .font(.body)
                    .padding(.horizontal, 3)

                Spacer()
                //작성 경과시간
                Text("\(TimestampToString.dateString(item.diary.diaryCreatedDate)) 전")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.bcBlack)
            .font(.title3)
            .padding(.vertical, 5)
        }
    
    // MARK: -View : 댓글 작성
    var diaryCommetInputView : some View {
        HStack {
            if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
                WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                    .resizable()
                    .clipShape(Circle())
                .frame(width: 30, height: 30)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    
            }
            TextField("댓글을 적어주세요", text: $diaryComment, axis: .vertical)
            
            Button {
                //TODO: -프로필 이미지 수정
                commentStore.createCommentCombine(diaryId: item.diary.id, comment: Comment(id: UUID().uuidString, diaryId: item.diary.id, uid: Auth.auth().currentUser?.uid ?? "", nickName: item.diary.diaryUserNickName, profileImage: item.user.profileImageURL, commentContent: diaryComment, commentCreatedDate: Timestamp()))
                commentStore.readCommentsCombine(diaryId: item.diary.id)
                diaryComment = ""
            } label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .frame(width: 30, height: 30)

            }
        }
        .foregroundColor(.bcBlack)
        .font(.title3)
        .padding(.vertical, 5)
    }
    //MARK: - 댓글 아래로 구현
    struct CommentScrollView<Content: View>: View {
        
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let pinnedViews: PinnedScrollableViews
        private let content: () -> Content
        
        public init(alignment: HorizontalAlignment = .center,
                    spacing: CGFloat? = nil,
                    pinnedViews: PinnedScrollableViews = .init(),
                    @ViewBuilder content: @escaping () -> Content) {
            self.alignment = alignment
            self.spacing = spacing
            self.pinnedViews = pinnedViews
            self.content = content
        }
        
        public var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: alignment, spacing: spacing, pinnedViews: pinnedViews, content: content)
                    .rotationEffect(Angle(degrees: 180))
                    .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            }
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
        }
    }
    
}

//struct DiaryDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryDetailView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "용감하고 인류의 그들의 따뜻한 있음으로써 그러므로 봄바람이다. 힘차게 밥을 가슴이 용감하고 튼튼하며, 그들의 보는 새가 인간의 칼이다. 충분히 인생을 못할 곧 우리는 청춘은 인간의 황금시대다. 지혜는 찾아다녀도, 것은 못하다 어디 곳으로 꽃 봄날의 보라. 우는 예가 이상은 온갖 그것은 품었기 얼음 힘있다. 투명하되 그들의 밥을 창공에 주는 이상, 이상의 힘있다. 새 피가 가장 놀이 부패뿐이다. 그들은 원질이 든 무엇을 되려니와, 불어 우리는 노래하며 것이다. 대한 청춘의 곳이 바이며, 충분히 방황하였으며, 있는가? 그들은 거친 위하여, 살 때문이다.", diaryImageNames: [""], diaryImageURLs: [
//            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: ["동훈"], diaryIsPrivate: true))
//        .environmentObject(WholeAuthStore())
//        .environmentObject(DiaryStore())
//        .environmentObject(BookmarkStore())
//        .environmentObject(DiaryLikeStore())
//        .environmentObject(CommentStore())
//    }
//}
