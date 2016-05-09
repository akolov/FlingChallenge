//
//  SessionManager.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public final class SessionManager: NSObject {

  public static let apiSession: NSURLSession = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    return session
  }()

  public static let downloaderSession: NSURLSession = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.URLCache = downloaderCache
    let session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    return session
  }()

}

private extension SessionManager {

  private class Delegate: NSObject, NSURLSessionDelegate {

    @objc
    func URLSession(session: NSURLSession,
                    didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                    completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
      guard !FlingChallengeKit.strictSSL else {
        completionHandler(.PerformDefaultHandling, nil)
        return
      }

      guard let trust = challenge.protectionSpace.serverTrust
            where challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust &&
                  challenge.protectionSpace.host == FlingChallengeKit.apiHost else {
        completionHandler(.PerformDefaultHandling, nil)
        return
      }

      let credential = NSURLCredential(forTrust: trust)
      completionHandler(.UseCredential, credential)
    }

  }

  private static let delegate = Delegate()
  private static let downloaderCache = NSURLCache(memoryCapacity: 0,
                                                  diskCapacity: 100 * 1024 * 1024,
                                                  diskPath: "downloads")

}
