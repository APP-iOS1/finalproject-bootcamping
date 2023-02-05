//
//  CampingSpotListView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
//import ExpandableText     // 패키지 또 추가하면 충돌날거같아서 일단 코드만 추가해둠~

struct CampingSpotListView: View {
    //TODO: 북마크 만들기
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    
    @State private var isLoading: Bool = false
    
    var campingSpotList: [Item]
    
    var body: some View {
        VStack{
            ScrollView(showsIndicators: false){
                LazyVStack {
                    ForEach(Array(campingSpotStore.campingSpotList.enumerated()), id: \.offset) { (index, camping) in
                        NavigationLink {
                            CampingSpotDetailView(places: camping)
                        } label: {
                            CampingSpotListRaw(item: camping)
                                .padding(.bottom,40)
                        }
                        .onAppear {
                            if index == campingSpotStore.campingSpotList.count - 1 {
                                Task {
                                    campingSpotStore.readCampingSpotListCombine()
                                    campingSpotStore.campingSpotList.append(contentsOf: campingSpotStore.campingSpots)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text("캠핑 모아보기")
                }
            }
        }
    }
}


struct CampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CampingSpotListView(campingSpotList: [])
                .environmentObject(CampingSpotStore())
        }
    }
}
