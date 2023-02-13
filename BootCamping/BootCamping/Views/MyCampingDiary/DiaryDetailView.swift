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
    //    @EnvironmentObject var commentStore: CommentStore
    @EnvironmentObject var diaryStore: DiaryStore
//        @EnvironmentObject var diaryLikeStore: DiaryLikeStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
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
    @State private var isShowingUserReportAlert = false
    @State private var isShowingUserBlockedAlert = false
    
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
                            diaryDetailInfo
                            Divider()
                            //댓글
                            ForEach(commentStore.commentList) { comment in
                                DiaryCommentCellView(item2: item, item: comment)
                            }
                            //댓글 작성시 뷰 가장 아래로
                            EmptyView().id(bottomID)
                        }
                        .padding(.horizontal, UIScreen.screenWidth * 0.03)
                    }
                    .onAppear {
                        proxy.scrollTo(topID)
                    }
                    //                    .onChange(of: commentStore.commentList.count) { _ in
                    //                        withAnimation { proxy.scrollTo(bottomID) }
                    //                    }
                }
                //                diaryCommetInputView\
                //댓글작성
                HStack {
                    if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
                        WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                    }
                    TextField("댓글을 적어주세요", text: $diaryComment, axis: .vertical)
                    
                    Button {
                        //TODO: -프로필 이미지 수정
                        commentStore.createCommentCombine(diaryId: item.diary.id, comment: Comment(id: UUID().uuidString, diaryId: item.diary.id, uid: wholeAuthStore.currnetUserInfo?.id ?? "" , nickName: wholeAuthStore.currnetUserInfo?.nickName ?? "", profileImage: wholeAuthStore.currnetUserInfo?.profileImageURL ?? "", commentContent: diaryComment, commentCreatedDate: Timestamp()))
                        commentStore.readCommentsCombine(diaryId: item.diary.id)
                        withAnimation {
                            proxy.scrollTo(bottomID)
                        }
                        
                        diaryComment = ""
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.title2)
                    }
                    .disabled(diaryComment == "")
                    
                }
                .foregroundColor(.bcBlack)
                .font(.title3)
                .padding(.vertical, 5)
                .padding(.horizontal, UIScreen.screenWidth * 0.03)
                
            }
            .padding(.top)
            .padding(.bottom)
            .navigationTitle("BOOTCAMPING")
            .onAppear{
//                isBookmarked = bookmarkStore.checkBookmarkedDiary(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, diaryId: item.diary.id)
                commentStore.readCommentsCombine(diaryId: item.diary.id)
                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
                //TODO: -함수 업데이트되면 넣기
                diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
            }
            .onTapGesture {
                inputFocused = false
            }
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
                Circle()
                    .frame(width: 30, height: 30)
            }
            
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
        Image(systemName: "lock")
            .foregroundColor(Color.secondary)
    }
    
    //MARK: - Alert Menu 버튼
    var alertMenu: some View {
        //MARK: - ... 버튼입니다.
        Menu {
            NavigationLink {
                DiaryEditView(diaryTitle: item.diary.diaryTitle, diaryIsPrivate: item.diary.diaryIsPrivate, diaryContent: item.diary.diaryContent, campingSpotItem: diaryCampingSpot.first ?? campingSpotStore.campingSpot, campingSpot: diaryCampingSpot.first?.facltNm ?? "", selectedDate: item.diary.diaryVisitedDate)
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
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        .pinchZoomAndDrag()
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
            CampingSpotDetailView(campingSpot: campingSpotStore.campingSpotList.first ?? campingSpotStore.campingSpot)
        } label: {
            HStack {
                WebImage(url: URL(string: campingSpotStore.campingSpotList.first?.firstImageUrl == "" ? campingSpotStore.noImageURL : campingSpotStore.campingSpotList.first?.firstImageUrl ?? "")) //TODO: -캠핑장 사진 연동
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(campingSpotStore.campingSpotList.first?.facltNm ?? "")
                        .font(.headline)
                    HStack {
                        Text("\(campingSpotStore.campingSpotList.first?.doNm ?? "") \(campingSpotStore.campingSpotList.first?.sigunguNm ?? "")")
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
                    if diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") {
                        diaryLikeStore.removeDiaryLikeCombine(diaryId: item.diary.id)
                    } else {
                        diaryLikeStore.addDiaryLikeCombine(diaryId: item.diary.id)
                    }
                    //TODO: -함수 업데이트되면 넣기
                    diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
                    
                } label: {
                    Image(systemName: diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? "flame.fill" : "flame")
                        .foregroundColor(diaryLikeStore.diaryLikeList.contains(wholeAuthStore.currentUser?.uid ?? "") ? .red : .bcBlack)
                }
                Text("\(diaryLikeStore.diaryLikeList.count)")
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
//    var diaryCommetInputView : some View {
//        HStack {
//            if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
//                WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
//                    .resizable()
//                    .clipShape(Circle())
//                .frame(width: 30, height: 30)
//            } else {
//                Image(systemName: "person.fill")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .aspectRatio(contentMode: .fill)
//                    .clipShape(Circle())
//
//            }
//            TextField("댓글을 적어주세요", text: $diaryComment, axis: .vertical)
//
//            Button {
//                //TODO: -프로필 이미지 수정
//                commentStore.createCommentCombine(diaryId: item.diary.id, comment: Comment(id: UUID().uuidString, diaryId: item.diary.id, uid: Auth.auth().currentUser?.uid ?? "", nickName: item.diary.diaryUserNickName, profileImage: item.user.profileImageURL, commentContent: diaryComment, commentCreatedDate: Timestamp()))
//                commentStore.readCommentsCombine(diaryId: item.diary.id)
//                diaryComment = ""
//            } label: {
//                Image(systemName: "paperplane")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//
//            }
//        }
//        .foregroundColor(.bcBlack)
//        .font(.title3)
//        .padding(.vertical, 5)
//    }
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
