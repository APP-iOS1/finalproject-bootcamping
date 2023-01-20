//
//  Reservation.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import Foundation

struct Reservation: Identifiable {
    let id: String
    let campingSpotId: String // 캠핑장 고유 id <- json에서는 contentId
    let userId: String // uid
    let date: Date // 방문 날짜
}

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

//MARK: 샘플 일정 데이터
struct Schedule: Identifiable {
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

struct ScheduleMetaData: Identifiable {
    var id = UUID().uuidString
    var schedule: [Schedule]
    var scheduleDate: Date
}

func getSampleDate(offset: Int) -> Date {
    let calendar = Calendar.current
    
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

var schedules: [ScheduleMetaData] = [
    ScheduleMetaData(schedule: [
        Schedule(title: "샘플1"),
        Schedule(title: "샘플2"),
        Schedule(title: "샘플3")
    ], scheduleDate: getSampleDate(offset: 1)),
    
    ScheduleMetaData(schedule: [
        Schedule(title: "샘플4")
    ], scheduleDate: getSampleDate(offset: -3)),
    
    ScheduleMetaData(schedule: [
        Schedule(title: "샘플5"),
        Schedule(title: "샘플6")
    ], scheduleDate: getSampleDate(offset: -8)),
    
    ScheduleMetaData(schedule: [
        Schedule(title: "샘플7"),
        Schedule(title: "샘플8"),
        Schedule(title: "샘플9"),
        Schedule(title: "샘플10")
    ], scheduleDate: getSampleDate(offset: 20))
]
