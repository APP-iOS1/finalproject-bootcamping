//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct MyCampingDiaryView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var faceId: FaceId
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                if faceId.isUnlocked {
                    VStack(alignment: .center) {
                        Text("일기가 잠겨있습니다.").padding()
                        
                        Button {
                            faceId.authenticate()
                        } label: {
                            Label("잠금 해제하기", systemImage: "lock")
                        }
                    }
                    
                } else {
                    ForEach(diaryStore.diaryList) { diaryData in
                        //네비게이션 화살표 없애기
                        VStack {
                            ZStack {
                                NavigationLink {
                                    DiaryDetailView(item: diaryData)
                                } label: {
                                    DiaryCellView(item: diaryData)
                                        .padding(.bottom,40)
                                }
                                .foregroundColor(.bcBlack)
                                .padding(.vertical, UIScreen.screenHeight * 0.01)
                            }
                        }
                    }
                    .onAppear {
                        diaryStore.readDiarysCombine()
                        print("\(diaryStore.diaryList)")
                    }
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
        }
        .onAppear(perform: faceId.authenticate)
    }
}


struct MyCampingDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        MyCampingDiaryView()
            .environmentObject(DiaryStore())
            .environmentObject(FaceId())
    }
}
