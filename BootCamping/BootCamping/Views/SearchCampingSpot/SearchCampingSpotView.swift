//
//  SearchCampingSpotView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

/*
 location
 seoul : 서울
 incheon : 경기 / 인천
 gangwon : 강원
 Chungcheong : 충청
 busan : 경상 / 부산
 jeju : 전라 / 제주
 
 view
 mountain : 산
 ocean : 바다 / 해변
 valley : 계곡
 forest : 숲
 river : 강 / 호수
 island : 섬
 */

struct SearchCampingSpotView: View {
    @EnvironmentObject var campingSpotStore: CampingSpotStore
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
        Filtering(filterViewLocation: "ocean", filters: ["바다", "해변"], filterNames: ["바다", "해변"]),
        Filtering(filterViewLocation: "valley", filters: ["계곡"], filterNames: ["계곡"]),
        Filtering(filterViewLocation: "forest", filters: ["숲"], filterNames: ["숲"]),
        Filtering(filterViewLocation: "river", filters: ["강", "호수"], filterNames: ["호수", "호수"]),
        Filtering(filterViewLocation: "island", filters: ["섬"], filterNames: ["섬"]),
    ]
    
    var cols = [
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
    ]
    
    //MARK: 추천 캠핑장 사진 및 이름
    var campingSpotADImage = ["e", "a", "g", "d"]
    var campingSpotADName = ["쿠니 캠핑장", "후니 글램핑", "미니즈 캠핑장", "소영 카라반"]
    var campingSpotADAddress = ["대구광역시 달서구", "서울특별시 마포구", "경기도 광명시", "경기도 하남시"]
    
    //MARK: 추천 캠핑장 그리드
    let columns2 = Array(repeating: GridItem(.flexible()), count: 2)
    
    //MARK: searchable
    @State var searchText: String = ""
    
    //MARK: 검색할때 필터링하여 저장
    var filterCamping: [Item] {
        if searchText == "" { return campingSpotStore.campingSpotList }
        //MARK: 검색 조건 정하기 - 현재: "캠핑장 이름, 주소, 전망" 검색 가능. -> 좋은 조건 생각나면 더 추가해주세용
        return campingSpotStore.campingSpotList.filter{$0.facltNm.lowercased().contains(searchText.lowercased()) || $0.addr1.lowercased().contains(searchText.lowercased()) || $0.lctCl.lowercased().contains(searchText.lowercased())}
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
                    .padding(.horizontal, UIScreen.screenWidth*0.03)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("BOOTCAMPING")
                                .font(.title.bold())
                        }
                    }
                }
            }
            else {
                if !filterCamping.isEmpty {
                    VStack{
                        ScrollView(showsIndicators: false) {
                            ForEach(filterCamping, id: \.self) { campingSpot in
                                NavigationLink {
                                    CampingSpotDetailView(places: campingSpot)
                                } label: {
                                    VStack{
                                        CampingSpotListRaw(item: campingSpot)
                                            .padding(.bottom,40)
                                    }
                                }
                            }
                        }
                    }
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
                campingSpotStore.campingSpotList = []
                campingSpotStore.campingSpots = []
//                campingSpotStore.lastDoc = nil
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
                                Text("\(campingSpot.filters.first!)")
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
                ForEach(0..<campingSpotADName.count, id:\.self){ index in
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

//struct SearchCampingSpotView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack{
//            SearchCampingSpotView()
//        }
//    }
//}
