//
//  LocationManager.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/05/25.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var showLocationDisabledAlert: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        DispatchQueue.global(qos: .background).async {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                if !servicesEnabled {
                    self.showLocationDisabledAlert = true
                }
            }
        }

        self.authorizationStatus = locationManager.authorizationStatus
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // iOS 14+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus

            switch self.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationManager.stopUpdatingLocation()
            default:
                break
            }
        }
    }

    // Optional: for iOS <14 fallback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status

            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationManager.stopUpdatingLocation()
            default:
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }

        DispatchQueue.main.async {
            self.currentLocation = latestLocation
        }

        // Reverse geocode on background thread
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(latestLocation) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                if let error = error {
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                }
                return
            }

            DispatchQueue.main.async {
                self.currentPlacemark = placemark
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}
