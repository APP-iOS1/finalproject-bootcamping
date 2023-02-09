//
//  SearchByCampingSpotNameView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/09.
//

import SwiftUI

struct SearchByCampingSpotNameView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    
    @Binding var campingSpot: String
    
    var body: some View {
        VStack {
            TextField("여행지를 검색해주세요.", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
                .onSubmit {
                    keywordForParameter = keywordForSearching
                    isLoading = false
                    isSearching = true
                    campingSpotStore.campingSpotList.removeAll()
                    campingSpotStore.lastDoc = nil
                }
            if isSearching {
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false) {
                        if !isLoading {
                            VStack {
                                ProgressView()
                            }
                            .task {
                                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter))
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                    isLoading.toggle()
                                }
                            }
                        } else {
                            LazyVStack {
                                if campingSpotStore.campingSpotList.isEmpty {
                                    Spacer()
                                    Text("검색결과가 없습니다")
                                    Spacer()
                                } else {
                                    ForEach(campingSpotStore.campingSpotList.indices, id: \.self) { index in
                                        Button {
                                            campingSpot = campingSpotStore.campingSpotList[index].facltNm
                                            dismiss()
                                        } label: {
                                            HStack {
                                                SearchByCampingSpotNameRow(campingSpot: campingSpotStore.campingSpotList[index])
                                                Spacer()
                                            }
                                        }
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
            else {
                Spacer()
                Text("최근검색 리스트로")
                Spacer()
            }
        }
    }
}

struct SearchByCampingSpotNameRow: View {
    var campingSpot: Item
    
    var body: some View {
        Text("\(campingSpot.facltNm)")
            .foregroundColor(Color.bcBlack)
            .font(.headline)
    }
}
struct SearchByCampingSpotNameView_Previews: PreviewProvider {
    static var previews: some View {
        SearchByCampingSpotNameView(campingSpot: .constant(""))
    }
}
