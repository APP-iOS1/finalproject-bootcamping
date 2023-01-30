//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//
import SwiftUI
import Firebase

struct DiaryDetailView: View {
    @State var sampleText: String = "품었기 불어 새 교향악이다. 되려니와, 내는 가슴에 얼음과 이상 내려온 영원히 전인 것이다. 그들의 청춘의 눈이 뼈 있는 위하여, 이것이다. 이것을 우는 어디 인간에 있으랴? 그림자는 못하다 없으면 그들은 것이다. 청춘의 그들을 영락과 듣는다. 보배를 공자는 능히 사막이다. 내는 청춘에서만 보내는 피고 그들에게 불어 끓는다. 심장의 풀이 오아이스도 두손을 밝은 이상은 행복스럽고 있다. 천고에 생생하며, 꽃 작고 따뜻한 이상이 두기 보라."
    @State var diaryComment: String = ""
    
    var item: Diary
    
    var body: some View {
        VStack {
            ScrollView{
                VStack {
                    DiaryDetailTitleView
                    DiaryDetailTapView
                    DiaryDetailInfoView
                    Divider()
                    DiaryCommetView
                }
            }
            Divider()
            DiaryCommetInputView
        }
    }
    // MARK: -View : 프로필사진, 작성자 이름, 수정 삭제버튼
    private var DiaryDetailTitleView : some View {
        HStack{
            Circle()
                .frame(width: 25)
            Text("햄뿡이")
            Image(systemName: "lock")
            Spacer()
            //삭제 수정
            Image(systemName: "ellipsis")
        }
        .padding(.horizontal)
    }

    // MARK: -View : 캠핑장 사진 탭뷰
    private var DiaryDetailTapView : some View {
        
        TabView{
            Image("1")
                .resizable()
            Image("2")
                .resizable()
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        
    }

    // MARK: -View : 다이어리 상세 정보
    private var DiaryDetailInfoView : some View {
        VStack(alignment: .leading) {
            Text("충주호 보면서 불멍하기")
                .font(.system(.title2, weight: .semibold))
                .padding(.bottom, 1)
            HStack {
                Image("1")
                    .resizable()
                    .frame(width: 50, height: 50)
                    
                VStack(alignment: .leading) {
                    Text("충주호 캠핑장")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("충북 충주")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, 1)
                }
            }
            Text("방문일: 2023.01.18")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 1)
            HStack {
                Image(systemName: "heart")
                Text("3")
                    .padding(.leading, -8)
                Image(systemName: "bubble.left")
                Text("8")
                    .padding(.leading, -8)
                Spacer()
            }
            .padding(.bottom, 1)
            Text(sampleText)
                .padding(.bottom, 1)
            Text("15분 전")
                .foregroundColor(.gray)

        }
        .padding(.horizontal)
    }


    // MARK: -View : 댓글 뷰
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
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text("햄뿡이")
                        .font(.title3)
                    Text("너무 좋아보여요")
                }
            }
            HStack{
                Circle()
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text("햄뿡이")
                        .font(.title3)
                    Text("너무 좋아보여요")
                }
            }
            HStack{
                Circle()
                    .frame(width: 30)
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
                .frame(width: 30)
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

struct DiaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryDetailView(item: Diary(id: "", uid: "", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
    }
}
