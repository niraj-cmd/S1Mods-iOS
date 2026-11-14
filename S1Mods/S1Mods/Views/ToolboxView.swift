import SwiftUI

struct ToolboxView: View {
    @ObservedObject var viewModel: ScooterViewModel
    @State private var showShellSheet = false
    @State private var showSettingsSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "Quick Actions")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ToolboxButton(icon: "camera.fill", title: "Screenshot", color: .blue) { Task { await viewModel.captureScreenshot() } }
                    ToolboxButton(icon: "memorychip.fill", title: "RAM Info", color: .green) { Task { await viewModel.fetchRAMInfo() } }
                    ToolboxButton(icon: "info.circle.fill", title: "Scooter Info", color: .orange) { Task { await viewModel.fetchScooterInfo() } }
                    ToolboxButton(icon: "house.fill", title: "Dashboard Home", color: .purple) { Task { await viewModel.openApp("com.olaelectric.hmiclient") } }
                    ToolboxButton(icon: "terminal.fill", title: "Shell", color: .red) { showShellSheet = true }
                    ToolboxButton(icon: "gear", title: "Settings", color: .teal) { showSettingsSheet = true }
                }.padding(.horizontal, 16)

                SectionHeader(title: "Installed Mods")
                VStack(spacing: 8) {
                    ModActionRow(app: .balls, title: "Balls Navigation", subtitle: "Floating nav buttons", action: { Task { await viewModel.openApp("com.asjohn720.ball") } }, uninstallAction: { Task { await viewModel.uninstallPackage("com.asjohn720.ball") } })
                    ModActionRow(app: .androidAuto, title: "Android Auto", subtitle: "OpenHeadUnit projection", action: { Task { await viewModel.openApp("com.asjohn720.androidauto") } }, uninstallAction: { Task { await viewModel.uninstallPackage("com.asjohn720.androidauto") } })
                    ModActionRow(app: .music, title: "Music Mod", subtitle: "Ad-free music", action: { Task { await viewModel.openApp("com.asjohn720.musicmod") } }, uninstallAction: { Task { await viewModel.uninstallPackage("com.asjohn720.musicmod") } })
                }.padding(.horizontal, 16)

                SectionHeader(title: "Settings Shortcuts")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    SettingsShortcutButton(icon: "wifi", title: "Wi-Fi", action: "android.settings.WIFI_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "antenna.radiowaves.left.and.right", title: "Bluetooth", action: "android.settings.BLUETOOTH_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "display", title: "Display", action: "android.settings.DISPLAY_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "speaker.wave.2.fill", title: "Sound", action: "android.settings.SOUND_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "battery.100", title: "Battery", action: "android.settings.BATTERY_SAVER_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "app.fill", title: "Apps", action: "android.settings.APPLICATION_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "externaldrive.fill", title: "Storage", action: "android.settings.INTERNAL_STORAGE_SETTINGS", viewModel: viewModel)
                    SettingsShortcutButton(icon: "info.circle", title: "About", action: "android.settings.DEVICE_INFO_SETTINGS", viewModel: viewModel)
                }.padding(.horizontal, 16)

                Spacer().frame(height: 100)
            }.padding(.top, 8)
        }.background(Color.bgDark)
        .sheet(isPresented: $showShellSheet) { ShellCommandSheet(viewModel: viewModel) }
        .sheet(isPresented: $showSettingsSheet) { SettingsActionSheet(viewModel: viewModel) }
    }
}
