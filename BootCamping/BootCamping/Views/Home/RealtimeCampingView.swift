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
    @EnvironmentObject var blockedUserStore: BlockedUserStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList.filter{ !wholeAuthStore.currnetUserInfo!.blockedUser.contains($0.diary.uid) }, id: \.self) { userInfoDiary in
                        DiaryCellView(item: userInfoDiary)
                            .task {
                                guard let index = diaryStore.realTimeDiaryUserInfoDiaryList.firstIndex(where: { $0.diary.id == userInfoDiary.diary.id}) else { return }
                                
                                if (index + 1) % 5 == 0 {
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
                //탭틱
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
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
