//
//  ViewController.swift
//  RotaryWheel
//
//  Created by satoutakeshi on 2018/12/04.
//  Copyright © 2018年 Personal Factory. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RotaryProtocol {

    private var valueLabel: UILabel = UILabel(frame: CGRect(x: 100, y: 350, width: 120, height: 30))

    func wheelDidChangeValue(newValue: String) {
        valueLabel.text = newValue
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        valueLabel.textAlignment = .center
        valueLabel.backgroundColor = UIColor.gray
        self.view.addSubview(valueLabel)

        let wheel = RotaryWheel(frame: CGRect(x: 0, y: 0, width: 200, height: 200),
                                delegate: self,
                                section: 8)

        wheel.center = CGPoint(x: 160, y: 200)
        self.view.addSubview(wheel)
    }


}

