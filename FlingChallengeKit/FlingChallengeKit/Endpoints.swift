//
//  Endpoints.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

enum Endpoints: String {

  case Feed = "/"
  case Photos = "/photos/{id}"

  func URL(parameters: [String: String]? = nil) throws -> NSURL {
    guard let components = NSURLComponents(URL: FlingChallengeKit.baseURL, resolvingAgainstBaseURL: false) else {
      throw FlingChallengeError.ConfigurationError(description: "Could not create API URL components " +
                                                                "from base URL: \(FlingChallengeKit.baseURL)")
    }

    var path = self.rawValue
    if let parameters = parameters {
      for (key, value) in parameters {
        path = path.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
      }
    }

    components.path = path
    guard let URL = components.URL else {
      throw FlingChallengeError.ConfigurationError(description: "Could not create API URL" +
                                                                "for endpoint \(self.rawValue) " +
                                                                "with parameters: \(parameters)")
    }

    return URL
  }

}
