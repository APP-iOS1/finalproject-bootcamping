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
    @StateObject var commentStore: CommentStore
    @EnvironmentObject var diaryStore: DiaryStore
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @StateObject var scrollViewHelper: ScrollViewHelper
    
    //선택한 다이어리 정보 변수입니다.
    var item2: UserInfoDiary
    
    var diaryCampingSpot: [CampingSpot] {
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
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    var body: some View {
        ZStack {
            
            Color(.red)
            
            HStack {
                Spacer()
                
                Button {
                    commentStore.deleteCommentCombine(diaryId: item2.diary.id, comment: item)
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                }

            }
            if (wholeAuthStore.currentUser?.uid == item2.diary.uid) || (wholeAuthStore.currentUser?.uid == item.uid) {
                HStack(alignment: .top) {
                    diaryCommetUserProfile
//                        .frame(width: 35)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.nickName)
//                                .font(.subheadline)
                                .font(.footnote)
                                .foregroundColor(.bcDarkGray)

                            Text("·")
                                .font(.footnote)
                                .foregroundColor(.bcDarkGray)
                            Text("\(TimestampToString.dateString(item.commentCreatedDate)) 전")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(item.commentContent)
                            .font(.callout)
                            .foregroundColor(.bcBlack)
                            .padding(.top, -5)
                    }
                    .padding(.trailing, 5)
                    
                    Spacer()
                }
                .padding(.vertical, UIScreen.screenWidth * 0.02)
                .background(Color("BCWhite"))
                .contentShape(Rectangle())
                .offset(x: scrollViewHelper.commentOffset[item.id] ?? 0)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
            } else {
                HStack(alignment: .top) {
                    diaryCommetUserProfile
//                        .frame(width: 35)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.nickName)
                                .font(.footnote)
                                .foregroundColor(.bcDarkGray)
                            Text("·")
                                .font(.footnote)
                                .foregroundColor(.bcDarkGray)
                            Text("\(TimestampToString.dateString(item.commentCreatedDate)) 전")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(item.commentContent)
                            .font(.callout)
                            .foregroundColor(.bcBlack)
                            .padding(.top, -5)
                    }
                    .padding(.trailing, 5)
                    
                    Spacer()
                }
                .padding(.vertical, UIScreen.screenWidth * 0.02)
                .background(Color("BCWhite"))
                .contentShape(Rectangle())
                .offset(x: offset)
            }
        }
        
        
    }
    
    func onChanged(value: DragGesture.Value) {
        withAnimation(.easeOut) {
            for i in scrollViewHelper.commentOffset {
                if item.id != i.key {
                    scrollViewHelper.commentOffset[i.key] = nil
                }
            }
        }
        if value.translation.width < 0 && -value.translation.width < 65  {
            
            if isSwiped {
                scrollViewHelper.commentOffset[item.id] = -50
            } else {
                scrollViewHelper.commentOffset[item.id] = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        
        withAnimation(.easeOut) {
            if value.translation.width < 0 {
                
                if -value.translation.width > 50 {
                    isSwiped = true
                    scrollViewHelper.commentOffset[item.id] = -50
                } else if -value.translation.width <= 50 {
                    isSwiped = false
                    scrollViewHelper.commentOffset[item.id] = 0
                } else {
                    isSwiped = false
                    scrollViewHelper.commentOffset[item.id] = 0
                }
            } else {
                isSwiped = false
                scrollViewHelper.commentOffset[item.id] = 0
            }
        }
    }
}

private extension DiaryCommentCellView {
    @ViewBuilder
    var diaryCommetUserProfile: some View {
        if item.profileImage != "" {
            WebImage(url: URL(string: item.profileImage))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Image("defaultProfileImage")
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: 40, height: 40)
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
