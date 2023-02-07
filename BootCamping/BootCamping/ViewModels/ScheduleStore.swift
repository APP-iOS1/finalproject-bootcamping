//
//  ScheduleStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/31.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseAnalytics
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

extension ScheduleStore {
    // MARK: - setNotification
    /// 시뮬레이터에서는 확인이 안 됨에 주의해주세요!
    /// 실 기기로 테스트 하는 경우에만 푸시 알림 확인이 가능합니다
    func setNotification(startDate: Date) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == UNAuthorizationStatus.notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert,.sound,.badge], completionHandler: { didAllow, Error in
                        print(didAllow) //
                    })
            }
            if settings.authorizationStatus == UNAuthorizationStatus.authorized{
                let content = UNMutableNotificationContent()
                content.badge = 1
                content.title = "에휴"
                content.body = "왜 안 되는데.."
                content.userInfo = ["name" : "민콩"]
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "민콩noti", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("set Notification Error \(error)")
                    }
                }
            }
        }
    }
}
