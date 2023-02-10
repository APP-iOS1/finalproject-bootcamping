//
//  LocalNotification.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/10.
//

import Foundation

struct LocalNotification {
    var identifier: String
    var title: String
    var body: String
    var subtitle: String?
    var dateComponents: DateComponents
    var repeats: Bool
    
    init(identifier: String,
         title: String,
         body: String,
         subtitle: String? = nil,
         dateComponents: DateComponents,
         repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.subtitle = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
}
