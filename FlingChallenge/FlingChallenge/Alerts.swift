//
//  Alerts.swift
//  FlingChallenge
//
//  Created by Alexander Kolov on 9/5/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import UIKit

final class Alerts {

  static func presentFatalAlert(controller: UIViewController) {
    let title = NSLocalizedString("Oh no! 😢", comment: "Title of the fatal alert")
    let message = NSLocalizedString("Something really bad is preventing the app from working properly.\n" +
                                    "Please force quit the app by swiping it up in the task switcher and " +
                                    "try launching again. If the issue persists, reboot your device and/or " +
                                    "delete and reinstall the app.\nSorry about this!",
                                    comment: "Message of the fatal alert")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

    let actionTitle = NSLocalizedString("Dismiss", comment: "Dismiss action title")
    let action = UIAlertAction(title: actionTitle, style: .Cancel, handler: nil)
    alert.addAction(action)

    controller.presentViewController(alert, animated: true, completion: nil)
  }

}
