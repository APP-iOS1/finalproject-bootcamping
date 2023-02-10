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
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var bookmarkStore: BookmarkStore
    
    @StateObject var diaryStore: DiaryStore = DiaryStore()
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5, longitude: 126.9),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State var annotatedItem: [AnnotatedItem] = []
    @State private var isBookmarked: Bool = false
    
    var campingSpot: Item
    
    var body: some View {
        
        ZStack {
            ScrollView(showsIndicators: false) {
                TabView {
                    ForEach(0...2, id: \.self) { item in
                        // 캠핑장 사진
                        if campingSpot.firstImageUrl.isEmpty {
                            // 이미지 없는 것도 있어서 어떻게 할 지 고민 중~
                            Image("noImage")
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
                                .padding(.bottom, 5)
                        } else {
                            WebImage(url: URL(string: campingSpot.firstImageUrl))
                                .resizable()
                                .placeholder {
                                    Rectangle().foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
                                .padding(.bottom, 5)
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                .tabViewStyle(PageTabViewStyle())
                // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        HStack(alignment: .top) {
                            Text("\(campingSpot.facltNm)") // 캠핑장 이름
                                .font(.title)
                                .bold()
                            Spacer()
                            Button {
                                isBookmarked.toggle()
                                if isBookmarked{
                                    bookmarkStore.addBookmarkSpotCombine(campingSpotId: campingSpot.contentId)
                                } else{
                                    bookmarkStore.removeBookmarkCampingSpotCombine(campingSpotId: campingSpot.contentId)
                                }
                                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
                            } label: {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .bold()
                                    .foregroundColor(Color.accentColor)
                            }
                            .padding()
                            
                        }
                        .padding(.top, -15)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.gray)
                            Text("\(campingSpot.addr1)") // 캠핑장 주소
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 15)
                    }
                    
                    Group {
                        Text("\(campingSpot.intro)")
                            .lineSpacing(7)
                    }
                    
                    
                    Divider()
                        .padding(.vertical)
                    Group {
                        Text("편의시설 및 서비스")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        ServiceIcon(campingSpot: campingSpot)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    Group {
                        Text("위치 보기")
                            .font(.headline)
                            .padding(.bottom, 10)
                        NavigationLink {
                            FullMapView(annotatedItem: annotatedItem, region: region, campingSpot: campingSpot)
                        } label: {
                            Map(coordinateRegion: $region, interactionModes: [], annotationItems: annotatedItem) { item in
                                MapMarker(coordinate: item.coordinate, tint: Color.bcGreen)
                            }
                            .frame(width: UIScreen.screenWidth * 0.95, height: 250)
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
                            if diaryStore.diaryList.isEmpty {
                                Text("등록된 리뷰가 없습니다.")
                            } else if diaryStore.diaryList.count <= 3 {
                                HStack {
                                    ForEach(diaryStore.diaryList.indices, id: \.self) { index in
                                        NavigationLink {
                                            
                                        } label: {
                                            CampingSpotDiaryRow(diary: diaryStore.diaryList[index])
                                        }
                                    }
                                }
                            } else if diaryStore.diaryList.count > 3 {
                                HStack {
                                    ForEach(0...3, id: \.self) { index in
                                        NavigationLink {
                                            
                                        } label: {
                                            CampingSpotDiaryRow(diary: diaryStore.diaryList[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
                .padding(.vertical, 30)
            }
        }
        .task {
            region.center = CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)
            annotatedItem.append(AnnotatedItem(name: campingSpot.facltNm, coordinate: CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)))
            isBookmarked = bookmarkStore.checkBookmarkedSpot(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, campingSpotId: campingSpot.contentId)
            diaryStore.readCampingSpotsDiarysCombine(contentId: campingSpot.contentId)
            print(diaryStore.diaryList)
        }
    }
}

struct CampingSpotDiaryRow: View {
    
    var diary: Diary
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: diary.diaryImageURLs.first!))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.screenWidth * 0.3, height: UIScreen.screenWidth * 0.3)
                .cornerRadius(10)
                .clipped()
            Text(diary.diaryTitle)
                .font(.callout)
                .frame(width: 120)
                .lineLimit(2)
        }
    }
}

// 편의시설 및 서비스 아이콘 구조체
struct ServiceIcon: View {
    var campingSpot: Item
    
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
            ForEach(campingSpot.sbrsCl.components(separatedBy: ","), id: \.self) { svc in
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

//struct CampingSpotDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        CampingSpotDetailView(campingSpot: Item(contentId: "", facltNm: "", lineIntro: "", intro: "", allar: "", insrncAt: "", trsagntNo: "", bizrno: "", facltDivNm: "", mangeDivNm: "", mgcDiv: "", manageSttus: "", hvofBgnde: "", hvofEnddle: "", featureNm: "", induty: "", lctCl: "", doNm: "", sigunguNm: "", zipcode: "", addr1: "", addr2: "", mapX: "", mapY: "", direction: "", tel: "", homepage: "", resveUrl: "", resveCl: "", manageNmpr: "", gnrlSiteCo: "", autoSiteCo: "", glampSiteCo: "", caravSiteCo: "", indvdlCaravSiteCo: "", sitedStnc: "", siteMg1Width: "", siteMg2Width: "", siteMg3Width: "", siteMg1Vrticl: "", siteMg2Vrticl: "", siteMg3Vrticl: "", siteMg1Co: "", siteMg2Co: "", siteMg3Co: "", siteBottomCl1: "", siteBottomCl2: "", siteBottomCl3: "", siteBottomCl4: "", siteBottomCl5: "", tooltip: "", glampInnerFclty: "", caravInnerFclty: "", prmisnDe: "", operPdCl: "", operDeCl: "", trlerAcmpnyAt: "", caravAcmpnyAt: "", toiletCo: "", swrmCo: "", wtrplCo: "", brazierCl: "", sbrsCl: "", sbrsEtc: "", posblFcltyCl: "", posblFcltyEtc: "", clturEventAt: "", clturEvent: "", exprnProgrmAt: "", exprnProgrm: "", extshrCo: "", frprvtWrppCo: "", frprvtSandCo: "", fireSensorCo: "", themaEnvrnCl: "", eqpmnLendCl: "", animalCmgCl: "", tourEraCl: "", firstImageUrl: "", createdtime: "", modifiedtime: ""))
//            .environmentObject(AuthStore())
//            .environmentObject(BookmarkSpotStore())
//    }
//}
