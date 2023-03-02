//
//  Places.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2022/11/14.
//

import Foundation

//MARK: - 캠핑장 리스트 구조체
struct CampingSpot: Codable, Hashable {
    let contentId: String
    let facltNm: String
    let lineIntro: String
    let intro: String
    let allar: String
    let insrncAt: String
    let trsagntNo: String
    let bizrno: String
    let facltDivNm: String
    let mangeDivNm: String
    let mgcDiv: String
    let manageSttus: String
    let hvofBgnde: String
    let hvofEnddle: String
    let featureNm: String
    let induty: String
    let lctCl: String
    let doNm: String
    let sigunguNm: String
    let zipcode: String
    let addr1: String
    let addr2: String
    let mapX: String
    let mapY: String
    let direction: String
    let tel: String
    let homepage: String
    let resveUrl: String
    let resveCl: String
    let manageNmpr: String
    let gnrlSiteCo: String
    let autoSiteCo: String
    let glampSiteCo: String
    let caravSiteCo: String
    let indvdlCaravSiteCo: String
    let sitedStnc: String
    let siteMg1Width: String
    let siteMg2Width: String
    let siteMg3Width: String
    let siteMg1Vrticl: String
    let siteMg2Vrticl: String
    let siteMg3Vrticl: String
    let siteMg1Co: String
    let siteMg2Co: String
    let siteMg3Co: String
    let siteBottomCl1: String
    let siteBottomCl2: String
    let siteBottomCl3: String
    let siteBottomCl4: String
    let siteBottomCl5: String
    let tooltip: String
    let glampInnerFclty: String
    let caravInnerFclty: String
    let prmisnDe: String
    let operPdCl: String
    let operDeCl: String
    let trlerAcmpnyAt: String
    let caravAcmpnyAt: String
    let toiletCo: String
    let swrmCo: String
    let wtrplCo: String
    let brazierCl: String
    let sbrsCl: String
    let sbrsEtc: String
    let posblFcltyCl: String
    let posblFcltyEtc: String
    let clturEventAt: String
    let clturEvent: String
    let exprnProgrmAt: String
    let exprnProgrm: String
    let extshrCo: String
    let frprvtWrppCo: String
    let frprvtSandCo: String
    let fireSensorCo: String
    let themaEnvrnCl: String
    let eqpmnLendCl: String
    let animalCmgCl: String
    let tourEraCl: String
    let firstImageUrl: String
    let createdtime: String
    let modifiedtime: String
}

// 카테고리 별 데이터를 리턴해주는 ObservableObject 추가 (현재 안씀)
class PlaceStore: ObservableObject {
    @Published var places: [CampingSpot] = []
    @Published var selectedCategory: String = "all"
    
    func returnPlaces() -> [CampingSpot] {
        switch selectedCategory {
        case "all" :
            return places
        case "일반야영장":
            return places.filter { $0.induty.contains("일반야영장")}
        case "자동차야영장" :
            return places.filter { $0.induty.contains("자동차야영장")}
        case "글램핑":
            return places.filter { $0.induty.contains("글램핑")}
        case "카라반":
            return places.filter { $0.induty.contains("카라반")}
        default :
            return places
        }
    }
}
