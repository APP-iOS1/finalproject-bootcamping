//
//  FirebaseCampingSpotService.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/03.
//

import Combine
import Firebase
import FirebaseFirestore
import Foundation

enum FirebaseCampingSpotServiceError: Error {
    case badSnapshot
    case createCampingSpotError
    case updateCampingSpotError
    case deleteCampingSpotError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "게시물 가져오기 실패"
        case .createCampingSpotError:
            return "게시물 작성 실패"
        case .updateCampingSpotError:
            return "게시물 업데이트 실패"
        case .deleteCampingSpotError:
            return "게시물 삭제 실패"
        }
    }
}

struct FirebaseCampingSpotService {
    
    let database = Firestore.firestore()
    
    func readCampingSpotService() -> AnyPublisher<[Item], Error> {
        Future<[Item], Error> { promise in
            database.collection("CampingSpotList")
                .limit(to: 10)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseCampingSpotServiceError.badSnapshot))
                        return
                    }
                    
                    var campingSpotList: [Item] = []
                    
                    campingSpotList = snapshot.documents.map { docData in
                        return Item(
                            contentId: docData["contentId"] as? String ?? "",
                            facltNm: docData["facltNm"] as? String ?? "",
                            lineIntro: docData["lineIntro"] as? String ?? "",
                            intro: docData["intro"] as? String ?? "",
                            allar: docData["allar"] as? String ?? "",
                            insrncAt: docData["insrncAt"] as? String ?? "",
                            trsagntNo: docData["trsagntNo"] as? String ?? "",
                            bizrno: docData["bizrno"] as? String ?? "",
                            facltDivNm: docData["facltDivNm"] as? String ?? "",
                            mangeDivNm: docData["mangeDivNm"] as? String ?? "",
                            mgcDiv: docData["mgcDiv"] as? String ?? "",
                            manageSttus: docData["manageSttus"] as? String ?? "",
                            hvofBgnde: docData["hvofBgnde"] as? String ?? "",
                            hvofEnddle: docData["hvofEnddle"] as? String ?? "",
                            featureNm: docData["featureNm"] as? String ?? "",
                            induty: docData["induty"] as? String ?? "",
                            lctCl: docData["lctCl"] as? String ?? "",
                            doNm: docData["doNm"] as? String ?? "",
                            sigunguNm: docData["sigunguNm"] as? String ?? "",
                            zipcode: docData["zipcode"] as? String ?? "",
                            addr1: docData["addr1"] as? String ?? "",
                            addr2: docData["addr2"] as? String ?? "",
                            mapX: docData["mapX"] as? String ?? "",
                            mapY: docData["mapY"] as? String ?? "",
                            direction: docData["direction"] as? String ?? "",
                            tel: docData["tel"] as? String ?? "",
                            homepage: docData["homepage"] as? String ?? "",
                            resveUrl: docData["resveUrl"] as? String ?? "",
                            resveCl: docData["resveCl"] as? String ?? "",
                            manageNmpr: docData["manageNmpr"] as? String ?? "",
                            gnrlSiteCo: docData["gnrlSiteCo"] as? String ?? "",
                            autoSiteCo: docData["autoSiteCo"] as? String ?? "",
                            glampSiteCo: docData["glampSiteCo"] as? String ?? "",
                            caravSiteCo: docData["caravSiteCo"] as? String ?? "",
                            indvdlCaravSiteCo: docData["indvdlCaravSiteCo"] as? String ?? "",
                            sitedStnc: docData["sitedStnc"] as? String ?? "",
                            siteMg1Width: docData["siteMg1Width"] as? String ?? "",
                            siteMg2Width: docData["siteMg2Width"] as? String ?? "",
                            siteMg3Width: docData["siteMg3Width"] as? String ?? "",
                            siteMg1Vrticl: docData["siteMg1Vrticl"] as? String ?? "",
                            siteMg2Vrticl: docData["siteMg2Vrticl"] as? String ?? "",
                            siteMg3Vrticl: docData["siteMg3Vrticl"] as? String ?? "",
                            siteMg1Co: docData["siteMg1Co"] as? String ?? "",
                            siteMg2Co: docData["siteMg2Co"] as? String ?? "",
                            siteMg3Co: docData["siteMg3Co"] as? String ?? "",
                            siteBottomCl1: docData["siteBottomCl1"] as? String ?? "",
                            siteBottomCl2: docData["siteBottomCl2"] as? String ?? "",
                            siteBottomCl3: docData["siteBottomCl3"] as? String ?? "",
                            siteBottomCl4: docData["siteBottomCl4"] as? String ?? "",
                            siteBottomCl5: docData["siteBottomCl5"] as? String ?? "",
                            tooltip: docData["tooltip"] as? String ?? "",
                            glampInnerFclty: docData["glampInnerFclty"] as? String ?? "",
                            caravInnerFclty: docData["caravInnerFclty"] as? String ?? "",
                            prmisnDe: docData["prmisnDe"] as? String ?? "",
                            operPdCl: docData["operPdCl"] as? String ?? "",
                            operDeCl: docData["operDeCl"] as? String ?? "",
                            trlerAcmpnyAt: docData["trlerAcmpnyAt"] as? String ?? "",
                            caravAcmpnyAt: docData["caravAcmpnyAt"] as? String ?? "",
                            toiletCo: docData["toiletCo"] as? String ?? "",
                            swrmCo: docData["swrmCo"] as? String ?? "",
                            wtrplCo: docData["wtrplCo"] as? String ?? "",
                            brazierCl: docData["brazierCl"] as? String ?? "",
                            sbrsCl: docData["sbrsCl"] as? String ?? "",
                            sbrsEtc: docData["sbrsEtc"] as? String ?? "",
                            posblFcltyCl: docData["posblFcltyCl"] as? String ?? "",
                            posblFcltyEtc: docData["posblFcltyEtc"] as? String ?? "",
                            clturEventAt: docData["clturEventAt"] as? String ?? "",
                            clturEvent: docData["clturEvent"] as? String ?? "",
                            exprnProgrmAt: docData["exprnProgrmAt"] as? String ?? "",
                            exprnProgrm: docData["exprnProgrm"] as? String ?? "",
                            extshrCo: docData["extshrCo"] as? String ?? "",
                            frprvtWrppCo: docData["frprvtWrppCo"] as? String ?? "",
                            frprvtSandCo: docData["frprvtSandCo"] as? String ?? "",
                            fireSensorCo: docData["fireSensorCo"] as? String ?? "",
                            themaEnvrnCl: docData["themaEnvrnCl"] as? String ?? "",
                            eqpmnLendCl: docData["eqpmnLendCl"] as? String ?? "",
                            animalCmgCl: docData["animalCmgCl"] as? String ?? "",
                            tourEraCl: docData["tourEraCl"] as? String ?? "",
                            firstImageUrl: docData["firstImageUrl"] as? String ?? "",
                            createdtime: docData["createdtime"] as? String ?? "",
                            modifiedtime: docData["modifiedtime"] as? String ?? ""
                        )
                    }
                    promise(.success(campingSpotList))
                }
        }
        .eraseToAnyPublisher()
    }
    
    
}
