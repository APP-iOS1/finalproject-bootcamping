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
    static let bcWhite = Color("BCWhite")
}

//MARK: - 키보드 dismiss extension함수입니다.
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }

        return renderImage
    }
}

extension Image {
    func resizeImage(imgName: String) -> Image {
        guard let img = UIImage(named: imgName)?.resize(newWidth: UIScreen.screenWidth * 1 / 5) else { fatalError("Fail to load image") }
        return Image(uiImage: img)
    }
}


