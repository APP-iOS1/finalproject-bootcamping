//
//  FirebaseReportService.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/14.
//

import Firebase
import Combine

struct FirebaseReportService {
    
    let database = Firestore.firestore()
    
    //MARK: - Read FirebaseReportService
    func readReportService() -> AnyPublisher<[ReportedDiary], Error> {
        Future<[ReportedDiary], Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            database.collection("ReportedDiaries")
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error)
                        return
                        
                    }
                    guard let snapshot = snapshot else { return }
                    var reportedDiaries = [ReportedDiary]()
                    
                    reportedDiaries = snapshot.documents.map { document in
                        return ReportedDiary(id: document.documentID, reportedDiaryId: document["reportedDiaryId"] as? String ?? "", reportOption: document["reportOption"] as? String ?? "")}
                    
                    promise(.success(reportedDiaries))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Create FirebaseReportService
    func createReportService(reportedDiary: ReportedDiary) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.database
                .collection("ReportedDiaries")
                .document(reportedDiary.id)
                .setData([
                "id": reportedDiary.id,
                "reportedDiaryId": reportedDiary.reportedDiaryId,
                "reportOption": reportedDiary.reportOption]) { error in
                if let error = error {
                    print(error)
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
