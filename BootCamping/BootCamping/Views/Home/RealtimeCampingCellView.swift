//
//  RealtimeCampingCellView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct RealtimeCampingCellView: View {
    
    var item: Diary
    
    var body: some View {
        VStack(alignment: .leading) {
            
            WebImage(url: URL(string: item.diaryImageURLs[0]))
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                .aspectRatio(contentMode: .fill)
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
            
            Text(item.diaryTitle)
                .font(.system(.title3, weight: .semibold))
                .padding()
            Text(item.diaryContent)
                .padding(.horizontal)
            
            HStack {
                Text(item.uid)
                Text("\(item.diaryCreatedDate)")
                Text(item.diaryLike)
//                Text(item.comment)
            }
            .font(.system(.subheadline))
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal)
                .padding(.bottom)

        }
    }
}

struct RealtimeCampingCellView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingCellView(item: Diary(id: "", uid: "", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
    }
}
