//
//  RealtimeCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import Firebase

struct RealtimeCampingView: View {
    //샘플 데이터입니다.
    var realtimeCampingSampleDataList = [
        Diary(id: "", uid: "", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true)
        ]

    var body: some View {
        ScrollView {
            ForEach(realtimeCampingSampleDataList, id: \.self) { item in
                //네비게이션 화살표 없애기
                VStack {
                    NavigationLink {
                        DiaryDetailView(item: item)
                    } label: {
                        RealtimeCampingCellView(item: item)
                    }
                    .foregroundColor(Color("BCBlack"))
                }
            }
        }
        .padding()
    }
}

//MARK: - 샘플 데이터 구조체입니다.
struct RealtimeCampingSampleData: Hashable {
    var picture: String
    var title: String
    var user: String
    var date: String
    var like: String
    var comment: String
    var content: String
}


struct RealtimeCampingView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingView()
    }
}
