//
//  HeartLiveApp.swift
//  HeartLive Watch App
//
import SwiftUI

@main
struct HeartLiveApp: App {
    @StateObject private var heartRateVM = HeartRateVM()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HeartRateView()
                .environmentObject(heartRateVM)
                .onAppear {
                    heartRateVM.requestHealthKitAuthorization()
                }
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        heartRateVM.startHeartRateStream()
                    case .inactive, .background:
                        heartRateVM.stopHeartRateStream()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
