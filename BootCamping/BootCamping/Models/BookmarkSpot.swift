//
//  BookmarkSpot.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/01.
//

import Foundation

struct BookmarkSpot: Hashable, Identifiable {
    let id: [String] // 북마크 한 장소id
    let uid: String // 유저
}
