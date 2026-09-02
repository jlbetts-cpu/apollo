//
//  SunsetClock.swift
//  Apollo
//
//  When the feed unlocks. Wins stay locked until sunset and everyone's
//  unlock at once — one fixed daily moment instead of a compulsion (case
//  study, "The feed").
//
//  Sunset is computed locally with the NOAA general solar position
//  algorithm from the device's coarse location; no network, no server. If
//  location is unavailable or denied, the clock falls back to 7:42 PM local
//  (the time in the mockups) so the screen is never blank.
//
//  Guest mode: the unlock is a fixed offset from launch so the locked feed
//  looks exactly like the Figma frame (2:41:23) and so the unlock animation
//  can be watched by long-pressing the countdown (see FeedLockedHero).
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class SunsetClock: NSObject, ObservableObject {
    static let shared = SunsetClock()

    /// The next unlock moment. Never nil once `start()` has run.
    @Published private(set) var unlockDate: Date = SunsetClock.fallbackUnlock(after: .now)
    @Published private(set) var isUnlocked: Bool = false

    /// Guest-mode offset from launch, matching the mockup's countdown.
    static let guestUnlockOffset: TimeInterval = 2 * 3600 + 41 * 60 + 23

    private let locationManager = CLLocationManager()
    private var coordinate: CLLocationCoordinate2D?
    private var ticker: AnyCancellable?
    private var guestOverride: Date?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    // MARK: - Lifecycle

    func start() {
        if ApolloRepositories.isGuest {
            guestOverride = Date().addingTimeInterval(Self.guestUnlockOffset)
        } else {
            requestLocationIfNeeded()
        }
        recompute()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
    }

    /// Guest/debug only: pull the unlock to a few seconds from now so the
    /// unlock choreography can be watched without waiting for dusk.
    func debugUnlock(in seconds: TimeInterval = 3) {
        guard ApolloRepositories.isGuest else { return }
        guestOverride = Date().addingTimeInterval(seconds)
        recompute()
    }

    /// Guest/debug only: re-lock so the animation can be replayed.
    func debugRelock() {
        guard ApolloRepositories.isGuest else { return }
        guestOverride = Date().addingTimeInterval(Self.guestUnlockOffset)
        recompute()
    }

    // MARK: - Computation

    private func tick() {
        let nowUnlocked = Date() >= unlockDate
        if nowUnlocked != isUnlocked { isUnlocked = nowUnlocked }
        // Roll to tomorrow's sunset once today's has passed by more than an
        // hour, so the app still shows a sensible countdown late at night.
        if nowUnlocked, Date().timeIntervalSince(unlockDate) > 3600, guestOverride == nil {
            recompute()
        }
    }

    private func recompute() {
        let now = Date()
        if let guestOverride {
            unlockDate = guestOverride
        } else if let coordinate,
                  let today = Self.sunset(on: now, latitude: coordinate.latitude, longitude: coordinate.longitude) {
            unlockDate = today > now
                ? today
                : (Self.sunset(on: now.addingTimeInterval(86_400), latitude: coordinate.latitude, longitude: coordinate.longitude) ?? Self.fallbackUnlock(after: now))
        } else {
            unlockDate = Self.fallbackUnlock(after: now)
        }
        isUnlocked = now >= unlockDate
    }

    /// 7:42 PM local today, or tomorrow if that has passed.
    static func fallbackUnlock(after now: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = 19; comps.minute = 42; comps.second = 0
        let today = cal.date(from: comps) ?? now
        return today > now ? today : (cal.date(byAdding: .day, value: 1, to: today) ?? today)
    }

    /// NOAA general solar position algorithm. Returns nil at latitudes where
    /// the sun does not set on that date.
    static func sunset(on date: Date, latitude: Double, longitude: Double) -> Date? {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        guard let dayOfYear = utc.ordinality(of: .day, in: .year, for: date) else { return nil }

        func deg(_ r: Double) -> Double { r * 180 / .pi }
        func rad(_ d: Double) -> Double { d * .pi / 180 }
        func norm(_ x: Double, _ range: Double) -> Double {
            var v = x.truncatingRemainder(dividingBy: range)
            if v < 0 { v += range }
            return v
        }

        let zenith = 90.833
        let lngHour = longitude / 15
        let t = Double(dayOfYear) + ((18 - lngHour) / 24)
        let meanAnomaly = (0.9856 * t) - 3.289
        var trueLong = meanAnomaly + (1.916 * sin(rad(meanAnomaly))) + (0.020 * sin(rad(2 * meanAnomaly))) + 282.634
        trueLong = norm(trueLong, 360)

        var rightAscension = deg(atan(0.91764 * tan(rad(trueLong))))
        rightAscension = norm(rightAscension, 360)
        let lQuadrant = floor(trueLong / 90) * 90
        let raQuadrant = floor(rightAscension / 90) * 90
        rightAscension = (rightAscension + (lQuadrant - raQuadrant)) / 15

        let sinDec = 0.39782 * sin(rad(trueLong))
        let cosDec = cos(asin(sinDec))
        let cosH = (cos(rad(zenith)) - (sinDec * sin(rad(latitude)))) / (cosDec * cos(rad(latitude)))
        guard cosH >= -1, cosH <= 1 else { return nil }

        let hourAngle = deg(acos(cosH)) / 15
        let localMeanTime = hourAngle + rightAscension - (0.06571 * t) - 6.622
        let utHours = norm(localMeanTime - lngHour, 24)

        let startOfDay = utc.startOfDay(for: date)
        return startOfDay.addingTimeInterval(utHours * 3600)
    }

    // MARK: - Location

    private func requestLocationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
}

extension SunsetClock: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let coord = last.coordinate
        Task { @MainActor in
            self.coordinate = coord
            self.recompute()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fall back silently; the 7:42 PM default is already showing.
    }
}
