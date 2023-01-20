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
            addSchedule
            CustomDatePickerView(currentDate: $currentDate, currentMonth: $currentMonth)
        }
        .padding(.vertical)
    }
    // MARK: -Button : 나의 캠핑 일정 추가하기 버튼
    private var addSchedule : some View {
        NavigationLink {
            
        } label: {
            Text("나의 캠핑 일정 추가하기")
                .modifier(GreenButtonModifier())
            
        }
    }
}



//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
