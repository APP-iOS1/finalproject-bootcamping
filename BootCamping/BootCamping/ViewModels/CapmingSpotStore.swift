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
    /*
     campingSpotLocation
     campingSpotView
     campingSpotName
     campingSpotContenId
     */
    //MARK: 캠핑장리스트 combine으로 읽어오는 함수
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
