//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
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
        
        navigationController?.navigationBar.isTranslucent = false
        title = "Detection"
        
        let rangingButton = UIBarButtonItem()
        
        viewModel
            .rangingButtonIcon
            .bind(to: rangingButton.rx.image)
            .disposed(by: disposeBag)
        
        rangingButton
            .rx
            .tap
            .subscribe(onNext: { [unowned self] _ in
                
                self.viewModel.changeRanging()
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = rangingButton
        
        let view = self.view as! DetectionView
        
        viewModel
            .status
            .bind(to: view.statusLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        view.proximityUUIDInputTextField
            .rx
            .text
            .subscribe(onNext: { [unowned self] text in
                // TODO: Input text Check XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
                //                self.viewModel.updateProximityUUID(text: text!)
            })
            .disposed(by: disposeBag)
        
        view.majorInputTextField
            .rx
            .text
            .subscribe(onNext: { [unowned self] text in
                // TODO: Input text Check 0 ~ 65535
                self.viewModel.updateInputMajor(text: text!)
            })
            .disposed(by: disposeBag)
        
        view.minorInputTextField
            .rx
            .text
            .subscribe(onNext: { [unowned self] text in
                // TODO: Input text Check 0 ~ 65535
                self.viewModel.updateInputMinor(text: text!)
            })
            .disposed(by: disposeBag)
        
        viewModel.inputProximityUUID
            .bind(to: view.proximityUUIDInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.InputMajor
            .bind(to: view.majorInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.inputMinor
            .bind(to: view.minorInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.sections.asObservable()
            .bind(to: view
                .detectionInfoTableView
                .rx
                .items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        view.detectionInfoTableView
            .register(DetectionInfoTableViewCell.self, forCellReuseIdentifier: "DetectionInfoTableViewCell")
        
        view.detectionInfoTableView
            .rx
            .setDelegate(self).addDisposableTo(disposeBag)
        
        // !!!: Re Setting, because since it is overwritten by the setting timing of the initial value.
        self.viewModel.updateProximityUUID(text: Const.kDefaultProximityUUIDString)
    }
}

extension DetectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
