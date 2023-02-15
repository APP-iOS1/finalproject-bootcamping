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
                VStack {
                    WebImage(url: URL(string: campingSpot.firstImageUrl == "" ? CampingSpotStore().noImageURL : campingSpot.firstImageUrl))
                        .resizable()
                        .placeholder {
                            Rectangle().foregroundColor(.secondary)
                        }
                        .transition(.fade(duration: 0.5))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.screenWidth)
                        .padding(.bottom, 5)
                    
                    if !campingSpot.lctCl.isEmpty {
                        HStack {
                            ForEach(campingSpot.lctCl.components(separatedBy: ","), id: \.self) { view in
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 40 ,height: 20)
                                    .foregroundColor(.bcGreen)
                                    .overlay {
                                        Text(view)
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                    }
                            }
                            Spacer()
//                            Button {
//                                isBookmarked.toggle()
//                                if isBookmarked {
//                                    bookmarkStore.addBookmarkSpotCombine(campingSpotId: campingSpot.contentId)
//                                } else {
//                                    bookmarkStore.removeBookmarkCampingSpotCombine(campingSpotId: campingSpot.contentId)
//                                }
//                                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
//                            } label: {
//                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
//                                    .foregroundColor(Color.accentColor)
//                            }
//                            .padding()
                        }
                        .padding(.horizontal, UIScreen.screenWidth * 0.05)
                        .padding(.top, 5)
                    }
//                    else {
//                        HStack {
//                            Spacer()
//                            Button {
//                                isBookmarked.toggle()
//                                if isBookmarked{
//                                    bookmarkStore.addBookmarkSpotCombine(campingSpotId: campingSpot.contentId)
//                                } else{
//                                    bookmarkStore.removeBookmarkCampingSpotCombine(campingSpotId: campingSpot.contentId)
//                                }
//                                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
//                            } label: {
//                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
//                                    .foregroundColor(Color.accentColor)
//                            }
//                            .padding()
//                        }
//                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        HStack(alignment: .top) {
                            Text("\(campingSpot.facltNm)") // 캠핑장 이름
                                .font(.title)
                                .bold()
                                
                            Spacer()
                            
                            Button {
                                isBookmarked.toggle()
                                if isBookmarked {
                                    bookmarkStore.addBookmarkSpotCombine(campingSpotId: campingSpot.contentId)
                                    //탭틱
                                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                } else {
                                    bookmarkStore.removeBookmarkCampingSpotCombine(campingSpotId: campingSpot.contentId)
                                }
                                wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
                            } label: {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(Color.accentColor)
                                    .font(.system(size: 18))
                            }
                            .padding(.leading, 20)
                            
                            
                            
                        }
                        .padding(.top, -30)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.secondary)
                            Text("\(campingSpot.addr1)") // 캠핑장 주소
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                UIPasteboard.general.string = campingSpot.addr1
                                isPaste = true
                                //탭틱
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("복사")
                                        .padding(.leading, -3)
                                        .underline()
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
                                Button {
                                    //탭틱
                                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
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
                        if campingSpot.resveUrl != "" {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                Link(destination: ((URL(string: campingSpot.resveUrl) ?? URL(string: campingSpot.homepage)) ?? URL(string: "https://www.google.com"))!, label: {
                                    Text("예약하러 가기")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .underline()
                                })
                            }
                        }
                        Text(" ")
                        if campingSpot.operPdCl != "" {
                            VStack {
                                Text("운영계절 : \(campingSpot.operPdCl)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if campingSpot.operDeCl != "" {
                            VStack {
                                Text("운영일 : \(campingSpot.operDeCl)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Divider()
                            .padding(.vertical)
                    }
                    
                    Group {
                        if campingSpot.intro != "" {
                            Text("캠핑장 소개")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("\(campingSpot.intro)")
                                .font(.subheadline)
                                .lineSpacing(7)
                            Divider()
                                .padding(.vertical)
                        } else {
                            Text("캠핑장 소개")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("업체에서 제공하는 소개글이 없습니다.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    Group {
                        if campingSpot.eqpmnLendCl != "" {
                            Text("대여 가능한 캠핑장비")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("\(campingSpot.eqpmnLendCl)")
                                .font(.subheadline)
                                .lineSpacing(7)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    Group {
                        if campingSpot.sbrsCl != "" {
                            Text("편의시설 및 서비스")
                                .font(.headline)
                                .padding(.bottom, 10)
                            
                            ServiceIcon(campingSpot: campingSpot)
                        } else {
                            Text("편의시설 및 서비스")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("업체에서 제공하는 서비스 정보가 없습니다.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                            
                        Divider()
                            .padding(.vertical)
                    }
                    
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
                            region.center = CLLocationCoordinate2D(latitude: Double(campingSpot.mapY) ?? 23.0, longitude: Double(campingSpot.mapX) ?? 36.0)
                        }
                        Divider()
                            .padding(.vertical)
                        
                        
                    }
                    
                    Group {
                        if campingSpot.posblFcltyCl != "" {
                            Text("이용 가능한 주변 시설")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("\(campingSpot.posblFcltyCl)")
                                .font(.subheadline)
                                .lineSpacing(7)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    Group {
                        if campingSpot.exprnProgrm != "" {
                            Text("체험 프로그램")
                                .font(.headline)
                                .padding(.bottom, 10)
                            ForEach(campingSpot.exprnProgrm.components(separatedBy: ","), id: \.self) { exprn in
                                HStack {
                                    Text("#\(exprn)")
                                        .font(.subheadline)
                                }
                            }
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    Group {
                        if campingSpot.featureNm != "" {
                            Text("캠핑장 특징")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("\(campingSpot.featureNm)")
                                .font(.subheadline)
                                .lineSpacing(7)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    Group {
                        if campingSpot.tooltip != "" {
                            Text("캠핑장 팁")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("\(campingSpot.tooltip)")
                                .font(.subheadline)
                                .lineSpacing(7)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    
                    
                    Group {
                        HStack {
                            Text("관련 캠핑일기")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Spacer()
                            
                            NavigationLink {
                                DiaryListForCampingSpotView(contentId: campingSpot.contentId, diaryStore: diaryStore)
                            } label: {
                                Text("더 보기")
                                    .font(.subheadline)
                                    .underline()
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 10)
                                    .padding(.trailing, 10)
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            if diaryStore.realTimeDiaryUserInfoDiaryList.isEmpty {
                                Text("등록된 캠핑일기가 없습니다.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if diaryStore.realTimeDiaryUserInfoDiaryList.count <= 3 {
                                HStack {
                                    ForEach(diaryStore.realTimeDiaryUserInfoDiaryList.indices, id: \.self) { index in
                                        NavigationLink {
                                            DiaryDetailView(item: diaryStore.realTimeDiaryUserInfoDiaryList[index])
                                        } label: {
                                            CampingSpotDiaryRow(item: diaryStore.realTimeDiaryUserInfoDiaryList[index])
                                        }
                                    }
                                }
                            } else if diaryStore.realTimeDiaryUserInfoDiaryList.count > 3 {
                                HStack {
                                    ForEach(0...2, id: \.self) { index in
                                        NavigationLink {
                                            DiaryDetailView(item: diaryStore.realTimeDiaryUserInfoDiaryList[index])
                                        } label: {
                                            CampingSpotDiaryRow(item: diaryStore.realTimeDiaryUserInfoDiaryList[index])
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
            annotatedItem.append(AnnotatedItem(name: campingSpot.facltNm, coordinate: CLLocationCoordinate2D(latitude: Double(campingSpot.mapY) ?? 23.0, longitude: Double(campingSpot.mapX) ?? 36.0)))
            isBookmarked = bookmarkStore.checkBookmarkedSpot(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, campingSpotId: campingSpot.contentId)
            diaryStore.readCampingSpotsDiariesCombine(contentId: campingSpot.contentId)
        }
        .alert("복사가 완료되었습니다", isPresented: $isPaste) {
            Button("완료") {
                isPaste = false
            }
        }
    }
}

struct CampingSpotDiaryRow: View {
    
    var item: UserInfoDiary
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: item.diary.diaryImageURLs.first!))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.screenWidth * 0.3, height: UIScreen.screenWidth * 0.3)
                .cornerRadius(10)
                .clipped()
            Text(item.diary.diaryTitle)
                .font(.callout)
                .frame(width: 120)
                .lineLimit(2)
        }
        .foregroundColor(Color.bcBlack)
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
            }
        }
    }
}
