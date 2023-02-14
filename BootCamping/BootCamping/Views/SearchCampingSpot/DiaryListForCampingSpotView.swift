//
//  DiaryListForCampingSpotView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/10.
//

import SwiftUI

struct DiaryListForCampingSpotView: View {
    
    var contentId: String
    @StateObject var diaryStore: DiaryStore
    @StateObject var commentStore: CommentStore = CommentStore()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList, id: \.self) {  item in
                            DiaryCellView(item: item)
                        }
                    }
            }
        }
        .onAppear {
            diaryStore.readCampingSpotsDiariesCombine(contentId: contentId)
        }
    }
}
