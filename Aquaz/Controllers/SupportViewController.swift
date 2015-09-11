//
//  SupportViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import MessageUI
import Social

class SupportViewController: UIViewController {
  
  @IBOutlet weak var applicationTitle: UILabel!
  @IBOutlet weak var tellToFriendTextView: UITextView!
  @IBOutlet weak var reviewTextView: UITextView!
  
  private struct Strings {
    lazy var applicationTitleTemplate: String = NSLocalizedString(
      "SVC:Aquaz %@",
      value: "Aquaz %@",
      comment: "SupportViewController: Template for application title with version number")
    
    lazy var mailToFriendsSubject: String = NSLocalizedString(
      "SVC:I suggest you to try Aquaz",
      value: "I suggest you to try Aquaz",
      comment: "SupportViewController: Subject of tell-to-friend e-mail")
    
    lazy var mailToFriendsWelcomeBody: String = NSLocalizedString(
      "SVC:Hey there!<br><br>I\'ve been using Aquaz and thought you might like it. It\'s an easy way to track your water intake.",
      value: "Hey there!<br><br>I\'ve been using Aquaz and thought you might like it. It\'s an easy way to track your water intake.",
      comment: "SupportViewController: Body of tell-to-friend e-mail")

    lazy var cancel: String = NSLocalizedString(
      "SVC:Cancel",
      value: "Cancel",
      comment: "SupportViewController: Title for cancel button")

    lazy var ok: String = NSLocalizedString(
      "SVC:OK",
      value: "OK",
      comment: "SupportViewController: Title for OK button")

    lazy var feedbackOfferAction: String = NSLocalizedString(
      "SVC:Send a suggestion",
      value: "Send a suggestion",
      comment: "SupportViewController: Title for [Send a suggestion] item in the action sheet used for choosing type of e-mail for developers")
    
    lazy var feedbackBugAction: String = NSLocalizedString(
      "SVC:Report an issue",
      value: "Report an issue",
      comment: "SupportViewController: Title for [Report an issue] item in the action sheet used for choosing type of e-mail for developers")
    
    lazy var feedbackHelpAction: String = NSLocalizedString(
      "SVC:Request help",
      value: "Request help",
      comment: "SupportViewController: Title for [Request help] item in the action sheet used for choosing type of e-mail for developers")
    
    lazy var facebookText: String = NSLocalizedString(
      "SVC:Hey people! I\'ve been using Aquaz and thought you might like it. It\'s an easy way to track your water intake.",
      value: "Hey people! I\'ve been using Aquaz and thought you might like it. It\'s an easy way to track your water intake.",
      comment: "SupportViewController: Text for social message")

    lazy var twitterText: String = self.facebookText

    lazy var facebookNotFound: String = NSLocalizedString(
      "SVC:Facebook account is not found",
      value: "Facebook account is not found",
      comment: "SupportViewController: Information message if no Facebook account found on device")
    
    lazy var twitterNotFound: String = NSLocalizedString(
      "SVC:Twitter account is not found",
      value: "Twitter account is not found",
      comment: "SupportViewController: Information message if no Twitter account found on device")
  }
  
  private var strings = Strings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    setupApplicationTitle()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func preferredContentSizeChanged() {
    applicationTitle.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    tellToFriendTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    reviewTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    view.invalidateIntrinsicContentSize()
  }

  private func setupApplicationTitle() {
    applicationTitle.text = String.localizedStringWithFormat(strings.applicationTitleTemplate, applicationVersion)
  }
  
  @IBAction func tellToFriendsByMail() {
    let link = "<a href=\(GlobalConstants.appStoreLink)>\(GlobalConstants.appStoreLink)</a>"
    let body = "\(strings.mailToFriendsWelcomeBody)<br><br>\(link)"
    
    showEmailComposer(subject: strings.mailToFriendsSubject, body: body, recipients: nil)
  }
  
  @IBAction func tellToFriendsByTwitter() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      let text = "\(strings.twitterText) \(GlobalConstants.appStoreLink)"
      controller.setInitialText(text)
      presentViewController(controller, animated:true, completion:nil)
    } else {
      let alert = UIAlertView(title: nil, message: strings.twitterNotFound, delegate: nil, cancelButtonTitle: strings.ok)
      alert.show()
    }
  }
  
  @IBAction func tellToFriendsByFacebook() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
      let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      let text = "\(strings.twitterText) \(GlobalConstants.appStoreLink)"
      controller.setInitialText(text)
      presentViewController(controller, animated:true, completion:nil)
    } else {
      let alert = UIAlertView(title: nil, message: strings.facebookNotFound, delegate: nil, cancelButtonTitle: strings.ok)
      alert.show()
    }
  }
  
  @IBAction func sendMailToDevelopers() {
    let actionSheet = UIActionSheet(title: nil, delegate: self,
      cancelButtonTitle: strings.cancel,
      destructiveButtonTitle: nil,
      otherButtonTitles: strings.feedbackOfferAction, strings.feedbackBugAction, strings.feedbackHelpAction)
    actionSheet.showInView(view)
  }
  
  private func showEmailComposer(subject subject: String, body: String, recipients: [String]?) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.setSubject(subject)
    mailComposer.setMessageBody(body, isHTML: true)
    
    if let recipients = recipients {
      mailComposer.setToRecipients(recipients)
    }
    
    mailComposer.mailComposeDelegate = self

    presentViewController(mailComposer, animated: true, completion: nil)
  }
  
  @IBAction func reviewAppInAppstore() {
    if let url = NSURL(string: GlobalConstants.appStoreLink) {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  private var applicationVersion: String {
    return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
  }

  private var applicationBuild: String {
    return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
  }
  
  private var deviceInfo: String {
    return UIDevice.currentDevice().model
  }
  
  private var systemInfo: String {
    return "\(UIDevice.currentDevice().systemName) \(UIDevice.currentDevice().systemVersion)"
  }
}

extension SupportViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    let subject: String

    switch buttonIndex {
    case 0: return // Cancel
    case 1: subject = "Aquaz: Suggestion"
    case 2: subject = "Aquaz: Issue"
    case 3: subject = "Aquaz: Help"
    default: return
    }
    
    let body = "<br><br>About: \(composeAboutInfo())"
    
    showEmailComposer(subject: subject, body: body, recipients: [GlobalConstants.developerMail])
  }

  private func composeAboutInfo() -> String {
    let applicationInfo = "Aquaz \(applicationVersion) (\(applicationBuild))"
    return "\(applicationInfo), \(systemInfo)"
  }
  
}

extension SupportViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }

}
