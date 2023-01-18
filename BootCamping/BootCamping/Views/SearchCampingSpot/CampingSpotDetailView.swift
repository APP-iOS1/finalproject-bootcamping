//
//  CampingSpotDetailView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/01/18.
//

import SwiftUI
import CoreLocation
import MapKit

struct CampingSpotDetailView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    
    var body: some View {
        let images = ["10", "9", "8"]
        let diary = ["1", "2", "3"]
     //   let services = ["전기", "무선인터넷", "장작판매", "온수", "트렘폴린", "물놀이장", "놀이터", "산책로", "운동장", "운동시설", "마트.편의점"]
        ZStack {
            ScrollView {
                TabView {
                    ForEach(images, id: \.self) { item in
                        Image(item).resizable().scaledToFill()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(width: UIScreen.screenWidth, height: 300)
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text("디노담양힐링파크") // 캠핑장 이름
                            .font(.title)
                            .padding(.top, -15)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.gray)
                            Text("전남 담양군 봉산면 탄금길 9-26") // 캠핑장 주소
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Group {
                        Text("보배를 무엇을 눈에 끓는다. 구하지 일월과 얼음 아니한 들어 군영과 뜨고, 크고 가는 약동하다. 위하여 풀밭에 착목한는 그들의 예가 붙잡아 주는 창공에 것이다.보라, 있는가? 새 미묘한 고동을 만물은 새가 때문이다. 이상은 예가 용감하고 이성은 있는 보이는 그들을 못하다 방황 하였으며, 봄바람이다. 더운지라 무엇을 그들의 얼음에 힘차게 열매를 철환하였는가? 가지에 천자만홍이 날카로우나 약동하다. ")
                            .lineSpacing(7)
                    }
                    .padding(7)
                    
                    Divider()
                        .padding()
                    Group {
                        Text("편의시설 및 서비스")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Image("facilities")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    Divider()
                        .padding()
                    
                    Group {
                        Text("위치 보기")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                            .frame(width: UIScreen.screenWidth * 0.84, height: 250)
                            .cornerRadius(10)
                     
                    }
                    
                    Divider()
                        .padding()
                    
                    Group {
                        HStack {
                            Text("관련 캠핑일기")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Spacer()
                            
                            Button {
                            } label: {
                                Text("더 보기")
                                    .font(.callout)
                                    .padding(.bottom, 10)
                                    .padding(.trailing, 10)
                            }
                        }
                        ScrollView(.horizontal) {
                            HStack {
                                    ForEach(diary, id: \.self) { item in
                                        VStack(alignment: .leading) {
                                        Image(item).resizable()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(7)
                                            .scaledToFill()
                                        Text("충주호 캠핑장 명당자리 예약하는 방법")
                                                .font(.callout)
                                                .frame(width: 120)
                                                .lineLimit(2)
                                    }
                            }
                                
                                
                                
//                                VStack(alignment: .leading) {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .frame(width: 120, height: 120)
//                                    Text("캠핑장 다녀옴")
//                                }
//                                VStack {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .frame(width: 120, height: 120)
//                                    Text("제목 대충 뭐라고")
//                                }
//                                VStack {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .frame(width: 120, height: 120)
//                                    Text("지으면 되나")
//                                }
                                
                            }
                        }
                    }
                    
                }
                .padding(30)
            }
        }
    }
}





struct CampingSpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotDetailView()
    }
}
