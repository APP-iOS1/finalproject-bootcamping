//
//  ContactMail.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import Foundation

struct ComposeMailData {
  let subject: String
  let recipients: [String]?
  let message: String
  let attachments: [AttachmentData]?
}

struct AttachmentData {
  let data: Data
  let mimeType: String
  let fileName: String
}
