//
//  CampingSpotListSearchingView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/08.
//

import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import SwiftUI

enum filterCase {
    case campingSpotName
    case campingSpotAddr
    case campingSpotContenId
}

struct CampingSpotListSearchingView: View {
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    
    var selectedFilter: filterCase
    
    var body: some View {
        VStack {
            TextField("\(Image(systemName: "magnifyingglass"))캠핑하실 지역을 검색해 주세요", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
                .submitLabel(.search)
                .onSubmit {
                    keywordForParameter = keywordForSearching
                    isLoading = false
                    isSearching = true
                    campingSpotStore.campingSpotList.removeAll()
                    campingSpotStore.lastDoc = nil
                    //For Googole Analystic
                    Analytics.logEvent(AnalyticsEventSearch, parameters: [
                        "UID" : "\(String(describing: Auth.auth().currentUser?.uid))",
                        "Email" : "\(String(describing: Auth.auth().currentUser?.email))",
                        "searchingKeyword" : "\(keywordForParameter)",
                      ])
                    //탭틱
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
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
                                switch selectedFilter {
                                case .campingSpotName:
                                    campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter))
                                case .campingSpotAddr:
                                    campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotAddr: keywordForParameter))
                                default:
                                    print(#function, "")
                                }
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                    isLoading.toggle()
                                }
                            }
                        } else {
                            LazyVStack {
                                if campingSpotStore.campingSpotList.isEmpty {
                                    Spacer()
                                    Text("검색 결과가 없습니다.")
                                    Spacer()
                                } else {
                                    ForEach(campingSpotStore.campingSpotList.indices, id: \.self) { index in
                                        NavigationLink {
                                            CampingSpotDetailView(campingSpot: campingSpotStore.campingSpotList[index])
                                        } label: {
                                            CampingSpotListRaw(item: campingSpotStore.campingSpotList[index])
                                                .padding(.bottom,40)
                                        }
                                        .task {
                                            if index == campingSpotStore.campingSpotList.count - 1 {
                                                Task {
                                                    switch selectedFilter {
                                                    case .campingSpotName:
                                                        campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter, lastDoc: campingSpotStore.lastDoc))
                                                    case .campingSpotAddr:
                                                        campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotAddr: keywordForParameter, lastDoc: campingSpotStore.lastDoc))
                                                    default:
                                                        print(#function, "")
                                                    }
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
            } else {
                Spacer()
            }
        }
    }
}



struct CampingSpotListSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotListSearchingView(selectedFilter: filterCase.campingSpotName)
    }
}
