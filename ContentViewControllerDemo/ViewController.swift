//
//  ViewController.swift
//  ContentViewControllerDemo
//
//  Created by YTiOSer on 2018/5/10.
//  Copyright © 2018年 KK. All rights reserved.
//

import UIKit

class ViewController: ContentViewController {

    override func viewDidLoad() {
        
        let vc1 = ListViewController()
        vc1.title = "First" //MARK: 必须设置title 或注册自定义enum 获取rawValue  title就是可选的选项
        vc1.view.backgroundColor = UIColor.red
        addChildViewController(vc1)
        
        let vc2 = ListViewController()
        vc2.title = "Second"
        vc2.view.backgroundColor = UIColor.green
        addChildViewController(vc2)
        
        let vc3 = ListViewController()
        vc3.title = "Third"
        vc3.view.backgroundColor = UIColor.orange
        addChildViewController(vc3)
        
        titleButtonW = kScreenW / 3 //设置宽
        
        super.viewDidLoad() //主意需要在调父类初始化钱设置  这样才起作用
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

