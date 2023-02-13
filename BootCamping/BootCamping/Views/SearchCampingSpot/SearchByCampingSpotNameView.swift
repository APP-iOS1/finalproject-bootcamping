//
//  SearchByCampingSpotNameView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/09.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchByCampingSpotNameView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    
    @Binding var campingSpot: Item
    
    var body: some View {
        VStack {
            TextField("여행지를 검색해주세요.", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    keywordForParameter = keywordForSearching
                    isLoading = false
                    isSearching = true
                    campingSpotStore.campingSpotList.removeAll()
                    campingSpotStore.lastDoc = nil
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.03)
                
            if isSearching {
                VStack() {
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
                            LazyVStack(alignment: .center) {
                                if campingSpotStore.campingSpotList.isEmpty {
                                    Spacer()
                                    Text("검색결과가 없습니다")
                                    Spacer()
                                } else {
                                    ForEach(campingSpotStore.campingSpotList.indices, id: \.self) { index in
                                        Button {
                                            campingSpot = campingSpotStore.campingSpotList[index]
                                            dismiss()
                                        } label: {
                                            SearchByCampingSpotNameRow(campingSpot: campingSpotStore.campingSpotList[index])
                                                .padding(.horizontal, UIScreen.screenWidth * 0.03)
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
                    .padding(.bottom, 0.1)
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
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.bcDarkGray, lineWidth: 1)
            .opacity(0.3)
            .overlay (
                HStack {
                    WebImage(url: URL(string: campingSpot.firstImageUrl == "" ? CampingSpotStore().noImageURL : campingSpot.firstImageUrl))
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(5)
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(campingSpot.facltNm)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                        HStack {
                            Text(campingSpot.addr1)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 2)
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .foregroundColor(.bcBlack)
                    .padding()
                }
            )
            .frame(width: UIScreen.screenWidth * 0.94, height: 70)
    }
}
