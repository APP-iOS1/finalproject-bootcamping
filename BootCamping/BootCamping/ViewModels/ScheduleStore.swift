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

class ScheduleStore: ObservableObject {
    @Published var scheduleList: [Schedule] = []
    
    let database = Firestore.firestore()
    
    // MARK: Add Schedule
    func addSchedule(_ schedule: Schedule) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
       
        database.collection("UserList")
            .document(userUID)
            .collection("Schedule")
            .addDocument(data: ["id": schedule.id,
                                "title": schedule.title,
                                "date": schedule.date.toString()
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
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssSSS"
                        
                        let schedule: Schedule = Schedule(id: id, title: title, date: dateFormatter.date(from: date) ?? Date())
                        self.scheduleList.append(schedule)
                    }
                }
            }
    }
}
