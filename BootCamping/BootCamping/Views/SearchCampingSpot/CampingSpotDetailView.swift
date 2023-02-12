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
    @State private var isPaste: Bool = false
    @State private var isBookmarked: Bool = false
    
    var campingSpot: Item
    
    var body: some View {
        
        VStack() {
            ScrollView(showsIndicators: false) {
                WebImage(url: URL(string: campingSpot.firstImageUrl))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.secondary)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.screenWidth)
                    .padding(.bottom, 5)
                
                if !campingSpot.lctCl.isEmpty {
                    HStack {
                        ForEach(campingSpot.lctCl.components(separatedBy: ","), id: \.self) { view in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40 ,height: 20)
                                .foregroundColor(.bcGreen)
                                .overlay{
                                    Text(view)
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                }
                        }
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
                    .padding(.horizontal, UIScreen.screenWidth*0.05)
                } else {
                    HStack {
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
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        HStack(alignment: .top) {
                            Text("\(campingSpot.facltNm)") // 캠핑장 이름
                                .font(.title)
                                .bold()
                            Spacer()
                            
                            
                        }
                        .padding(.top, -15)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.secondary)
                            Text("\(campingSpot.addr1)") // 캠핑장 주소
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Button {
                                UIPasteboard.general.string = campingSpot.addr1
                                isPaste = true
                            } label: {
                                Text("복사")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .underline()
                            }
                        }
                        if campingSpot.tel != "" {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                Text(campingSpot.tel)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                Button{
                                    if let url = URL(string: "tel://\(campingSpot.tel)"), UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text("전화걸기")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .underline()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 15)
                    
                    Group {
                        if campingSpot.intro != "" {
                            Text("\(campingSpot.intro)")
                                .lineSpacing(7)
                        } else {
                            Text("업체에서 제공하는 정보가 없습니다")
                        }
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
                        .onAppear {
                            region.center = CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)
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
                            
                            NavigationLink {
                                
                            } label: {
                                Text("더 보기")
                                    .font(.callout)
                                    .padding(.bottom, 10)
                                    .padding(.trailing, 10)
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            if diaryStore.diaryList.filter { !$0.diaryIsPrivate }.isEmpty {
                                Text("등록된 리뷰가 없습니다.")
                            } else if diaryStore.diaryList.count <= 3 {
                                HStack {
                                    ForEach(diaryStore.diaryList.filter { !$0.diaryIsPrivate }.indices, id: \.self) { index in
                                        NavigationLink {
                                            
                                        } label: {
                                            CampingSpotDiaryRow(diary: diaryStore.diaryList[index])
                                        }
                                    }
                                }
                            } else if diaryStore.diaryList.filter { !$0.diaryIsPrivate }.count > 3 {
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
//            region.center = CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)
            annotatedItem.append(AnnotatedItem(name: campingSpot.facltNm, coordinate: CLLocationCoordinate2D(latitude: Double(campingSpot.mapY)!, longitude: Double(campingSpot.mapX)!)))
            isBookmarked = bookmarkStore.checkBookmarkedSpot(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, campingSpotId: campingSpot.contentId)
            diaryStore.readCampingSpotsDiarysCombine(contentId: campingSpot.contentId)
        }
        .alert("복사가 완료되었습니다", isPresented: $isPaste) {
            Button("완료") {
                isPaste = false
            }
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
