//
//  CalendarView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import SwiftUI

//MARK: 메인 뷰
struct CalendarView: View {
    
    @State var currentDate: Date = Date()
    @State var currentMonth: Int = 0
    
    var body: some View {
        VStack {
            //달력섹션
            CustomDatePickerView(currentDate: $currentDate, currentMonth: $currentMonth)
        }
        .padding(.vertical)
    }

    
}



//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
