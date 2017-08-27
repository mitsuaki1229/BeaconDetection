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
        view = DetectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingNavigation()
        settingView()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func settingNavigation() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Detection"
        
        let settingBtn = UIBarButtonItem()
        settingBtn.title = "⚙"
        settingBtn.style = .plain
        settingBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSettingBtn()
        }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = settingBtn
    }
    
    private func settingView() {
        
        let view = self.view as! DetectionView
        
        // バインド
        viewModel
            .status
            .asObservable()
            .bind(to: view.statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.proximityUUID.subscribe(onNext: { u in
            view.proximityUUIDLabel.text = u.uuidString
        }).disposed(by: disposeBag)
        
        viewModel.major.subscribe(onNext: { n in
            view.majorLabel.text = n.stringValue
        }).disposed(by: disposeBag)
        
        viewModel.minor.subscribe(onNext: { n in
            view.minorLabel.text = n.stringValue
        }).disposed(by: disposeBag)
        
        viewModel.accuracy.subscribe(onNext: { i in
            view.accuracyLabel.text = String(i)
        }).disposed(by: disposeBag)
        
        viewModel.rssi.subscribe(onNext: { i in
            view.rssiLabel.text = String(i)
        }).disposed(by: disposeBag)
        
        // アクション
        view.sendBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSendBtn()
        }).disposed(by: disposeBag)
        
        view.retryBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchRetryBtn()
        }).disposed(by: disposeBag)
        
        view.helpBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchHelpBtn()
        }).disposed(by: disposeBag)
        
        view.stopBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchStopBtn()
        }).disposed(by: disposeBag)
        
        view.simulatorBtn.rx.tap.subscribe(onNext: { [weak self] x in
            self?.touchSimulatorBtn()
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Action
    
    private func touchSendBtn() {
        print("touchSendBtn")
        
        viewModel.sendBeaconDetectionData()
    }
    
    private func touchHelpBtn() {
        print("touchHelpBtn")
        
        let helpViewController = HelpViewController()
        helpViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(helpViewController, animated: true, completion: nil)
    }
    
    private func touchRetryBtn() {
        print("touchRetryBtn")
        
        viewModel.startRanging()
    }
    
    private func touchStopBtn() {
        print("touchStopBtn")
        
        viewModel.stopRanging()
    }
    
    private func touchSimulatorBtn() {
        print("touchSimulatorBtn")
        
        let simulatorViewController = SimulatorViewController()
        navigationController?.pushViewController(simulatorViewController, animated: true)
    }
    
    private func touchSettingBtn() {
        print("touchSettingBtn")
        
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
}
