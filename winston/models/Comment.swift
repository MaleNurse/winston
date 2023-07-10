//
//  CommentData.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Defaults
import SwiftUI

typealias Comment = GenericRedditEntity<CommentData>

enum Oops: Error {
    case oops
}

extension Comment {
  convenience init(data: T, api: RedditAPI, kind: String? = nil) {
    self.init(data: data, api: api, typePrefix: "t1_")
    self.kind = kind
    //    self.data?.repliesWinston =
    if let replies = self.data?.replies {
      switch replies {
      case .first(_):
        break
      case.second(let listing):
        self.childrenWinston.data = listing.data?.children?.compactMap { x in
          if let innerData = x.data { return Comment(data: innerData, api: redditAPI, kind: x.kind) }
          return nil
        } ?? []
      }
    }
  }
  convenience init(message: Message) throws {
    let rawMessage = message
    if let message = message.data {
      self.init(data: CommentData(
        subreddit_id: nil,
        subreddit: message.subreddit,
        likes: message.likes != nil ? message.likes! > 0 : nil,
        replies: message.replies != nil ? .first(message.replies!) : nil,
        saved: false,
        id: message.id,
        archived: false,
        count: message.num_comments,
        author: message.author,
        created_utc: message.created_utc,
        send_replies: false,
        parent_id: message.parent_id,
        score: message.score,
        author_fullname: message.author_fullname,
        approved_by: nil,
        mod_note: nil,
        collapsed: false,
        body: message.body,
        top_awarded_type: nil,
        name: message.name,
        downs: nil,
        children: nil,
        body_html: message.body_html,
        created: message.created,
        link_id: nil,
        link_title: message.link_title,
        subreddit_name_prefixed: message.subreddit_name_prefixed,
        depth: nil,
        author_flair_background_color: nil,
        collapsed_because_crowd_control: nil,
        mod_reports: nil,
        num_reports: nil,
        ups: nil
      ), api: rawMessage.redditAPI, typePrefix: "t1_")
    } else {
      throw Oops.oops
    }
  }
  
  func loadChildren(parent: Comment, postFullname: String, preparation: (() -> Void)? = nil, callback: (() -> Void)? = nil) async {
    if let id = data?.id, let kind = kind, kind == "more", let data = data, let count = data.count, let parent_id = data.parent_id  {
      if let children = await redditAPI.fetchMoreReplies(comments: count > 0 ? data.children! : [String(parent_id.dropFirst(3))], postFullname: postFullname, dropFirst: count == 0) {
        var loadedComments: [Comment] = []
        children.forEach { x in
          if let data = x.data { loadedComments.append(Comment(data: data, api: redditAPI, kind: x.kind)) }
        }
        Task { [loadedComments] in
          await redditAPI.updateAvatarURLCacheFromComments(comments: loadedComments)
        }
        await MainActor.run { [loadedComments] in
          //          preparation?()
          //          doThisAfter(0) {
          if let index = parent.childrenWinston.data.firstIndex(where: { $0.data?.id == id }) {
            withAnimation {
              parent.childrenWinston.data.remove(at: index)
              parent.childrenWinston.data.insert(contentsOf: loadedComments, at: index)
            }
            //            }
            //            doThisAfter(0.2) {
            //              callback?()
            //            }
          }
        }
      }
    }
  }
  
  func reply(_ text: String) async -> Bool {
    if let fullname = data?.name {
      return await redditAPI.newReply(text, fullname) ?? false
    }
    return false
  }
  
  func vote(action: RedditAPI.VoteAction) async -> Bool? {
    let oldLikes = data?.likes
    let oldUps = data?.ups ?? 0
    var newAction = action
    newAction = action.boolVersion() == oldLikes ? .none : action
    await MainActor.run { [newAction] in
      data?.likes = newAction.boolVersion()
      data?.ups = oldUps + (action.boolVersion() == oldLikes ? oldLikes == nil ? 0 : -action.rawValue : action.rawValue * (oldLikes == nil ? 1 : 2))
    }
    let result = await redditAPI.vote(newAction, id: "\(typePrefix ?? "")\(id)")
    if result == nil || !result! {
      await MainActor.run { [oldLikes] in
        data?.likes = oldLikes
        data?.ups = oldUps
      }
    }
    return result
  }
}

struct CommentData: GenericRedditEntityDataType {
  let subreddit_id: String?
  //  let approved_at_utc: String?
  //  let author_is_blocked: Bool?
  //  let comment_type: String?
  //  let awarders: [String]?
  //  let mod_reason_by: String?
  //  let banned_by: String?
  //  let author_flair_type: String?
  //  let total_awards_received: Int?
  let subreddit: String?
  //  let author_flair_template_id: String?
  var likes: Bool?
  var replies: Either<String, Listing<CommentData>>?
  //  let user_reports: [String]?
  let saved: Bool?
  let id: String
  //  let banned_at_utc: String?
  //  let mod_reason_title: String?
  //  let gilded: Int?
  let archived: Bool?
  //  let collapsed_reason_code: String?
  //  let no_follow: Bool?
  let count: Int?
  let author: String?
  //  let can_mod_post: Bool?
  let created_utc: Double?
  let send_replies: Bool?
  let parent_id: String?
  let score: Int?
  let author_fullname: String?
  let approved_by: String?
  let mod_note: String?
  //  let all_awardings: [String]?
  let collapsed: Bool?
  let body: String?
  //  let edited: Bool?
  let top_awarded_type: String?
  //  let author_flair_css_class: String?
  let name: String?
  //  let is_submitter: Bool?
  let downs: Int?
  //  let author_flair_richtext: [String]?
  //  let author_patreon_flair: Bool?
  let children: [String]?
  let body_html: String?
  //  let removal_reason: String?
  //  let collapsed_reason: String?
  //  let distinguished: String?
  //  let associated_award: String?
  //  let stickied: Bool?
  //  let author_premium: Bool?
  //  let can_gild: Bool?
  //  let gildings: [String: String]?
  //  let unrepliable_reason: String?
  //  let author_flair_text_color: String?
  //  let score_hidden: Bool?
  //  let permalink: String?
  //  let subreddit_type: String?
  //  let locked: Bool?
  //  let report_reasons: String?
  let created: Double?
  //  let author_flair_text: String?
  //  let treatment_tags: [String]?
  let link_id: String?
  let link_title: String?
  let subreddit_name_prefixed: String?
  //  let controversiality: Int?
  let depth: Int?
  let author_flair_background_color: String?
  let collapsed_because_crowd_control: String?
  let mod_reports: [String]?
  let num_reports: Int?
  var ups: Int?
}

struct Gildings: Codable {
}

struct CommentSort: Codable, Identifiable {
  var icon: String
  var value: String
  var id: String {
    value
  }
}

enum CommentSortOption: Codable, CaseIterable, Identifiable, Defaults.Serializable {
  var id: String {
    self.rawVal.id
  }
  
  case confidence
  case new
  case top
  case controversial
  case old
  case random
  case qa
  case live
  
  var rawVal: SubListingSort {
    switch self {
    case .confidence:
      return SubListingSort(icon: "flame.fill", value: "confidence")
    case .new:
      return SubListingSort(icon: "newspaper.fill", value: "new")
    case .top:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "top")
    case .controversial:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "controversial")
    case .old:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "old")
    case .random:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "random")
    case .qa:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "qa")
    case .live:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "live")
    }
  }
}
