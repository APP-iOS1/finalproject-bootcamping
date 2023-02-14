//
//  RealtimeCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import Firebase
import AlertToast


struct RealtimeCampingView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var commentStore: CommentStore
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList, id: \.self) { userInfoDiary in
                        
                        DiaryCellView(item: userInfoDiary)
                            .task {
                                guard let index = diaryStore.realTimeDiaryUserInfoDiaryList.firstIndex(where: { $0.diary.id == userInfoDiary.diary.id}) else { return }
                                if index % 5 == 4 {
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
            .alert("다이어리 만들기에 실패했습니다.. 다시 시도해 주세요.", isPresented: $diaryStore.isError) {
                Button("확인", role: .cancel) {
                    diaryStore.isError = false
                }
                
            }
            .toast(isPresenting: $diaryStore.isProcessing) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .padding(.bottom, 1)
        }
    }
}
