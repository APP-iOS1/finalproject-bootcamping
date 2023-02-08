//
//  SearchCampingSpotListView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/08.
//

import SwiftUI

struct SearchCampingSpotListView: View {
    
    @State var keywordForSearching: String = ""
    
    var body: some View {
        VStack {
            TextField("여행지를 검색해주세요.", text: $keywordForSearching)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.bcBlack, lineWidth: 1)
                }
            CampingSpotListView(readDocuments: ReadDocuments())
        }
    }
}

struct SearchCampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCampingSpotListView()
    }
}
