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
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    @State private var isShowingAcceptedToast = false
    @State private var isShowingBlockedToast = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList.filter{ !wholeAuthStore.currnetUserInfo!.blockedUser.contains($0.diary.uid) }, id: \.self) { item in
                        DiaryCellView(item: item, isShowingAcceptedToast: $isShowingAcceptedToast, isShowingBlockedToast: $isShowingBlockedToast)
                        }
                    }
            }
        }
        .onAppear {
            diaryStore.readCampingSpotsDiariesCombine(contentId: contentId)
        }
    }
}
