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

extension Reactive where Base: UIBarButtonItem {
    
    var image: UIBindingObserver<Base, UIImage> {
        return UIBindingObserver(UIElement: base) { UIElement, value in
            UIElement.image = value
        }
    }
}
