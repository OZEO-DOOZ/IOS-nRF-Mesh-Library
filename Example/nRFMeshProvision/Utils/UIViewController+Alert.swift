//
//  UIViewController+Alert.swift
//  nRFMeshProvision_Example
//
//  Created by Aleksander Nowakowski on 20/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

extension Selector {
    
    static let nameRequired = #selector(UIViewController.nameRequired(_:))
    static let unicastAddress = #selector(UIViewController.unicastAddressOptional(_:))
    static let unicastAddressRequired = #selector(UIViewController.unicastAddressRequired(_:))
    static let groupAddress = #selector(UIViewController.groupAddressOptional(_:))
    static let groupAddressRequired = #selector(UIViewController.groupAddressRequired(_:))
    static let scene = #selector(UIViewController.sceneOptional(_:))
    static let sceneRequired = #selector(UIViewController.sceneRequired(_:))
    static let keyRequired = #selector(UIViewController.keyRequired(_:))
    
}

extension UIViewController {
    
    /// Shows a confirmation action sheet with given title and message.
    /// The handler will be executed when user selects Confirm action.
    ///
    /// - parameters:
    ///   - title:   The alert title.
    ///   - message: The message below the title.
    ///   - handler: The Confirm button handler.
    func confirm(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: handler))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    /// Displays an alert dialog with given title and message.
    /// The alert dialog will contain an OK button.
    ///
    /// - parameters:
    ///   - title:   The alert title.
    ///   - message: The message below the title.
    ///   - action:  An optional second action.
    ///   - handler: The OK button handler.
    func presentAlert(title: String?, message: String?,
                      option action: UIAlertAction? = nil,
                      handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: handler))
            if let action = action {
                alert.addAction(action)
            }
            self.present(alert, animated: true)
        }
    }
    
    /// Displays an alert dialog with given title and message.
    /// The alert dialog will contain two Text Fields allowing to
    /// specify a Range.
    ///
    /// - parameters:
    ///   - title:    The alert title.
    ///   - message:  The message below the title.
    ///   - range:    The initial value for the text fields.
    ///   - selector: An optional validator for the text fields.
    ///   - handler:  The OK button handler.
    func presentRangeAlert(title: String?, message: String?, range: RangeObject? = nil,
                           type selector: Selector? = nil,
                           handler: ((ClosedRange<UInt16>) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text                   = range?.lowerBound.hex
                textField.placeholder            = "Lower bound, e.g. 0001"
                textField.clearButtonMode        = .whileEditing
                textField.returnKeyType          = .next
                textField.keyboardType           = .alphabet
                textField.autocapitalizationType = .allCharacters
                if let selector = selector {
                    textField.addTarget(self, action: selector, for: .editingChanged)
                    textField.addTarget(self, action: selector, for: .editingDidBegin)
                }
            }
            alert.addTextField { textField in
                textField.text                   = range?.upperBound.hex
                textField.placeholder            = "Upper bound, e.g. AFFF"
                textField.clearButtonMode        = .whileEditing
                textField.returnKeyType          = .next
                textField.keyboardType           = .alphabet
                textField.autocapitalizationType = .allCharacters
                if let selector = selector {
                    textField.addTarget(self, action: selector, for: .editingChanged)
                    textField.addTarget(self, action: selector, for: .editingDidBegin)
                }
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let lowerBound = UInt16(alert.textFields![0].text!, radix: 16)
                let upperBound = UInt16(alert.textFields![1].text!, radix: 16)
                
                if let lowerBound = lowerBound, let upperBound = upperBound {
                    handler?(lowerBound...upperBound)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    /// Displays an alert dialog with given title and message and
    /// a text field with initial text and placeholder.
    /// Use type parameter to set the value validator.
    ///
    /// - parameters:
    ///   - title:       The alert title.
    ///   - message:     The message below the title.
    ///   - text:        Initial value of the text field.
    ///   - placeholder: The placeholder if text is empty.
    ///   - type:        The selector to be used for value validation.
    ///   - action:      An optional additional action.
    ///   - handler:     The OK button handler.
    func presentTextAlert(title: String?, message: String?, text: String? = "", placeHolder: String? = "",
                          type selector: Selector? = nil, option action: UIAlertAction? = nil,
                          handler: ((String) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text                   = text
                textField.placeholder            = placeHolder
                textField.clearButtonMode        = .whileEditing
                textField.returnKeyType          = .done
                textField.keyboardType           = .alphabet
                
                if let selector = selector {
                    textField.addTarget(self, action: selector, for: .editingChanged)
                    textField.addTarget(self, action: selector, for: .editingDidBegin)
                    
                    switch selector {
                    case .nameRequired:
                        textField.autocapitalizationType = .words
                        break
                    case .unicastAddress, .groupAddress,
                         .unicastAddressRequired, .groupAddressRequired:
                        textField.autocapitalizationType = .allCharacters
                    default:
                        break
                    }
                }
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                handler?(alert.textFields![0].text!)
            })
            if let action = action {
                alert.addAction(action)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    /// Displays an alert dialog with given title and message and
    /// a text field with initial text and placeholder.
    ///
    /// - parameters:
    ///   - title:       The alert title.
    ///   - message:     The message below the title.
    ///   - name:        The initial name of the key.
    ///   - key:         Initial value of the text field.
    ///   - handler:     The OK or Generate button handler.
    func presentKeyDialog(title: String?, message: String?,
                          name: String? = "", key: Data? = nil,
                          handler: ((String, Data) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text                   = name
                textField.placeholder            = "E.g. Lights and Switches"
                textField.clearButtonMode        = .whileEditing
                textField.returnKeyType          = .next
                textField.keyboardType           = .alphabet
                textField.autocapitalizationType = .words
                
                textField.addTarget(self, action: .nameRequired, for: .editingChanged)
                textField.addTarget(self, action: .nameRequired, for: .editingDidBegin)
            }
            alert.addTextField { textField in
                textField.text                   = key?.hex ?? Data.random128BitKey().hex
                textField.placeholder            = "E.g. 001122334455667788990AABBCCDDEEFF"
                textField.clearButtonMode        = .whileEditing
                textField.returnKeyType          = .done
                textField.keyboardType           = .alphabet
                textField.autocapitalizationType = .allCharacters
                
                textField.addTarget(self, action: .keyRequired, for: .editingChanged)
                textField.addTarget(self, action: .keyRequired, for: .editingDidBegin)
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let name = alert.textFields![0].text,
                   let hex = alert.textFields![1].text,
                   let key = Data(hex: hex) {
                    handler?(name, key)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Validators
    
    @objc func nameRequired(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        alert.setValid(textField.text != "")
    }
    
    @objc func unicastAddressOptional(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, !text.isEmpty {
            if let address = UInt16(text, radix: 16) {
                alert.setValid(address.isUnicast)
            } else {
                alert.setValid(false)
            }
        } else {
            alert.setValid(true)
        }
    }
    
    @objc func groupAddressOptional(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, !text.isEmpty {
            if let address = UInt16(text, radix: 16) {
                alert.setValid(address.isGroup)
            } else {
                alert.setValid(false)
            }
        } else {
            alert.setValid(true)
        }
    }
    
    @objc func sceneOptional(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, !text.isEmpty {
            if let scene = UInt16(text, radix: 16) {
                alert.setValid(scene.isValidScene)
            } else {
                alert.setValid(false)
            }
        } else {
            alert.setValid(true)
        }
    }
    
    @objc func unicastAddressRequired(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, let address = UInt16(text, radix: 16) {
            alert.setValid(address.isUnicast)
        } else {
            alert.setValid(false)
        }
    }
    
    @objc func groupAddressRequired(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, let address = UInt16(text, radix: 16) {
            alert.setValid(address.isGroup)
        } else {
            alert.setValid(false)
        }
    }
    
    @objc func sceneRequired(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, let scene = UInt16(text, radix: 16) {
            alert.setValid(scene.isValidScene)
        } else {
            alert.setValid(false)
        }
    }
    
    @objc func keyRequired(_ textField: UITextField) {
        let alert = getAlert(from: textField)
        
        if let text = textField.text, let data = Data(hex: text) {
            // A valid key is 16 bytes long (128-bit).
            alert.setValid(data.count == 16)
        } else {
            alert.setValid(false)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the reference to the UIAlertController.
    ///
    /// - parameter responder: The responder used to search for the alert.
    /// - returns: The active UIAlertController instance.
    private func getAlert(from responder: UIResponder) -> UIAlertController {
        // Hold my beer and watch this: how to get a reference to the alert.
        // Inspired by: https://github.com/mattneub/Programming-iOS-Book-Examples/blob/86fa1b2f57916fcf717945d24c2432143b25865b/bk2ch13p620dialogsOniPhone/ch26p888dialogsOniPhone/ViewController.swift#L59
        var resp: UIResponder! = responder
        while !(resp is UIAlertController) { resp = resp.next }
        return resp as! UIAlertController
    }
    
}

private extension UIAlertController {
    
    func setValid(_ valid: Bool) {
        // Assuming OK butotn as first action!
        actions[0].isEnabled = valid
    }
    
}
