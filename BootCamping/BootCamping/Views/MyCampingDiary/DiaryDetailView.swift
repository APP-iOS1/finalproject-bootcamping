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
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var authStore: AuthStore
    
    @State var diaryComment: String = ""
    
    @State var isBookmarked: Bool = false
    var item: Diary
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    DiaryDetailImage
                    DiaryDetailTitle
                    DiaryDetailContent
                    diaryCampingLink
                    diaryDetailInfo
                    Divider()
                    DiaryCommetView
                }
            }
            Divider()
            DiaryCommetInputView
        }
        .onAppear{
            isBookmarked = checkBookmark(diaryId: item.id)
        }

    }
    
    func checkBookmark(diaryId: String) -> Bool {
        for user in authStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                if user.bookMarkedDiaries.contains(diaryId) { return true
                }
            }
        }
        return false
    }
}
// MARK: -View : 프로필사진, 작성자 이름, 수정 삭제버튼
//    private var DiaryDetailTitleView : some View {
//        HStack{
//            Circle()
//                .frame(width: 25)
//            Text("햄뿡이")
//            Image(systemName: "lock")
//            Spacer()
//            //삭제 수정
//            Image(systemName: "ellipsis")
//        }
//        .padding(.horizontal)
//    }

extension DiaryDetailView {
    // MARK: -View : 다이어리 사진
    var DiaryDetailImage: some View {
        TabView{
            ForEach(item.diaryImageURLs, id: \.self) { url in
                ZStack{
                    WebImage(url: URL(string: url))
                        .resizable()
                        .placeholder {
                            Rectangle().foregroundColor(.gray)
                        }
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                        .aspectRatio(contentMode: .fill)
                    Button {
                        isBookmarked.toggle()
                        if isBookmarked{
                            diaryStore.addBookmarkDiaryCombine(diaryId: item.id)
                        } else{
                            diaryStore.removeBookmarkDiaryCombine(diaryId: item.id)
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .offset(x:UIScreen.screenWidth*0.45, y: -UIScreen.screenWidth*0.45)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                }
                
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
    
    // MARK: -View : 다이어리 제목
    var DiaryDetailTitle: some View {
        Text(item.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding()
    }
    
    // MARK: -View : 다이어리 내용
    var DiaryDetailContent: some View {
        Text(item.diaryContent)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
    }
    
    //MARK: - 방문한 캠핑장 링크
    //TODO: - 캠핑장 정보 연결
    var diaryCampingLink: some View {
        NavigationLink {
            Text("캠핑장 정보 연결")
        } label: {
            HStack {
                Image("1") //TODO: -캠핑장 사진 연동
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.diaryAddress)
                        .font(.headline)
                    HStack {
                        Text(item.diaryAddress + "(대구시 수성구)") //TODO: -앞에 -시 -구 까지 짜르기
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
        }
        .foregroundColor(.clear)
        .padding()
    }
    
    //MARK: - 좋아요, 댓글, 유저 닉네임, 타임스탬프
    var diaryDetailInfo: some View {
        HStack {
            Button {
                //TODO: -좋아요 배열에 유저 추가되도록 연동
            } label: {
                Text("좋아요 \(item.diaryLike.count)")
                    .font(.body)
                    .padding(.horizontal, 3)
            }
            Button {
                //TODO: -댓글 연동, 누르면 키보드 나오면서 댓글 쓸 수 있도록 수정
            } label: {
                Text("댓글 8")
                    .font(.body)
                    .padding(.horizontal, 3)
            }
            Spacer()
            Text("by \(item.diaryUserNickName)")
            Text("|")
            Text("\(TimestampToString.dateString(item.diaryCreatedDate)) 전")
        }
        .foregroundColor(.bcBlack)
        .font(.system(.subheadline))
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    // MARK: -View : 댓글 뷰
    //TODO: -댓글 연동
    private var DiaryCommetView : some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("댓글")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 1)
                Spacer()
            }
            HStack{
                Circle()
                    .frame(width: 35)
                VStack(alignment: .leading) {
                    Text("햄뿡이")
                        .font(.title3)
                    Text("너무 좋아보여요")
                }
            }
            HStack{
                Circle()
                    .frame(width: 35)
                VStack(alignment: .leading) {
                    Text("햄뿡이")
                        .font(.title3)
                    Text("너무 좋아보여요")
                }
            }
            HStack{
                Circle()
                    .frame(width: 35)
                VStack(alignment: .leading) {
                    Text("햄뿡이")
                        .font(.title3)
                    Text("너무 좋아보여요")
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: -View : 댓글 작성
    private var DiaryCommetInputView : some View {
        
        HStack {
            Circle()
                .frame(width: 35)
            TextField("댓글을 적어주세요", text: $diaryComment, axis: .vertical)
            Button(action: {}) {
                Image(systemName: "arrowshape.turn.up.right.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
}

//struct DiaryDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryDetailView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "용감하고 인류의 그들의 따뜻한 있음으로써 그러므로 봄바람이다. 힘차게 밥을 가슴이 용감하고 튼튼하며, 그들의 보는 새가 인간의 칼이다. 충분히 인생을 못할 곧 우리는 청춘은 인간의 황금시대다. 지혜는 찾아다녀도, 것은 못하다 어디 곳으로 꽃 봄날의 보라. 우는 예가 이상은 온갖 그것은 품었기 얼음 힘있다. 투명하되 그들의 밥을 창공에 주는 이상, 이상의 힘있다. 새 피가 가장 놀이 부패뿐이다. 그들은 원질이 든 무엇을 되려니와, 불어 우리는 노래하며 것이다. 대한 청춘의 곳이 바이며, 충분히 방황하였으며, 있는가? 그들은 거친 위하여, 살 때문이다.", diaryImageNames: [""], diaryImageURLs: [
//            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
//    }
//}
