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
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    
    @State private var isLoading: Bool = false
    
    var readDocuments: ReadDocuments
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                if !isLoading {
                    LazyVStack {
                        ForEach(0...2, id: \.self) { _ in
                            EmptyCampingSpotListCell()
                                
                        }
                    }
                    .task {
                        campingSpotStore.readCampingSpotListCombine(readDocument: readDocuments)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            if !campingSpotStore.campingSpotList.isEmpty {
                                isLoading.toggle()
                            }
                        }
                    }
                } else {
                    LazyVStack {
                        ForEach(campingSpotStore.campingSpotList.indices, id: \.self) { index in
                            NavigationLink {
                                CampingSpotDetailView(places: campingSpotStore.campingSpotList[index])
                            } label: {
                                CampingSpotListRaw(item: campingSpotStore.campingSpotList[index])
                                    .padding(.bottom,40)
                            }
                            .task {
                                if index == campingSpotStore.campingSpotList.count - 1 {
                                    Task {
                                        campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotLocation: readDocuments.campingSpotLocation, campingSpotView: readDocuments.campingSpotView, campingSpotName: readDocuments.campingSpotName, campingSpotContenId: readDocuments.campingSpotContenId, lastDoc: campingSpotStore.lastDoc))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("캠핑장 리스트")
            }
        }
    }
}


struct CampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CampingSpotListView(readDocuments: ReadDocuments())
                .environmentObject(CampingSpotStore())
        }
    }
}
