//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

struct MyCampingDiaryView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "plus")
            }
            .padding(.horizontal)
            .padding(.bottom)
            Divider()
            ScrollView {
                DiaryDetailView()
            }
        }
    }
}

struct MyCampingDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        MyCampingDiaryView()
    }
}
