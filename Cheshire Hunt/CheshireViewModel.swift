//
//  CheshireViewModel.swift
//  Cheshire Hunt
//
//  Created by Christine Putri on 20/05/24.
//

import Foundation
import CoreLocation
import SwiftUI
import AVFoundation

class CheshireViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var catPositions: [String: CGPoint] = ["oren": CGPoint(x: 200, y: 150),
                                                      "belang": CGPoint(x: 660, y: 450),
                                                      "putih": CGPoint(x: 1250, y: 370)]
    @Published var cats = ["belang": false, "oren": false, "putih": false]
    @Published var showTrophy = false
    @Published var showReplay = false
    @Published var footPosition: CGPoint?

    private var locationManager: CLLocationManager = CLLocationManager()
    private var catLocations: [String: CLLocation] = ["belang": CLLocation(latitude: -6.302113, longitude: 106.652296),
                                                      "oren": CLLocation(latitude: -6.302241, longitude: 106.652160),
                                                      "putih": CLLocation(latitude: -6.302094, longitude: 106.652426)]
    private var startPlayer: AVAudioPlayer?
    private var songPlayer: AVAudioPlayer?
    private var meowPlayer: AVAudioPlayer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func isCatNearby(name: String, userLatitude: Double, userLongitude: Double) -> Bool {
        guard let catLocation = catLocations[name] else { return false }
        let userLongitudeRounded = round(userLongitude * 100000) / 100000 // Round to 5 decimal places
        let catLongitudeRounded = round(catLocation.coordinate.longitude * 100000) / 100000

        let longitudeDifference = abs(userLongitudeRounded - catLongitudeRounded)

        return longitudeDifference <= 0.00001 // Toleransi longitude hingga 5 angka di belakang koma
    }

    func catTapped(name: String) {
        if let url = Bundle.main.url(forResource: "meow", withExtension: "mp3") {
            do {
                meowPlayer = try AVAudioPlayer(contentsOf: url)
                meowPlayer?.volume = 1.0  // Set the volume of the "meow" sound to be higher
                meowPlayer?.play()
                cats[name] = true
                if !cats.values.contains(false) {
                    showTrophy = true
                    playYaySound()
                }
            } catch {
                print("Error suara meow: \(error)")
            }
        }
    }

    func playStartSound() {
        if let url = Bundle.main.url(forResource: "start", withExtension: "mp3") {
            do {
                startPlayer = try AVAudioPlayer(contentsOf: url)
                startPlayer?.play()
            } catch {
                print("Error suara start: \(error)")
            }
        }
    }

    func playSong() {
        if let url = Bundle.main.url(forResource: "song", withExtension: "mp3") {
            do {
                songPlayer = try AVAudioPlayer(contentsOf: url)
                songPlayer?.numberOfLoops = -1  // Set the song to loop indefinitely
                songPlayer?.volume = 0.2  // Set the volume of the "song" sound lower
                songPlayer?.play()
            } catch {
                print("Error suara song: \(error)")
            }
        }
    }

    func stopSong() {
        songPlayer?.stop()
    }

    private func playYaySound() {
        if let url = Bundle.main.url(forResource: "yay", withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.play()
            } catch {
                print("Error suara trophy: \(error)")
            }
        }
    }

    func resetGame() {
        cats = ["belang": false, "oren": false, "putih": false]
        showTrophy = false
        showReplay = false
        catPositions = ["oren": CGPoint(x: 200, y: 150),
                        "belang": CGPoint(x: 660, y: 450),
                        "putih": CGPoint(x: 1250, y: 370)]
        stopSong()
        startPlayer?.stop()
        footPosition = nil
    }

    func updateCatStates(latitude: Double, longitude: Double) {
        for (catName, catLocation) in catLocations {
            if isCatNearby(name: catName, userLatitude: latitude, userLongitude: longitude) {
                catTapped(name: catName)
            }
        }
    }

    func updateFootPosition(latitude: Double, longitude: Double, geometry: CGSize) {
        // Convert latitude and longitude to screen position
        let mapWidth = geometry.width
        let mapHeight = geometry.height
        
        // Assumes that (latitudeMin, longitudeMin) is the top-left and (latitudeMax, longitudeMax) is the bottom-right of the map.
        let latitudeMin: Double = -6.302500
        let latitudeMax: Double = -6.301500
        let longitudeMin: Double = 106.651500
        let longitudeMax: Double = 106.653000

        let xPos = (longitude - longitudeMin) / (longitudeMax - longitudeMin) * mapWidth
        let yPos = (latitudeMax - latitude) / (latitudeMax - latitudeMin) * mapHeight

        footPosition = CGPoint(x: xPos, y: yPos)
    }
}

