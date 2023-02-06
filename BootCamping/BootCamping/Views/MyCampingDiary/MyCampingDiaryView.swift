//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase

struct MyCampingDiaryView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var faceId: FaceId
    
    var body: some View {
        VStack {
            //TODO: -자기 다이어리 없으면 DiaryAddView나오도록
            //            ForEach(diaryStore.diaryList) { diaryData in
            //                if diaryData.uid == Auth.auth().currentUser?.uid && diaryData == nil {
            //                    DiaryAddView()
            //                }
            
            ScrollView(showsIndicators: false) {
                if faceId.isUnlocked {
                    VStack(alignment: .center) {
                        Text("일기가 잠겨있습니다.")
                            .padding()
                        
                        Button {
                            faceId.authenticate()
                        } label: {
                            Label("잠금 해제하기", systemImage: "lock")
                        }
                    }
                    
                } else {
                    //uid 비교해 자신이 쓴 글만 나오도록
                    ForEach(diaryStore.diaryList) { diaryData in
                        if diaryData.uid == Auth.auth().currentUser?.uid {
                            VStack {
                                //                            RealtimeCampingCellView(item: diaryData)
                                DiaryCellView(item: diaryData)
                                    .padding(.bottom, 20)
                            }
                            .onAppear {
                                diaryStore.readDiarysCombine()
                                print("\(diaryStore.diaryList)")
                            }
                        }
                    }
                }
                
            }
        }
        .onAppear(perform: faceId.authenticate)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("My Camping Diary")
                    .font(.title.bold())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    DiaryAddView()
                } label: {
                    Image(systemName: "plus")
                }
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
