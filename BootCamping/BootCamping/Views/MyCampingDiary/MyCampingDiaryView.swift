//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct MyCampingDiaryView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore

    var body: some View {
        ScrollView {
            ForEach(diaryStore.diaryList) { diaryData in
                //네비게이션 화살표 없애기
                VStack {
                    ZStack {
                        NavigationLink {
                            DiaryDetailView(item: diaryData)
                        } label: {
                            VStack {
                                DiaryCellView(item: diaryData)
                                Divider()
                            }
                        }
                        .foregroundColor(Color("BCBlack"))
                        .padding(.horizontal, UIScreen.screenWidth * 0.1)
                        .padding(.vertical, UIScreen.screenHeight * 0.01)
                        

                    }
                }
            }
            .onAppear {
                diaryStore.getData()
                print("\(diaryStore.diaryList)")
            }
            .listStyle(.plain)
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


//struct MyCampingDiaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyCampingDiaryView()
//    }
//}
