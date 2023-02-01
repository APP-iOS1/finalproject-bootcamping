//
//  Reservation.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import Foundation

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

//MARK: 샘플 일정 데이터
struct Schedule: Identifiable {
    var id: String
//    var campingSpotId: String // 캠핑장 고유 id <- json에서는 contentId
    var title: String
    var date: Date
}

//func getSampleDate(offset: Int) -> Date {
//    let calendar = Calendar.current
//    let date = calendar.date(byAdding: .day, value: offset, to: Date())
//
//    return date ?? Date()
//}

var schedules: [Schedule] = [
    Schedule(id: UUID().uuidString, title: "샘플1", date: Date()),
    Schedule(id: UUID().uuidString, title: "샘플2", date: Date()),
    Schedule(id: UUID().uuidString, title: "샘플3", date: Date())
]

