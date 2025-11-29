//
//  HeartRateVM.swift
//  HeartLive

import Foundation
import HealthKit
import Combine

class HeartRateVM: ObservableObject {
    @Published var currentHeartRate: Double?
    @Published var averageHeartRate: Double?
    @Published var minHeartRate: Double?
    @Published var maxHeartRate: Double?
    @Published var heartRateHistory: [HeartRateReading] = []
    @Published var isMonitoring = false
    @Published var hasHealthKitAccess = false
    @Published var lastUpdateTime: String?
    
    private let healthKitService = HealthKitServices()
    private let heartRateStream = HeartRateStream(store: <#HKHealthStore#>)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        heartRateStream.$currentHeartRate
            .receive(on: RunLoop.main)
            .sink { [weak self] bpm in
                self?.currentHeartRate = bpm
                self?.lastUpdateTime = self?.getCurrentTime()
                
                if let bpm = bpm {
                    let reading = HeartRateReading(bpm: bpm, timestamp: Date())
                    self?.heartRateHistory.append(reading)
                    self?.calculateStatistics()
                }
            }
            .store(in: &cancellables)
    }
    
    func requestHealthKitAuthorization() {
        healthKitService.requestAuthorization { [weak self] success in
            DispatchQueue.main.async {
                self?.hasHealthKitAccess = success
                if success {
                    self?.startHeartRateStream()
                }
            }
        }
    }
    
    func startHeartRateStream() {
        heartRateStream.startStreaming()
        isMonitoring = true
    }
    
    func stopHeartRateStream() {
        heartRateStream.stopStreaming()
        isMonitoring = false
    }
    
    private func calculateStatistics() {
        guard !heartRateHistory.isEmpty else { return }
        
        let bpms = heartRateHistory.map { $0.bpm }
        averageHeartRate = bpms.reduce(0, +) / Double(bpms.count)
        minHeartRate = bpms.min()
        maxHeartRate = bpms.max()
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}

struct HeartRateReading {
    let bpm: Double
    let timestamp: Date
}
