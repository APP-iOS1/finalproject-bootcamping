//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct DiaryCellView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    //    @EnvironmentObject var diaryLikeStore: DiaryLikeStore
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    @State var isBookmarked: Bool = false
    
    //선택한 다이어리 정보 변수입니다.
    var item: UserInfoDiary
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingUserReportAlert = false
    
    @EnvironmentObject var faceId: FaceId
    @AppStorage("faceId") var usingFaceId: Bool = false
    
    var diaryCampingSpot: [Item] {
        get {
            return campingSpotStore.campingSpotList.filter{
                $0.contentId == item.diary.diaryAddress
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            diaryUserProfile
            //MARK: - 잠금상태 && Faceid 설정 일때 잠금화면
            if item.diary.diaryIsPrivate && faceId.islocked == true {
                    Button {
                        faceId.authenticate()
                    } label: {
                        VStack {
                            Image(systemName: "lock")
                                
                            Text("비공개 일기입니다.\n잠금을 해제해주세요.")
                        }
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    }
                
            } else {
                diaryImage
                
                NavigationLink {
                    DiaryDetailView(item: item)
                } label: {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center){
                            if (item.diary.uid == wholeAuthStore.currnetUserInfo!.id && item.diary.diaryIsPrivate) {
                                isPrivateImage
                            }
                            diaryTitle
                        }
                        diaryContent
                        if !campingSpotStore.campingSpotList.isEmpty {
                            diaryCampingLink
                        }
                        diaryDetailInfo
                        Divider().padding(.bottom, 3)
                        
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                }
                .foregroundColor(.bcBlack)
            }
        }
        
        .padding(.top, UIScreen.screenWidth * 0.03)
        .onAppear {
            commentStore.readCommentsCombine(diaryId: item.diary.id)
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
            //TODO: -함수 업데이트되면 넣기
            diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
        }
    }
}

private extension DiaryCellView {
    //TODO: -유저 프로필 이미지 연결
    //    var userProfileURL: String? {
    //        for user in wholeAuthStore.userList {
    //            if user.id == item.uid {
    //                return user.profileImageURL
    //            }
    //        }
    //        return ""
    //    }
    
    
    //MARK: - 메인 이미지
    var diaryImage: some View {
        TabView{
            ForEach(item.diary.diaryImageURLs, id: \.self) { url in
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
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        .pinchZoomAndDrag()
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
            Text(item.user.nickName)
                .font(.headline).fontWeight(.semibold)
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
                ReportUserView(user: User(id: "", profileImageName: "", profileImageURL: "", nickName: "", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: []), placeholder: "", options: [])
            }
        }
        
    }
    
    //MARK: - 제목
    var diaryTitle: some View {
        Text(item.diary.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.vertical, 5)
    }
    
    // MARK: - 다이어리 공개 여부를 나타내는 이미지
    private var isPrivateImage: some View {
        Image(systemName: "lock")
            .foregroundColor(Color.secondary)
    }
    
    //MARK: - 내용
    var diaryContent: some View {
        Text(item.diary.diaryContent)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    //MARK: - 캠핑장 이동
    var diaryCampingLink: some View {
        HStack {
            WebImage(url: URL(string: campingSpotStore.campingSpotList.first?.firstImageUrl == "" ? campingSpotStore.noImageURL : campingSpotStore.campingSpotList.first?.firstImageUrl ?? "")) //TODO: -캠핑장 사진 연동
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(campingSpotStore.campingSpotList.first?.facltNm ?? "")
                    .font(.headline)
                HStack {
                    Text("방문일자: \(item.diary.diaryVisitedDate.getKoreanDate())")
                        .font(.footnote)
                        .padding(.vertical, 2)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .foregroundColor(.bcBlack)
            
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.bcDarkGray, lineWidth: 1)
                .opacity(0.3)
        )
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
                //탭틱
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                
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
}


//struct DiaryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryCellView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
//            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: ["동훈"], diaryIsPrivate: true))
//        .environmentObject(WholeAuthStore())
//        .environmentObject(DiaryStore())
//        .environmentObject(BookmarkStore())
//        .environmentObject(DiaryLikeStore())
//        .environmentObject(CommentStore())
//
//    }
//}


