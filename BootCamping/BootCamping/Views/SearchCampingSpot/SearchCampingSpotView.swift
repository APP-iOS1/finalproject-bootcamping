//
//  SearchCampingSpotView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//
import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift
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
        Filtering(filterViewLocation: "incheon", filters: ["경기도", "인천시"], filterNames: ["경기·인천"]),
        Filtering(filterViewLocation: "gangwon", filters: ["강원도"], filterNames: ["강원"]),
        Filtering(filterViewLocation: "Chungcheong", filters: ["충청남도", "충청북도"], filterNames: ["충청"]),
        Filtering(filterViewLocation: "busan", filters: ["경상남도", "경상북도", "부산시"], filterNames: ["경상·부산"]),
        Filtering(filterViewLocation: "jeju", filters: ["전라남도", "전라북도", "제주도"], filterNames: ["전라·제주"]),
    ]
    var campingSpotListForViewFilter: [Filtering] = [
        Filtering(filterViewLocation: "mountain", filters: ["산"], filterNames: ["산"]),
        Filtering(filterViewLocation: "ocean", filters: ["해변"], filterNames: ["해변·바다"]),
        Filtering(filterViewLocation: "valley", filters: ["계곡"], filterNames: ["계곡"]),
        Filtering(filterViewLocation: "forest", filters: ["숲"], filterNames: ["숲"]),
        Filtering(filterViewLocation: "river", filters: ["강", "호수"], filterNames: ["강·호수"]),
        Filtering(filterViewLocation: "island", filters: ["섬"], filterNames: ["섬"]),
    ]
    var cols = [
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30),
    ]
    
    //MARK: 추천 캠핑장 사진 및 이름
    var campingSpotADImage = ["e", "a", "g", "d"]
    var campingSpotADName = ["2879", "100040", "2727", "2860"]
    var campingSpotADAddress = ["대구광역시 달서구", "서울특별시 마포구", "경기도 광명시", "경기도 하남시"]
    
    //MARK: 추천 캠핑장 그리드
    let columns2 = Array(repeating: GridItem(.flexible()), count: 2)
    
    //MARK: searchable
    @State var searchText: String = ""
    
    @FocusState var isTextFieldFocused: Bool
    
    @State private var isLoading: Bool = false
    @State var keywordForSearching: String = ""
    @State var keywordForParameter: String = ""
    @State var isSearching: Bool = false
    

    var body: some View {
        VStack {
            ScrollView {
                campingSpotListSearchTextfield
                if !isSearching {
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
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("캠핑장 검색")
                        .font(.title2.bold())
                }
                if isSearching {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isSearching.toggle()
                            keywordForSearching = ""
                            campingSpotStore.campingSpotList = []
                            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: campingSpotADName))
                        } label: {
                            Text("취소")
                        }

                    }
                }
            }
        }
        .task {
            campingSpotStore.campingSpotList = []
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: campingSpotADName))
        }
        .onTapGesture {
            dismissKeyboard()
        }
        .onDisappear {
            dismissKeyboard()
        }
    }
}

extension SearchCampingSpotView {
    
    private var campingSpotListSearchTextfield: some View {
        VStack {
            TextField("\(Image(systemName: "magnifyingglass"))캠핑하실 지역을 검색해 주세요", text: $keywordForSearching)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .showClearButton($keywordForSearching)
                .padding(.horizontal, UIScreen.screenWidth*0.03)
                .submitLabel(.search)
                .onSubmit {
                    keywordForParameter = keywordForSearching
                    isLoading = false
                    isSearching = true
                    campingSpotStore.campingSpotList.removeAll()
                    campingSpotStore.lastDoc = nil
                    //For Googole Analystic
                    Analytics.logEvent("Search", parameters: [
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
                                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter))
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
//                                                    campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotName: keywordForParameter, lastDoc: campingSpotStore.lastDoc))
                                                    print("WOW")
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
            Text("지역별 캠핑장")
                .font(.title3.bold())
                .padding(.leading, 5)
            
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(campingSpotListForLocationFilter, id: \.id) { campingSpot in
                    NavigationLink {
                        CampingSpotListView(readDocuments: ReadDocuments(campingSpotLocation: campingSpot.filters))
                    } label: {
                        VStack {
                            Image("\(campingSpot.filterViewLocation)")
                                .resizeImage(imgName: "\(campingSpot.filterViewLocation)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .cornerRadius(50)
                                .clipped()
                            if campingSpot.filterNames.count > 1 {
                                HStack {
                                    ForEach(campingSpot.filterNames, id: \.self) { location in
                                        Text("\(location)")
                                            .font(.callout)
                                    }
                                }
                            } else {
                                Text("\(campingSpot.filterNames.first!)")
                                    .font(.callout)
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
            Text("전망별 캠핑장")
                .font(.title3.bold())
                .padding(.leading, 5)
            
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(campingSpotListForViewFilter, id: \.id) { campingSpot in
                    NavigationLink {
                        CampingSpotListView(readDocuments: ReadDocuments(campingSpotView: campingSpot.filters))
                    } label: {
                        VStack {
                            Image("\(campingSpot.filterViewLocation)")
                                .resizeImage(imgName: "\(campingSpot.filterViewLocation)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .cornerRadius(50)
                                .clipped()
                            if campingSpot.filterNames.count > 1 {
                                HStack {
                                    ForEach(campingSpot.filterNames, id: \.self) { location in
                                        Text("\(location)")
                                            .font(.callout)
                                    }
                                }
                            } else {
                                Text("\(campingSpot.filterNames.first!)")
                                    .font(.callout)
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
            Text("부트캠핑이 추천해요!")
                .font(.title3.bold())
                .padding(.leading, 5)
            
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
                            if index == 999 {
                                VStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.bcGreen)
                                        .opacity(0.5)
                                        .frame(width: 25, height: 15)
                                        .overlay{
                                            Text("AD")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                }
                                .padding(.trailing, -4)
                            }

                            Text(campingSpotStore.campingSpotList[index].facltNm)
                        }
                        .frame(height: 8)
                        .padding(.top, 6)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .padding(.trailing, -3)
                                .padding(.vertical, 3)
                            Text("\(campingSpotStore.campingSpotList[index].doNm) \(campingSpotStore.campingSpotList[index].sigunguNm)")
                                .font(.caption)
                                .padding(.vertical, 3)
                        }
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}
