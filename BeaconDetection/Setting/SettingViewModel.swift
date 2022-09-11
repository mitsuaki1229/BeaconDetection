//
//  SettingViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxDataSources

struct SettinglistData {
    var title: String
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

enum SettinglistType: Int {
    case readme = 0
    case license = 1
    case version = 2
    case clearTips = 3
}

class SettingViewModel: NSObject {

    let dataSource = RxTableViewSectionedReloadDataSource<SectionSettingListData>(configureCell: {_, tableView, indexPath, _ in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
        
    })

    var sections: [SectionSettingListData] {
        
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        return [
            SectionSettingListData(header: "", items: [
                SettinglistData(title: "README"),
                SettinglistData(title: "LICENSE"),
                SettinglistData(title: "Version:" + version),
                SettinglistData(title: "Clear Checked Tips")
                ])
        ]
    }
    
    override init() {
        super.init()
        
        dataSource.configureCell = {_, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = item.title
            
            switch SettinglistType(rawValue: ip.row)! {
            case .readme, .license:
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            case .clearTips:
                cell.selectionStyle = .default
                cell.accessoryType = .none
            case .version:
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = {ds, index in
            ds.sectionModels[index].header
        }
    }
    
    func clearCheckedTips() {
        UserDefaults().set(0, forKey: Const.kCheckedTipsUserDefaultKey)
    }
}
