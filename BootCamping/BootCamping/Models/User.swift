//
//  UserInfo.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import Foundation

struct User: Identifiable, Hashable {
    let id: String
    var profileImage: String
    var nickName: String
    var userEmail: String
    var bookMarkedDiaries: [String]
}
