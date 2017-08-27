//
//  DescriptionViewController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/12.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import WebKit

class DescriptionViewController: UIViewController {
    
    private let viewModel: DescriptionViewModel!
    
    init(type: DescriptionFileType) {
        viewModel = DescriptionViewModel(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = DescriptionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Description"
        
        loadDisplayArea()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadDisplayArea() {
        
        let descriptionView = view as! DescriptionView
        descriptionView.displayArea.loadHTMLString(viewModel.getHtml(), baseURL: nil)
    }
}
