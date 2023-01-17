//
//  Date.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import Foundation

extension Date {
    public func getKoreanDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
}
