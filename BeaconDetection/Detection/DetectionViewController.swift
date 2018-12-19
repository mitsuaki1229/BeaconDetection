//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import AMPopTip
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
        
        viewModel.updateProximityUUIDToUserDefault()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpPopTip()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removePopTips(view: view)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard event?.type == UIEvent.EventType.motion && event?.subtype == UIEvent.EventSubtype.motionShake else { return }
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
        
        let numberPadToolbar: UIToolbar = UIToolbar()
        numberPadToolbar.items = items
        numberPadToolbar.sizeToFit()
        
        let view = self.view as! DetectionView
        view.proximityUUIDInputTextField.inputAccessoryView = numberPadToolbar
        view.majorInputTextField.inputAccessoryView = numberPadToolbar
        view.minorInputTextField.inputAccessoryView = numberPadToolbar
    }
    
    private func setUpPopTip() {
        popTipChain(nextTips: CommonModel().nextTips())
    }
    
    private func popTipChain(pt: PopTip = PopTip(), nextTips: Int, completion: (() -> Void)? = nil) {
        
        guard nextTips >= 1,
            nextTips < 9 else { return }
        
        let view = self.view as! DetectionView
        popTipDisplayPosition(tips: nextTips) { (direction, frame) in
            pt.show(text: ("CheckedTips" + nextTips.description).localized, direction: direction, maxWidth: 200, in: view, from: frame)
        }
        
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
    
    private func popTipDisplayPosition(tips: Int, position: (_ direction: PopTipDirection, _ frame: CGRect) -> Void) {
        let view = self.view as! DetectionView
        switch tips {
        case 1, 2:
            position(.down, view.proximityUUIDInputTextField.frame)
        case 3:
            position(.left, view.majorInputTextField.frame)
        case 4, 5:
            position(.down, view.statusLabel.frame)
        case 6:
            position(.none, view.detectionInfoTableView.frame)
        case 7, 8:
            position(.none, view.frame)
        default:
            assert(false, "Implementation error")
        }
    }
    
    private func removePopTips(view: UIView) {
        for subview in view.subviews {
            guard let subview = subview as? PopTip else { continue }
            subview.removeFromSuperview()
        }
    }
}

extension DetectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
