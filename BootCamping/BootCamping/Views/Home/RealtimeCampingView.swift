//
//  RealtimeCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import Firebase

struct RealtimeCampingView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var commentStore: CommentStore
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList.indices, id: \.self) { index in
                        
                        DiaryCellView(item: diaryStore.realTimeDiaryUserInfoDiaryList[index])
                            .task {
                                if index == diaryStore.realTimeDiaryUserInfoDiaryList.count - 1 {
                                    Task {
                                        diaryStore.nextGetRealtimeDiaryCombine()
                                    }
                                }
                            }
                        
                    }
                }
            }
            
            .refreshable {
                diaryStore.firstGetRealTimeDiaryCombine()
            }
            .padding(.top)
            .padding(.bottom, 1)
        }
    }
}
