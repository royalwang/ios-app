//
//  PasscodeUtilities.swift
//  ownCloud
//
//  Created by Javier Gonzalez on 06/05/2018.
//  Copyright © 2018 ownCloud GmbH. All rights reserved.
//

import UIKit
import ownCloudSDK

let DateHomeButtonPressed = "DateHomeButtonPressed"

class PasscodeUtilities: NSObject {

    private var passcodeViewController: PasscodeViewController?
    private var userDefaults: UserDefaults?

    static var sharedPasscodeUtilities : PasscodeUtilities = {
        let sharedInstance = PasscodeUtilities()
        return (sharedInstance)
    }()

    public override init() {
        super.init()
    }

    func storeDateHomeButtonPressed() {
        if self.passcodeViewController != nil {
            //Only store the date if the PasscodeViewController is not shown
            let archivedTime = NSKeyedArchiver.archivedData(withRootObject: Date())
            UserDefaults.standard.set(archivedTime, forKey: DateHomeButtonPressed)
        }
    }

    // MARK: - Unlock device

    func askPasscodeIfIsActivated(viewController: UIViewController, hiddenOverlay:Bool) {
        if OCAppIdentity.shared().keychain.readDataFromKeychainItem(forAccount: passcodeKeychainAccount, path: passcodeKeychainPath) != nil {

            self.passcodeViewController = PasscodeViewController(mode: PasscodeInterfaceMode.unlockPasscode, passcodeFromFirstStep: nil, hiddenOverlay:hiddenOverlay)
            viewController.present(self.passcodeViewController!, animated: false, completion: nil)
        }
    }

    func dismissAskedPasscodeIfDateToAskIsLower() {

        let secondsPassedMinToAsk = UserDefaults.standard.integer(forKey: SecuritySettingsfrequencyKey)

        let dateData = UserDefaults.standard.data(forKey: DateHomeButtonPressed)
        if let date = NSKeyedUnarchiver.unarchiveObject(with: dateData!) as? Date {
            let elapsed = Date().timeIntervalSince(date)

            if Int(elapsed) < secondsPassedMinToAsk {
                if self.passcodeViewController != nil {
                    self.passcodeViewController?.dismiss(animated: true, completion: nil)
                    self.passcodeViewController = nil
                }
            } else {
                self.passcodeViewController?.hideOverly()
            }
        }
    }
}
