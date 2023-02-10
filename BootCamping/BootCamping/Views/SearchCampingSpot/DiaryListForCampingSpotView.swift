////
////  DiaryListForCampingSpotView.swift
////  BootCamping
////
////  Created by Donghoon Bae on 2023/02/10.
////
//
//import SwiftUI
//
//struct DiaryListForCampingSpotView: View {
//    var diaryList: [Diary]
//    
//    var body: some View {
//        VStack {
//            ScrollView(showsIndicators: false) {
//                LazyVStack {
//                    ForEach(diaryList.indices, id: \.self) { index in
//                        if diary.diaryIsPrivate == false {
//                            DiaryCellView(item: diaryStore.userInfoDiaryList[index])
//                                .task {
//                                    if index == diaryStore.userInfoDiaryList.count - 1 {
//                                        Task {
//                                            diaryStore.nextGetDiaryCombine()
//                                        }
//                                    }
//                                }
//                        }
//                    }
//                }
//            }
//    }
//}
//
//struct DiaryListForCampingSpotView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryListForCampingSpotView()
//    }
//}
