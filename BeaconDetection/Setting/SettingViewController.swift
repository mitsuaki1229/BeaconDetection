//
//  SettingViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SettingViewController: UIViewController {
    
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Setting"
        
        let view = self.view as! SettingView
        view.listTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        view.listTableView.rx.itemSelected
            .map { [weak self] ip in
                return (ip, self?.viewModel.dataSource[ip])
            }
            .subscribe(onNext: { [weak self] ip, _ in
                
                view.listTableView.deselectRow(at: ip, animated: true)
                
                if ip.row == SettinglistType.clearTips.rawValue {
                    self?.viewModel.clearCheckedTips()
                    let alert = UIAlertController(title: "Info", message: "Clear Checked Tips.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.rootViewController().present(alert, animated: false, completion: nil)
                    return
                }
                
                guard let type = DescriptionFileType(rawValue: ip.row),
                    type != .none else { return }
                let descriptionViewController = DescriptionViewController(type: type)
                self?.navigationController?.pushViewController(descriptionViewController, animated: true)
                
            }).disposed(by: disposeBag)
        
        Observable.just(viewModel.sections)
            .bind(to: view
                .listTableView.rx
                .items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
