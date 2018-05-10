//
//  ContentViewController.swift
//  ContentViewControllerDemo
//
//  Created by YTiOSer on 2018/5/10.
//  Copyright © 2018年 KK. All rights reserved.
//

import UIKit

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height
typealias didClickedButtonClosure = (_ buttonTag: Int) -> Void //点击按钮闭包

class ContentViewController: UIViewController {

    var titleButtonW:CGFloat = 70 //可设置单个按钮宽
    var titleButtonH:CGFloat = 44 //按钮高
    var indicatorMargin : CGFloat = 2
    var indicatorHeight : CGFloat = 2
    var defaultIndex:Int = 0 //可设置默认选中
    var titleWidths = [CGFloat]()
    var spaceWidth : CGFloat = 0
    var totalTitleWidth : CGFloat = 0
    var didTabSwitchClosure: didClickedButtonClosure?
    // 记录选中
    var selecedBtn = UIButton(type: .custom)
    // 约束变化
    var indicatorLeftConstraint = NSLayoutConstraint()
    var indicatorCenterXConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        // 添加子控制器view
        titleWidths = childViewControllers.map{ $0.title!.widthWithConstrainedWidth(width: kScreenW, font: UIFont.systemFont(ofSize: 16)) }
        totalTitleWidth = titleWidths.reduce(0, +)
        let num = childViewControllers.count
        spaceWidth = (titleButtonW * CGFloat(num) - totalTitleWidth) / CGFloat(num + 1)
        
        for (index,viewController) in childViewControllers.enumerated() {
            let btn = UIButton(type: .custom)
            btn.setTitle(viewController.title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.setTitleColor(UIColor.blue, for: .selected)
            btn.setTitleColor(UIColor.gray, for: .normal)
            btn.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
            let lastBtn = titleView.subviews.last ?? UIButton(frame: .zero)
            let btnX = lastBtn.frame.maxX
            btn.frame = CGRect(x: btnX + spaceWidth, y: 0, width: titleWidths[index], height: titleButtonH)
            btn.tag = index
            titleView.addSubview(btn)
            
        }
        
        // 设置titleview
        navigationItem.titleView = titleView
        
        // 如果按你数量超过一个 默认点击第一个
        if titleView.subviews.count > 0 {
            buttonClick(sender: titleView.subviews[defaultIndex] as! UIButton)
            titleView.addSubview(indicator)
        }
        
        // 主动加载数据
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // MARK: - 懒加载
    lazy var indicator : UIView = {
        let indicator_ = UIView()
        indicator_.backgroundColor = UIColor.blue
        indicator_.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.addSubview(indicator_)
        indicator_.frame = CGRect(x: self.spaceWidth, y: self.titleButtonH - self.indicatorHeight, width: self.titleWidths[0], height: self.indicatorHeight)
        return indicator_
    }()
    
    lazy var titleView : UIView = {
        let num = self.childViewControllers.count
        let titleView_ = UIView(frame: CGRect(x: 0, y: 20, width:self.titleButtonW * CGFloat(num) , height: self.titleButtonH))
        return titleView_
    }()
    
    lazy var scrollView : UIScrollView = {
        let num = self.childViewControllers.count
        let scrollView_ = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        scrollView_.isPagingEnabled = true
        scrollView_.showsHorizontalScrollIndicator = false
        scrollView_.delegate = self
        scrollView_.contentSize = CGSize(width: Int(kScreenW) * num, height: 0)
        scrollView_.backgroundColor = UIColor.white
        scrollView_.bounces = false
        self.view.addSubview(scrollView_)
        return scrollView_
    }()
    
    deinit {
        
    }
    
}


extension ContentViewController{
    
    func  initBtnW(btnW: Int) -> Void {
        titleButtonW =  CGFloat(btnW)
    }
    
    func selectChildController(index: Int) {
        if index < 0 || index > childViewControllers.count { return }
        if let button = titleView.subviews[index] as? UIButton {
            buttonClick(sender: button)
        }
    }
    
    @objc func buttonClick(sender:UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        selecedBtn.isSelected = false
        selecedBtn = sender
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.tag * Int(kScreenW)), y: 0), animated: true)
        
        if self.didTabSwitchClosure != nil{
            self.didTabSwitchClosure!(sender.tag)
        }
    }
    
}


// MARK: UIScrollViewDelegate
extension ContentViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let num = Int(scrollView.contentOffset.x / kScreenW)
        let willSelectedBtn = titleView.subviews[num] as! UIButton
        let vc = childViewControllers[num]
        scrollView.addSubview(vc.view)
        vc.view.frame = CGRect(x: kScreenW * CGFloat(num), y: 0, width: kScreenW, height: kScreenH)
        buttonClick(sender: willSelectedBtn)
        indicateFrameDidChanged(contentOffsetX: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let num = Int(scrollView.contentOffset.x / kScreenW)
        let vc = childViewControllers[num]
        scrollView.addSubview(vc.view)
        vc.view.frame = CGRect(x: kScreenW * CGFloat(num), y: 0, width: kScreenW, height: kScreenH)
        indicateFrameDidChanged(contentOffsetX: scrollView.contentOffset.x)
    }
    func indicateFrameDidChanged(contentOffsetX:CGFloat){
        let index = contentOffsetX / CGFloat(kScreenW + 0.1)
        let indicatorWidthDistance = (titleWidths[Int(index + 1)] - titleWidths[Int(index)])
        let indicatorXDistance = titleWidths[Int(index)] + spaceWidth
        let ratio = (contentOffsetX - kScreenW * CGFloat(Int(index))) / kScreenW
        indicator.frame.origin.x = ratio * indicatorXDistance + titleView.subviews[Int(index)].frame.origin.x
        indicator.frame.size.width = ratio * indicatorWidthDistance  + titleWidths[Int(index)]
    }
    
}


// MARK: 字符串extension
extension String{
    
    func widthWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
    
}

