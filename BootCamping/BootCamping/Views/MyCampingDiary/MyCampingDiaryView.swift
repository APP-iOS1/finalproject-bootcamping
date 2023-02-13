//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AlertToast


struct MyCampingDiaryView: View {
    
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var faceId: FaceId
    //    @EnvironmentObject var commentStore: CommentStore
    
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    
    
    @AppStorage("faceId") var usingFaceId: Bool? //페이스id 설정 사용하는지
    //faceId.isLocked // 페이스 아이디가 잠겨있는지.
    
    var body: some View {
        NavigationStack{
            ZStack {
                VStack {
                    if usingFaceId ?? true && faceId.islocked {
                        DiaryLockedView()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack {
                                ForEach(diaryStore.myDiaryUserInfoDiaryList.indices, id: \.self) { index in
                                    DiaryCellView(item: diaryStore.myDiaryUserInfoDiaryList[index])
                                        .task {
                                            if index == diaryStore.myDiaryUserInfoDiaryList.count - 1 {
                                                Task {
                                                    diaryStore.nextGetMyDiaryCombine()
                                                }
                                            }
                                        }
                                    
                                }
                            }
                        }
                        .refreshable {
                            diaryStore.firstGetMyDiaryCombine()
                        }
                        .padding(.top)
                        .padding(.bottom, 1)
                    }
                    
                }
                .background(Color.bcWhite)
                //다이어리 비어있을때 추가 화면
                DiaryEmptyView().zIndex(-1)
                diaryStore.isProcessing ? Color.black.opacity(0.3) : Color.clear
                
            }
            .onAppear {
                if usingFaceId == true {
                    faceId.authenticate()
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("My Camping Diary")
                        .font(.title.bold())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink (destination: DiaryAddView())
                    {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("다이어리 만들기에 실패했습니다.. 다시 시도해 주세요.", isPresented: $diaryStore.isError) {
                Button("확인", role: .cancel) {
                    diaryStore.isError = false
                }
            }
            .toast(isPresenting: $diaryStore.isProcessing) {
                AlertToast(displayMode: .alert, type: .loading)
            }
        }
    }
}

struct MyCampingDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        MyCampingDiaryView()
            .environmentObject(DiaryStore())
            .environmentObject(FaceId())
    }
}


