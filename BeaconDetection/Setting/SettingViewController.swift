//
//  SettingViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

// MARK: データ・ソース用コマンド

enum TableViewEditingCommand {
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

// MARK: テーブル用データ

struct SettinglistData {
    var title: String
    var themeColor: UIColor
}

struct SectionSettingListData {
    var header: String
    var items: [Item]
}

extension SectionSettingListData: SectionModelType {
    
    typealias Item = SettinglistData
    
    init(original: SectionSettingListData, items: [Item]) {
        self = original
        self.items = items
    }
}

//SettingListTableViewCell

class SettingViewController: UIViewController {
    
    let viewModel = SettingViewModel()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionSettingListData>()
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingView = self.view as! SettingView
        settingView.listTableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
        dataSource.configureCell = {ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? SettingListTableViewCell(style: .default, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = item.title
            cell.backgroundColor = item.themeColor
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = {ds, index in
            ds.sectionModels[index].header
        }
        
        dataSource.canEditRowAtIndexPath = { ds, index in
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = { de, index in
            return true
        }
        
        let sections = [
            SectionSettingListData(header: "First Section", items: [
                SettinglistData(title: "テスト1", themeColor: UIColor.white),
                SettinglistData(title: "テスト2", themeColor: UIColor.blue),
                SettinglistData(title: "テスト3", themeColor: UIColor.white),
                SettinglistData(title: "テスト4", themeColor: UIColor.blue),
                SettinglistData(title: "テスト5", themeColor: UIColor.white),
                SettinglistData(title: "テスト6", themeColor: UIColor.blue),
                SettinglistData(title: "テスト7", themeColor: UIColor.white),
                SettinglistData(title: "テスト8", themeColor: UIColor.blue)
                ]),
            SectionSettingListData(header: "Second Section", items: [
                SettinglistData(title: "テスト1", themeColor: UIColor.white),
                SettinglistData(title: "テスト2", themeColor: UIColor.blue),
                SettinglistData(title: "テスト3", themeColor: UIColor.white),
                SettinglistData(title: "テスト4", themeColor: UIColor.blue),
                SettinglistData(title: "テスト5", themeColor: UIColor.white),
                SettinglistData(title: "テスト6", themeColor: UIColor.blue),
                SettinglistData(title: "テスト7", themeColor: UIColor.white),
                SettinglistData(title: "テスト8", themeColor: UIColor.blue)
                ])
        ]
        
        let initialState = SectionedTableViewState(sections: sections)
        
        Observable.just(sections).bind(to: settingView.listTableView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        
        let deleteCommand = settingView.listTableView.rx.itemDeleted.asObservable()
        .map(TableViewEditingCommand.DeleteItem)
        
        let movedCommand = settingView.listTableView.rx.itemMoved.asObservable()
        .map(TableViewEditingCommand.MoveItem)
        
        Observable.of(deleteCommand, movedCommand)
            .merge()
            .scan(initialState) { (state: SectionedTableViewState, commond: TableViewEditingCommand) -> SectionedTableViewState in
                return state.execute(commond: commond)
                
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
            .bind(to: settingView.listTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let settingView = self.view as! SettingView
        settingView.listTableView.setEditing(true, animated: true)
    }
}

struct SectionedTableViewState {
    
    fileprivate var sections: [SectionSettingListData]
    
    init(sections: [SectionSettingListData]) {
        self.sections = sections
    }
    
    func execute(commond: TableViewEditingCommand) -> SectionedTableViewState {
        switch commond {
        case .DeleteItem(let indexPath):
            
            var sections = self.sections
            var items = sections[indexPath.section].items
            
            items.remove(at: indexPath.section)
            sections[indexPath.section] = SectionSettingListData(original: sections[indexPath.section], items: items)
            
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row), at: moveEvent.destinationIndex.row)
                let destinationSection = SectionSettingListData(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = SectionSettingListData(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = SectionSettingListData(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
            }
            
            return SectionedTableViewState(sections: sections)
        }
    }
}

extension SettingViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
