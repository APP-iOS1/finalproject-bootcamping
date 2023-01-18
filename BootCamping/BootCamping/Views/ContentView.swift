//
//  ContentView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var tabSelection = 1
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationStack {
                HomeView()
            }.tabItem {
                Label("메인", systemImage: "tent")
            }.tag(1)
            NavigationStack {
                SearchCampingSpotView()
            }.tabItem {
                Label("캠핑장 검색", systemImage: "magnifyingglass")
            }.tag(2)
            NavigationStack {
                MyCampingDiaryView()
            }.tabItem {
                Label("내 캠핑일기", systemImage: "book")
            }.tag(3)
            NavigationStack {
                MyPageView()
            }.tabItem {
                Label("마이 페이지", systemImage: "person")
            }.tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
