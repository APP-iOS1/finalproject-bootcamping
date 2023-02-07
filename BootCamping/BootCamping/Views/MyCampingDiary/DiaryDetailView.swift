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
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var commentStore: CommentStore
    
    @State var diaryComment: String = ""
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    
    @EnvironmentObject var diaryStore: DiaryStore
    
    @State var isBookmarked: Bool = false
    
    var item: Diary
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    diaryUserProfile
                    diaryDetailImage
                    Group {
//                        diaryDetailTitle //본문에 빼고 타이틀 위로 올리기?
                        diaryDetailContent
                        diaryCampingLink
                        diaryDetailInfo
                        Divider()
                        
//                        diaryCommetView //기존 더미 댓글
//                        List { //list로 댓글 삭제 기능 넣으려고 했는데 잘 안되네용ㅎㅎ
                            ForEach(commentStore.comments) { comment in
                                if comment.diaryId == item.id {
                                   DiaryCommentCellView(item: comment)
                                }
                            }
//                            .onDelete(perform: user.id == item.uid ? delete: nil)
//                        }
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                }
            }
            Divider()
            //댓글 작성
            diaryCommetInputView
        }
        .navigationTitle(item.diaryTitle)
        .onAppear{
            isBookmarked = bookmarkStore.checkBookmarkedDiary(diaryId: item.id)
            commentStore.fetchComment()
        }
        
    }
}


private extension DiaryDetailView {
    
    //글 작성 유저
    var user: User {
        authStore.userList.filter { $0.id == Auth.auth().currentUser?.uid }.first!
    }
    
    //MARK: - 댓글 삭제 기능
    func delete(at offsets: IndexSet) {
        commentStore.comments.remove(atOffsets: offsets)
    }
    
    //글 작성 유저 닉네임 변수
    var userNickName: String? {
        for user in authStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                return user.nickName
            }
        }
        return nil
    }
    //글 작성 유저 프로필 변수
    var userImage: String? {
        for user in authStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                return user.profileImageURL
            }
        }
        return nil
    }
    //MARK: - 다이어리 작성자 프로필
    var diaryUserProfile: some View {
        HStack {
            WebImage(url: URL(string: userImage ?? "기본이미지 넣기"))
                .resizable()
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.01)
                .clipShape(Circle())
            
            //유저 닉네임
            Text(userNickName ?? "부트캠퍼")
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
                
            }
            
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
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
    
    // MARK: -View : 다이어리 사진
    var diaryDetailImage: some View {
        TabView{
            ForEach(item.diaryImageURLs, id: \.self) { url in
                ZStack{
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
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
    
    // MARK: -View : 다이어리 제목
    var diaryDetailTitle: some View {
        Text(item.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.vertical, 5)
    }
    
    // MARK: -View : 다이어리 내용
    var diaryDetailContent: some View {
        Text(item.diaryContent)
            .multilineTextAlignment(.leading)
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
        }
        .foregroundColor(.clear)
    }
    
    
    //MARK: - 좋아요, 댓글, 타임스탬프
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
            Text("\(TimestampToString.dateString(item.diaryCreatedDate)) 전")
        }
        .foregroundColor(.bcBlack)
        .font(.system(.subheadline))
        .padding(.vertical, 5)
    }
    
    // MARK: -View : 댓글 뷰
    //TODO: -댓글 연동
    private var diaryCommetView : some View {
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
    }
    
    // MARK: -View : 댓글 작성
    private var diaryCommetInputView : some View {
        
        HStack {
            Circle()
                .frame(width: 35)
            TextField("댓글을 적어주세요", text: $diaryComment, axis: .vertical)
            
            Button {
                commentStore.addComment(Comment(id: UUID().uuidString, diaryId: item.id, uid: Auth.auth().currentUser?.uid ?? "", nickName: userNickName ?? "", profileImage: userImage ?? "", commentContent: diaryComment, commentCreatedDate: Timestamp()))
                commentStore.fetchComment()
            } label: {
                Image(systemName: "arrowshape.turn.up.right.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
}

struct DiaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryDetailView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "용감하고 인류의 그들의 따뜻한 있음으로써 그러므로 봄바람이다. 힘차게 밥을 가슴이 용감하고 튼튼하며, 그들의 보는 새가 인간의 칼이다. 충분히 인생을 못할 곧 우리는 청춘은 인간의 황금시대다. 지혜는 찾아다녀도, 것은 못하다 어디 곳으로 꽃 봄날의 보라. 우는 예가 이상은 온갖 그것은 품었기 얼음 힘있다. 투명하되 그들의 밥을 창공에 주는 이상, 이상의 힘있다. 새 피가 가장 놀이 부패뿐이다. 그들은 원질이 든 무엇을 되려니와, 불어 우리는 노래하며 것이다. 대한 청춘의 곳이 바이며, 충분히 방황하였으며, 있는가? 그들은 거친 위하여, 살 때문이다.", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
        .environmentObject(AuthStore())
        .environmentObject(DiaryStore())
        .environmentObject(BookmarkStore())
    }
}
