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
    
    @AppStorage("faceId") var usingFaceId: Bool? //페이스id 설정 사용하는지
    //faceId.isLocked // 페이스 아이디가 잠겨있는지.
    @AppStorage("isDiaryEmpty") var isDiaryEmpty: Bool = false
    
    var body: some View {
        
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
                    .onAppear {
                        diaryStore.readDiarysCombine()
                        print("\(diaryStore.diaryList)")
                    }
                    
                }
                
            }
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
