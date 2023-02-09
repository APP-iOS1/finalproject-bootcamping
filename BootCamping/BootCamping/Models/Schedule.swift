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

struct Schedule: Identifiable {
    var id: String
//    var campingSpotId: String // 캠핑장 고유 id <- json에서는 contentId
    var title: String
    var date: Date
    var color: String
}

