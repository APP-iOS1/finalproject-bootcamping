//
//  UserInfo.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import Foundation

struct User: Identifiable {
    let id: String
    let profileImage: String
    let nickName: String
    let userEmail: String?
    let bookMarkedDiaries: [String]
}
