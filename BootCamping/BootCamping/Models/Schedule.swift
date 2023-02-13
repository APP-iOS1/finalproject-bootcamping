//
//  Schedule.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import Foundation

// MARK: - DateValue 커스텀 캘린더를 그리기 위한 구조체
struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

// MARK: - Schedule 모델
struct Schedule: Identifiable {
    var id: String // UUID().uuidString
    var title: String // 캠핑장 고유 contentId
    var date: Date // 날짜
    var color: String // 캘린더에 표시하는 일정 색상
}

