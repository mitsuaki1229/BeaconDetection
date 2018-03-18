//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class DetectionViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = DetectionViewModel()
    
    override func loadView() {
        view = DetectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        setupViews()
        addDoneButtonOnKeyboard()
        
        viewModel.updateProximityUUIDToDefault()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard event?.type == UIEventType.motion && event?.subtype == UIEventSubtype.motionShake else { return }
        viewModel.clearSections()
    }
    
    private func setupNavigationbar() {
        
        navigationController?.navigationBar.isTranslucent = false
        title = "Detection"
        
        let rangingButton = UIBarButtonItem()
        
        viewModel
            .rangingButtonIcon
            .bind(to: rangingButton.rx.image)
            .disposed(by: disposeBag)
        
        rangingButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.changeRanging()
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = rangingButton
    }
    
    private func setupViews() {
        
        let view = self.view as! DetectionView
        
        viewModel.status.bind(to: view.statusLabel.rx.text).addDisposableTo(disposeBag)
        
        view.proximityUUIDInputTextField.rx.text
            .subscribe(onNext: { [unowned self] text in
                self.viewModel.updateProximityUUID(uuidText: text!)
            })
            .disposed(by: disposeBag)
        
        view.majorInputTextField.rx.text
            .subscribe(onNext: { [unowned self] text in
                self.viewModel.updateInputMajor(text: text!)
            })
            .disposed(by: disposeBag)
        
        view.minorInputTextField.rx.text
            .subscribe(onNext: { [unowned self] text in
                self.viewModel.updateInputMinor(text: text!)
            })
            .disposed(by: disposeBag)
        
        viewModel.inputProximityUUID
            .bind(to: view.proximityUUIDInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.inputMajor
            .bind(to: view.majorInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.inputMinor
            .bind(to: view.minorInputTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.sections.asObservable()
            .bind(to: view.detectionInfoTableView.rx
                .items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        view.detectionInfoTableView
            .register(DetectionInfoTableViewCell.self, forCellReuseIdentifier: "DetectionInfoTableViewCell")
        
        view.detectionInfoTableView.rx
            .setDelegate(self).addDisposableTo(disposeBag)
    }
    
    private func addDoneButtonOnKeyboard() {
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem()
        doneButton.title = "done"
        doneButton.style = .done
        
        doneButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
                self.viewModel.reSettingBeaconManager()
            }).disposed(by: disposeBag)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(doneButton)
        
        let numberPadToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        numberPadToolbar.barStyle = .default
        
        numberPadToolbar.items = items
        numberPadToolbar.sizeToFit()
        
        let view = self.view as! DetectionView
        view.majorInputTextField.inputAccessoryView = numberPadToolbar
        view.minorInputTextField.inputAccessoryView = numberPadToolbar
    }
}

extension DetectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
