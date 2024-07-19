//
//  DeviceOrientationService.swift
//  LBC
//
//  Created by Berserk on 19/07/2024.
//

import Combine
import UIKit

final class DeviceOrientationService {
    
    static let shared = DeviceOrientationService()
    
    // MARK: - Properties
    
    private let orientationSubject = PassthroughSubject<UIDeviceOrientation, Never>()
    
    var orientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        return orientationSubject.eraseToAnyPublisher()
    }
    
    private var cancellabes = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                let currentOrientation = UIDevice.current.orientation
                self?.orientationSubject.send(currentOrientation)
            }
            .store(in: &cancellabes)
    }
}
