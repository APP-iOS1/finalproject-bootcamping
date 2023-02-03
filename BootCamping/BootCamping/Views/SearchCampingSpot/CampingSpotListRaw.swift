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
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
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

struct CampingSpotListRaw_Previews: PreviewProvider {
    static var previews: some View {
        CampingSpotListRaw(item: Item(contentId: "", facltNm: "", lineIntro: "", intro: "", allar: "", insrncAt: "", trsagntNo: "", bizrno: "", facltDivNm: "", mangeDivNm: "", mgcDiv: "", manageSttus: "", hvofBgnde: "", hvofEnddle: "", featureNm: "", induty: "", lctCl: "", doNm: "", sigunguNm: "", zipcode: "", addr1: "", addr2: "", mapX: "", mapY: "", direction: "", tel: "", homepage: "", resveUrl: "", resveCl: "", manageNmpr: "", gnrlSiteCo: "", autoSiteCo: "", glampSiteCo: "", caravSiteCo: "", indvdlCaravSiteCo: "", sitedStnc: "", siteMg1Width: "", siteMg2Width: "", siteMg3Width: "", siteMg1Vrticl: "", siteMg2Vrticl: "", siteMg3Vrticl: "", siteMg1Co: "", siteMg2Co: "", siteMg3Co: "", siteBottomCl1: "", siteBottomCl2: "", siteBottomCl3: "", siteBottomCl4: "", siteBottomCl5: "", tooltip: "", glampInnerFclty: "", caravInnerFclty: "", prmisnDe: "", operPdCl: "", operDeCl: "", trlerAcmpnyAt: "", caravAcmpnyAt: "", toiletCo: "", swrmCo: "", wtrplCo: "", brazierCl: "", sbrsCl: "", sbrsEtc: "", posblFcltyCl: "", posblFcltyEtc: "", clturEventAt: "", clturEvent: "", exprnProgrmAt: "", exprnProgrm: "", extshrCo: "", frprvtWrppCo: "", frprvtSandCo: "", fireSensorCo: "", themaEnvrnCl: "", eqpmnLendCl: "", animalCmgCl: "", tourEraCl: "", firstImageUrl: "", createdtime: "", modifiedtime: ""))
    }
}
