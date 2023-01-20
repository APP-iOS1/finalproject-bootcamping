//
//  CampingSpotListView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/18.
//

import SwiftUI
//import ExpandableText     // 패키지 또 추가하면 충돌날거같아서 일단 코드만 추가해둠~

struct CampingSpotListView: View {
    
    @EnvironmentObject var campingSpotStore: CampingSpotStore

    //TODO: 북마크 만들기
    var body: some View {
        List {
            ForEach(campingSpotStore.campingSpotList, id: \.contentId) { campingSpot in
//                ZStack{
//                    NavigationLink {
//                        CampingSpotDetailView(campingSpot: campingSpot)
//                    } label: {
//                        CampingSpotListCell(campingSpot: campingSpot)
//                            .padding(.horizontal, UIScreen.screenWidth*0.1)
//
//                    }
//                    .opacity(0)
//                }
                Text("test")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("캠핑 모아보기")
            }
        }
        .task {
            campingSpotStore.fetchCampingSpot()
        }
    }
}


struct CampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CampingSpotListView()
                .environmentObject(CampingSpotStore())
        }
    }
}
