//
//  UIScreen+Extension.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

//MARK: - 사용하는 컬러 익스텐션입니다.
extension Color {
    static let bcBlack = Color("BCBlack")
    static let bcGreen = Color("BCGreen")
    static let bcDarkGray = Color("BCDarkGray")
    static let bcYellow = Color("BCYellow")
}

//MARK: - 키보드 dismiss extension함수입니다.
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}




