//
//  SearchCampingSpotView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SDWebImageSwiftUI
import SwiftUI

struct SearchCampingSpotView: View {
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()

    @State var page: Int = 2
    
    //MARK: 광고 사진 - 수정 필요
    var adImage = ["ad1", "ad2", "ad3", "ad4"]
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @State var selection = 0
    
    //MARK: 캠핑장 필터 딕셔너리
    var campingSpotListForLocationFilter: [Filtering] = [
        Filtering(filterViewLocation: "seoul", filters: ["서울시"], filterNames: ["서울"]),
        Filtering(filterViewLocation: "incheon", filters: ["경기도", "인천시"], filterNames: ["경기", "인천"]),
        Filtering(filterViewLocation: "gangwon", filters: ["강원도"], filterNames: ["강원"]),
        Filtering(filterViewLocation: "Chungcheong", filters: ["충청남도", "충청북도"], filterNames: ["충청"]),
        Filtering(filterViewLocation: "busan", filters: ["경상남도", "경상북도", "부산시"], filterNames: ["경상", "부산"]),
        Filtering(filterViewLocation: "jeju", filters: ["전라남도", "전라북도", "제주도"], filterNames: ["전라", "제주"]),
    ]
    var campingSpotListForViewFilter: [Filtering] = [
        Filtering(filterViewLocation: "mountain", filters: ["산"], filterNames: ["산"]),
        Filtering(filterViewLocation: "ocean", filters: ["해변"], filterNames: ["해변", "바다"]),
        Filtering(filterViewLocation: "valley", filters: ["계곡"], filterNames: ["계곡"]),
        Filtering(filterViewLocation: "forest", filters: ["숲"], filterNames: ["숲"]),
        Filtering(filterViewLocation: "river", filters: ["강", "호수"], filterNames: ["강", "호수"]),
        Filtering(filterViewLocation: "island", filters: ["섬"], filterNames: ["섬"]),
    ]
    var cols = [
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
    ]
    
    //MARK: 추천 캠핑장 사진 및 이름
    var campingSpotADImage = ["e", "a", "g", "d"]
    var campingSpotADName = ["100002", "100040", "2727", "2860"]
    var campingSpotADAddress = ["대구광역시 달서구", "서울특별시 마포구", "경기도 광명시", "경기도 하남시"]
    
    //MARK: 추천 캠핑장 그리드
    let columns2 = Array(repeating: GridItem(.flexible()), count: 2)
    
    //MARK: searchable
    @State var searchText: String = ""

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading){
                    
                    // 광고 부분
//                    adCamping
                    
                    // 지역 선택
                    areaSelect
                        .padding(.top, 10)
                    
                    // 전망 선택
                    viewSelect
                    
                    // 추천 캠핑장
                    recommendCampingSpot
                    
                }//VStack 끝
                .padding(.horizontal, UIScreen.screenWidth*0.03)
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("BOOTCAMPING")
                        .font(.title.bold())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        CampingSpotListSearchingView(selectedFilter: filterCase.campingSpotAddr)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .task {
            campingSpotStore.campingSpotList = []
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: campingSpotADName))
        }
    }
}

extension SearchCampingSpotView {
    
    //MARK: 광고 부분
    private var adCamping: some View {
        TabView(selection: $selection){
            ForEach(0..<adImage.count, id: \.self) { index in
                Image(adImage[index])
                    .resizable()
                    
            }
        }
        .frame(width: UIScreen.screenWidth*0.9, height: UIScreen.screenHeight*0.09)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .cornerRadius(10)
        .onReceive(timer, perform: { t in
            selection += 1
            
            if selection == 4 {
                selection = 0
            }
        })
        .animation(.easeIn, value: selection)
        .padding(.bottom, 20)
    }

    //MARK: 지역 선택 부분 doNm
    private var areaSelect: some View {
        VStack(alignment: .leading) {
            Text("지역 선택")
                .font(.title.bold())
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(campingSpotListForLocationFilter, id: \.id) { campingSpot in
                    NavigationLink {
                        CampingSpotListView(readDocuments: ReadDocuments(campingSpotLocation: campingSpot.filters))
                    } label: {
                        VStack {
                            Image("\(campingSpot.filterViewLocation)")
                                .resizeImage(imgName: "\(campingSpot.filterViewLocation)")
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                            if campingSpot.filterNames.count > 1 {
                                HStack {
                                    ForEach(campingSpot.filterNames, id: \.self) { location in
                                        Text("\(location)")
                                    }
                                }
                            } else {
                                Text("\(campingSpot.filterNames.first!)")
                            }
                        }
                    }
                }
            }
            .foregroundColor(Color.bcBlack)
            .padding(.bottom, 30)
        }
    }
    
    //MARK: 전망 선택 부분 lctCl
    private var viewSelect: some View {
        VStack(alignment: .leading){
            Text("전망 선택")
                .font(.title.bold())
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(campingSpotListForViewFilter, id: \.id) { campingSpot in
                    NavigationLink {
                        CampingSpotListView(readDocuments: ReadDocuments(campingSpotView: campingSpot.filters))
                    } label: {
                        VStack {
                            Image("\(campingSpot.filterViewLocation)")
                                .resizeImage(imgName: "\(campingSpot.filterViewLocation)")
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                            if campingSpot.filterNames.count > 1 {
                                HStack {
                                    ForEach(campingSpot.filterNames, id: \.self) { location in
                                        Text("\(location)")
                                    }
                                }
                            } else {
                                Text("\(campingSpot.filterNames.first!)")
                            }
                        }
                    }
                }
            }
        }
        .foregroundColor(Color.bcBlack)
        .padding(.bottom, 30)
    }
    
    //MARK: 추천 캠핑장 선택 부분
    private var recommendCampingSpot: some View {
        VStack(alignment: .leading){
            Text("추천 캠핑장!")
                .font(.title.bold())
            LazyVGrid(columns: columns2) {
                ForEach(campingSpotStore.campingSpotList.indices, id:\.self){ index in
                    VStack(alignment: .leading){
                        NavigationLink {
                            CampingSpotDetailView(campingSpot: campingSpotStore.campingSpotList[index])
                        } label: {
                            WebImage(url: URL(string: campingSpotStore.campingSpotList[index].firstImageUrl == "" ? campingSpotStore.noImageURL : campingSpotStore.campingSpotList[index].firstImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.screenWidth * 0.44, height: UIScreen.screenWidth * 0.4)
                                .cornerRadius(10)
                                .clipped()
                        }
                        
                        HStack{

                            //MARK: 추천 캠핑장 제일 첫번째 거 광고 표시
                            if index == 0 {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.gray)
                                    .opacity(0.5)
                                    .frame(width: 25, height: 15)
                                    .overlay{
                                        Text("AD")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                            }

                            Text(campingSpotStore.campingSpotList[index].facltNm)
                        }
                        .frame(height: 8)
                        .padding(.top, 6)
                        HStack{
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .padding(.trailing, -7)
                            Text("\(campingSpotStore.campingSpotList[index].doNm) \(campingSpotStore.campingSpotList[index].sigunguNm)")
                                .font(.caption)
                        }
                        .padding(.bottom)
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}

//struct SearchCampingSpotView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack{
//            SearchCampingSpotView()
//        }
//    }
//}
