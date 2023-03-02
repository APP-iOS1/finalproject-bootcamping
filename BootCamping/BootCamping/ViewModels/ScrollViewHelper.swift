//
//  ScrollViewHelper.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/14.
//

import Foundation
import UIKit
import Combine
import SwiftUI


class ScrollViewHelper: NSObject, UIScrollViewDelegate, ObservableObject {
    
    @Published var isSwiped: Bool = false
    @Published var commentOffset: [String: CGFloat] = [ : ]
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        withAnimation(.easeOut) {
            self.commentOffset = [ : ]
        }
    }
}
