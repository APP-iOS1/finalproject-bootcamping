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

/*
//MARK: 샘플 일정 데이터
struct Schedule: Identifiable {
    var id = UUID().uuidString
    var campingSpotId: String // 캠핑장 고유 id <- json에서는 contentId
    var title: String
    var date: Date
}
 */

class ScheduleStore: ObservableObject {
    @Published var scheduleList: [Schedule] = []

    let database = Firestore.firestore()
    
    // MARK: Add Schedule
    func addSchedule(_ schedule: Schedule) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        
    }
    
}
