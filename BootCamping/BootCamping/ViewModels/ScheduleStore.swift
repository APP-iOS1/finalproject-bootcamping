//
//  ScheduleStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/31.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import FirebaseStorage
import Combine

class ScheduleStore: ObservableObject {
    
    @Published var scheduleList: [Schedule] = []
    @Published var firebaseScheduleServiceError: FirebaseScheduleServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    
    let database = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: Add Schedule
    func addSchedule(_ schedule: Schedule) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        database.collection("UserList")
            .document(userUID)
            .collection("Schedule")
            .addDocument(data: ["id": schedule.id,
                                "title": schedule.title,
                                "date": dateFormatter.string(from: schedule.date)
                               ])
        fetchSchedule()
    }
    // MARK: fetch Schedule
    func fetchSchedule()  {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        database.collection("UserList")
            .document(userUID)
            .collection("Schedule")
            .getDocuments { (snapshot, error) in
                self.scheduleList.removeAll()
                if let snapshot {
                    for document in snapshot.documents {
                        
                        let docData = document.data()
                        
                        let id: String = docData["id"] as? String ?? ""
                        let title: String = docData["title"] as? String ?? ""
                        let date: String = docData["date"] as? String ?? ""
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        let schedule: Schedule = Schedule(id: id, title: title, date: dateFormatter.date(from: date) ?? Date())
                        self.scheduleList.append(schedule)
                    }
                }
            }
    }
    
    //MARK: Read Schedule Combine
    
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
    
    //MARK: Create Schedule Combine
    
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
                    self.readScheduleCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: Delete Schedule Combine
    
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
