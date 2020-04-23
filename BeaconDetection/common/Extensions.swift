//
//  Extensions.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/20.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension UIViewController {
    
    func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
}

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UITextField {
    
    func roundBorder(placeholderText: String = "") {
        
        placeholder = placeholderText
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5.0
    }
}

extension Reactive where Base: UIBarButtonItem {
    
    var image: Binder<UIImage> {
        return Binder(base) { UIElement, value in
            UIElement.image = value
        }
    }
}
