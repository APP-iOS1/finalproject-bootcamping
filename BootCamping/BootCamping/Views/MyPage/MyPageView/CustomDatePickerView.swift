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
    
    //화살표 누르면 달(month) 업데이트
    @Binding var currentMonth: Int
    
    var body: some View {
        VStack(spacing: 25) {
            //요일 array
            let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
            
            //MARK: 라벨(연도, 달, 화살표)
            HStack(spacing: 20) {
                Text("\(extraData_YearMonth()[0]).\(extraData_YearMonth()[1])")
                    .font(.title.bold())
                
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                
                addScheduleButton
            }
            .padding(.horizontal)
            
            Divider()
            
            // MARK: - 요일뷰
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // MARK: - 날짜뷰
            //lazy grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(extractDate()) { value in
                    CardView(value: value)
                        .background (
                            Rectangle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.gray)
                                .opacity((isSameDay(date1: value.date, date2: currentDate) && value.day != -1) ? 1 : 0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                            // FIXME: - value.date를 확인해보면 표시되는 날짜보다 하루씩 늦음
                            /// 2월 1일 데이터는 1월 31일 date형식인 걸 확인할 수 있다,, 수정하기,,
//                            print(value.date)
//                            print(currentDate)
                        }
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(extraData_MonthDay()[0]).\(extraData_MonthDay()[1]) \(extraData_MonthDay()[2])")
                        .font(.title2.bold())
                        .padding(.top, 25)
                    
                    ScrollView(showsIndicators: false) {
                        //MARK: 일정 디테일
                        if scheduleStore.scheduleList.first(where: { schedule in
                            return isSameDay(date1: schedule.date, date2: currentDate)
                        }) != nil{
                            ForEach(scheduleStore.scheduleList.filter{ schedule in
                                return isSameDay(date1: schedule.date, date2: currentDate)
                            }) { schedule in
                                Text("\(schedule.title)")
                            }
                        } else {
                            Text("No schedule")
                        }
                    }
                    .padding(.horizontal,30)
                    Spacer()
                }
            }
        }
        .onChange(of: currentMonth) { newValue in
            //updating Month
            currentDate = getCurrentMonth()
        }
    }

    // MARK: -Button : 나의 캠핑 일정 추가하기 버튼
    private var addScheduleButton : some View {
        NavigationLink {
            AddScheduleView()
        } label: {
            Text("일정 추가")
                .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenHeight * 0.05)
                .foregroundColor(.white)
                .background(Color.bcGreen)
                .cornerRadius(10)
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
                        }) {_ in
                            Circle()
                                .fill(Color.red)
                                .frame(width: 7, height: 7)
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
        formatter.dateFormat = "MM dd EEEE"
        
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

//MARK: 일정 구분선
///달력 뷰에서 일정별로 구분해주는 선을 그려주는 구조체입니다. Color를 인자로 받습니다.
///해당 색은 구분선의 색으로 사용됩니다.
struct ExDivider: View {
    let color: Color
    let width: CGFloat = 5
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(color)
            .frame(width: width, height: 45)
        //            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct TaskCellView: View{
    let color: UIColor
    var body: some View {
        HStack(spacing: 30) {
            ExDivider(color: Color.red)
            VStack(alignment: .leading, spacing: 5) {
                Text("캠핑장 이름")
                    .font(.body.bold())
            }
        }
        .padding(.bottom, 10)
        .padding(.top, 20)
    }
}



//
//struct CustomDatePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
