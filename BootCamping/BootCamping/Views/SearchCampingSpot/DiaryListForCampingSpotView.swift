//
//  DiaryListForCampingSpotView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/10.
//

import SwiftUI

struct DiaryListForCampingSpotView: View {
    
    var diaryList: [Diary]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryList.indices, id: \.self) { index in
                        if diaryList[index].diaryIsPrivate == false {
                            DiaryCellView(item: UserInfoDiary(diary: diaryList[index], user: User(id: "", profileImageName: "", profileImageURL: "", nickName: "", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: [])))
//                                .task {
//                                    if index == diaryList.count - 1 {
//                                        Task {
//                                            diaryStore.nextGetRealtimeDiaryCombine()
//                                        }
//                                    }
                                }
                        }
                    }
                }
            }
    }
}

//struct DiaryListForCampingSpotView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryListForCampingSpotView()
//    }
//}
