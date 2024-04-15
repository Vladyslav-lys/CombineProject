//
//  NetworkReachabilityManager.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import SystemConfiguration

class NetworkReachabilityManager {
    private enum NetworkReachabilityStatus: Equatable {
        case unknown
        case notReachable
        case reachable(ConnectionType)

        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isActuallyReachable else {
                self = .notReachable
                return
            }
            var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)
            if flags.isCellular {
                networkStatus = .reachable(.cellular)
            }
            self = networkStatus
        }

        enum ConnectionType {
            case ethernetOrWiFi, cellular
        }
    }

    // MARK: - Properties
    var isReachable: Bool { isReachableOnCellular || isReachableOnEthernetOrWiFi }
    var isReachableOnCellular: Bool { status == .reachable(.cellular) }
    var isReachableOnEthernetOrWiFi: Bool { status == .reachable(.ethernetOrWiFi) }
    
    private var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        return (SCNetworkReachabilityGetFlags(reachability, &flags)) ? flags : nil
    }

    private var status: NetworkReachabilityStatus {
        flags.map(NetworkReachabilityStatus.init) ?? .unknown
    }

    private let reachability: SCNetworkReachability

    // MARK: - Lifecycles
    public init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
        self.reachability = reachability
    }

    deinit {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
}

extension SCNetworkReachabilityFlags {
    private var isReachable: Bool { contains(.reachable) }
    private var isConnectionRequired: Bool { contains(.connectionRequired) }
    var canConnectAutomatically: Bool {
        contains(.connectionOnDemand) || contains(.connectionOnTraffic)
    }
    var canConnectWithoutUserInteraction: Bool {
        canConnectAutomatically && !contains(.interventionRequired)
    }
    var isActuallyReachable: Bool {
        isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction)
    }
    var isCellular: Bool { contains(.isWWAN) }
}
