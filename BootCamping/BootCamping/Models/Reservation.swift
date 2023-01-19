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
