//
//  CampingSpotListSearchingView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/08.
//

import SwiftUI

struct CampingSpotListSearchingView: View {
    
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    
    var body: some View {
        VStack {
            TextField("여행지를 검색해주세요.", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
            if isSearching {
                CampingSpotListView(readDocuments: ReadDocuments(campingSpotLocation: [keywordForParameter]))
            } else {
                Spacer()
                Text("최근검색 리스트로")
                Spacer()
            }
        }
        .onSubmit {
            keywordForParameter = keywordForSearching
            isSearching = true
        }
    }
}

struct CampingSpotListSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotListSearchingView()
    }
}
