//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/06.
//  Copyright © 2015年 : Ihara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetectionViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = DetectionViewModel()
    
    override func loadView() {
        self.view = DetectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingNavigation()
        self.settingView()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func settingNavigation() {
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "探知"
        
        let settingBtn = UIBarButtonItem()
        settingBtn.title = "設定"
        settingBtn.style = .plain
        settingBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSettingBtn()
        }).addDisposableTo(disposeBag)
        
        self.navigationItem.rightBarButtonItem = settingBtn
    }
    
    private func settingView() {
        
        let view = self.view as! DetectionView
        
        // バインド
        viewModel
            .status
            .asObservable()
            .bind(to: view.statusLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.proximityUUID.subscribe(onNext: { u in
            view.proximityUUIDLabel.text = u.uuidString
        }).addDisposableTo(disposeBag)
        
        viewModel.major.subscribe(onNext: { n in
            view.majorLabel.text = n.stringValue
        }).addDisposableTo(disposeBag)
        
        viewModel.minor.subscribe(onNext: { n in
            view.minorLabel.text = n.stringValue
        }).addDisposableTo(disposeBag)
        
        viewModel.accuracy.subscribe(onNext: { i in
            view.accuracyLabel.text = String(i)
        }).addDisposableTo(disposeBag)
        
        viewModel.rssi.subscribe(onNext: { i in
            view.rssiLabel.text = String(i)
        }).addDisposableTo(disposeBag)
        
        // アクション
        view.sendBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSendBtn()
        }).addDisposableTo(disposeBag)
        
        view.retryBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchRetryBtn()
        }).addDisposableTo(disposeBag)
        
        view.helpBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchHelpBtn()
        }).addDisposableTo(disposeBag)
        
        view.stopBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchStopBtn()
        }).addDisposableTo(disposeBag)
        
        view.simulatorBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSimulatorBtn()
        }).addDisposableTo(disposeBag)
    }
    
    // MARK: - Action
    
    private func touchSendBtn() {
        print("touchSendBtn")
        
        self.viewModel.sendBeaconDetectionData()
    }
    
    private func touchHelpBtn() {
        print("touchHelpBtn")
        
        let helpViewController = HelpViewController()
        helpViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(helpViewController, animated: true, completion: nil)
    }
    
    private func touchRetryBtn() {
        print("touchRetryBtn")
        
        self.viewModel.startRanging()
    }
    
    private func touchStopBtn() {
        print("touchStopBtn")
        
        self.viewModel.stopRanging()
    }
    
    private func touchSimulatorBtn() {
        print("touchSimulatorBtn")
        
        let simulatorViewController = SimulatorViewController()
        self.navigationController?.pushViewController(simulatorViewController, animated: true)
    }
    
    private func touchSettingBtn() {
        print("touchSettingBtn")
        
        let settingViewController = SettingViewController()
        self.navigationController?.pushViewController(settingViewController, animated: true)
    }
}
