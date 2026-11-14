import Foundation
import SwiftUI

// MARK: - Enums

enum SetupStep: Int, CaseIterable, Identifiable {
    case verifyConnection = 1
    case unlockADB = 2
    case installAPKs = 3
    case grantPermissions = 4
    case finalizeHome = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .verifyConnection: return "Detect Scooter & Connect"
        case .unlockADB: return "In-Memory ADB Unlock"
        case .installAPKs: return "Install Selected Mod APKs"
        case .grantPermissions: return "Grant System Permissions"
        case .finalizeHome: return "Initialize & Return to Home"
        }
    }
}

enum ModApp: String, CaseIterable, Identifiable {
    case balls = "balls"
    case androidAuto = "android_auto"
    case music = "music"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .balls: return "Balls Navigation"
        case .androidAuto: return "Android Auto"
        case .music: return "Music Mod"
        }
    }

    var packageName: String {
        switch self {
        case .balls: return "com.asjohn720.ball"
        case .androidAuto: return "com.asjohn720.androidauto"
        case .music: return "com.asjohn720.musicmod"
        }
    }

    var assetFileName: String {
        switch self {
        case .balls: return "balls-1.1.0-lite-release.apk"
        case .androidAuto: return "com.asjohn720.androidauto.apk"
        case .music: return "musicmod-release.apk"
        }
    }

    var isMandatory: Bool {
        switch self {
        case .balls: return true
        case .androidAuto, .music: return false
        }
    }

    var description: String {
        switch self {
        case .balls: return "Floating nav buttons"
        case .androidAuto: return "Maps, music and calls"
        case .music: return "Ad-free music"
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case setup = "Setup"
    case toolbox = "Tools"
    case customAPK = "Apps"
    case terminal = "Shell"

    var id: String { rawValue }
    var title: String { rawValue }
    var icon: String {
        switch self {
        case .setup: return "bolt.fill"
        case .toolbox: return "square.grid.2x2.fill"
        case .customAPK: return "square.and.arrow.down.fill"
        case .terminal: return "terminal.fill"
        }
    }
}

// MARK: - Data Models

struct DiscoveredScooter: Identifiable, Codable {
    let id = UUID()
    let ip: String
    let scope: Int?
    let isPortOpen: Bool
    let interfaceName: String
    let source: String
    var displayName: String = "Ola Scooter"
    var displayAddress: String {
        if let scope = scope { return "\(ip)%\(scope)" }
        return ip
    }
}

struct ScooterInfo: Codable {
    let uid: String
    let androidVersion: String
    let buildId: String
    let model: String
    let scooterMode: String
}

struct VehicleSummary: Codable, Identifiable {
    let id = UUID()
    let model: String
    let moveOS: String
    let majorVersion: Int?
    let supported: Bool
}

struct RamInfo: Codable {
    let totalMB: Int
    let usedMB: Int
    let freeMB: Int
}

struct ScooterConnectionState: Codable {
    var ip: String = ""
    var scope: Int? = nil
    var isConnected: Bool = false
    var vehicleSummary: VehicleSummary? = nil
}

// MARK: - Relay Protocol Models

struct RelayRequest: Codable {
    let id: UUID = UUID()
    let command: String
    let payload: [String: String]?
    let timeout: TimeInterval?
}

struct RelayResponse: Codable {
    let id: UUID
    let success: Bool
    let data: [String: String]?
    let error: String?
    let logs: [String]?
}

// MARK: - Setup State

class SetupState: ObservableObject {
    @Published var currentStep: SetupStep? = nil
    @Published var isRunning: Bool = false
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String? = nil
    @Published var logs: [String] = []
    @Published var selectedApps: Set<ModApp> = Set(ModApp.allCases)

    func addLog(_ message: String) {
        DispatchQueue.main.async { self.logs.append(message) }
    }
    func clearLogs() {
        DispatchQueue.main.async { self.logs.removeAll() }
    }
}
