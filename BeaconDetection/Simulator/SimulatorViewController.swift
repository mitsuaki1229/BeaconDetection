//
//  SimulatorViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimulatorViewController: UIViewController {
    
    private let viewModel = SimulatorViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = SimulatorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Simulator"
        
        let simulatorView = view as! SimulatorView
        
        viewModel.proximityUUID.subscribe(onNext: { u in
            simulatorView.uuidLabel.text = u.uuidString
        }).disposed(by: disposeBag)
        
        viewModel.major.subscribe(onNext: { n in
            simulatorView.majorLabel.text = n.stringValue
        }).disposed(by: disposeBag)
        
        viewModel.minor.subscribe(onNext: { n in
            simulatorView.minorLabel.text = n.stringValue
        }).disposed(by: disposeBag)
        
        viewModel.identifier.subscribe(onNext: { s in
            simulatorView.identifierLabel.text = s
        }).disposed(by: disposeBag)
        
        viewModel.status.subscribe(onNext: { [unowned self] status in
            
            switch status {
            case .other:
                break
            case .normal:
                self.beginningAnimation()
            case .peripheralError:
                let alert = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                }))
                
                self.rootViewController().present(
                    alert,
                    animated: false,
                    completion: {
                })
            }
        }).disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    private func beginningAnimation() {
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: .repeat, animations: { () -> Void in
                        
                        let view = self.view as! SimulatorView
                        view.backgroundImageView.alpha = 0.0
        }, completion: nil)
    }
}
