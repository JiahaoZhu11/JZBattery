//
//  JZBattery.swift
//  JZVideoPlayer
//
//  Created by Jiahao Zhu on 2020/12/11.
//

import UIKit

public class JZBatteryView: UIView {
    
    public var batteryStateChangeCallback: ((UIDevice.BatteryState) -> ())?
    
    public var batteryLevelChangeCallback: ((Float) -> ())?
    
    public var currentBatteryState: UIDevice.BatteryState {
        get {
            return batteryState
        }
    }
    
    public var currentBatteryLevel: Float {
        get {
            return batteryLevel
        }
    }
    
    private var batteryFillingView: UIView!
    
    private var width: CGFloat = 0
    
    private var height: CGFloat = 0
    
    private var origin: CGPoint = CGPoint.zero
    
    private var batteryState: UIDevice.BatteryState = {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryState = UIDevice.current.batteryState
        return batteryState
    }() {
        didSet {
            switch batteryState {
            case .charging, .full:
                batteryFillingView.backgroundColor = .green
            case .unplugged:
                if batteryLevel < 0.2 {
                    batteryFillingView.backgroundColor = .red
                } else {
                    batteryFillingView.backgroundColor = .white
                }
            default:
                batteryFillingView.backgroundColor = .white
            }
        }
    }
    
    private var batteryLevel: Float = {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        return batteryLevel
    }() {
        didSet {
            batteryFillingView.frame.size.width = (width - 2) * CGFloat(batteryLevel)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawBattery()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        drawBattery()
    }
    
    private func drawBattery() {
        width = frame.width - 5
        height = min(frame.height - 2, width / 2)
        origin = CGPoint(x: 1, y: (frame.height - height) / 2)
        
        /// 电池左侧
        let leftPath = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y, width: width, height: height), cornerRadius: 2)
        let batteryLayer = CAShapeLayer(layer: layer)
        batteryLayer.lineWidth = 1
        batteryLayer.strokeColor = UIColor.white.cgColor
        batteryLayer.fillColor = UIColor.clear.cgColor
        batteryLayer.path = leftPath.cgPath
        layer.addSublayer(batteryLayer)
        
        // 电池右侧
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: origin.x + width + 1, y: origin.y + height / 3))
        rightPath.addLine(to: CGPoint(x: origin.x + width + 1, y: origin.y + 2 * height / 3))
        let batteryHeadLayer = CAShapeLayer(layer: layer)
        batteryHeadLayer.lineWidth = 2
        batteryHeadLayer.strokeColor = UIColor.white.cgColor
        batteryHeadLayer.fillColor = UIColor.clear.cgColor
        batteryHeadLayer.path = rightPath.cgPath
        layer.addSublayer(batteryHeadLayer)
        
        // 电池填充
        batteryFillingView = UIView(frame: CGRect(x: origin.x + 1, y: origin.y + 1, width: (width - 2) * CGFloat(batteryLevel), height: height - 2))
        batteryFillingView.layer.cornerRadius = 2
        initBatteryStatus()
        addSubview(batteryFillingView)
    }
    
    private func initBatteryStatus() {
        observeBatteryStatus()
        switch batteryState {
        case .charging, .full:
            batteryFillingView.backgroundColor = .green
        case .unplugged:
            if batteryLevel < 0.2 {
                batteryFillingView.backgroundColor = .red
            } else {
                batteryFillingView.backgroundColor = .white
            }
        default:
            batteryFillingView.backgroundColor = .white
        }
    }
    
    private func observeBatteryStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBatteryLevel), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBatteryState), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    @objc private func updateBatteryState() {
        batteryState = UIDevice.current.batteryState
        batteryStateChangeCallback?(batteryState)
    }
    
    @objc private func updateBatteryLevel() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryLevelChangeCallback?(batteryLevel)
    }
}
