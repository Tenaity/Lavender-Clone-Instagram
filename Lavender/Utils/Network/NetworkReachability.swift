//
//  NetworkReachability.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Alamofire

public struct NetworkReachability {
    private static let networkReachability = NetworkReachability()
    private init() { }
    private let manager = NetworkReachabilityManager()

    public static func startListening() {
        networkReachability.manager?.startListening { status in
            NotificationCenter.default.post(name: networkReachabilityChangedNotification, object: nil, userInfo: ["status": status])
        }
    }
    
    public static var isReachable: Bool {
        return networkReachability.manager?.isReachable ?? false
    }
    
    public static var noInternetError: Error? {
        isReachable ? nil : NetworkError.noInternetConnection
    }
    
    public static let networkReachabilityChangedNotification = NSNotification.Name("networkReachabilityChangedNotification")
}

public class ReachabilityHandler {
    
    public var onNetworkStateChanged: ((Bool) -> Void)?
    
    public func startListening() {
        isReachable = NetworkReachability.isReachable
        NotificationCenter.default.addObserver(self, selector: #selector(networkReachabilityChanged(notification:)), name: NetworkReachability.networkReachabilityChangedNotification, object: nil)
    }
    
    private let internetDetectionInterval = 5.0
    private var timer: Timer?
    private var isReachable: Bool = true {
        didSet {
            guard isReachable != oldValue else { return }
            endTimer()
            timer = Timer.scheduledTimer(timeInterval: internetDetectionInterval, target: self, selector: #selector(countdown), userInfo: nil, repeats: false)
        }
    }
    
    public static let shared = ReachabilityHandler()
    
    private init() { }

    @objc private func networkReachabilityChanged(notification: NSNotification) {
        isReachable = NetworkReachability.isReachable
    }
    
    @objc private func countdown() {
        onNetworkStateChanged?(isReachable)
        endTimer()
    }
    
    private func endTimer() {
        timer?.invalidate()
        timer = nil
    }
}

