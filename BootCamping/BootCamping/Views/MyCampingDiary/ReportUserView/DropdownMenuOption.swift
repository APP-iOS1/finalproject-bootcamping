//
//  DropdownMenuOption.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/13.
//

import Foundation

struct DropdownMenuOption: Identifiable, Hashable {
    let id = UUID().uuidString
    let option: String
}

extension DropdownMenuOption {
//    static let testSingleMonth: DropdownMenuOption = DropdownMenuOption(option: "March")
    static let ReportReason: [DropdownMenuOption] = [
        DropdownMenuOption(option: "부적절한 홍보/도배"),
        DropdownMenuOption(option: "음란성/도박 등 불법성"),
        DropdownMenuOption(option: "비방/욕설"),
        DropdownMenuOption(option: "혐오 발언 또는 상징"),
        DropdownMenuOption(option: "지식재산권 침해"),
        DropdownMenuOption(option: "기타")
    ]
}
