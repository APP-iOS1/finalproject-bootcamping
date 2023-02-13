//
//  CustomDatePickerView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/19.
//

import SwiftUI

struct CustomDatePickerView: View {
    
    @EnvironmentObject var scheduleStore: ScheduleStore
    
    @Binding var currentDate: Date
    @Binding var currentMonth: Int
    
    let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    //lazy grid columns
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 25) {
            HStack(spacing: 20){
                // 2023.02 < >
                calendarLabelView
                // 일정 추가 버튼
                addScheduleButton
            }
            // 일 월 화 수 목 금 토
            dayLabelView
            Divider()
            VStack{
                calendarView
                taskView
            }
            .onChange(of: currentMonth) { newValue in
                //updating Month
                currentDate = getCurrentMonth()
            }
        }
    }
    
    // MARK: - 날짜 비교
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // MARK: - 현재 날짜의 연도, 달만 String으로 변환. 반환형식 예시: 2023 01
    ///달력이 나타내는 연도, 달을 알려주기 위한 함수. 현재 날짜(currentDate)변수의 데이터를 Date -> String 타입 변환,
    ///"YYYY MM"형식으로 반환. (예시: 2023 01)
    func extraData_YearMonth() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    // MARK: - 현재 날짜의 달, 일(day), 요일만 String으로 변환. 반환형식 예시: 01
    ///달력이 나타내는 달, 일(day)을 알려주기 위한 함수. 현재 날짜(currentDate)변수의 데이터를 Date -> String 타입 변환,
    ///"MM DD"형식으로 반환. (예시: 01)
    func extraData_MonthDay() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "MM dd"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    // MARK: - Month GET
    ///현재 달(month) 받아오는 함수
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else { return Date() }
        
        return currentMonth
    }
    
    // MARK: - 날짜 GET
    ///날짜 추출해주는 함수. DateValue 배열로 반환한다.
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            
            //일(day) get
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

extension CustomDatePickerView{
    //MARK: - 라벨(연도, 달, 화살표)
    private var calendarLabelView: some View{
        HStack(spacing: 20) {
            Text("\(extraData_YearMonth()[0]).\(extraData_YearMonth()[1])")
                .font(.title.bold())
            
            Button {
                currentMonth -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            Button {
                currentMonth += 1
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
    }
    
    // MARK: - 요일뷰(일,월,화,...,토)
    private var dayLabelView: some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: -Button : 나의 캠핑 일정 추가하기 버튼
    private var addScheduleButton : some View {
        NavigationLink {
            AddScheduleView()
        } label: {
            Text("일정 추가")
                .frame(width: UIScreen.screenWidth * 0.25, height: UIScreen.screenHeight * 0.045)
                .foregroundColor(.white)
                .background(Color.bcGreen)
                .cornerRadius(8)
        }
    }
    
    // MARK: - 날짜 그리드 뷰
    private var calendarView: some View{
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(extractDate()) { value in
                CardView(value: value)
                    .background (
                        Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.bcYellow)
                            .opacity((isSameDay(date1: value.date, date2: currentDate) && value.day != -1) ? 1 : 0)
                    )
                    .onTapGesture {
                        currentDate = value.date
                    }
            }
        }
    }
    // MARK: - 일정 뷰
    private var taskView: some View{
        VStack(alignment: .leading) {
            //MARK: 일정 디테일
            if scheduleStore.scheduleList.first(where: { schedule in
                return isSameDay(date1: schedule.date, date2: currentDate)
            }) != nil{
                ScrollView(showsIndicators: false) {
                    ForEach(scheduleStore.scheduleList.filter{ schedule in
                        return isSameDay(date1: schedule.date, date2: currentDate)
                    }) { schedule in
                        TaskCellView(month: extraData_MonthDay()[0], day: extraData_MonthDay()[1], schedule: schedule, color: schedule.color)
                    }
                }
            } else {
                Text("해당 날짜의 캠핑 일정이 없습니다")
                    .padding(.vertical, UIScreen.screenHeight * 0.05)
            }
        }
    }
    
    // MARK: - 달력 디테일 뷰 생성
    ///달력 디테일 뷰(day 데이터) 구성하는 함수
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack {
            if value.day != -1 {
                if scheduleStore.scheduleList.first(where: { schedule in
                    return isSameDay(date1: schedule.date, date2: value.date)
                }) != nil {
                    Text("\(value.day)")
                        .font(.body.bold())
                    Spacer()
                    HStack(spacing: 8) {
                        // 스케줄 개수만큼 점으로 표시하기
                        ForEach(scheduleStore.scheduleList.filter{ schedule in
                            return isSameDay(date1: schedule.date, date2: value.date)
                        }) { schedule in
                            Image(systemName: "flag.fill")
                                .font(.caption)
                                .foregroundColor(Color[schedule.color])
                        }
                    }
                } else {
                    Text("\(value.day)")
                        .font(.body.bold())
                    Spacer()
                }
            }
        }
        .padding(.vertical, 5)
        .frame(height: 50, alignment: .top)
    }
}

//MARK: - extension: 현재 달(month) 날짜들을 Date 타입으로 Get
extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)
        
        return range?.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        } ?? []
    }
}
