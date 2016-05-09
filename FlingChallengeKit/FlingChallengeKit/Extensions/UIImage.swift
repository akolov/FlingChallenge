//
// Copyright (c) 2015-2016 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  UIImage.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import UIKit

private let lock = NSLock()

extension UIImage {

  public static func fling_threadSafeImageWithData(data: NSData) -> UIImage? {
    lock.lock()
    let image = UIImage(data: data)
    lock.unlock()
    return image
  }

  public static func fling_threadSafeImageWithData(data: NSData, scale: CGFloat) -> UIImage? {
    lock.lock()
    let image = UIImage(data: data, scale: scale)
    lock.unlock()
    return image
  }

}

extension UIImage {

  private struct AssociatedKeys {
    static var InflatedKey = "fling_UIImage.Inflated"
  }

  var fling_inflated: Bool {
    get {
      if let inflated = objc_getAssociatedObject(self, &AssociatedKeys.InflatedKey) as? Bool {
        return inflated
      }
      else {
        return false
      }
    }
    set(inflated) {
      objc_setAssociatedObject(self, &AssociatedKeys.InflatedKey, inflated, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func fling_inflate() {
    guard !fling_inflated else { return }
    fling_inflated = true
    CGDataProviderCopyData(CGImageGetDataProvider(CGImage))
  }

}
