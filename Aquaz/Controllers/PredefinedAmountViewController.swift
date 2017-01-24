//
//  PredefinedAmountViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 23.01.17.
//  Copyright © 2017 Sergey Balyakin. All rights reserved.
//

import UIKit

class PredefinedAmountViewController: UIViewController {

  @IBOutlet weak var pickerView: UIPickerView!
  var didSelectRowFunction: ((Double) -> ())!
  var amount: Double!
  
  fileprivate let amountsCollection = Settings.sharedInstance.generalVolumeUnits.value.amountsCollection
  fileprivate let formatPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  fileprivate let formatDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let row = findRowWithNearestAmount(amount: amount) {
      pickerView.selectRow(row, inComponent: 0, animated: false)
    }
  }

  fileprivate func findRowWithNearestAmount(amount: Double) -> Int? {
    var minimumDelta = Double.infinity
    var row: Int?
    
    for (index, currentAmount) in amountsCollection.enumerated() {
      let delta = abs(amount - currentAmount)
      if delta < minimumDelta {
        minimumDelta = delta
        row = index
      }
    }
    return row
  }
}

extension PredefinedAmountViewController: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return amountsCollection.count
  }
}

extension PredefinedAmountViewController: UIPickerViewDelegate {
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let amount = amountsCollection[row]
    let title = Units.sharedInstance.formatMetricAmountToText(metricAmount: amount, unitType: .volume, roundPrecision: formatPrecision, fractionDigits: formatDecimals, displayUnits: true)
    return title
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let amount = amountsCollection[row]
    didSelectRowFunction(amount)
  }
}


private extension Units.Volume {
  var precision: Double {
    switch self {
    case .millilitres: return 10.0
    case .fluidOunces: return 0.5
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
  
  var amountsCollection: DoubleCollection {
    switch self {
    case .millilitres: return DoubleCollection(minimumValue: 50, maximumValue: 1500, step: 10)
    case .fluidOunces: return DoubleCollection(minimumValue: Quantity.convert(amount: 1, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit()),
                                               maximumValue: Quantity.convert(amount: 50, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit()),
                                               step: Quantity.convert(amount: 0.5, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit()))
    }
  }
}
