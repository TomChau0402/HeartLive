//
//  HeartRateView.swift
//  HeartLive

import SwiftUI
import HealthKit

struct HeartRateView: View {
    @EnvironmentObject var heartRateVM: HeartRateVM
    @State private var showHistory = false
    @State private var animatedHeartbeat = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                headerView
                
                // Main Heart Rate Card
                heartRateCardView
                
                // Additional Metrics
                metricsGridView
                
                // History Button
                historyButtonView
                
                // Status Information
                statusView
            }
            .padding()
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.black, Color(.systemGray6)]),
            startPoint: .top,
            endPoint: .bottom
        ))
        .sheet(isPresented: $showHistory) {
            HeartRateHistoryView()
                .environmentObject(heartRateVM)
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Heart Live")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Real-time Monitoring")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.title2)
                .foregroundColor(.red)
        }
    }
    
    private var heartRateCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray5),
                        Color(.systemGray4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 12) {
                // Animated Heart Icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(heartRateColor)
                    .scaleEffect(animatedHeartbeat ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: animatedHeartbeat
                    )
                    .onAppear {
                        animatedHeartbeat = true
                    }
                
                // Current Heart Rate
                VStack(spacing: 4) {
                    if let currentBPM = heartRateVM.currentHeartRate {
                        Text("\(Int(currentBPM))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                    } else {
                        Text("--")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Status Indicator
                statusIndicatorView
            }
            .padding(30)
        }
        .frame(height: 200)
    }
    
    private var statusIndicatorView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(heartRateVM.isMonitoring ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(heartRateVM.isMonitoring ? "Monitoring" : "Not Monitoring")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var metricsGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            MetricCard(
                title: "Avg Today",
                value: heartRateVM.averageHeartRate.map { "\(Int($0))" } ?? "--",
                unit: "BPM",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            
            MetricCard(
                title: "Min Today",
                value: heartRateVM.minHeartRate.map { "\(Int($0))" } ?? "--",
                unit: "BPM",
                icon: "arrow.down.circle",
                color: .green
            )
            
            MetricCard(
                title: "Max Today",
                value: heartRateVM.maxHeartRate.map { "\(Int($0))" } ?? "--",
                unit: "BPM",
                icon: "arrow.up.circle",
                color: .red
            )
            
            MetricCard(
                title: "Last Update",
                value: heartRateVM.lastUpdateTime ?? "--",
                unit: "",
                icon: "clock",
                color: .orange
            )
        }
    }
    
    private var historyButtonView: some View {
        Button(action: {
            showHistory = true
        }) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text("View History")
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
                .foregroundColor(.white)
            
            if heartRateVM.hasHealthKitAccess {
                Text("HealthKit: Connected")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("HealthKit: Access Required")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            if heartRateVM.isMonitoring {
                Text("Receiving live heart rate data")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
    
    private var heartRateColor: Color {
        guard let bpm = heartRateVM.currentHeartRate else { return .gray }
        
        switch bpm {
        case ..<60: return .blue
        case 60...100: return .green
        case 101...120: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct HeartRateHistoryView: View {
    @EnvironmentObject var heartRateVM: HeartRateVM
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if heartRateVM.heartRateHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Heart Rate Data")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Heart rate data will appear here as it's collected")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(heartRateVM.heartRateHistory.reversed(), id: \.timestamp) { reading in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(reading.bpm)) BPM")
                                    .font(.headline)
                                
                                Text(formatDate(reading.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .foregroundColor(getColorForBPM(reading.bpm))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Heart Rate History")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func getColorForBPM(_ bpm: Double) -> Color {
        switch bpm {
        case ..<60: return .blue
        case 60...100: return .green
        case 101...120: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
            .environmentObject(HeartRateVM())
    }
}
