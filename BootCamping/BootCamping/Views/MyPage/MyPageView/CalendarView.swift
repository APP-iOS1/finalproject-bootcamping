//
//  CalendarView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import SwiftUI

//MARK: - 나의 캠핑 일정에 나타나는 캘린더 뷰
struct CalendarView: View {
    
    @State var currentDate: Date = Date()
    @State var currentMonth: Int = 0
    
    var body: some View {
        VStack {
            CustomDatePickerView(currentDate: $currentDate, currentMonth: $currentMonth)
        }
        .padding(.vertical)
    }

    
}
