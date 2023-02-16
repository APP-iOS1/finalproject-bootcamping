//
//  SplashScreenView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/06.
//

import SwiftUI
import FirebaseAuth

struct SplashScreenView: View {
    @EnvironmentObject var authStore: AuthStore
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.bcGreen
                VStack {
                    LottieView()
                        .frame(width: 150, height: 150)
                        .padding(.leading, 65)
                        .offset(x: 0, y: -100)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
                VStack {
                    Image("loginName")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)
                        .offset(x: 0, y: 40)
                }

            }
            .ignoresSafeArea()
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
