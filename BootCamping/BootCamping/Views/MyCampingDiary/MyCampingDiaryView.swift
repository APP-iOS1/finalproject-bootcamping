//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MyCampingDiaryView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var faceId: FaceId
    
    @AppStorage("faceId") var usingFaceId: Bool? //페이스id 설정 사용하는지
    //faceId.isLocked // 페이스 아이디가 잠겨있는지.
    
    var body: some View {
        
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    if usingFaceId ?? true && faceId.islocked {
                        DiaryLockedView()
                    } else {
                        ForEach(diaryStore.diaryList) { diaryData in
                            if diaryData.uid == Auth.auth().currentUser?.uid {
                                VStack {
                                    DiaryCellView(item: diaryData)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                    }
                    
                }
                .background(Color.bcWhite)
            }
            //다이어리 비어있을때 추가 화면
            diaryEmptyView.zIndex(-1)
        }
        .onAppear {
            diaryStore.readDiarysCombine()
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
                NavigationLink {
                    DiaryAddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}


private extension MyCampingDiaryView {
    var diaryEmptyView: some View {
        VStack {
            Text("다이어리가 비어있습니다.")
                .font(.title3)
                .padding()

            NavigationLink {
                DiaryAddView()
            } label: {
                Text("다이어리 작성하러 가기")
            }
            .modifier(GreenButtonModifier())

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


