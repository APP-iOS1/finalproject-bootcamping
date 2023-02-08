//
//  CampingSpotListSearchingView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/08.
//

import SwiftUI

struct CampingSpotListSearchingView: View {
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var isSearching: Bool = false
    
    
    var body: some View {
        VStack {
            TextField("여행지를 검색해주세요.", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
                .onSubmit {
                    isSearching = true
                }
            if isSearching {
                VStack {
                    ScrollView(showsIndicators: false) {
                        if !isLoading {
                            LazyVStack {
                                ForEach(0...2, id: \.self) { _ in
                                    EmptyCampingSpotListCell()
                                }
                            }
                            .task {
                                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotAddr: keywordForSearching))
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
//                                        if index == campingSpotStore.campingSpotList.count - 1 && campingSpotStore.lastDoc != nil {
                                        if index == campingSpotStore.campingSpotList.count - 1{
                                            Task {
                                                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotAddr: keywordForSearching, lastDoc: campingSpotStore.lastDoc))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Spacer()
                Text("최근검색 리스트로")
                Spacer()
            }
        }
    }
}



struct CampingSpotListSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotListSearchingView()
    }
}
