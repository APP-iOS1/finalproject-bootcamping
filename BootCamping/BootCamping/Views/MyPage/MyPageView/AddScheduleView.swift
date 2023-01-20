//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var dates: Set<DateComponents> = []
    @State private var campingSpot: String = ""
    
    var body: some View {
        // FIXME: 여행 일정의 첫 날과 마지막 날을 선택하면 범위 선택이 가능해야 함
        /// 여러 날짜 선택이 가능한데 날짜 두 개만 선택받을 수 있게 해야 함
        MultiDatePicker("Dates Available", selection: $dates)
            .fixedSize()
        Group {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Dismiss")
            }
        }
    }
    // MARK: -View : updateUserPhoneNumberTextField
    private var titleTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("캠핑장 이름")
                .font(.title3)
                .bold()
            // TODO: autocomplete textfield,,? T^T
            TextField("캠핑장이름", text: $campingSpot)
        }
    }
}



struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
