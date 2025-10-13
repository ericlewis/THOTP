import SwiftUI
import THOTP
import Base32

@Observable
class UrgencySettings {
    // Glow settings
    var glowStartProgress: Double = 0.5

    // Text color settings
    var textColorStartProgress: Double = 0.3

    // Flash settings
    var flashStartProgress: Double = 0.2
    var flashMinFrequency: Double = 1.0
    var flashMaxFrequency: Double = 2.0
    var flashMinAmplitude: Double = 0.10
    var flashMaxAmplitude: Double = 0.20

    // Scale settings
    var scaleStartProgress: Double = 0.2
    var scaleMinFrequency: Double = 1.5
    var scaleMaxFrequency: Double = 3.0
    var scaleMaxBase: Double = 0.03
    var scaleMinPulse: Double = 0.02
    var scaleMaxPulse: Double = 0.06

    // Glow settings
    var glowMinRadius: Double = 5.0
    var glowMaxRadius: Double = 30.0
}

struct SettingsView: View {
    @Bindable var settings: UrgencySettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Glow Effect") {
                    VStack(alignment: .leading) {
                        Text("Start at: \(Int(settings.glowStartProgress * 100))%")
                        Slider(value: $settings.glowStartProgress, in: 0.1...1.0)
                    }

                    VStack(alignment: .leading) {
                        Text("Min Radius: \(Int(settings.glowMinRadius))pt")
                        Slider(value: $settings.glowMinRadius, in: 0...20)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Radius: \(Int(settings.glowMaxRadius))pt")
                        Slider(value: $settings.glowMaxRadius, in: 10...50)
                    }
                }

                Section("Text Color") {
                    VStack(alignment: .leading) {
                        Text("Start at: \(Int(settings.textColorStartProgress * 100))%")
                        Slider(value: $settings.textColorStartProgress, in: 0.1...1.0)
                    }
                }

                Section("Flash Effect") {
                    VStack(alignment: .leading) {
                        Text("Start at: \(Int(settings.flashStartProgress * 100))%")
                        Slider(value: $settings.flashStartProgress, in: 0.05...0.5)
                    }

                    VStack(alignment: .leading) {
                        Text("Min Freq: \(String(format: "%.1f Hz", settings.flashMinFrequency))")
                        Slider(value: $settings.flashMinFrequency, in: 0.5...3.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Freq: \(String(format: "%.1f Hz", settings.flashMaxFrequency))")
                        Slider(value: $settings.flashMaxFrequency, in: 1.0...5.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Min Amplitude: \(Int(settings.flashMinAmplitude * 100))%")
                        Slider(value: $settings.flashMinAmplitude, in: 0.0...0.3)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Amplitude: \(Int(settings.flashMaxAmplitude * 100))%")
                        Slider(value: $settings.flashMaxAmplitude, in: 0.1...0.5)
                    }
                }

                Section("Scale Effect") {
                    VStack(alignment: .leading) {
                        Text("Start at: \(Int(settings.scaleStartProgress * 100))%")
                        Slider(value: $settings.scaleStartProgress, in: 0.05...0.5)
                    }

                    VStack(alignment: .leading) {
                        Text("Min Pulse Freq: \(String(format: "%.1f Hz", settings.scaleMinFrequency))")
                        Slider(value: $settings.scaleMinFrequency, in: 0.5...3.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Pulse Freq: \(String(format: "%.1f Hz", settings.scaleMaxFrequency))")
                        Slider(value: $settings.scaleMaxFrequency, in: 1.0...5.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Base Scale: \(String(format: "%.2fx", 1.0 + settings.scaleMaxBase))")
                        Slider(value: $settings.scaleMaxBase, in: 0.0...0.1, step: 0.01)
                    }

                    VStack(alignment: .leading) {
                        Text("Min Pulse: \(Int(settings.scaleMinPulse * 100))%")
                        Slider(value: $settings.scaleMinPulse, in: 0.0...0.05, step: 0.01)
                    }

                    VStack(alignment: .leading) {
                        Text("Max Pulse: \(Int(settings.scaleMaxPulse * 100))%")
                        Slider(value: $settings.scaleMaxPulse, in: 0.02...0.15, step: 0.01)
                    }
                }

                Section {
                    Button("Reset to Defaults") {
                        settings.glowStartProgress = 0.5
                        settings.textColorStartProgress = 0.3
                        settings.flashStartProgress = 0.2
                        settings.flashMinFrequency = 1.0
                        settings.flashMaxFrequency = 2.0
                        settings.flashMinAmplitude = 0.10
                        settings.flashMaxAmplitude = 0.20
                        settings.scaleStartProgress = 0.2
                        settings.scaleMinFrequency = 1.5
                        settings.scaleMaxFrequency = 3.0
                        settings.scaleMaxBase = 0.03
                        settings.scaleMinPulse = 0.02
                        settings.scaleMaxPulse = 0.06
                        settings.glowMinRadius = 5.0
                        settings.glowMaxRadius = 30.0
                    }
                }
            }
            .navigationTitle("Urgency Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var passwords: [Password] = []
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var showingSettings = false
    @State private var scannedCode: String?
    @State private var newPassword: Password?
    @State private var settings = UrgencySettings()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(passwords, id: \.issuer) { password in
                    Section {
                        PasswordRowView(password: password, settings: settings)
                    }
                }
                .onDelete(perform: deletePasswords)
            }
            .searchable(text: .constant(""))
            .navigationTitle("Ohhhhh Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarSpacer(.fixed, placement: .bottomBar)
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            showingScanner = true
                        }
                        Button("Enter Manually", systemImage: "rectangle.and.pencil.and.ellipsis") {
                            showingManualEntry = true
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .listSectionSpacing(.compact)
        }
        .task {
            loadPasswords()
        }
        .sheet(isPresented: $showingScanner) {
            QRScannerView(scannedCode: $scannedCode)
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntryView(newPassword: $newPassword)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: scannedCode) { _, newValue in
            if let code = newValue, let url = URL(string: code) {
                handleScannedURL(url)
                scannedCode = nil
            }
        }
        .onChange(of: newPassword) { _, password in
            if let password {
                addPassword(password)
                newPassword = nil
            }
        }
    }
    
    private func deletePasswords(at offsets: IndexSet) {
        passwords.remove(atOffsets: offsets)
    }
    
    private func handleScannedURL(_ url: URL) {
        do {
            let password = try Password(url: url)
            addPassword(password)
        } catch {
            print("Failed to parse scanned URL: \(error)")
        }
    }
    
    private func addPassword(_ password: Password) {
        if !passwords.contains(where: { $0.name == password.name && $0.issuer == password.issuer }) {
            passwords.append(password)
        }
    }
    
    private func loadPasswords() {
        guard let secretData = "JBSWY3DPEHPK3PXP".base32DecodedData else { return }
        
        var examples: [Password] = []
        
        // SHA1 - 6 digits (Google Authenticator default)
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha1,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "Google (SHA1)",
                generator: generator
            ))
        }
        
        // SHA256 - 6 digits
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "GitHub (SHA256)",
                generator: generator
            ))
        }
        
        // SHA512 - 8 digits
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha512,
            secret: secretData,
            digits: 8
        ) {
            examples.append(Password(
                name: "admin@example.com",
                issuer: "AWS (SHA512)",
                generator: generator
            ))
        }
        
        // Short period (15 seconds)
        if let generator = try? Generator(
            type: .timer(period: 15),
            hash: .sha256,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "FastCorp (15s)",
                generator: generator
            ))
        }
        
        // Counter-based (HOTP)
        if let generator = try? Generator(
            type: .counter(0),
            hash: .sha1,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "Legacy (HOTP)",
                generator: generator
            ))
        }
        
        passwords = examples
    }
}

struct PasswordRowView: View {
    let password: Password
    let settings: UrgencySettings

    var body: some View {
        TimelineView(.animation) { _ in
            rowContent(
                currentCode: password.currentPassword ?? "------",
                timeRemaining: password.timeRemaining ?? 0,
                progress: password.passwordProgress ?? 0
            )
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func rowContent(currentCode: String, timeRemaining: TimeInterval, progress: Double) -> some View {
        let color = progressColor(progress: progress, timeRemaining: timeRemaining)
        let flashOpacity = calculateFlashOpacity(progress: progress, timeRemaining: timeRemaining)
        let scaleEffect = calculateScaleEffect(progress: progress, timeRemaining: timeRemaining)
        let glowIntensity = calculateGlowIntensity(progress: progress)
        let glowColor = calculateGlowColor(progress: progress)
        let textColor = calculateTextColor(progress: progress)

        Gauge(value: progress) {
            LabeledContent {
                Text(currentCode)
                    .font(.system(.title2, design: .monospaced).bold())
                    .monospacedDigit()
                    .foregroundStyle(textColor)
                    .opacity(flashOpacity)
                    .scaleEffect(scaleEffect)
                    .shadow(color: glowColor.opacity(glowIntensity * 0.95), radius: settings.glowMaxRadius - (glowIntensity * (settings.glowMaxRadius - settings.glowMinRadius)))
                    .shadow(color: glowColor.opacity(glowIntensity * 0.7), radius: (settings.glowMaxRadius * 1.67) - (glowIntensity * (settings.glowMaxRadius * 1.67 - settings.glowMinRadius * 2)))
            } label: {
                Text(password.issuer ?? "Unknown")
                    .font(.headline)
                Text(password.name)
            }
        }
        .tint(color)
    }
    
    private var isTimerBased: Bool {
        if case .timer = password.generator.generatorAlgorithm {
            return true
        }
        return false
    }
    
    private func progressColor(progress: Double, timeRemaining: TimeInterval) -> Color {
        let p = min(max(progress, 0), 1)
        let hue = 0.33 * p
        let saturation = 0.6 + 0.4 * (1 - p)
        let baseBrightness: Double = 0.9
        let phase = (timeRemaining.truncatingRemainder(dividingBy: 1.0)) * 2 * .pi
        let pulse = 0.05 * (1 - p) * sin(phase)
        let brightness = min(max(baseBrightness + pulse, 0.8), 1.0)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    private func calculateFlashOpacity(progress: Double, timeRemaining: TimeInterval) -> Double {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start flashing based on settings
        guard p < settings.flashStartProgress else { return 1.0 }

        // Calculate intensity based on threshold
        let intensity = 1.0 - (p / settings.flashStartProgress)

        // Flash frequency increases based on settings
        let frequency = settings.flashMinFrequency + ((settings.flashMaxFrequency - settings.flashMinFrequency) * intensity)

        // Phase based on timeRemaining for continuous frequency changes
        let phase = timeRemaining * frequency * 2 * .pi

        // Amplitude increases with intensity based on settings
        let amplitude = settings.flashMinAmplitude + ((settings.flashMaxAmplitude - settings.flashMinAmplitude) * intensity)

        // Calculate opacity pulse using sine wave
        let pulse = amplitude * (0.5 - 0.5 * sin(phase))

        return 1.0 - pulse
    }

    private func calculateScaleEffect(progress: Double, timeRemaining: TimeInterval) -> CGFloat {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start scaling based on settings
        guard p < settings.scaleStartProgress else { return 1.0 }

        // Calculate intensity based on threshold
        let intensity = 1.0 - (p / settings.scaleStartProgress)

        // Use cubic curve for base scale growth
        let exponentialIntensity = intensity * intensity * intensity

        // Base scale grows based on settings
        let baseScale = 1.0 + (settings.scaleMaxBase * exponentialIntensity)

        // Pulsing effect that gets faster based on settings
        let pulseFrequency = settings.scaleMinFrequency + ((settings.scaleMaxFrequency - settings.scaleMinFrequency) * intensity)
        let phase = timeRemaining * pulseFrequency * 2 * .pi

        // Pulse amplitude increases based on settings
        let pulseAmplitude = settings.scaleMinPulse + ((settings.scaleMaxPulse - settings.scaleMinPulse) * exponentialIntensity)
        let pulse = pulseAmplitude * (0.5 + 0.5 * sin(phase))

        return baseScale + pulse
    }

    private func calculateGlowIntensity(progress: Double) -> Double {
        let p = min(max(progress, 0), 1)

        // Glow starts based on settings
        guard p < settings.glowStartProgress else { return 0.0 }

        // Calculate intensity based on threshold
        let intensity = 1.0 - (p / settings.glowStartProgress)

        // Use quadratic curve for smooth buildup
        return intensity * intensity
    }

    private func calculateGlowColor(progress: Double) -> Color {
        let p = min(max(progress, 0), 1)

        // Glow is visible based on settings, interpolate within that range
        let normalized = p / settings.glowStartProgress // Maps threshold→1.0, 0.0→0.0
        let hue = 0.33 * normalized

        // Increase saturation as urgency increases
        let saturation = 0.7 + 0.3 * (1 - normalized)

        return Color(hue: hue, saturation: saturation, brightness: 0.9)
    }

    private func calculateTextColor(progress: Double) -> Color {
        let p = min(max(progress, 0), 1)

        // Start interpolation at threshold, but keep very subtle initially
        guard p < settings.textColorStartProgress else { return .primary }

        // Interpolate from yellow-green to red within threshold → 0% range
        let normalized = p / settings.textColorStartProgress
        let hue = 0.15 * normalized

        // Start with very low saturation (nearly grayscale) and gradually increase
        // This creates a smooth transition from primary appearance
        let intensityCurve = (1 - normalized) * (1 - normalized) // Quadratic for smooth ramp
        let saturation = intensityCurve * 0.8

        // Keep brightness high to prevent dark colors
        return Color(hue: hue, saturation: saturation, brightness: 0.95)
    }
}

#Preview {
    ContentView()
}
