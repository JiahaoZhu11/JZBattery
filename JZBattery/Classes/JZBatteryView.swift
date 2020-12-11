//
//  JZBattery.swift
//  JZVideoPlayer
//
//  Created by Jiahao Zhu on 2020/12/11.
//

import UIKit

public class JZBatteryView: UIView {
    
    /// 电池状态改变回调
    public var batteryStateChangeCallback: ((UIDevice.BatteryState) -> ())?
    
    /// 电池电量改变回调
    public var batteryLevelChangeCallback: ((Float) -> ())?
    
    /// 当前电池状态
    public var currentBatteryState: UIDevice.BatteryState {
        get {
            return batteryState
        }
    }
    
    /// 当前电池电量
    public var currentBatteryLevel: Float {
        get {
            return batteryLevel
        }
    }
    
    private lazy var batteryBodyLayer: CAShapeLayer = {
        let layer = CAShapeLayer(layer: self.layer)
        layer.lineWidth = 1
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var batteryNodeLayer: CAShapeLayer = {
        let layer = CAShapeLayer(layer: self.layer)
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var batteryFillingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        return view
    }()
    
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
        
        initBatteryStatus()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initBatteryStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        drawBattery()
    }
    
    private func drawBattery() {
        width = frame.width - 5
        height = min(frame.height - 2, width / 2)
        origin = CGPoint(x: 1, y: (frame.height - height) / 2)
        
        /// 电池左侧
        let leftPath = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y, width: width, height: height), cornerRadius: 2)
        batteryBodyLayer.path = leftPath.cgPath
        
        // 电池右侧
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: origin.x + width + 1, y: origin.y + height / 3))
        rightPath.addLine(to: CGPoint(x: origin.x + width + 1, y: origin.y + 2 * height / 3))
        batteryNodeLayer.path = rightPath.cgPath
        
        // 电池填充
        batteryFillingView.frame = CGRect(x: origin.x + 1, y: origin.y + 1, width: (width - 2) * CGFloat(batteryLevel), height: height - 2)
    }
    
    private func initBatteryStatus() {
        layer.addSublayer(batteryBodyLayer)
        layer.addSublayer(batteryNodeLayer)
        addSubview(batteryFillingView)
        observeBatteryStatus()
        batteryState = UIDevice.current.batteryState
    }
    
    private func observeBatteryStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBatteryLevel), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBatteryState), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
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
