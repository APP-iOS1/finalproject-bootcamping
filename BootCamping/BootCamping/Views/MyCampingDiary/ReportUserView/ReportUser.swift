//
//  ReportUser.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/13.
//

import SwiftUI

struct ReportUser: View {
    @State private var isOptionsPresented: Bool = false
    
    @Binding var selectedOption: DropdownMenuOption?
    
    let placeholder: String
    let options: [DropdownMenuOption]
    
    var body: some View {
        Button(action: {
                self.isOptionsPresented.toggle()
        }) {
            HStack {
                Text(selectedOption == nil ? placeholder : selectedOption!.option)
                    .foregroundColor(selectedOption == nil ? .gray : .black)
                Spacer()
                
                Image(systemName: self.isOptionsPresented ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 12, height: 10)
            }
        }//
        
        .padding(13)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 1)
        }
        .overlay(alignment: .top) {
            VStack {
                if self.isOptionsPresented {
                    Spacer(minLength: 60)
                    DropdownMenuList(options: self.options) { option in
                        self.isOptionsPresented = false
                        self.selectedOption = option
                    }//
                    
                }//
            }
        }//
    }
}

struct DropdownMenuList: View {
    let options: [DropdownMenuOption]
    let onSelectedAction: (_ option: DropdownMenuOption) -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            ForEach(options) { option in
                DropdownMenuListRow(onSelectedAction: self.onSelectedAction, option: option)
            }//
        }
        // .frame(height: 200)
        .padding(.vertical, 5)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 1)
        }//
    }
}

struct DropdownMenuListRow: View {
    let onSelectedAction: (_ option: DropdownMenuOption) -> Void
    let option: DropdownMenuOption
    
    var body: some View {
        Button(action: {
            self.onSelectedAction(option)
        }) {
            Text(option.option)
                .frame(maxWidth: .infinity, alignment: .leading)
        }//
        .foregroundColor(.bcBlack)
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}







struct ReportUser_Previews: PreviewProvider {
    static var previews: some View {
        ReportUser(
            selectedOption: .constant(nil), placeholder: "이 게시물을 신고하는 이유", options: DropdownMenuOption.ReportReason)
    }
}
