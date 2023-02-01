//
//  Date.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import Foundation
import Firebase

//MARK: - Date포맷 설정
extension Date {
    public func getKoreanDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: self)
    }
}


// MARK: - String을 Date포맷으로 변경
extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

//MARK: - TimeStamp 설정 함수
class TimestampToString {
    
    //MARK: --분 전 으로 시간 표시 됨
    static func dateString(_ timestamp: Timestamp) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth] // 시간 단위 설정
        formatter.maximumUnitCount = 1 // 시간 단위를 몇개를 나타낼 것인가
        formatter.unitsStyle = .abbreviated // 단위의 가장 앞글자 약어(s, m, h, d, w 등)으로 설정
        
        // 한글로 변환
        var calender = Calendar.current
        calender.locale = Locale(identifier: "ko")
        formatter.calendar = calender
        
        // 만들어진 시간부터 지금(Date())까지 얼마만큼의 시간이 걸렸는지 계산해서 차이(difference)를 반환
        return formatter.string(from: timestamp.dateValue(), to: Date()) ?? ""
    }
    
    //MARK: 작성 월,일,요일
    static func dateString2(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "MM.dd EEEEE" // "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from:  timestamp.dateValue())

    }
    //MARK: 작성 시간, 분
    static func dateString3(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "HH:mm" // "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from:  timestamp.dateValue())

    }
}
