//
//  CampingSpotListView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
//import ExpandableText     // 패키지 또 추가하면 충돌날거같아서 일단 코드만 추가해둠~

struct CampingSpotListView: View {
    //TODO: 북마크 만들기
    @EnvironmentObject var campingSpotStore: CampingSpotStore
//    var item: [Item]

    var body: some View {
        VStack{
            ScrollView(showsIndicators: false){
                ForEach(campingSpotStore.campingSpotList, id: \.self) { camping in
                    NavigationLink {
                        CampingSpotDetailView(places: camping)
                    } label: {
                        VStack{
                            campingSpotListCell(item: camping)
                                .padding(.bottom,40)
//                            Divider()
//                                .padding(.bottom, 10)
                            ///Divider() 없어도 구분 잘 되나요??
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text("캠핑 모아보기")
                }
            }
        }

    }
}

//MARK: 캠핑장 리스트 셀 뷰
struct campingSpotListCell : View{
    var item: Item

    
    var body: some View{
        VStack(alignment: .leading){
            
            // 캠핑장 사진
            if item.firstImageUrl.isEmpty {
                // 이미지 없는 것도 있어서 어떻게 할 지 고민 중~
                Image("noImage")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
                    .padding(.bottom, 5)
            } else {
                WebImage(url: URL(string: item.firstImageUrl))
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
                    .padding(.bottom, 5)
            }
            
            // 전망
            if !item.lctCl.isEmpty {
                HStack {
                    ForEach(item.lctCl.components(separatedBy: ","), id: \.self) { view in
                        RoundedRectangle(cornerRadius: 10)
//                            .frame(width: 35, height: 20)
                            .frame(width: 40 ,height: 20)
                            .foregroundColor(.bcGreen)
                            .overlay{
                                Text(view)
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                    }
                }
                .padding(.horizontal, UIScreen.screenWidth*0.05)
            }
            
            
            // 캠핑장 이름
            Text(item.facltNm)
                .font(.title3.bold())
                .foregroundColor(.bcBlack)
                .padding(.horizontal, UIScreen.screenWidth*0.05)

            // 캠핑장 간단 주소
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.trailing, -7)
                Text("\(item.doNm) \(item.sigunguNm)")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 5)
            .padding(.horizontal, UIScreen.screenWidth*0.05)

            // 캠핑장 설명 3줄
            if item.lineIntro != "" {
                Text(item.lineIntro)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.bcBlack)
                    .padding(.horizontal, UIScreen.screenWidth*0.05)
            }
            //                        .lineLimit(3)//optional
            //                        .expandButton(TextSet(text: "more", font: .body, color: .blue))//optional
            //                        .collapseButton(TextSet(text: "less", font: .body, color: .blue))//optional
            //                        .expandAnimation(.easeOut)//optional
            
        }
    }
}


//struct CampingSpotListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack{
//            CampingSpotListView()
//        }
//    }
//}
