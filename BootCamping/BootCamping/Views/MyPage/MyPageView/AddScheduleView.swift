//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var scheduleStore: ScheduleStore
    @Environment(\.dismiss) private var dismiss
    
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var campingSpot: String = ""
    @State private var isAddingDisable = true
    
    // 캠핑 종료일이 시작일보다 늦어야 하므로 종료일 날짜 선택 범위를 제한해준다.
    var dateRange: ClosedRange<Date> {
        let max = Calendar.current.date(
            byAdding: .year,
            value: 10,
            to: endDate
        )!
        return startDate...max
    }
    
    //onAppear 시 캠핑장 데이터 패치
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    @State var page: Int = 2
    var fetchData: FetchData = FetchData()

    var body: some View {
        // FIXME: 여행 일정의 첫 날과 마지막 날을 선택하면 범위 선택이 가능해야 함
        VStack{
            Spacer()
            Divider()
            titleTextField
                .padding(.vertical, 10)
            Divider()
                .padding(.bottom, 10)
            DatePicker(
                "캠핑 시작일",
                selection: $startDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.automatic)
            DatePicker(
                "캠핑 종료일",
                selection: $endDate,
                in: dateRange,
                displayedComponents: [.date]
            )
            .datePickerStyle(.automatic)
            .onChange(of: startDate) { newStartDate in
                if endDate < newStartDate {
                    endDate = newStartDate
                }
            }
            Spacer()
            addScheduleButton
                .padding(.bottom, 50)
        }
        .onAppear{
            isAddingDisable = checkSchedule(startDate: startDate, endDate: endDate)
            
            Task {
                campingSpotStore.campingSpotList = try await fetchData.fetchData(page: page)
            }
            
        }
        .onChange(of: [self.startDate, self.endDate]) { newvalues in
            isAddingDisable = checkSchedule(startDate: newvalues[0], endDate: newvalues[1])
            print("isAddingDisable \(isAddingDisable)")
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    func checkSchedule(startDate: Date, endDate: Date) -> Bool {
        if startDate > endDate {  return true }
        for schedule in scheduleStore.scheduleList{
            if (startDate ... endDate).contains(schedule.date) {
                print("check Schedule returns true")
                return true
            }
        }
        print("check Schedule returns false")
        return true
    }
}

extension AddScheduleView {
    
    // MARK: -View : 캠핑장 이름 titleTextField
    private var titleTextField : some View {
        VStack {
            if campingSpot == "" {
                HStack{
                    NavigationLink {
                        SearchCampingSpotListView(campingSpotName: $campingSpot)
                    } label: {
                        HStack{
                            Text("캠핑장 추가하기")
                                .foregroundColor(.bcBlack)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.bcBlack)
                        }
                    }
                }
            } else {
                HStack {
                    Text("\(campingSpot)")
                        .lineLimit(1)
                    Spacer()
                    Button {
                        campingSpot = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.bcBlack)

                    }

                }
                
            }
        }
    }
    // MARK: -View : addScheduleButton
    private var addScheduleButton : some View {
        Button {
            let calendar = Calendar.current
            if endDate.timeIntervalSince(startDate) > 0 {
                let interval = endDate.timeIntervalSince(startDate)
                let days = Int(interval / 86400)
                for day in 0...days {
                    scheduleStore.addSchedule(Schedule(id: UUID().uuidString, title: campingSpot, date: calendar.date(byAdding: .day, value: day, to: startDate) ?? Date()))
                }
            } else {
                scheduleStore.addSchedule(Schedule(id: UUID().uuidString, title: campingSpot, date: startDate))
            }
            dismiss()
        } label: {
            Text("등록")
                .bold()
            //                    .modifier(GreenButtonModifier())
        }
        .disabled(campingSpot == "" || isAddingDisable)
        
    }
}



struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
            .environmentObject(ScheduleStore())
            .environmentObject(CampingSpotStore())
    }
}
