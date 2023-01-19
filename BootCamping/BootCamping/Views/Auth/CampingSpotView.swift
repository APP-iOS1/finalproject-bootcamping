//
//  CampingSpotView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/19.
//

import SwiftUI

struct CampingSpotView: View {
    @ObservedObject var placeStore: PlaceStore = PlaceStore()
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    var fetchData: FetchData = FetchData()
    @State var page: Int = 1
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button {
                    Task {
                        page += 1
                        placeStore.places.append(contentsOf: try await fetchData.fetchData(page: page))
                        print(placeStore.places)
                        for i in placeStore.places {
                            campingSpotStore.addCampingSpotList(i)
                        }
                        placeStore.places.removeAll()
                        print(placeStore.places)
                    }
                } label: {
                    Text("\(page) 넣는중")
                }
                Spacer()
            }
        }
    }
}

struct CampingSpotView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotView()
            .environmentObject(CampingSpotStore())
    }
}
