//
//  SearchCampingSpotView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct SearchCampingSpotView: View {
    //MARK: 광고 사진 - 수정 필요
    var adImage = ["back", "camp", "car", "gl"]
    
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
    @State var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                
                //MARK: 광고 부분
                //TODO: 동훈님한테 광고 넘어가는거 배우기~
                TabView{
                    ForEach(adImage, id: \.self) { image in
                        Image(image)
                    }
                }
                .frame(width: .infinity, height: 100)
                .tabViewStyle(.page)
                .padding(.bottom, 30)
                
                                
                //MARK: 지역 선택 부분
                Text("지역 선택")
                    .font(.title.bold())
                LazyVGrid(columns: columns) {
                    ForEach(0..<areaName.count) { index in
                        VStack{
                            Image(areaImage[index])
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                            Text(areaName[index])
                        }
                    }
                }
                .padding(.bottom, 30)
                
                //MARK: 전망 선택 부분
                Text("전망 선택")
                    .font(.title.bold())
                LazyVGrid(columns: columns) {
                    ForEach(0..<viewName.count) { index in
                        VStack{
                            Image(viewImage[index])
                                .resizable()
                                .cornerRadius(50)
                                .frame(width: 90, height: 90)
                                .aspectRatio(contentMode: .fit)
                            Text(viewName[index])
                        }
                    }
                }
                .padding(.bottom, 30)
                
                //MARK: 추천 캠핑장 선택 부분
                Text("추천 캠핑장!")
                    .font(.title.bold())
                LazyVGrid(columns: columns2) {
                    ForEach(0..<campingSpotADName.count){ index in
                        VStack(alignment: .leading){
                            ZStack(alignment: .topTrailing){
                                Image(campingSpotADImage[index])
                                    .resizable()
                                    .cornerRadius(10)
                                    .frame(width: 150, height: 150)
                                    .aspectRatio(contentMode: .fit)
                                //MARK: 추천 캠핑장 제일 첫번째 거 광고 표시
                                if index == 0 {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.white)
                                        .opacity(0.2)
                                        .frame(width: 25, height: 15)
                                        .overlay{
                                            Text("AD")
                                                .font(.caption2)
                                        }
                                        .padding(3)
                                }
                            }
                            Text(campingSpotADName[index])
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
                
                
            }//VStack 끝
            .padding(.horizontal)
            .navigationTitle("BOOTCAMPING")
            .searchable(text: $searchText) //위치 제일 위만 되는듯
            //MARK: searchable 첫글자 대문자 X, 자동완성 X
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)

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
