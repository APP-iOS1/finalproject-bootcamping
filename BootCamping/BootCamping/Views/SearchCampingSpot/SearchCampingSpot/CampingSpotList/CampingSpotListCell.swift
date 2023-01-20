//
//  CampingSpotListCell.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct CampingSpotListCell: View {
    
    var campingSpot: Item

    var body: some View {
        VStack(alignment: .leading){
            
            // 캠핑장 사진
            WebImage(url: URL(string: campingSpot.firstImageUrl))
                .resizable()
                .frame(width: UIScreen.screenWidth*0.9, height: UIScreen.screenWidth*0.9)
            
                .padding(.bottom, 5)
            
            
            // 전망 알려주는 라벨
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 20)
                .foregroundColor(Color("BCGreen"))
                .overlay{
                    Text("\(campingSpot.lctCl)")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            
            // 캠핑장 이름
            Text("\(campingSpot.facltNm)")
                .font(.title3.bold())
            
            // 캠핑장 간단 주소
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.trailing, -7)
                Text("\(campingSpot.doNm) \(campingSpot.sigunguNm)")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 5)
            
            // 캠핑장 설명 3줄
            Text("\(campingSpot.intro)")
                .font(.callout)
                .padding(.bottom)
                .lineLimit(3)//optional
//                .expandButton(TextSet(text: "more", font: .body, color: .blue))//optional
//                .collapseButton(TextSet(text: "less", font: .body, color: .blue))//optional
//                .expandAnimation(.easeOut)//optional
            
        }
    }
}

struct CampingSpotListCell_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotListCell(campingSpot: CampingSpotStore().campingSpotList.first!)
    }
}
