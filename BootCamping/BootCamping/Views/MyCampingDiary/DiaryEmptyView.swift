//
//  DiaryEmptyView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/08.
//

import SwiftUI
import AlertToast

struct DiaryEmptyView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var isShowingAdd = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(systemName: "tray")
                    .font(.largeTitle)
                Text("내 캠핑일기가 아직 없어요.")
                    .font(.title3)
                    .padding()
                    .padding(.bottom, 50)
                
                Button {
                    self.isShowingAdd = true
                } label: {
                    Text("캠핑일기 작성하러 가기")
                        .modifier(GreenButtonModifier())
                }
                .sheet(isPresented: self.$isShowingAdd) {
                    DiaryAddView()
                }
                
//                NavigationLink (destination: DiaryAddView()){
//                    Text("캠핑일기 작성하러 가기")
//                        .modifier(GreenButtonModifier())
//                }
                Spacer()
            }
            diaryStore.isProcessing ? Color.black.opacity(0.3) : Color.clear
        }
        .onChange(of: diaryStore.createFinshed) { _ in
            diaryStore.firstGetMyDiaryCombine()
            diaryStore.firstGetRealTimeDiaryCombine()
        }
        .alert("다이어리 만들기에 실패했습니다.. 다시 시도해 주세요.", isPresented: $diaryStore.isError) {
            Button("확인", role: .cancel) {
                diaryStore.isError = false
            }
            
        }
        .toast(isPresenting: $diaryStore.isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}
