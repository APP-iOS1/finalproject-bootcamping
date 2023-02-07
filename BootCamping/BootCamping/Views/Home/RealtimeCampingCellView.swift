////
////  RealtimeCampingCellView.swift
////  BootCamping
////
////  Created by Deokhun KIM on 2023/01/18.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//import Firebase
//
//struct RealtimeCampingCellView: View {
//    
//    @EnvironmentObject var authStore: AuthStore
//    @EnvironmentObject var diaryStore: DiaryStore
//    //선택한 다이어리 정보 변수입니다.
//    var item: Diary
//    //삭제 알림
//    @State private var isShowingDeleteAlert = false
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            diaryUserProfile
//            diaryImage
//            NavigationLink {
//                DiaryDetailView(item: item)
//            } label: {
//                VStack(alignment: .leading) {
//                    HStack {
//                        diaryTitle
//                        Spacer()
//                        diaryIsPrivate
//                    }
//                    diaryContent
//                    diaryCampingLink
//                    diaryInfo
//                }
//                .padding(.horizontal, UIScreen.screenWidth * 0.03)
//            }
//            .foregroundColor(.bcBlack)
//        }
//
//    }
//}
//
//private extension RealtimeCampingCellView {
//    //MARK: - 메인 이미지
//    var diaryImage: some View {
//        TabView{
//            ForEach(item.diaryImageURLs, id: \.self) { url in
//                WebImage(url: URL(string: url))
//                    .resizable()
//                    .placeholder {
//                        Rectangle().foregroundColor(.gray)
//                    }
//                    .scaledToFill()
//                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
//                    .clipped()
//            }
//        }
//        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
//        .tabViewStyle(PageTabViewStyle())
//        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
//        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
//    }
//    
//    //MARK: - 다이어리 작성자 프로필
//    var diaryUserProfile: some View {
//        
//        HStack {
////            //TODO: -유저 프로필 사진
////            ForEach(authStore.userList) { user in
////                if item.uid == user.id && user.profileImage != "" {
////                    WebImage(url: URL(string: user.profileImage))
////                        .resizable()
////                        .placeholder {
////                            Rectangle().foregroundColor(.gray)
////                        }
////                        .scaledToFill()
////                        .frame(width: UIScreen.screenWidth * 0.01)
////                        .clipShape(Circle())
////                } else {
//                    Image(systemName: "person.fill")
//                        .overlay {
//                            Circle().stroke(lineWidth: 1)
//                        }
////                }
////            }
//            
//            //유저 닉네임
//            Text(item.diaryUserNickName)
//                .font(.headline).fontWeight(.semibold)
//            Spacer()
//            //MARK: - ... 버튼입니다.
//            Menu {
//                Button {
//                    //TODO: -수정기능 추가
//                } label: {
//                    Text("수정하기")
//                }
//                
//                Button {
//                    isShowingDeleteAlert = true
//                } label: {
//                    Text("삭제하기")
//                }
//                
//            } label: {
//                Image(systemName: "ellipsis")
//            }
//            
//            //MARK: - 일기 삭제 알림
//            .alert("일기를 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
//                Button("취소", role: .cancel) {
//                    isShowingDeleteAlert = false
//                }
//                Button("삭제", role: .destructive) {
//                    diaryStore.deleteDiaryCombine(diary: item)
//                }
//            }
