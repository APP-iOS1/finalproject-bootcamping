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
                            LazyVStack {
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
        .padding(.horizontal, UIScreen.screenHeight * 0.03)
    }
}

struct SearchByCampingSpotNameRow: View {
    var campingSpot: Item
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: campingSpot.firstImageUrl)) //TODO: -캠핑장 사진 연동
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(campingSpot.facltNm)
                    .font(.headline)
                HStack {
                    Text(campingSpot.addr1)
                    //TODO: 캠핑장 주소 -앞에 -시 -구 까지 짜르기
                        .font(.footnote)
                        .padding(.vertical, 2)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .foregroundColor(.bcBlack)
            
        }
        .padding(10)
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.bcDarkGray, lineWidth: 1)
                    .opacity(0.3)
            )
    }
}

struct SearchByCampingSpotNameView_Previews: PreviewProvider {
    static var previews: some View {
//        SearchByCampingSpotNameView(campingSpot: .constant(""))
        Text("")
    }
}
