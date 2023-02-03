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
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var authStore: AuthStore
    //선택한 다이어리 정보 변수입니다.
    var item: Diary
    
    var body: some View {
        VStack(alignment: .leading) {
            diaryImage
            diaryTitle
            diaryContent
            diaryCampingLink
            diaryInfo
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
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                        .aspectRatio(contentMode: .fill)
                    
                }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
    
    //MARK: - 제목
    var diaryTitle: some View {
        HStack {
            Text(item.diaryTitle)
                .font(.system(.title3, weight: .semibold))
                .padding()
            Spacer()
            Button {
                diaryStore.deleteDiaryCombine(diary: item)
            } label: {
                Image(systemName: "trash")
                    .padding()
            }

        }
    }
    
    //MARK: - 내용
    var diaryContent: some View {
        Text(item.diaryContent)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
    }
    
    //MARK: - 캠핑장 이동
    var diaryCampingLink: some View {
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
        .foregroundColor(.clear)
        .padding()
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
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct DiaryCellView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingCellView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
        .environmentObject(AuthStore())
        
    }
}
