//
//  RotaryWheel.swift
//  RotaryWheel
//
//  Created by satoutakeshi on 2018/12/04.
//  Copyright © 2018年 Personal Factory. All rights reserved.
//

import UIKit

class RotaryWheel: UIControl {

    weak var delegate: RotaryProtocol!
    var container: UIView!
    var numberOfSections: Int
    var startTransform: CGAffineTransform?
    var cloves: [Clove] = []
    var currentValue: Int

    var deltaAngle: CGFloat = 0.0
    let minAlphavalue: CGFloat = 0.6
    let maxAlphavalue: CGFloat = 1.0

    init(frame: CGRect, delegate: RotaryProtocol, section: Int) {
        self.currentValue = 0
        self.numberOfSections = section
        self.delegate = delegate
        super.init(frame: frame)
        drawWeel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawWeel() {
        container = UIView(frame: self.frame)
        let angleSize = 2 * .pi/Double(numberOfSections)

        for i in 0 ..< numberOfSections {
            let segumentImage = UIImageView(image: UIImage(named: "segment"))
            segumentImage.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            segumentImage.layer.position = CGPoint(x: container.bounds.width/2.0 - container.frame.origin.x,
                                                   y: container.bounds.height/2.0 - container.frame.origin.y)
            segumentImage.transform = CGAffineTransform(rotationAngle: CGFloat(angleSize) * CGFloat(i))
            segumentImage.alpha = minAlphavalue
            segumentImage.tag = i

            if (i == 0) {
                segumentImage.alpha = maxAlphavalue
            }

            let cloveImage = UIImageView(frame: CGRect(x: 12, y: 15, width: 40, height: 40))
            cloveImage.image = UIImage(named: "icon\(i)")
            segumentImage.addSubview(cloveImage)

            container.addSubview(segumentImage)
        }

        container.isUserInteractionEnabled = false
        self.addSubview(container)

        let backImage = UIImageView(frame: self.frame)
        backImage.image = UIImage(named: "bg")
        self.addSubview(backImage)

        let mask = UIImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        mask.image = UIImage(named: "centerButton")
        mask.center = self.center
        mask.center = CGPoint(x: mask.center.x, y: mask.center.y + 3)
        self.addSubview(mask)

        if (numberOfSections % 2 == 0) {
            buildClovesEven()
        } else {
            buildClovesOdd()
        }

        delegate.wheelDidChangeValue(newValue: getCloveName(position: currentValue))
    }

    func getCloveByValue(value: Int) -> UIImageView? {
        var imageView: UIImageView?
        let views = container.subviews
        for view in views {
            if (view.tag == value) {
                imageView = view as? UIImageView
            }
        }
        return imageView
    }

    func buildClovesEven() {
        // これはなんの値だろう？
        let fanWidth = .pi * 2 / Double(numberOfSections)
        var mid = 0.0

        for i in 0 ..< numberOfSections {
            var clove = Clove(minValue: Float(mid - (fanWidth/2)),
                              maxValue: Float(mid + (fanWidth/2)),
                              midValue: Float(mid),
                              value: i)

            if (Double(clove.maxValue) - Double(fanWidth) < -.pi) {
                mid = .pi
                clove.midValue = Float(mid)
                clove.minValue = abs(clove.maxValue) // fabsは浮動小数点数の絶対値

            }

            mid -= fanWidth
            print("cl is \(clove)")

            cloves.append(clove)
        }
    }

    func buildClovesOdd() {
        // これはなんの値だろう？
        let fanWidth = .pi*2 / Double(numberOfSections)
        var mid = 0.0

        for i in 0 ..< numberOfSections {
            var clove = Clove(minValue: Float(mid - (fanWidth/2)),
                              maxValue: Float(mid + (fanWidth/2)),
                              midValue: Float(mid),
                              value: i)

            mid -= fanWidth
            clove.midValue = Float(mid)

            if (mid < -.pi) {
                mid = -mid
                mid -= fanWidth //反映してないけど大丈夫？
                clove.midValue = Float(mid)
            }

            print("cl is \(clove)")
            cloves.append(clove)
        }
    }

    func calculateDistanceFromCenter(point: CGPoint) -> Float {
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        return Float(sqrt(dx*dx + dy*dy))
    }

    // タッチ開始
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        let dist = calculateDistanceFromCenter(point: touchPoint) //距離

        if (dist < 40 || dist > 100) {
            // forcing a tap to be on the ferrule
            // ホイールの外だったら何もしない？
            print("ignoring tap \(touchPoint.x), \(touchPoint.y)")
            return false
        }

        let dx = touchPoint.x - container.center.x
        let dy = touchPoint.y - container.center.y
        deltaAngle = atan2(dy, dx) //タンジェントなんだ。

        startTransform = container.transform

        let imageView = getCloveByValue(value: currentValue)
        imageView?.alpha = minAlphavalue //classだから暗黙的共有でalpha変えられる

        return true
    }

    // ドラッグ中
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        let dist = calculateDistanceFromCenter(point: point)

        if (dist < 40 || dist > 100) {
            // a drag path too close to the center
            //NSLog(@"drag path too close to the center (%f,%f)", pt.x, pt.y);
            print("drag path too close to the center \(point.x), \(point.y)")

            // here you might want to implement your solution when the drag
            // is too close to the center
            // You might go back to the clove previously selected
            // or you might calculate the clove corresponding to
            // the "exit point" of the drag.
        }

        let dx = point.x - container.center.x
        let dy = point.y - container.center.y
        let angle = atan2(dy, dx)

        let angleDifference = deltaAngle - angle

        container.transform = startTransform?.rotated(by: -angleDifference) ?? CGAffineTransform.identity

        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let radians = atan2(container.transform.b, container.transform.a)

        var newVal = 0.0

        for clove in cloves {
            if (CGFloat(clove.minValue) > 0 && CGFloat(clove.maxValue) < 0) { // anomalous case 例外ケース

                if (CGFloat(clove.maxValue) > radians || CGFloat(clove.minValue) < radians) {
                    if radians > 0 {  // we are in the positive quadrant +の四分円にいる

                        newVal = Double(radians - .pi)

                    } else {// we are in the negative one -の四分円にいる
                        newVal = Double((radians + .pi))
                    }

                    currentValue = clove.value
                }

            } else if (radians > CGFloat(clove.minValue) && radians < CGFloat(clove.maxValue)) {

                newVal = Double(radians - CGFloat(clove.midValue))
                currentValue = clove.value
            }
        }

        //アニメーション
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)

        let t = container.transform.rotated(by: CGFloat(-newVal))
        container.transform = t

        UIView.commitAnimations()

        self.delegate.wheelDidChangeValue(newValue: getCloveName(position: currentValue))

        let imageView = getCloveByValue(value: currentValue)
        imageView?.alpha = maxAlphavalue
    }

    func getCloveName(position: Int) -> String {
        let res: String
        switch position {
        case 0:
            res = "Circles"
        case 1:
            res = "Flower"
        case 2:
            res = "Monster"
        case 3:
            res = "Person"
        case 4:
            res = "Smile"
        case 5:
            res = "Sun"
        case 6:
            res = "Swirl"
        case 7:
            res = "3 circles"
        case 8:
            res = "Triangle"
        default:
            res = ""
        }

        return res
    }

}
