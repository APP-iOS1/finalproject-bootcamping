//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import AlertToast

struct DiaryCellView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore
    @EnvironmentObject var reportStore: ReportStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    
    @State var isBookmarked: Bool = false
    
    //선택한 다이어리 정보 변수입니다.
    var item: UserInfoDiary
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingConfirmationDialog = false
    @State private var isShowingUserReportAlert = false
    
    @State private var reportState = ReportState.notReported
    @State private var isShowingAcceptedToast = false
    @State private var isShowingBlockedToast = false
    
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
                VStack(alignment: .center) {
                    Button {
                            faceId.authenticate()
                    } label: {
                            Image(systemName: "lock")
                                .resizable()
                                .padding()
                                .foregroundColor(Color.bcGreen)
                    }
                    .frame(height: UIScreen.screenWidth / 5)
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 10)
                    Text("비공개 일기입니다")
                    Text("버튼을 눌러 잠금을 해제해주세요")
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                .background(Color.secondary)
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
                        HStack {
                            Spacer()
                            HStack{
                                Text("자세히 보기")
                                Image(systemName: "chevron.right.2")
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                        
                        if !campingSpotStore.campingSpotList.isEmpty {
                            diaryCampingLink
                        }
                        
                        Divider().padding(.top, 5)
                        
                        diaryDetailInfo
//                        Divider().padding(.bottom, 3)
                        
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                }
                .foregroundColor(.bcBlack)
            }
        }
        .toast(isPresenting: $isShowingAcceptedToast) {
            AlertToast(type: .regular, title: "이 게시물에 대한 신고가 접수되었습니다.")
        }
        .toast(isPresenting: $isShowingBlockedToast) {
            AlertToast(type: .regular, title: "이 사용자를 차단했습니다.", subtitle: "차단 해제는 마이페이지 > 설정에서 가능합니다.")
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
        .padding(.top, UIScreen.screenWidth * 0.03)
        .onAppear {
            commentStore.readCommentsCombine(diaryId: item.diary.id)
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diary.diaryAddress]))
            //TODO: -함수 업데이트되면 넣기
            diaryLikeStore.readDiaryLikeCombine(diaryId: item.diary.id)
            reportState = (reportStore.reportedDiaries.filter{ reportedDiary in reportedDiary.reportedDiaryId == item.diary.id }.count != 0) ? ReportState.alreadyReported : ReportState.notReported
        }
        .onChange(of: reportState) { newReportState in
            isShowingAcceptedToast = (reportState == ReportState.nowReported)
        }
    }
}

private extension DiaryCellView {
    //MARK: - 메인 이미지
    var diaryImage: some View {
        TabView{
            ForEach(item.diary.diaryImageURLs, id: \.self) { url in
                WebImage(url: URL(string: url))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    .clipped()
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
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
            Text(item.user.nickName)
                .font(.callout)
//            Text(item.diary.diaryUserNickName)
                
            Spacer()
            //MARK: -...버튼 글 쓴 유저일때만 ...나타나도록
            if item.diary.uid == Auth.auth().currentUser?.uid {
                alertMenu
                 //   .padding(.top, 5)
            }
            else {
                reportAlertMenu
                  //  .padding(.top, 5)
            }
            
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)

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
                .frame(width: 30, height: 30)
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
            Button("게시물 신고하기", role: .destructive) {
                isShowingUserReportAlert.toggle()
            }
            Button("\(item.user.nickName)님 차단하기", role: .destructive) {
                blockedUserStore.addBlockedUserCombine(blockedUserId: item.diary.uid)
                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
                isShowingBlockedToast.toggle()
            }
            Button("취소", role: .cancel) {}
        })
    }
    
    //MARK: - 제목
    var diaryTitle: some View {
        Text(item.diary.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.top, 10)
            .padding(.bottom, 5)
            .multilineTextAlignment(.leading)
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
            .padding(.bottom, 25)
    }
    
    //MARK: - 캠핑장 이동
    var diaryCampingLink: some View {
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
                    Text("방문일자: \(item.diary.diaryVisitedDate.getKoreanDate())")
                        .padding(.vertical, 2)
                    Spacer()
                }
                .font(.footnote)
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
        .padding(.bottom, 15)
    }
}
