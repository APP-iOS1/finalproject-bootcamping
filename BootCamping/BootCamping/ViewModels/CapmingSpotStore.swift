//
//  CapmingSpotStore.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/19.
//

import Combine
import Foundation
import Firebase
import FirebaseFirestore

//MARK: - 캠핑리스트 추가/ 업데이트 함수입니다.
class CampingSpotStore: ObservableObject {
    @Published var campingSpotList: [Item] = []
    @Published var campingSpots: [Item] = []
    @Published var firebaseCampingSpotServiceError: FirebaseCampingSpotServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "Error"
    @Published var lastDoc: QueryDocumentSnapshot?
    
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCampingSpot() {
        database.collection("CampingSpotList").getDocuments { (snapshot, error) in
            self.campingSpotList.removeAll()
            
            if let snapshot {
                for document in snapshot.documents {
                    let contentId: String = document.documentID
                    let docData = document.data()
                    let facltNm: String = docData["facltNm"] as? String ?? ""
                    let lineIntro: String = docData["lineIntro"] as? String ?? ""
                    let intro: String = docData["intro"] as? String ?? ""
                    let allar: String = docData["allar"] as? String ?? ""
                    let insrncAt: String = docData["insrncAt"] as? String ?? ""
                    let trsagntNo: String = docData["trsagntNo"] as? String ?? ""
                    let bizrno: String = docData["bizrno"] as? String ?? ""
                    let facltDivNm: String = docData["facltDivNm"] as? String ?? ""
                    let mangeDivNm: String = docData["mangeDivNm"] as? String ?? ""
                    let mgcDiv: String = docData["mgcDiv"] as? String ?? ""
                    let manageSttus: String = docData["manageSttus"] as? String ?? ""
                    let hvofBgnde: String = docData["hvofBgnde"] as? String ?? ""
                    let hvofEnddle: String = docData["hvofEnddle"] as? String ?? ""
                    let featureNm: String = docData["featureNm"] as? String ?? ""
                    let induty: String = docData["induty"] as? String ?? ""
                    let lctCl: String = docData["lctCl"] as? String ?? ""
                    let doNm: String = docData["doNm"] as? String ?? ""
                    let sigunguNm: String = docData["sigunguNm"] as? String ?? ""
                    let zipcode: String = docData["zipcode"] as? String ?? ""
                    let addr1: String = docData["addr1"] as? String ?? ""
                    let addr2: String = docData["addr2"] as? String ?? ""
                    let mapX: String = docData["mapX"] as? String ?? ""
                    let mapY: String = docData["mapY"] as? String ?? ""
                    let direction: String = docData["direction"] as? String ?? ""
                    let tel: String = docData["tel"] as? String ?? ""
                    let homepage: String = docData["homepage"] as? String ?? ""
                    let resveUrl: String = docData["resveUrl"] as? String ?? ""
                    let resveCl: String = docData["resveCl"] as? String ?? ""
                    let manageNmpr: String = docData["manageNmpr"] as? String ?? ""
                    let gnrlSiteCo: String = docData["gnrlSiteCo"] as? String ?? ""
                    let autoSiteCo: String = docData["autoSiteCo"] as? String ?? ""
                    let glampSiteCo: String = docData["glampSiteCo"] as? String ?? ""
                    let caravSiteCo: String = docData["caravSiteCo"] as? String ?? ""
                    let indvdlCaravSiteCo: String = docData["indvdlCaravSiteCo"] as? String ?? ""
                    let sitedStnc: String = docData["sitedStnc"] as? String ?? ""
                    let siteMg1Width: String = docData["siteMg1Width"] as? String ?? ""
                    let siteMg2Width: String = docData["siteMg2Width"] as? String ?? ""
                    let siteMg3Width: String = docData["siteMg3Width"] as? String ?? ""
                    let siteMg1Vrticl: String = docData["siteMg1Vrticl"] as? String ?? ""
                    let siteMg2Vrticl: String = docData["siteMg2Vrticl"] as? String ?? ""
                    let siteMg3Vrticl: String = docData["siteMg3Vrticl"] as? String ?? ""
                    let siteMg1Co: String = docData["siteMg1Co"] as? String ?? ""
                    let siteMg2Co: String = docData["siteMg2Co"] as? String ?? ""
                    let siteMg3Co: String = docData["siteMg3Co"] as? String ?? ""
                    let siteBottomCl1: String = docData["siteBottomCl1"] as? String ?? ""
                    let siteBottomCl2: String = docData["siteBottomCl2"] as? String ?? ""
                    let siteBottomCl3: String = docData["siteBottomCl3"] as? String ?? ""
                    let siteBottomCl4: String = docData["siteBottomCl4"] as? String ?? ""
                    let siteBottomCl5: String = docData["siteBottomCl5"] as? String ?? ""
                    let tooltip: String = docData["tooltip"] as? String ?? ""
                    let glampInnerFclty: String = docData["glampInnerFclty"] as? String ?? ""
                    let caravInnerFclty: String = docData["caravInnerFclty"] as? String ?? ""
                    let prmisnDe: String = docData["prmisnDe"] as? String ?? ""
                    let operPdCl: String = docData["operPdCl"] as? String ?? ""
                    let operDeCl: String = docData["operDeCl"] as? String ?? ""
                    let trlerAcmpnyAt: String = docData["trlerAcmpnyAt"] as? String ?? ""
                    let caravAcmpnyAt: String = docData["caravAcmpnyAt"] as? String ?? ""
                    let toiletCo: String = docData["toiletCo"] as? String ?? ""
                    let swrmCo: String = docData["swrmCo"] as? String ?? ""
                    let wtrplCo: String = docData["wtrplCo"] as? String ?? ""
                    let brazierCl: String = docData["brazierCl"] as? String ?? ""
                    let sbrsCl: String = docData["sbrsCl"] as? String ?? ""
                    let sbrsEtc: String = docData["sbrsEtc"] as? String ?? ""
                    let posblFcltyCl: String = docData["posblFcltyCl"] as? String ?? ""
                    let posblFcltyEtc: String = docData["posblFcltyEtc"] as? String ?? ""
                    let clturEventAt: String = docData["clturEventAt"] as? String ?? ""
                    let clturEvent: String = docData["clturEvent"] as? String ?? ""
                    let exprnProgrmAt: String = docData["exprnProgrmAt"] as? String ?? ""
                    let exprnProgrm: String = docData["exprnProgrm"] as? String ?? ""
                    let extshrCo: String = docData["extshrCo"] as? String ?? ""
                    let frprvtWrppCo: String = docData["frprvtWrppCo"] as? String ?? ""
                    let frprvtSandCo: String = docData["frprvtSandCo"] as? String ?? ""
                    let fireSensorCo: String = docData["fireSensorCo"] as? String ?? ""
                    let themaEnvrnCl: String = docData["themaEnvrnCl"] as? String ?? ""
                    let eqpmnLendCl: String = docData["eqpmnLendCl"] as? String ?? ""
                    let animalCmgCl: String = docData["animalCmgCl"] as? String ?? ""
                    let tourEraCl: String = docData["tourEraCl"] as? String ?? ""
                    let firstImageUrl: String = docData["firstImageUrl"] as? String ?? ""
                    let createdtime: String = docData["createdtime"] as? String ?? ""
                    let modifiedtime: String = docData["modifiedtime"] as? String ?? ""
                    
                    let capmingSpot: Item = Item(contentId: contentId, facltNm: facltNm, lineIntro: lineIntro, intro: intro, allar: allar, insrncAt: insrncAt, trsagntNo: trsagntNo, bizrno: bizrno, facltDivNm: facltDivNm, mangeDivNm: mangeDivNm, mgcDiv: mgcDiv, manageSttus: manageSttus, hvofBgnde: hvofBgnde, hvofEnddle: hvofEnddle, featureNm: featureNm, induty: induty, lctCl: lctCl, doNm: doNm, sigunguNm: sigunguNm, zipcode: zipcode, addr1: addr1, addr2: addr2, mapX: mapX, mapY: mapY, direction: direction, tel: tel, homepage: homepage, resveUrl: resveUrl, resveCl: resveCl, manageNmpr: manageNmpr, gnrlSiteCo: gnrlSiteCo, autoSiteCo: autoSiteCo, glampSiteCo: glampSiteCo, caravSiteCo: caravSiteCo, indvdlCaravSiteCo: indvdlCaravSiteCo, sitedStnc: sitedStnc, siteMg1Width: siteMg1Width, siteMg2Width: siteMg2Width, siteMg3Width: siteMg3Width, siteMg1Vrticl: siteMg1Vrticl, siteMg2Vrticl: siteMg2Vrticl, siteMg3Vrticl: siteMg3Vrticl, siteMg1Co: siteMg1Co, siteMg2Co: siteMg2Co, siteMg3Co: siteMg3Co, siteBottomCl1: siteBottomCl1, siteBottomCl2: siteBottomCl2, siteBottomCl3: siteBottomCl3, siteBottomCl4: siteBottomCl4, siteBottomCl5: siteBottomCl5, tooltip: tooltip, glampInnerFclty: glampInnerFclty, caravInnerFclty: caravInnerFclty, prmisnDe: prmisnDe, operPdCl: operPdCl, operDeCl: operDeCl, trlerAcmpnyAt: trlerAcmpnyAt, caravAcmpnyAt: caravAcmpnyAt, toiletCo: toiletCo, swrmCo: swrmCo, wtrplCo: wtrplCo, brazierCl: brazierCl, sbrsCl: sbrsCl, sbrsEtc: sbrsEtc, posblFcltyCl: posblFcltyCl, posblFcltyEtc: posblFcltyEtc, clturEventAt: clturEventAt, clturEvent: clturEvent, exprnProgrmAt: exprnProgrmAt, exprnProgrm: exprnProgrm, extshrCo: extshrCo, frprvtWrppCo: frprvtWrppCo, frprvtSandCo: frprvtSandCo, fireSensorCo: fireSensorCo, themaEnvrnCl: themaEnvrnCl, eqpmnLendCl: eqpmnLendCl, animalCmgCl: animalCmgCl, tourEraCl: tourEraCl, firstImageUrl: firstImageUrl, createdtime: createdtime, modifiedtime: modifiedtime)
                    
                    self.campingSpotList.append(capmingSpot)
                }
            }
        }
    }
        
    /*
     contentId
     facltNm
     lineIntro
     intro
     allar
     insrncAt
     trsagntNo
     bizrno
     facltDivNm
     mangeDivNm
     mgcDiv
     manageSttus
     hvofBgnde
     hvofEnddle
     featureNm
     induty
     lctCl
     doNm
     sigunguNm
     zipcode
     addr1
     addr2
     mapX
     mapY
     direction
     tel
     homepage
     resveUrl
     resveCl
     manageNmpr
     gnrlSiteCo
     autoSiteCo
     glampSiteCo
     caravSiteCo
     indvdlCaravSiteCo
     sitedStnc
     siteMg1Width
     siteMg2Width
     siteMg3Width
     siteMg1Vrticl
     siteMg2Vrticl
     siteMg3Vrticl
     siteMg1Co
     siteMg2Co
     siteMg3Co
     siteBottomCl1
     siteBottomCl2
     siteBottomCl3
     siteBottomCl4
     siteBottomCl5
     tooltip
     glampInnerFclty
     caravInnerFclty
     prmisnDe
     operPdCl
     operDeCl
     trlerAcmpnyAt
     caravAcmpnyAt
     toiletCo
     swrmCo
     wtrplCo
     brazierCl
     sbrsCl
     sbrsEtc
     posblFcltyCl
     posblFcltyEtc
     clturEventAt
     clturEvent
     exprnProgrmAt
     exprnProgrm
     extshrCo
     frprvtWrppCo
     frprvtSandCo
     fireSensorCo
     themaEnvrnCl
     eqpmnLendCl
     animalCmgCl
     tourEraCl
     firstImageUrl
     createdtime
     modifiedtime
     */
    func addCampingSpotList(_ campingSpot: Item) {
        database.collection("CampingSpotList").document(campingSpot.contentId).setData([
            "contentId": campingSpot.contentId,
            "facltNm": campingSpot.facltNm,
            "lineIntro": campingSpot.lineIntro,
            "intro": campingSpot.intro,
            "allar": campingSpot.allar,
            "insrncAt": campingSpot.insrncAt,
            "trsagntNo": campingSpot.trsagntNo,
            "bizrno": campingSpot.bizrno,
            "facltDivNm": campingSpot.facltDivNm,
            "mangeDivNm": campingSpot.mangeDivNm,
            "mgcDiv": campingSpot.mgcDiv,
            "manageSttus": campingSpot.manageSttus,
            "hvofBgnde": campingSpot.hvofBgnde,
            "hvofEnddle": campingSpot.hvofEnddle,
            "featureNm": campingSpot.featureNm,
            "induty": campingSpot.induty,
            "lctCl": campingSpot.lctCl,
            "doNm": campingSpot.doNm,
            "sigunguNm": campingSpot.sigunguNm,
            "zipcode": campingSpot.zipcode,
            "addr1": campingSpot.addr1,
            "addr2": campingSpot.addr2,
            "mapX": campingSpot.mapX,
            "mapY": campingSpot.mapY,
            "direction": campingSpot.direction,
            "tel": campingSpot.tel,
            "homepage": campingSpot.homepage,
            "resveUrl": campingSpot.resveUrl,
            "resveCl": campingSpot.resveCl,
            "manageNmpr": campingSpot.manageNmpr,
            "gnrlSiteCo": campingSpot.gnrlSiteCo,
            "autoSiteCo": campingSpot.autoSiteCo,
            "glampSiteCo": campingSpot.glampSiteCo,
            "caravSiteCo": campingSpot.caravSiteCo,
            "indvdlCaravSiteCo": campingSpot.indvdlCaravSiteCo,
            "sitedStnc": campingSpot.sitedStnc,
            "siteMg1Width": campingSpot.siteMg1Width,
            "siteMg2Width": campingSpot.siteMg2Width,
            "siteMg3Width": campingSpot.siteMg3Width,
            "siteMg1Vrticl": campingSpot.siteMg1Vrticl,
            "siteMg2Vrticl": campingSpot.siteMg2Vrticl,
            "siteMg3Vrticl": campingSpot.siteMg3Vrticl,
            "siteMg1Co": campingSpot.siteMg1Co,
            "siteMg2Co": campingSpot.siteMg2Co,
            "siteMg3Co": campingSpot.siteMg3Co,
            "siteBottomCl1": campingSpot.siteBottomCl1,
            "siteBottomCl2": campingSpot.siteBottomCl2,
            "siteBottomCl3": campingSpot.siteBottomCl3,
            "siteBottomCl4": campingSpot.siteBottomCl4,
            "siteBottomCl5": campingSpot.siteBottomCl5,
            "tooltip": campingSpot.tooltip,
            "glampInnerFclty": campingSpot.glampInnerFclty,
            "caravInnerFclty": campingSpot.caravInnerFclty,
            "prmisnDe": campingSpot.prmisnDe,
            "operPdCl": campingSpot.operPdCl,
            "operDeCl": campingSpot.operDeCl,
            "trlerAcmpnyAt": campingSpot.trlerAcmpnyAt,
            "caravAcmpnyAt": campingSpot.caravAcmpnyAt,
            "toiletCo": campingSpot.toiletCo,
            "swrmCo": campingSpot.swrmCo,
            "wtrplCo": campingSpot.wtrplCo,
            "brazierCl": campingSpot.brazierCl,
            "sbrsCl": campingSpot.sbrsCl,
            "sbrsEtc": campingSpot.sbrsEtc,
            "posblFcltyCl": campingSpot.posblFcltyCl,
            "posblFcltyEtc": campingSpot.posblFcltyEtc,
            "clturEventAt": campingSpot.clturEventAt,
            "clturEvent": campingSpot.clturEvent,
            "exprnProgrmAt": campingSpot.exprnProgrmAt,
            "exprnProgrm": campingSpot.exprnProgrm,
            "extshrCo": campingSpot.extshrCo,
            "frprvtWrppCo": campingSpot.frprvtWrppCo,
            "frprvtSandCo": campingSpot.frprvtSandCo,
            "fireSensorCo": campingSpot.fireSensorCo,
            "themaEnvrnCl": campingSpot.themaEnvrnCl,
            "eqpmnLendCl": campingSpot.eqpmnLendCl,
            "animalCmgCl": campingSpot.animalCmgCl,
            "tourEraCl": campingSpot.tourEraCl,
            "firstImageUrl": campingSpot.firstImageUrl,
            "createdtime": campingSpot.createdtime,
            "modifiedtime": campingSpot.modifiedtime,
        ])
        fetchCampingSpot()
    }
    
    /*
     campingSpotLocation
     campingSpotView
     campingSpotName
     campingSpotContenId
     */
    //MARK: 캠핑장리스트 combine으로 읽어오는 함수
    func readCampingSpotListCombine(readDocument: ReadDocuments) {
        FirebaseCampingSpotService().readCampingSpotService(readDocument: ReadDocuments(campingSpotLocation: readDocument.campingSpotLocation, campingSpotView: readDocument.campingSpotView, campingSpotName: readDocument.campingSpotName, campingSpotContenId: readDocument.campingSpotContenId))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(#function, error)
                    print(#function, "Failed get CampingSpotList")
                    self.firebaseCampingSpotServiceError = .badSnapshot
                    self.showErrorAlertMessage = self.firebaseCampingSpotServiceError.errorDescription!
                    return
                case .finished:
                    print(#function, "Finished get CampingSpotList")
                    return
                }
            } receiveValue: { [weak self] lastDocument in
                self?.lastDoc = lastDocument.lastDoc
                self?.campingSpots = lastDocument.campingSpots ?? []
                self?.campingSpotList.append(contentsOf: self?.campingSpots ?? [])
            }
            .store(in: &cancellables)
    }
    
}
