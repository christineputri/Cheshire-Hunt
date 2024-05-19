//
//  ContentView.swift
//  Cheshire Hunt
//
//  Created by Christine Putri on 20/05/24.
//

import SwiftUI
import CoreLocation
import AVFoundation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @StateObject private var viewModel = CheshireViewModel()
    @State private var timeRemaining = 600
    @State private var timerIsActive = true
    @State private var gameStarted = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Image("Apple")
                    .resizable()
                    .scaledToFit()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .edgesIgnoringSafeArea(.all)
                if !gameStarted {
                    Image("rectangle")
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)

                    Image("start")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .onTapGesture {
                            gameStarted = true
                            viewModel.playStartSound()
                            viewModel.playSong()
                        }
                } else {
                    Group {
                        Image("belang")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .position(viewModel.catPositions["belang"] ?? CGPoint())
                            .opacity(viewModel.cats["belang"] ?? false ? 0 : 1)
                            .onAppear {
                                viewModel.updateCatStates(latitude: locationManager.latitude, longitude: locationManager.longitude)
                            }

                        Image("oren")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .position(viewModel.catPositions["oren"] ?? CGPoint())
                            .opacity(viewModel.cats["oren"] ?? false ? 0 : 1)
                            .onAppear {
                                viewModel.updateCatStates(latitude: locationManager.latitude, longitude: locationManager.longitude)
                            }

                        Image("putih")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .position(viewModel.catPositions["putih"] ?? CGPoint())
                            .opacity(viewModel.cats["putih"] ?? false ? 0 : 1)
                            .onAppear {
                                viewModel.updateCatStates(latitude: locationManager.latitude, longitude: locationManager.longitude)
                            }
                        VStack {
                            Text("Latitude: \(locationManager.latitude)\nLongitude: \(locationManager.longitude)")
                                .position(x: geometry.size.width / 2, y: geometry.size.height - 120)
                        }
                        .padding()
                    }

                    if viewModel.showTrophy {
                        Image("rectangle")
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)

                        Image("trophy")
                            .resizable()
                            .frame(width: 300, height: 300)
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 600)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    viewModel.showTrophy = false
                                    viewModel.showReplay = true
                                }
                            }
                    }

                    if viewModel.showReplay {
                        Image("rectangle")
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)

                        Image("replay")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .onTapGesture {
                                resetGame()
                            }
                    }

                    if timerIsActive {
                        Text("Time remaining: \(timeRemaining / 60):\(timeRemaining % 60)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding()
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if gameStarted && timeRemaining > 0 && timerIsActive {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                timerIsActive = false
            }
        }
        .onAppear {
            viewModel.startLocationUpdates()
        }
        .onChange(of: locationManager.latitude) { _ in
            viewModel.updateCatStates(latitude: locationManager.latitude, longitude: locationManager.longitude)
        }
        .onChange(of: locationManager.longitude) { _ in
            viewModel.updateCatStates(latitude: locationManager.latitude, longitude: locationManager.longitude)
        }
        .onChange(of: viewModel.showTrophy) { showTrophy in
            if showTrophy {
                timerIsActive = false
                viewModel.stopSong()
            }
        }
    }

    private func resetGame() {
        timeRemaining = 600
        timerIsActive = true
        gameStarted = false
        viewModel.resetGame()
    }
}
