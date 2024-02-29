//
//  IconManager.swift
//  winston
//
//  Created by Igor Marcossi on 30/09/23.
//

import Foundation
import SwiftUI

#if DEBUG
      private var envSuffix = "Debug"
#elseif ALPHA
      private var envSuffix = "Alpha"
#elseif BETA
      private var envSuffix = "Beta"
#else
      private var envSuffix = ""
#endif

enum WinstonAppIcon: String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  
  case standard,
       explode,
       peak,
       side,
       simpleEyesBlack,
       simpleEyesBlue,
       simpleFaceBlack,
       simpleFaceBlue
  
  var description: String {
    switch self {
    case .standard: return "Classic winston icon"
    case .explode: return "One of Winston's heroic moments."
    case .peak: return "Really, anyone?"
    case .side: return "Wow, look at him!"
    case .simpleEyesBlack: return "Why not right?"
    case .simpleEyesBlue: return "Why not in blue this time."
    case .simpleFaceBlack: return "Ok, I'll add the whole face."
    case .simpleFaceBlue: return "Ok... Blue..."
    }
  }
  
  var label: String {
    switch self {
    case .standard: return "Default"
    case .explode: return "Fantastic!"
    case .peak: return "Anyone?"
    case .side: return "Side view"
    case .simpleEyesBlack: return "Eyes (Black)"
    case .simpleEyesBlue: return "Eyes (Blue)"
    case .simpleFaceBlack: return "Face (Black)"
    case .simpleFaceBlue: return "Face (Blue)"
    }
  }
  
  var name: String? {
    switch self {
    case .standard: return nil
    case .explode: return "iconExplode\(envSuffix)"
    case .peak: return "iconPeak\(envSuffix)"
    case .side: return "iconSide\(envSuffix)"
    case .simpleEyesBlack: return "iconSimpleEyesBlack\(envSuffix)"
    case .simpleEyesBlue: return "iconSimpleEyesBlue\(envSuffix)"
    case .simpleFaceBlack: return "iconSimpleFaceBlack\(envSuffix)"
    case .simpleFaceBlue: return "iconSimpleFaceBlue\(envSuffix)"
    }
  }
  
  var preview: UIImage { UIImage(named: self.name ?? "iconStandard\(envSuffix)")! }
}

class AppIconManger {
  var current: WinstonAppIcon {
    return WinstonAppIcon.allCases.first(where: {
      $0.name == UIApplication.shared.alternateIconName
    }) ?? .standard
  }
  
  func setIcon(_ appIcon: WinstonAppIcon, completion: ((Bool) -> Void)? = nil) {
    guard current != appIcon,
          UIApplication.shared.supportsAlternateIcons
    else { return }
    UIApplication.shared.setAlternateIconName(appIcon.name) { error in
      if let error = error {
        print("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)")
      }
      completion?(error != nil)
    }
  }
}
