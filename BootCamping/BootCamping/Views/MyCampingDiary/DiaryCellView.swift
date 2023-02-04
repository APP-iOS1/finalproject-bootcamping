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
//    @EnvironmentObject var authStore: AuthStore
    //선택한 다이어리 정보 변수입니다.
    var item: Diary
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    @State var isBookmarked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            diaryUserProfile
            diaryImage
            NavigationLink {
                DiaryDetailView(item: item)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        diaryTitle
                        Spacer()
                        diaryIsPrivate
                    }
                    diaryContent
                    diaryCampingLink
                    diaryInfo
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.03)
            }
            .foregroundColor(.bcBlack)
        }
        .onAppear{
            isBookmarked = bookmarkStore.checkBookmarkedDiary(diaryId: item.id)
        }
    }
}

private extension DiaryCellView {
    //MARK: - 메인 이미지
    var diaryImage: some View {
        TabView{
            ForEach(item.diaryImageURLs, id: \.self) { url in
                WebImage(url: URL(string: url))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .scaledToFill()
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    .clipped()
                    .overlay(alignment: .topTrailing){
                        Button {
                            isBookmarked.toggle()
                            if isBookmarked{
                                bookmarkStore.addBookmarkDiaryCombine(diaryId: item.id)
                            } else{
                                bookmarkStore.removeBookmarkDiaryCombine(diaryId: item.id)
                            }
                        } label: {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        }
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                    }
                
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        //        .padding(.vertical, 3)
    }
    
    //MARK: - 다이어리 작성자 프로필
    var diaryUserProfile: some View {
        
        HStack {
            //TODO: -유저 프로필 사진
//            ForEach(authStore.userList) { user in
//                if item.uid == user.id && user.profileImage != "" {
//                    WebImage(url: URL(string: user.profileImage))
//                        .resizable()
//                        .placeholder {
//                            Rectangle().foregroundColor(.gray)
//                        }
//                        .scaledToFill()
//                        .frame(width: UIScreen.screenWidth * 0.01)
//                        .clipShape(Circle())
//                } else {
                    Image(systemName: "person.fill")
                        .overlay {
                            Circle().stroke(lineWidth: 1)
                        }
//                }
//            }
            //유저 닉네임
            Text(item.diaryUserNickName)
                .font(.headline).fontWeight(.semibold)
            Spacer()
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
            }
            //MARK: - 일기 삭제 알림
            .alert("일기를 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
                Button("취소", role: .cancel) {
                    isShowingDeleteAlert = false
                }
                Button("삭제", role: .destructive) {
                    diaryStore.deleteDiaryCombine(diary: item)
                }
            }

        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
        .padding(.top, 5)
    }

    
    //MARK: - 제목
    var diaryTitle: some View {
        Text(item.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.vertical, 5)
    }
    
    //MARK: - 다이어리 공개 여부 - 잠금 했을때만 자물쇠 나오도록 설정
    var diaryIsPrivate: some View {
        Image(systemName: item.diaryIsPrivate ? "lock" : "" )
    }
    
    //MARK: - 내용
    var diaryContent: some View {
        Text(item.diaryContent)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    //MARK: - 캠핑장 이동
    var diaryCampingLink: some View {
        HStack {
            Image("1") //TODO: -캠핑장 사진 연동
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("캠핑장 이름")
                    .font(.headline)
                HStack {
                    Text("대구시 수성구") //TODO: 캠핑장 주소 -앞에 -시 -구 까지 짜르기
                    Spacer()
                    //방문일
                    Text("\(item.diaryVisitedDate.getKoreanDate())")
                        .font(.footnote)
                }
                .font(.subheadline)
            }
            .foregroundColor(.bcBlack)

        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.2)
                .shadow(color: .gray, radius: 3)

        }
        .foregroundColor(.clear)
    }

    
    //MARK: - 좋아요, 댓글, 타임스탬프
    var diaryInfo: some View {
        HStack {
            Text("좋아요 \(item.diaryLike)")
            Text("댓글 8")
            Spacer()
            Text("\(TimestampToString.dateString(item.diaryCreatedDate)) 전")
        }
        .font(.system(.subheadline))
        .padding(.vertical)
    }
}


struct DiaryCellView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCellView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
        .environmentObject(AuthStore())
        .environmentObject(DiaryStore())
        
    }
}
