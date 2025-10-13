import SwiftUI
import THOTP
import Base32

struct ContentView: View {
    @State private var passwords: [Password] = []
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var scannedCode: String?
    @State private var newPassword: Password?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(passwords, id: \.issuer) { password in
                    Section {
                        PasswordRowView(password: password)
                    }
                }
                .onDelete(perform: deletePasswords)
            }
            .searchable(text: .constant(""))
            .navigationTitle("THOTP Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
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
        let isRedZone = progress < 0.25

        Gauge(value: progress) {
            LabeledContent {
                Text(currentCode)
                    .font(.system(.title2, design: .monospaced).bold())
                    .monospacedDigit()
                    .foregroundStyle(isRedZone ? .red : .primary)
                    .opacity(flashOpacity)
                    .shadow(color: isRedZone ? .red.opacity(0.8) : .clear, radius: isRedZone ? 12 : 0)
                    .shadow(color: isRedZone ? .red.opacity(0.4) : .clear, radius: isRedZone ? 24 : 0)
                    .animation(Animation.easeInOut(duration: 0.2), value: flashOpacity)
                    .animation(Animation.easeInOut(duration: 0.3), value: isRedZone)
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
    
    private func glowOpacity(progress: Double) -> Double {
        let p = min(max(progress, 0), 1)
        return 0.15 + 0.25 * (1 - p)
    }
    
    private func glowRadius(progress: Double) -> CGFloat {
        let p = min(max(progress, 0), 1)
        return 4 + 10 * (1 - p)
    }

    private func calculateFlashOpacity(progress: Double, timeRemaining: TimeInterval) -> Double {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start flashing when less than 25% time remains
        guard p < 0.25 else { return 1.0 }

        // Calculate flash intensity (0.0 = subtle, 1.0 = intense)
        let intensity = 1.0 - (p / 0.25)

        // Flash frequency increases as time runs out (0.5-2 Hz)
        let frequency = 0.5 + (1.5 * intensity)

        // Phase based on sub-second timing
        let phase = (timeRemaining.truncatingRemainder(dividingBy: 1.0 / frequency)) * frequency * 2 * .pi

        // Amplitude increases with intensity (subtle: 12%, intense: 35%)
        let amplitude = 0.12 + (0.23 * intensity)

        // Calculate opacity pulse (stays mostly visible, dips noticeably)
        let pulse = amplitude * (1.0 - cos(phase)) / 2.0

        return 1.0 - pulse
    }
}

#Preview {
    ContentView()
}
