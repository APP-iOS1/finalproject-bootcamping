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
        ScrollView {
            ForEach(diaryStore.diaryList) { item in
                VStack {
                    NavigationLink {
                        DiaryDetailView(item: item)
                    } label: {
                        RealtimeCampingCellView(item: item)
                    }
                    .foregroundColor(.bcBlack)
                }
            }
        }
        .padding()
        .onAppear {
            diaryStore.getData()
        }
    }
}

struct RealtimeCampingView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingView()
            .environmentObject(DiaryStore())
    }
}
