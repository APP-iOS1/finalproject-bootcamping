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
    
    var item: Diary
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Circle()
                    .frame(width: 25)
                Text(item.uid)
                Image(systemName: "lock")
                Spacer()
                //삭제 수정
                Image(systemName: "ellipsis")
            }
            .padding(3)
            
            ForEach(item.diaryImageURLs, id: \.self) { url in
                WebImage(url: URL(string: url))
                    .resizable()
                    .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                    .aspectRatio(contentMode: .fill)
            }
        
            Text(item.diaryTitle)
                .font(.system(.title3, weight: .semibold))
                .padding(3)
            HStack {
                Image("1")
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(item.diaryAddress)
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("충북 충주")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(3)
            HStack {
                Image(systemName: "heart")
                Text("3")
                    .padding(.leading, -8)
                Image(systemName: "bubble.left")
                Text("8")
                    .padding(.leading, -8)
                Spacer()
            }
            .padding(3)
            Text(item.diaryContent)
                .padding(3)
            Text("\(TimestampToString.dateString2(item.diaryCreatedDate))")
                .padding(3)
                .foregroundColor(.gray)

        }
    }
}

struct DiaryCellView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCellView(item: Diary(id: "", uid: "", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
    }
}
