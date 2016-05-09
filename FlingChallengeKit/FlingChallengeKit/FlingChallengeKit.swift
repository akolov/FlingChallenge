//
//  FlingChallengeKit.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public struct FlingChallengeKit {

  public static var secure = true
  public static var strictSSL = true
  public static var apiHost = "challenge.superfling.com"

  static var baseURL: NSURL {
    let components = NSURLComponents()
    components.scheme = secure ? "https" : "http"
    components.host = apiHost
    assert(components.URL != nil, "Base API URL should be valid")
    return components.URL!
  }

}
