//
//  ScheduleStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/31.
//

import Combine
import Firebase

class ScheduleStore: ObservableObject {
    
    @Published var scheduleList: [Schedule] = []
    @Published var firebaseScheduleServiceError: FirebaseScheduleServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    
    let database = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Read Schedule Combine
    func readScheduleCombine() {
        FirebaseScheduleService().readScheduleService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get Schedules")
                    self.firebaseScheduleServiceError = .badSnapshot
                    self.showErrorAlertMessage = self.firebaseScheduleServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished get Schedules")
                    return
                }
            } receiveValue: { [weak self] schedulesValue in
                self?.scheduleList = schedulesValue
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Create Schedule Combine
    func createScheduleCombine(schedule: Schedule) {
        FirebaseScheduleService().createScheduleService(schedule: schedule)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed create Schedule")
                    self.firebaseScheduleServiceError = .createScheduleError
                    self.showErrorAlertMessage = self.firebaseScheduleServiceError.errorDescription!
                    
                    return
                case .finished:
                    print("Finished create Schedule")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Delete Schedule Combine
    func deleteScheduleCombine(schedule: Schedule) {
        FirebaseScheduleService().deleteScheduleService(schedule: schedule)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed create Schedule")
                    self.firebaseScheduleServiceError = .deleteScheduleError
                    self.showErrorAlertMessage = self.firebaseScheduleServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished create Schedule")
                    self.readScheduleCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        
    }
    
}
