//
//  CampingSpotListRaw.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/03.
//

import SwiftUI
import SDWebImageSwiftUI

//MARK: 캠핑장 리스트 셀 뷰
struct CampingSpotListRaw: View {
    var item: Item
    
    var body: some View{
        VStack(alignment: .leading) {
            
            // 캠핑장 사진
            if item.firstImageUrl.isEmpty {
                Image("noImage")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
                    .padding(.bottom, 5)
            } else {
                WebImage(url: URL(string: item.firstImageUrl))
                    .resizable()
                    .placeholder {
                        ProgressView()
                            .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    .clipped()
                    .padding(.bottom, 5)
            }
            
            // 전망
            if !item.lctCl.isEmpty {
                HStack {
                    ForEach(item.lctCl.components(separatedBy: ","), id: \.self) { view in
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 40 ,height: 20)
                            .foregroundColor(.bcGreen)
                            .overlay{
                                Text(view)
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                    }
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.04)
            }
            
            
            // 캠핑장 이름
            Text(item.facltNm)
                .font(.title3.bold())
                .foregroundColor(.bcBlack)
                .padding(.horizontal, UIScreen.screenWidth * 0.04)

            // 캠핑장 간단 주소
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.trailing, -3)
                Text("\(item.doNm) \(item.sigunguNm)")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, -10)
            .padding(.horizontal, UIScreen.screenWidth * 0.04)

            // 캠핑장 설명 3줄
            if item.lineIntro != "" {
                Text(item.lineIntro)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.bcBlack)
                    .padding(.top, 13)
                    .padding(.horizontal, UIScreen.screenWidth * 0.04)
            } else {
                Text("업체에서 제공하는 소개글이 없습니다.")
                  //  .font(.callout)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
                    .padding(.top, 13)
                    .padding(.horizontal, UIScreen.screenWidth * 0.04)
            }
            
        }
    }
}
