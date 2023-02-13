//
//  DiaryCommentCell.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/07.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct DiaryCommentCellView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var commentStore: CommentStore
    @EnvironmentObject var diaryStore: DiaryStore
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    
    //선택한 다이어리 정보 변수입니다.
    var item2: UserInfoDiary
    
    var diaryCampingSpot: [Item] {
        get {
            return campingSpotStore.campingSpotList.filter{
                $0.contentId == item2.diary.diaryAddress
            }
        }
    }
    
    var item: Comment
    
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingUserReportAlert = false
    @State private var isShowingUserBlockedAlert = false
    
    var body: some View {
            HStack{
                diaryCommetUserProfile
                    .frame(width: 35)
                
                VStack(alignment: .leading) {
                    HStack{
                        Text(item.nickName)
                            .font(.footnote)
                        Text("\(TimestampToString.dateString(item.commentCreatedDate)) 전")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                    }
                    Text(item.commentContent)
                }
                .padding(.trailing, 3)
                
                Spacer()
            }
            .padding(.vertical, UIScreen.screenWidth * 0.01)
          
    }
}

private extension DiaryCommentCellView {
    @ViewBuilder
    var diaryCommetUserProfile: some View {
        if item.profileImage != "" {
            WebImage(url: URL(string: item.profileImage))
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
    }
    
    var diaryUserProfile: some View {
        HStack {
            //유저 닉네임
            Text(item.nickName)
                .font(.headline).fontWeight(.semibold)
            Spacer()
            //MARK: -...버튼 글 쓴 유저일때만 ...나타나도록
            if item.uid == Auth.auth().currentUser?.uid {
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
                DiaryEditView(diaryTitle: item2.diary.diaryTitle, diaryIsPrivate: item2.diary.diaryIsPrivate, diaryContent: item2.diary.diaryContent, campingSpotItem: diaryCampingSpot.first ?? campingSpotStore.campingSpot, campingSpot: diaryCampingSpot.first?.facltNm ?? "", item: item2, selectedDate: item2.diary.diaryVisitedDate)
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
        }
        //MARK: - 일기 삭제 알림
        .alert("일기를 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
            Button("취소", role: .cancel) {
                isShowingDeleteAlert = false
            }
            Button("삭제", role: .destructive) {
                //댓글 삭제 컴바인
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
}
