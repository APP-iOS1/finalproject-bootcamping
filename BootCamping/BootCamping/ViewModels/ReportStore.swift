//
//  ReportStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/14.
//

import Combine
import Firebase

// TODO: - 신고 프로세스 짜기...
class ReportStore: ObservableObject {
    
    @Published var reportedDiaries: [ReportedDiary] = []
    
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()
    
    func readReportCombine() {
        FirebaseReportService().readReportService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed create Report")
                    return
                case .finished:
                    print("Finished create Report")
                    return
                }
            } receiveValue: { [weak self] reportValues in
                self?.reportedDiaries = reportValues
            }
            .store(in: &cancellables)
    }
    
    // MARK: - createReportCombine
    func createReportCombine(reportedDiary: ReportedDiary) {
        FirebaseReportService().createReportService(reportedDiary: reportedDiary)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed create Report")
                    return
                case .finished:
                    print("Finished create Report")
                    self.readReportCombine()
                    return
                }
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
}
