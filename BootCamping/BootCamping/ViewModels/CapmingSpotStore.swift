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
    @Published var campingSpotList: [CampingSpot] = []
    @Published var campingSpots: [CampingSpot] = []
    @Published var campingSpot: CampingSpot = CampingSpot(contentId: "", facltNm: "", lineIntro: "", intro: "", allar: "", insrncAt: "", trsagntNo: "", bizrno: "", facltDivNm: "", mangeDivNm: "", mgcDiv: "", manageSttus: "", hvofBgnde: "", hvofEnddle: "", featureNm: "", induty: "", lctCl: "", doNm: "", sigunguNm: "", zipcode: "", addr1: "", addr2: "", mapX: "", mapY: "", direction: "", tel: "", homepage: "", resveUrl: "", resveCl: "", manageNmpr: "", gnrlSiteCo: "", autoSiteCo: "", glampSiteCo: "", caravSiteCo: "", indvdlCaravSiteCo: "", sitedStnc: "", siteMg1Width: "", siteMg2Width: "", siteMg3Width: "", siteMg1Vrticl: "", siteMg2Vrticl: "", siteMg3Vrticl: "", siteMg1Co: "", siteMg2Co: "", siteMg3Co: "", siteBottomCl1: "", siteBottomCl2: "", siteBottomCl3: "", siteBottomCl4: "", siteBottomCl5: "", tooltip: "", glampInnerFclty: "", caravInnerFclty: "", prmisnDe: "", operPdCl: "", operDeCl: "", trlerAcmpnyAt: "", caravAcmpnyAt: "", toiletCo: "", swrmCo: "", wtrplCo: "", brazierCl: "", sbrsCl: "", sbrsEtc: "", posblFcltyCl: "", posblFcltyEtc: "", clturEventAt: "", clturEvent: "", exprnProgrmAt: "", exprnProgrm: "", extshrCo: "", frprvtWrppCo: "", frprvtSandCo: "", fireSensorCo: "", themaEnvrnCl: "", eqpmnLendCl: "", animalCmgCl: "", tourEraCl: "", firstImageUrl: "", createdtime: "", modifiedtime: "")
    @Published var firebaseCampingSpotServiceError: FirebaseCampingSpotServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "Error"
    @Published var lastDoc: QueryDocumentSnapshot?
    @Published var noImageURL: String = "https://firebasestorage.googleapis.com/v0/b/bootcamping-280fc.appspot.com/o/BootcampingImage%2FnoImage.png?alt=media&token=d401f6bd-e6db-4e41-9db4-a082e16f8d6e"
    
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()
    /*
     campingSpotLocation
     campingSpotView
     campingSpotName
     campingSpotContenId
     */
    //MARK: - 캠핑장리스트 combine으로 읽어오는 함수
    func readCampingSpotListCombine(readDocument: ReadDocuments) {
        FirebaseCampingSpotService().readCampingSpotService(readDocument: readDocument)
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
                self!.campingSpots = lastDocument.campingSpots!
                self?.campingSpotList.append(contentsOf: lastDocument.campingSpots!)
            }
            .store(in: &cancellables)
    }
    
}
