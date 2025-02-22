//
//  OKTradeFeeViewController.swift
//  OneKey
//
//  Created by xuxiwen on 2021/3/21.
//  Copyright © 2021 Onekey. All rights reserved.
//

import UIKit
import Reusable
import PanModal

enum OKTradeFeeSelect {
    case slow
    case medium
    case fast
    case custum
}

class OKTradeFeeViewController: PanModalViewController {

    @IBOutlet weak var navView: OKModalNavView!

    @IBOutlet weak var slowFeeView: UIView!
    @IBOutlet weak var slowFeeSpeed: UILabel!
    @IBOutlet weak var slowFeeSelected: UIImageView!
    @IBOutlet weak var slowFeeCoinValue: UILabel!
    @IBOutlet weak var slowFeeRmbValue: UILabel!
    @IBOutlet weak var slowFeeTimeValue: UILabel!

    @IBOutlet weak var mediumFeeView: UIView!
    @IBOutlet weak var mediumFeeSpeed: UILabel!
    @IBOutlet weak var mediumFeeSelected: UIImageView!
    @IBOutlet weak var mediumFeeCoinValue: UILabel!
    @IBOutlet weak var mediumFeeRmbValue: UILabel!
    @IBOutlet weak var mediumFeeTimeValue: UILabel!

    @IBOutlet weak var fastFeeView: UIView!
    @IBOutlet weak var fastFeeSpeed: UILabel!
    @IBOutlet weak var fastFeeSelected: UIImageView!
    @IBOutlet weak var fastFeeCoinValue: UILabel!
    @IBOutlet weak var fastFeeRmbValue: UILabel!
    @IBOutlet weak var fastFeeTimeValue: UILabel!

    @IBOutlet weak var custumFeeView: UIView!
    @IBOutlet weak var custumFeeTitle: UILabel!
    @IBOutlet weak var custumFeeTime: UILabel!
    @IBOutlet weak var custumFeeValue: UILabel!
    @IBOutlet weak var custumFeeSelected: UIImageView!
    @IBOutlet weak var custunFeeGasTitle: UILabel!
    @IBOutlet weak var custunFeeGasTextFiled: UITextField!
    @IBOutlet weak var custunFeeGasPriceTitle: UILabel!
    @IBOutlet weak var custunFeeGasPriceTextFiled: UITextField!
    @IBOutlet weak var custumFeeFoldView: UIView!
    @IBOutlet weak var custumFeeFoldTitle: UILabel!
    @IBOutlet weak var custumFeeTipLabel: UILabel!

    var model: OKDefaultFeeInfoModel?
    var selectGasType: OKTradeFeeSelect = .medium
    var feeModel: OKSendFeeModel?
    var alertTipsContent: String = ""

    var callBackFee: ((OKTradeFeeSelect, OKSendFeeModel?) -> Void)?

    private var defaultFeeModel: OKDefaultFeeInfoModel?

    private var perTime: NSDecimalNumber?
    private var perRmb: NSDecimalNumber?
    private var perFee: NSDecimalNumber?
    private var allValue: NSDecimalNumber?
    private var keyboardDistance: CGFloat = 10

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = keyboardDistance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardDistance = IQKeyboardManager.shared().keyboardDistanceFromTextField
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 30

        navView.setNavTitle(string: "Miners fee".localized)
        slowFeeSpeed.text = "slow".localized
        mediumFeeSpeed.text = "recommended".localized
        fastFeeSpeed.text = "fast".localized
        custumFeeTitle.text = "The custom".localized
        custumFeeFoldTitle.text = "The custom".localized
        custunFeeGasTitle.text = "Gas Price (GWEI)"
        custunFeeGasPriceTitle.text = "Gas Limit"
        setDefaultValue()
        custunFeeGasTextFiled.keyboardType = .numberPad
        custunFeeGasPriceTextFiled.keyboardType = .numberPad

        custunFeeGasTextFiled.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        custunFeeGasPriceTextFiled.addTarget(self, action: #selector(didChangeText), for: .editingChanged)


        navView.setNavPop { [weak self] in
            guard let self = self else { return }
            self.popAction()
        }

        slowFeeView.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.updateSelectedUI(type: .slow)
        }

        mediumFeeView.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.updateSelectedUI(type: .medium)
        }

        fastFeeView.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.updateSelectedUI(type: .fast)
        }

        custumFeeFoldView.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.selectGasType = .custum
            self.updateSelectedUI(type: .custum)
        }

        custunFeeGasTextFiled.delegate = self
        custunFeeGasPriceTextFiled.delegate = self

        if let model = model {
            updateDefaultFeeInfo(model: model)
        }

        updateSelectedUI(type: selectGasType)
    }

    private func setDefaultValue() {
        slowFeeCoinValue.text = "--"
        slowFeeRmbValue.text = "--"
        slowFeeTimeValue.text = "--"
        mediumFeeCoinValue.text = "--"
        mediumFeeRmbValue.text = "--"
        mediumFeeTimeValue.text = "--"
        fastFeeCoinValue.text = "--"
        fastFeeRmbValue.text = "--"
        fastFeeTimeValue.text = "--"
        custumFeeValue.text = "--"
        custumFeeTime.text = "--"
        custunFeeGasTextFiled.text = "0"
        custunFeeGasPriceTextFiled.text = "0"
    }

    func updateDefaultFeeInfo(model: OKDefaultFeeInfoModel) {
        defaultFeeModel = model
        let token = tokenName()

        slowFeeCoinValue.text = model.slow.fee + " " + token
        slowFeeRmbValue.text = model.slow.fiat
        slowFeeTimeValue.text = "About 0 minutes".localized.replacingOccurrences(of: "0", with: " \(model.slow.time) ")

        mediumFeeCoinValue.text = model.normal.fee + " " + token
        mediumFeeRmbValue.text = model.normal.fiat
        mediumFeeTimeValue.text = "About 0 minutes".localized.replacingOccurrences(of: "0", with: " \(model.normal.time) ")

        fastFeeCoinValue.text = model.fast.fee + " " + token
        fastFeeRmbValue.text = model.fast.fiat
        fastFeeTimeValue.text = "About 0 minutes".localized.replacingOccurrences(of: "0", with: " \(model.fast.time) ")

        if self.selectGasType == .custum, let m = feeModel {
            custunFeeGasTextFiled.text = m.gas_limit
            custunFeeGasPriceTextFiled.text = m.gas_price
        } else {
            custunFeeGasTextFiled.text = model.normal.gas_limit
            custunFeeGasPriceTextFiled.text = model.normal.gas_price
        }

        let gasLimit = NSDecimalNumber(string: model.normal.gas_limit)
        let gasPrice = NSDecimalNumber(string: model.normal.gas_price)
        if !gasLimit.stringValue.isNaN, !gasLimit.stringValue.isNaN {
            allValue = gasLimit.multiplying(by: gasPrice, withBehavior: behavior())
        }
        perTime = NSDecimalNumber(string: model.normal.time)
        perRmb = NSDecimalNumber(string:  model.normal.fiat.split(" ").first ?? "0")
        perFee = NSDecimalNumber(string: model.normal.fee)

    }

    private func updateSelectedUI(type: OKTradeFeeSelect) {
        selectGasType = type
        custumFeeTipLabel.text = ""
        let feeViews = [slowFeeView, mediumFeeView, fastFeeView]
        let selectedViews = [slowFeeSelected, mediumFeeSelected, fastFeeSelected]
        var highlightView: UIView!
        var selectedView: UIView!
        switch selectGasType {
        case .slow:
            highlightView = slowFeeView
            selectedView = slowFeeSelected
            feeModel = defaultFeeModel?.slow
        case .medium:
            highlightView = mediumFeeView
            selectedView = mediumFeeSelected
            feeModel = defaultFeeModel?.normal
        case .fast:
            highlightView = fastFeeView
            selectedView = fastFeeSelected
            feeModel = defaultFeeModel?.fast
            break
        case .custum:
            highlightView = custumFeeFoldView
            selectedView = custumFeeSelected
            didChangeText()
            break
        }
        feeViews.forEach {
            $0?.borderColor = highlightView == $0 ? UIColor.tintBrand() : UIColor.fg_B03()
        }
        selectedViews.forEach {
            $0?.isHidden = selectedView != $0
        }

        let isSelectedCustum = highlightView == custumFeeFoldView
        custumFeeView.isHidden = !isSelectedCustum
        custumFeeFoldView.isHidden = isSelectedCustum
    }

    private func popAction() {
        func callBack() {
            if (model != nil) {
                callBackFee?(self.selectGasType, self.feeModel)
            }
            navigationController?.popViewController(animated: true)
        }
        if (alertTipsContent.isEmpty || selectGasType != .custum) {
            callBack()
        } else {
            let alert = UIAlertController(title: "prompt".localized, message: self.alertTipsContent,  preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel,  handler: { _ in
            }))
            alert.addAction(UIAlertAction(title: "Continue".localized, style: .default,  handler: { _ in
                callBack()
            }))
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Pan Modal Presentable

    override var shortFormHeight: PanModalHeight {
        .contentHeight(500)
    }

    override var longFormHeight: PanModalHeight {
        .maxHeight
    }

    override func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }

    @objc private func didChangeText() {
        updateCustumValue()
    }

    private func updateCustumValue() {
        func rest() {
            custumFeeValue.text = "--"
            custumFeeTime.text = "--"
            custumFeeTipLabel.text = ""
            alertTipsContent = ""
            selectGasType = .medium
            custunFeeGasTextFiled.textColor = .fg_B01()
            custunFeeGasPriceTextFiled.textColor = .fg_B01()
        }
        rest()

        guard let model = model else { return  }

        if let gasPrice = custunFeeGasPriceTextFiled.text, !gasPrice.isEmpty,
           let gas = custunFeeGasTextFiled.text, !gas.isEmpty,
           let allValue = allValue, let perTime = perTime, let perRmb = perRmb,  let perFee = perFee
        {
            let gasLimitDecimalNumber = NSDecimalNumber(string:gas)
            let gasPriceDecimalNumber = NSDecimalNumber(string: gasPrice)
            if gasLimitDecimalNumber.floatValue < (Float(model.normal.gas_limit) ?? 0) {
                custunFeeGasTextFiled.textColor = .tintRed()
                alertTipsContent = "Too little Gas Limit will cause the transaction to fail. Do you want to continue?".localized
                custumFeeTipLabel.text = String(format: "The minimum gas limit %@".localized, String(model.normal.gas_limit))
            }
            if gasLimitDecimalNumber.floatValue > (Float(model.normal.gas_limit) ?? 0) * 10 {
                custunFeeGasTextFiled.textColor = .tintRed()
                alertTipsContent = "Gas Limit is too much, do you want to continue?".localized
                custumFeeTipLabel.text = String(format: "The maximum gas limit %@".localized, String((Int(model.normal.gas_limit) ?? 0) * 10))
            }
            if gasPriceDecimalNumber.floatValue < 1 {
                custunFeeGasPriceTextFiled.textColor = .tintRed()
                alertTipsContent = "Too little Gas Price will cause the transaction to fail. Do you want to continue?".localized
                custumFeeTipLabel.text = String(format: "The minimum limit of Gas Price %@ gwei".localized, "1")
            }
            if gasPriceDecimalNumber.floatValue > (Float(model.fast.gas_price) ?? 0) * 10 {
                custunFeeGasPriceTextFiled.textColor = .tintRed()
                alertTipsContent = "Gas Price is too much, do you want to continue?".localized
                custumFeeTipLabel.text = String(format: "Gas Price maximum limit %@ gwei".localized, String((Int(model.fast.gas_price) ?? 0) * 10))
            }

            if gasPrice == "0" || gas == "0" {
                return
            }
            if allValue.stringValue == "0" {
                return
            }
            let ratio = gasLimitDecimalNumber.multiplying(by: gasPriceDecimalNumber, withBehavior: behavior()).dividing(by: allValue, withBehavior: behavior())
            if ratio.stringValue == "0" {
                return
            }
            let time =  NSDecimalNumber(string:"1").dividing(by: ratio, withBehavior: behavior()).multiplying(by: perTime, withBehavior: behavior(scale: 0)).intValue
            let rmb = ratio.multiplying(by: perRmb, withBehavior: behavior(scale: 2)).stringValue
            let fee = ratio.multiplying(by: perFee, withBehavior: behavior(scale: 9)).stringValue
            custumFeeTime.text =  "About 0 minutes".localized.replacingOccurrences(of: "0", with: " \(time) ")
            custumFeeValue.text = fee + " \(tokenName())" + " ≈ ¥" + rmb
            let model = OKSendFeeModel()
            model.fee = fee
            model.fiat = rmb
            model.gas_price = gasPrice
            model.gas_limit = gas
            model.time = String(time)
            selectGasType = .custum
            self.feeModel = model
        }
    }

    private func tokenName() -> String {
        return OKWalletManager.sharedInstance().currentWalletInfo?.coinType.chainNameToTokenName() ?? ""
    }

    private func behavior(scale: Int16 = 20) -> NSDecimalNumberHandler {
        return NSDecimalNumberHandler(
            roundingMode: .down,
            scale: scale,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: true
        )
    }
}

extension OKTradeFeeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        (self.navigationController as? PanModalNavViewController)?.panModalTransition(to: .longForm)
        return true
    }
}

extension OKTradeFeeViewController: StoryboardSceneBased {
    static let sceneStoryboard = UIStoryboard(name: "Tab_Discover", bundle: nil)
    static var sceneIdentifier = "OKTradeFeeViewController"
}
