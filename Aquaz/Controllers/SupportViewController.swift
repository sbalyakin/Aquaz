//
//  SupportViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import MessageUI
import Social

class SupportViewController: UIViewController {
  
  @IBOutlet weak var applicationTitle: UILabel!
  @IBOutlet weak var tellToFriendTextView: UITextView!
  @IBOutlet weak var reviewTextView: UITextView!
  
  fileprivate struct LocalizedStrings {
    
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

    lazy var cantSendEmailsTitle: String = NSLocalizedString(
      "SVC:Unable to send mail",
      value: "Unable to send mail",
      comment: "SupportViewController: Title of an alert shown if the device is not set up to send e-mails")

    lazy var cantSendEmailsBody: String = NSLocalizedString(
      "SVC:Please check your mail settings",
      value: "Please check you mail settings",
      comment: "SupportViewController: Body of an alert shown if the device is not set up to send e-mails")
  }
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    setupApplicationTitle()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func preferredContentSizeChanged() {
    applicationTitle.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
    tellToFriendTextView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    reviewTextView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    view.invalidateIntrinsicContentSize()
  }

  fileprivate func setupApplicationTitle() {
    applicationTitle.text = String.localizedStringWithFormat(localizedStrings.applicationTitleTemplate, applicationVersion)
  }
  
  @IBAction func tellToFriendsByMail() {
    if !checkSendingEmailAvailability() {
      return
    }
    
    let link = "<a href=\(GlobalConstants.appStoreLink)>\(GlobalConstants.appStoreLink)</a>"
    let body = "\(localizedStrings.mailToFriendsWelcomeBody)<br><br>\(link)"
    
    showEmailComposer(subject: localizedStrings.mailToFriendsSubject, body: body, recipients: nil)
  }
  
  @IBAction func tellToFriendsByTwitter() {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
      let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      let text = "\(localizedStrings.twitterText) \(GlobalConstants.appStoreLink)"
      controller?.setInitialText(text)
      present(controller!, animated:true, completion:nil)
    } else {
      let alert = UIAlertView(title: nil, message: localizedStrings.twitterNotFound, delegate: nil, cancelButtonTitle: localizedStrings.ok)
      alert.show()
    }
  }
  
  @IBAction func tellToFriendsByFacebook() {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
      let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      let text = "\(localizedStrings.twitterText) \(GlobalConstants.appStoreLink)"
      controller?.setInitialText(text)
      present(controller!, animated:true, completion:nil)
    } else {
      let alert = UIAlertView(title: nil, message: localizedStrings.facebookNotFound, delegate: nil, cancelButtonTitle: localizedStrings.ok)
      alert.show()
    }
  }
  
  @IBAction func sendMailToDevelopers() {
    if !checkSendingEmailAvailability() {
      return
    }
    
    let actionSheet = UIActionSheet(title: nil, delegate: self,
      cancelButtonTitle: localizedStrings.cancel,
      destructiveButtonTitle: nil,
      otherButtonTitles: localizedStrings.feedbackOfferAction, localizedStrings.feedbackBugAction, localizedStrings.feedbackHelpAction)
    actionSheet.show(in: view)
  }
  
  fileprivate func checkSendingEmailAvailability() -> Bool {
    if MFMailComposeViewController.canSendMail() {
      return true
    }
    
    let alert = UIAlertView(title: localizedStrings.cantSendEmailsTitle, message: localizedStrings.cantSendEmailsBody, delegate: nil, cancelButtonTitle: localizedStrings.ok)
    alert.show()
    
    return false
  }
  
  fileprivate func showEmailComposer(subject: String, body: String, recipients: [String]?) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.setSubject(subject)
    mailComposer.setMessageBody(body, isHTML: true)
    
    if let recipients = recipients {
      mailComposer.setToRecipients(recipients)
    }
    
    mailComposer.mailComposeDelegate = self

    present(mailComposer, animated: true, completion: nil)
  }
  
  @IBAction func reviewAppInAppstore() {
    if let url = URL(string: GlobalConstants.appStoreLink) {
      UIApplication.shared.openURL(url)
    }
  }
  
  fileprivate var applicationVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
  }

  fileprivate var applicationBuild: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
  }
  
  fileprivate var deviceInfo: String {
    return UIDevice.current.model
  }
  
  fileprivate var systemInfo: String {
    return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
  }
}

extension SupportViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
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

  fileprivate func composeAboutInfo() -> String {
    let applicationInfo = "Aquaz \(applicationVersion) (\(applicationBuild))"
    return "\(applicationInfo), \(systemInfo)"
  }
  
}

extension SupportViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true, completion: nil)
  }

}
