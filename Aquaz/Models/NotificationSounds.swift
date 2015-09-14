//
//  NotificationSounds.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.06.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class NotificationSounds {

  typealias SoundInfo = (fileName: String, title: String)
  
  static let soundList: [SoundInfo] = [
    ("aqua.caf",      NSLocalizedString("NS:Aqua",      value: "Aqua",      comment: "NotificationSounds: alarm sound named [Aqua]")),
    ("alarm.caf",     NSLocalizedString("NS:Alarm",     value: "Alarm",     comment: "NotificationSounds: alarm sound named [Alarm]")),
    ("bells.caf",     NSLocalizedString("NS:Bells",     value: "Bells",     comment: "NotificationSounds: alarm sound named [Bells]")),
    ("bubbles.caf",   NSLocalizedString("NS:Bubbles",   value: "Bubbles",   comment: "NotificationSounds: alarm sound named [Bubbles]")),
    ("chime.caf",     NSLocalizedString("NS:Chime",     value: "Chime",     comment: "NotificationSounds: alarm sound named [Chime]")),
    ("chirp.caf",     NSLocalizedString("NS:Chirp",     value: "Chirp",     comment: "NotificationSounds: alarm sound named [Chirp]")),
    ("chord.caf",     NSLocalizedString("NS:Chord",     value: "Chord",     comment: "NotificationSounds: alarm sound named [Chord]")),
    ("glass.caf",     NSLocalizedString("NS:Glass",     value: "Glass",     comment: "NotificationSounds: alarm sound named [Glass]")),
    ("hand-bell.caf", NSLocalizedString("NS:Hand Bell", value: "Hand Bell", comment: "NotificationSounds: alarm sound named [Hand Bell]")),
    ("magic.caf",     NSLocalizedString("NS:Magic",     value: "Magic",     comment: "NotificationSounds: alarm sound named [Magic]")),
    ("tiny-bell.caf", NSLocalizedString("NS:Tiny Bell", value: "Tiny Bell", comment: "NotificationSounds: alarm sound named [Tiny Bell]")),
    ("whistle.caf",   NSLocalizedString("NS:Whistle",   value: "Whistle",   comment: "NotificationSounds: alarm sound named [Whistle]"))]

}