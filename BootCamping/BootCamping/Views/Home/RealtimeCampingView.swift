//
//  RealtimeCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import Firebase

struct RealtimeCampingView: View {
    
    @EnvironmentObject var diaryStore: DiaryStore
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(diaryStore.diaryList) { item in
                    RealtimeCampingCellView(item: item)
                        .padding(.bottom, 20)
                }
            }
            .onAppear {
                diaryStore.getData()
            }
        }
        .padding(.top)
    }
}

struct RealtimeCampingView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingView()
            .environmentObject(DiaryStore())
    }
}
