//
//  Comment.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/19.
//

import Foundation
import Firebase

struct Comment{
    let id: String
    let diaryId: String                 // 글
    let uid: String                     // 유저
    let nickName: String                // 유저 이름
    let profileImage: String            // 유저 프로필 사진
    let commentContent: String          // 댓글
    let commentCreatedDate: Timestamp   // 댓글 작성 시간
    let commentLike: [String]           // 댓글에 좋아요
}
