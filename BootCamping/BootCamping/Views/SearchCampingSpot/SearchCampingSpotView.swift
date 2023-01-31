//
//  SearchCampingSpotView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct SearchCampingSpotView: View {
    var fecthData: FetchData = FetchData()
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    @State var page: Int = 2
    
    //MARK: 광고 사진 - 수정 필요
    var adImage = ["back", "camp", "car", "gl"]
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @State var selection = 0
    
    //MARK: 지역 사진 및 이름
    var areaImage = ["2", "Gyeonggi", "gangwon", "5", "busan", "jeju"]
    var areaName = ["서울", "경기 / 인천", "강원", "충청", "경상 / 부산", "전라 / 제주"]
    
    //MARK: 전망 사진 및 이름
    var viewImage = ["7", "8", "l", "12", "1", "9"]
    var viewName = ["산", "바다 / 해변", "강", "숲", "호수", "섬"]
    
    //MARK: 추천 캠핑장 사진 및 이름
    var campingSpotADImage = ["e", "a", "g", "d"]
    var campingSpotADName = ["쿠니 캠핑장", "후니 글램핑", "미니즈 캠핑장", "소영 카라반"]
    var campingSpotADAddress = ["대구광역시 달서구", "서울특별시 마포구", "경기도 광명시", "경기도 하남시"]
    
    //MARK: 지역, 전망 그리드
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    //MARK: 추천 캠핑장 그리드
    let columns2 = Array(repeating: GridItem(.flexible()), count: 2)
    
    //MARK: searchable
    @State var searchText: String = ""
    
    //MARK: 검색할때 필터링하여 저장
    var filterCamping: [Item] {
        if searchText == "" { return campingSpotStore.campingSpotList }
        return campingSpotStore.campingSpotList.filter{$0.facltNm.lowercased().contains(searchText.lowercased()) || $0.addr1.lowercased().contains(searchText.lowercased())}
    }
    
    var body: some View {
        NavigationView {
            if searchText == "" {
                ScrollView {
                    VStack(alignment: .leading){
                        
                        // 광고 부분
                        adCamping
                        
                        // 지역 선택
                        areaSelect
                        
                        // 전망 선택
                        viewSelect
                        
                        // 추천 캠핑장
                        recommendCampingSpot
                        
                    }//VStack 끝
                    .padding(.horizontal, UIScreen.screenWidth*0.1)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("BOOTCAMPING")
                                .font(.title.bold())
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if !filterCamping.isEmpty {
                    List {
                        ForEach(filterCamping, id: \.self) { campingSpot in
                            ZStack{
                                NavigationLink {
                                    CampingSpotDetailView(places: campingSpot)
                                } label: {
                                    campingSpotListCell(item: campingSpot)
                                }
                                .opacity(0)
                                campingSpotListCell(item: campingSpot)
                                    .padding(.horizontal, UIScreen.screenWidth*0.1)
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text("해당되는 캠핑장이 없습니다.")

                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "캠핑장, 지역 등을 검색해보세요")
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .onAppear{
            Task {
                campingSpotStore.campingSpotList = try await fecthData.fetchData(page: page)
            }
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
                    .cornerRadius(10)
            }
        }
        .frame(width: UIScreen.screenWidth*0.9, height: UIScreen.screenHeight*0.13)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(timer, perform: { t in
            selection += 1
            
            if selection == 4 {
                selection = 0
            }
        })
        .animation(.easeIn, value: selection)
        .padding(.bottom, 20)
    }
    
    //MARK: 지역 선택 부분
    private var areaSelect: some View {
        VStack(alignment: .leading){
            Text("지역 선택")
                .font(.title.bold())
            LazyVGrid(columns: columns) {
                ForEach(0..<areaName.count) { index in
                    VStack{
                        NavigationLink {
                            CampingSpotListView()
                        } label: {
                            Image(areaImage[index])
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        Text(areaName[index])
                    }
                }
            }
            .padding(.bottom, 30)
            
        }
    }
    
    //MARK: 전망 선택 부분
    private var viewSelect: some View {
        VStack(alignment: .leading){
            Text("전망 선택")
                .font(.title.bold())
            LazyVGrid(columns: columns) {
                ForEach(0..<viewName.count) { index in
                    VStack{
                        NavigationLink {
                            CampingSpotListView()
                        } label: {
                            Image(viewImage[index])
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        Text(viewName[index])
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    //MARK: 추천 캠핑장 선택 부분
    private var recommendCampingSpot: some View {
        VStack(alignment: .leading){
            Text("추천 캠핑장!")
                .font(.title.bold())
            LazyVGrid(columns: columns2) {
                ForEach(0..<campingSpotADName.count){ index in
                    VStack(alignment: .leading){
                        NavigationLink {
                       //     CampingSpotDetailView()
                        } label: {
                            Image(campingSpotADImage[index])
                                .resizable()
                                .cornerRadius(10)
                                .frame(height: 150)
                                .aspectRatio(contentMode: .fit)
                            
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

                            Text(campingSpotADName[index])
                        }
                        .frame(height: 8)
                        .padding(.top, 6)
                        HStack{
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .padding(.trailing, -7)
                            Text(campingSpotADAddress[index])
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

struct SearchCampingSpotView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SearchCampingSpotView()
        }
    }
}
