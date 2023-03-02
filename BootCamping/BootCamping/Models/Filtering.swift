//
//  Filtering.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/06.
//

import Foundation

//MARK: 뷰, 지역별로 필터해주기 위한 구조체
struct Filtering: Identifiable, Hashable {
    var id = UUID()
    var filterViewLocation: String
    var filters: [String]
    var filterNames: [String]
}
