//
//  SimulatorViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SimulatorViewController: UIViewController {
    
    private let viewModel = SimulatorViewModel()
    private let disposeBag = DisposeBag()
    
    private var contentCenter = {(view: SimulatorView) -> CGPoint in
        let x: CGFloat = (view.backgroundScrollView.contentSize.width - view.frame.width) / 2
        return CGPoint(x: x, y: 0)
    }
    
    override func loadView() {
        view = SimulatorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        setupViews()
        
        viewModel.status.subscribe(onNext: { [unowned self] status in
            
            switch status {
            case .other:
                break
            case .normal:
                self.switchAnimation(animatie: true)
            case .peripheralError:
                
                let alert = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.rootViewController().present(alert, animated: false, completion: nil)
                
                self.switchAnimation(animatie: false)
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.UIApplicationDidBecomeActive)
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.updateStatusSignal()
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.UIApplicationDidEnterBackground)
            .subscribe(onNext: { [unowned self] _ in
                self.switchAnimation(animatie: false)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateStatusSignal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let view = self.view as! SimulatorView
        view.backgroundScrollView.setContentOffset(contentCenter(view), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switchAnimation(animatie: false)
    }
    
    // MARK: Tools
    
    private func setupNavigationbar() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Simulator"
        
        let regenerateButton = UIBarButtonItem()
        regenerateButton.image = #imageLiteral(resourceName: "RegenerateButtonIcon")
        
        regenerateButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.regenerateBeacon()
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = regenerateButton
    }
    
    private func setupViews() {
        
        let view = self.view as! SimulatorView
        
        viewModel.proximityUUID.subscribe(onNext: {
            view.uuidLabel.text = $0.uuidString
        }).disposed(by: disposeBag)
        viewModel.major.subscribe(onNext: {
            view.majorLabel.text = $0.stringValue
        }).disposed(by: disposeBag)
        viewModel.minor.subscribe(onNext: {
            view.minorLabel.text = $0.stringValue
        }).disposed(by: disposeBag)
    }
    
    private func switchAnimation(animatie: Bool) {
        
        let view = self.view as! SimulatorView
        view.backgroundImageView.layer.removeAllAnimations()
        view.backgroundImageView.alpha = 1.0
        
        guard animatie else { return }
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: .repeat, animations: { [unowned self] () -> Void in
                        
                        let view = self.view as! SimulatorView
                        view.backgroundImageView.alpha = 0.0
            }, completion: nil)
    }
}
