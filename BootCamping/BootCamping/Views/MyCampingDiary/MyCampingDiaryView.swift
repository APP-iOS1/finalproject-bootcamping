//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct MyCampingDiaryView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    
    var diaryDatas = [
        RealtimeCampingSampleData(picture: "1", title: "충주호 보면서 불멍하기", user: "by User", date: "15분 전", like: "좋아요 3", comment: "댓글 8", content: "충주호 캠핑월드 겨우 한자리 잡았는데 후회없네요ㅠㅠ 뷰가 짱이라서 마음에 들...  더 보기"),
        RealtimeCampingSampleData(picture: "2", title: "충주호 보면서 불멍하기", user: "by User", date: "15분 전", like: "좋아요 3", comment: "댓글 8", content: "충주호 캠핑월드 겨우 한자리 잡았는데 후회없네요ㅠㅠ 뷰가 짱이라서 마음에 들...  더 보기"),
        RealtimeCampingSampleData(picture: "3", title: "충주호 보면서 불멍하기", user: "by User", date: "15분 전", like: "좋아요 3", comment: "댓글 8", content: "충주호 캠핑월드 겨우 한자리 잡았는데 후회없네요ㅠㅠ 뷰가 짱이라서 마음에 들...  더 보기"),
        RealtimeCampingSampleData(picture: "4", title: "충주호 보면서 불멍하기", user: "by User", date: "15분 전", like: "좋아요 3", comment: "댓글 8", content: "충주호 캠핑월드 겨우 한자리 잡았는데 후회없네요ㅠㅠ 뷰가 짱이라서 마음에 들...  더 보기"),
        ]
    var body: some View {
//        List(diaryDatas, id: \.self) { diaryData in
//            //네비게이션 화살표 없애기
//            VStack {
//                ZStack {
//                    NavigationLink {
//                        DiaryDetailView()
//                    } label: {
//                        EmptyView()
//                    }
//                    .opacity(0) //화살표 투명하게 만들기
//
//                    DiaryCellView(item: diaryData)
//                }
//            }
//        }
        List(diaryStore.diaryList) { diaryData in
            //네비게이션 화살표 없애기
            VStack {
                ZStack {
                    NavigationLink {
                        DiaryDetailView()
                    } label: {
                        EmptyView()
                    }
//                    .opacity(0) //화살표 투명하게 만들기
                    
                    DiaryCellView(item: diaryData)
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


//struct MyCampingDiaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyCampingDiaryView()
//    }
//}
