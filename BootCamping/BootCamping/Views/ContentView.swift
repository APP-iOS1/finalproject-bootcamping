//
//  ContentView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import CoreData
import FirebaseAuth
import SwiftUI

struct ContentView: View {
    //로그인 유무 변수
    @AppStorage("login") var isSignIn: Bool = false
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    
    //탭뷰 화면전환 셀렉션 변수
    @EnvironmentObject var tabSelection: TabSelector
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var localNotificationCenter: LocalNotificationCenter
    
    @State var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            if isLoading {
                SplashScreenView().transition(.identity).zIndex(1)
            }
            if isSignIn {
                TabView(selection: $tabSelection.screen) {
                    //MARK: - 첫번째 홈탭 입니다.
                    NavigationStack {
                        HomeView()
                    }.tabItem {
                        Label("메인", systemImage: "tent")
                    }.tag(TabViewScreen.one)
                    
                    //MARK: - 두번째 캠핑장 탭입니다.
                    NavigationStack {
                        SearchCampingSpotView()
                    }.tabItem {
                        Label("캠핑장 검색", systemImage: "magnifyingglass")
                    }.tag(TabViewScreen.two)
                    
                    //MARK: -세번째 캠핑일기 탭입니다.
                    NavigationView {
                        if diaryStore.myDiaryUserInfoDiaryList.count == 0 {
                            DiaryEmptyView()
                        } else {
                            MyCampingDiaryView()
                        }
                    }.tabItem {
                        Label("내 캠핑일기", systemImage: "book")
                    }.tag(TabViewScreen.three)
                    
                    //MARK: - 네번째 마이페이지 탭입니다.
                    NavigationStack {
                        MyPageView()
                    }.tabItem {
                        Label("마이 페이지", systemImage: "person")
                    }.tag(TabViewScreen.four)
                }
                .onAppear {
                    diaryStore.firstGetMyDiaryCombine()
                }
            } else {
                LoginView()
                    .task {
                        if Auth.auth().currentUser?.uid == nil {
                            isSignIn = false
                        }
                    }

            }
        }
        .onReceive(localNotificationCenter.$pageToNavigationTo) {
            guard let notificationSelection = $0 else  { return }
            self.tabSelection.change(to: notificationSelection)
        }
        .task {
            diaryStore.firstGetRealTimeDiaryCombine()
            wholeAuthStore.readUserListCombine()
            scheduleStore.readScheduleCombine()
            diaryStore.mostLikedGetDiarysCombine()
            localNotificationCenter.getCurrentSetting()
            //현재 로그인 되어있는지
            if isSignIn {
                wholeAuthStore.getUserInfo(userUID: wholeAuthStore.currentUser!.uid) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        withAnimation { isLoading.toggle() }
                    })
                }
            } else {
                // 로그인 안되어있을경우
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                    withAnimation { isLoading.toggle() }
                })
            }
        }
        .fullScreenCover(isPresented: $isFirstLaunching) {
            OnboardingTabView(isFirstLaunching: $isFirstLaunching)
        }
    }
}

//MARK: - 탭뷰 화면전환 함수
enum TabViewScreen {
    case one
    case two
    case three
    case four
}

//탭뷰 화면전환 함수입니다.
final class TabSelector: ObservableObject {
    
    @Published var screen: TabViewScreen = .one
    
    func change(to screen: TabViewScreen) {
        self.screen = screen
    }
}
