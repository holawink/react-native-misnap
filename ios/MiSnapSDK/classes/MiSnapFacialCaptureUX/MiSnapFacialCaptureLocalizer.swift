//
//  MiSnapFacialCaptureLocalizer.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Stas Tsuprenko on 6/12/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

class MiSnapFacialCaptureLocalizer {
    private static var sharedInstance: MiSnapFacialCaptureLocalizer?
    
    private var bundle: Bundle!
    private var localizableStringsName: String!
    
    class var shared: MiSnapFacialCaptureLocalizer {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = MiSnapFacialCaptureLocalizer()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    class func destroyShared() {
        self.sharedInstance = nil
    }
    
    private init() {
        self.bundle = Bundle.main
        self.localizableStringsName = "MiSnapFacialCaptureLocalizable"
    }
    
    public func set(bundle: Bundle = Bundle.main, localizableStringsName: String = "MiSnapFacialCaptureLocalizable") {
        self.bundle = bundle
        self.localizableStringsName = localizableStringsName
    }
    
    public func localizedString(for key: String) -> String {
        return self.bundle.localizedString(forKey: key, value: key, table: self.localizableStringsName)
    }
}
