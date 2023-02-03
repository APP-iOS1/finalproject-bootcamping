//
//  SearchCampingSpotListView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/01.
//

import SwiftUI

struct SearchCampingSpotListView: View {
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    @Environment(\.dismiss) private var dismiss

    //MARK: searchable
    @State var searchText: String = ""
    
    //MARK: 검색할 때 필터링하여 저장
    var filterCamping: [Item] {
        if searchText == "" { return campingSpotStore.campingSpotList }
        
        return campingSpotStore.campingSpotList.filter { $0.facltNm.lowercased().contains(searchText.lowercased()) }
    }
    
    @Binding var campingSpotName: String
    
    
    var body: some View {
        List {
            ForEach(filterCamping, id: \.self) { campingSpot in
                Button {
                    campingSpotName = campingSpot.facltNm
                    dismiss()
                    
                } label: {
                    
                    Text("\(campingSpot.facltNm)")
                }
            }
        }
        .listStyle(.plain)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("캠핑장 이름 검색하기")
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "캠핑장 이름을 검색해보세요")
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        
        
    }
}

struct SearchCampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SearchCampingSpotListView(campingSpotName: .constant(""))
                .environmentObject(CampingSpotStore())
        }
    }
}
