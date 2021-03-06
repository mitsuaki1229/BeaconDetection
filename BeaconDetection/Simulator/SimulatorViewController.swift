//
//  SimulatorViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import AMPopTip
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
                
                let alert = UIAlertController(title: "Error".localized, message: "Message001".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.rootViewController().present(alert, animated: false, completion: nil)
                
                self.switchAnimation(animatie: false)
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .subscribe { [unowned self] _ in
                self.viewModel.updateStatusSignal()
            }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIApplication.didEnterBackgroundNotification)
            .subscribe { [unowned self] _ in
                self.switchAnimation(animatie: false)
            }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateStatusSignal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let view = self.view as! SimulatorView
        view.backgroundScrollView.setContentOffset(contentCenter(view), animated: false)
        
        setUpPopTip()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switchAnimation(animatie: false)
        removePopTips(view: view)
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
            view.uuidLabel.text = $0?.uuidString
        }).disposed(by: disposeBag)
        viewModel.major.subscribe(onNext: {
            view.majorLabel.text = $0.stringValue
        }).disposed(by: disposeBag)
        viewModel.minor.subscribe(onNext: {
            view.minorLabel.text = $0.stringValue
        }).disposed(by: disposeBag)
    }
    
    private func setUpPopTip() {
        popTipChain(nextTips: CommonModel().nextTips())
    }
    
    private func popTipChain(pt: PopTip = PopTip(), nextTips: Int, completion: (() -> Void)? = nil) {
        
        guard nextTips >= 9,
            nextTips < 11 else { return }
        
        let view = self.view as! SimulatorView
        pt.show(text: ("CheckedTips" + nextTips.description).localized, direction: .none, maxWidth: 200, in: view, from: view.frame)
        
        let ptNext = PopTip()
        pt.dismissHandler = { [unowned self] _ in
            UserDefaults().set(nextTips, forKey: Const.kCheckedTipsUserDefaultKey)
            self.popTipChain(pt: ptNext, nextTips: (nextTips + 1), completion: {
                if let completion = completion {
                    completion()
                }
            })
        }
    }
    
    private func removePopTips(view: UIView) {
        for subview in view.subviews {
            guard let subview = subview as? PopTip else { continue }
            subview.removeFromSuperview()
        }
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
