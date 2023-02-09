//
//  SearchByCampingSpotNameView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/09.
//

import SwiftUI

struct SearchByCampingSpotNameView: View {
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    
    var body: some View {
        VStack {
            TextField("캠핑장 이름을 검색해주세요.", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
                .onSubmit {
                    keywordForParameter = keywordForSearching
                    isLoading = false
                    isSearching = true
                    campingSpotStore.campingSpotList.removeAll()
                    campingSpotStore.lastDoc = nil
                }
            if !isSearching {
                Text("키워드를 입력해주세요.")
                Spacer()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(campingSpotStore.campingSpotList.indices, id: \.self) { index in
//                            Text("\(campingSpotStore.campingSpotList[index])")
                            Text("\(index)")
                                .task {
                                    if index == campingSpotStore.campingSpotList.count - 1 {
                                        Task {
                                            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter, lastDoc: campingSpotStore.lastDoc))
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

struct SearchByCampingSpotNameView_Previews: PreviewProvider {
    static var previews: some View {
        SearchByCampingSpotNameView()
    }
}
