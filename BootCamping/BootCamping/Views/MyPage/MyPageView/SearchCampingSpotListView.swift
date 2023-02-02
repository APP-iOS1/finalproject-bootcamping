//
//  SearchCampingSpotListView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/01.
//

import SwiftUI

struct SearchCampingSpotListView: View {
    var fetchData: FetchData = FetchData()
    
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    
    @State var page: Int = 2
    
    //MARK: searchable
    @State var searchText: String = ""
    
    //MARK: 검색할 때 필터링하여 저장
    var filterCamping: [Item] {
        if searchText == "" { return campingSpotStore.campingSpotList }
        
        return campingSpotStore.campingSpotList.filter { $0.facltNm.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filterCamping, id: \.self) { campingSpot in
                    Text("\(campingSpot.facltNm)")
                }
            }
            .listStyle(.inset)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "캠핑장 이름을 검색해보세요")
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .onAppear{
            Task {
                campingSpotStore.campingSpotList = try await fetchData.fetchData(page: page)
            }
        }
    }
}

//struct SearchCampingSpotListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchCampingSpotListView()
//    }
//}
