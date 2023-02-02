//
//  CampingSpotDetailView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/01/18.
//

import SwiftUI
import CoreLocation
import MapKit
import SDWebImageSwiftUI

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct CampingSpotDetailView: View {
    //    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5, longitude: 126.9),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State var annotatedItem: [AnnotatedItem] = []
    @State private var isBookmark: Bool = false
    
    var places: Item
    
    var body: some View {
        let images = ["10", "9", "8"]
        let diary = ["1", "2", "3"]
        
        ZStack {
            ScrollView(showsIndicators: false) {
                TabView {
                    ForEach(images, id: \.self) { item in
                        WebImage(url: URL(string: places.firstImageUrl))
                            .resizable().scaledToFill()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(width: UIScreen.screenWidth, height: 300)
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        HStack(alignment: .top) {
                            Text("\(places.facltNm)") // 캠핑장 이름
                                .font(.title)
                                .bold()
                            Spacer()
                            
                            Button {
                                isBookmark.toggle()
                            } label: {
                                Image(systemName: isBookmark ? "bookmark.fill" : "bookmark")
                                    .font(.title3)
                                    .foregroundColor(.bcGreen)
                            }
                            
                        }
                        .padding(.top, -15)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.gray)
                            Text("\(places.addr1)") // 캠핑장 주소
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 15)
                    }
                    
                    Group {
                        Text("\(places.intro)")
                            .lineSpacing(7)
                    }
                    
                    
                    Divider()
                        .padding(.vertical)
                    Group {
                        Text("편의시설 및 서비스")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        ServiceIcon(places: places)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    Group {
                        Text("위치 보기")
                            .font(.headline)
                            .padding(.bottom, 10)
                        NavigationLink {
                            FullMapView(annotatedItem: annotatedItem, region: region, places: places)
                        } label: {
                            Map(coordinateRegion: $region, interactionModes: [], annotationItems: annotatedItem) { item in
                                MapMarker(coordinate: item.coordinate, tint: Color.bcGreen)
                            }
                            .frame(width: UIScreen.screenWidth * 0.84, height: 250)
                            .cornerRadius(10)
                        }
                        
                        
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
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
                        ScrollView(.horizontal, showsIndicators: false) {
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
                            }
                        }
                    }
                }
                .padding(30)
            }
            .onAppear {
                region.center = CLLocationCoordinate2D(latitude: Double(places.mapY)!, longitude: Double(places.mapX)!)
                annotatedItem.append(AnnotatedItem(name: places.facltNm, coordinate: CLLocationCoordinate2D(latitude: Double(places.mapY)!, longitude: Double(places.mapX)!)))
            }
        }
    }
}

// 편의시설 및 서비스 아이콘 구조체
struct ServiceIcon: View {
    var places: Item
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 5개 한줄에 띄우려면 5개 넣으면 됨...!
    
    func switchServiceIcon(svc: String) -> String {
        
        switch svc {
        case "전기":
            return "plug"
        case "무선인터넷":
            return "wifi"
        case "장작판매":
            return "firewood"
        case "온수":
            return "hotwater"
        case "트렘폴린":
            return "trampoline"
        case "물놀이장":
            return "swim"
        case "놀이터":
            return "playfc"
        case "산책로":
            return "walk"
        case "운동장":
            return "ground"
        case "운동시설":
            return "sportfc"
        case "마트.편의점":
            return "store"
        default:
            return ""
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(places.sbrsCl.components(separatedBy: ","), id: \.self) { svc in
                VStack {
                    Image(switchServiceIcon(svc: svc))
                        .resizable().frame(width:30, height:30)
                    Text(svc)
                        .font(.caption)
                        .kerning(-1)
                }
               // .padding(4)
            }
        }
    }
}

struct CampingSpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotDetailView(places: Item(contentId: "", facltNm: "", lineIntro: "", intro: "", allar: "", insrncAt: "", trsagntNo: "", bizrno: "", facltDivNm: "", mangeDivNm: "", mgcDiv: "", manageSttus: "", hvofBgnde: "", hvofEnddle: "", featureNm: "", induty: "", lctCl: "", doNm: "", sigunguNm: "", zipcode: "", addr1: "", addr2: "", mapX: "", mapY: "", direction: "", tel: "", homepage: "", resveUrl: "", resveCl: "", manageNmpr: "", gnrlSiteCo: "", autoSiteCo: "", glampSiteCo: "", caravSiteCo: "", indvdlCaravSiteCo: "", sitedStnc: "", siteMg1Width: "", siteMg2Width: "", siteMg3Width: "", siteMg1Vrticl: "", siteMg2Vrticl: "", siteMg3Vrticl: "", siteMg1Co: "", siteMg2Co: "", siteMg3Co: "", siteBottomCl1: "", siteBottomCl2: "", siteBottomCl3: "", siteBottomCl4: "", siteBottomCl5: "", tooltip: "", glampInnerFclty: "", caravInnerFclty: "", prmisnDe: "", operPdCl: "", operDeCl: "", trlerAcmpnyAt: "", caravAcmpnyAt: "", toiletCo: "", swrmCo: "", wtrplCo: "", brazierCl: "", sbrsCl: "", sbrsEtc: "", posblFcltyCl: "", posblFcltyEtc: "", clturEventAt: "", clturEvent: "", exprnProgrmAt: "", exprnProgrm: "", extshrCo: "", frprvtWrppCo: "", frprvtSandCo: "", fireSensorCo: "", themaEnvrnCl: "", eqpmnLendCl: "", animalCmgCl: "", tourEraCl: "", firstImageUrl: "", createdtime: "", modifiedtime: ""))
    }
}
