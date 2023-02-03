//
//  BookmarkSpot.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/01.
//

import Foundation

struct BookmarkSpot: Hashable, Identifiable {
    let id: String
    let campingSpot: String // 캠핑장 고유 ID (contentId)
}
