import SwiftUI
import UniformTypeIdentifiers

struct CustomAPKView: View {
    @ObservedObject var viewModel: ScooterViewModel
    @State private var showFilePicker = false
    @State private var showInstallConfirmation = false
    @State private var selectedAPKURL: URL?
    @State private var apkFileName = ""
    @State private var apkPackageName = ""
    @State private var isInstalling = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    SectionHeader(title: "Install Custom APK")
                    Button(action: { showFilePicker = true }) {
                        HStack(spacing: 12) {
                            ZStack { RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.2)).frame(width: 50, height: 50); Image(systemName: "doc.badge.plus").font(.system(size: 22, weight: .medium)).foregroundColor(.blue) }
                            VStack(alignment: .leading, spacing: 2) { Text("Select APK File").font(.system(size: 14, weight: .medium)).foregroundColor(.textPrimary); Text("Choose an APK from Files app").font(.system(size: 11)).foregroundColor(.textSecondary) }
                            Spacer(); Image(systemName: "chevron.right").foregroundColor(.textMuted)
                        }.padding(16).background(Color.surfaceDark).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
                    }.padding(.horizontal, 16)

                    if !apkFileName.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected APK").font(.system(size: 13, weight: .medium)).foregroundColor(.textMuted)
                            HStack { Image(systemName: "doc.fill").foregroundColor(.blue); VStack(alignment: .leading, spacing: 2) { Text(apkFileName).font(.system(size: 13, weight: .medium)).foregroundColor(.textPrimary).lineLimit(1); if !apkPackageName.isEmpty { Text(apkPackageName).font(.system(size: 11, design: .monospaced)).foregroundColor(.textSecondary) } }; Spacer() }.padding(12).background(Color.surfaceDark).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))
                        }.padding(.horizontal, 16)
                    }
                }

                VStack(spacing: 12) {
                    HStack { SectionHeader(title: "Installed Packages"); Spacer(); Button(action: { Task { await viewModel.fetchInstalledPackages() } }) { Image(systemName: "arrow.clockwise").font(.system(size: 14)).foregroundColor(.textSecondary) } }.padding(.horizontal, 16)
                    if viewModel.setupState.logs.isEmpty { Text("No package data. Tap refresh to fetch from vehicle.").font(.system(size: 12)).foregroundColor(.textMuted).frame(maxWidth: .infinity).padding(.vertical, 40) }
                    else { LogView(logs: viewModel.setupState.logs).frame(height: 300).padding(.horizontal, 16) }
                }
                Spacer().frame(height: 100)
            }.padding(.top, 8)
        }.background(Color.bgDark)
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [UTType(filenameExtension: "apk")!], allowsMultipleSelection: false) { result in handleFileSelection(result) }
        .sheet(isPresented: $showInstallConfirmation) { if let url = selectedAPKURL { InstallConfirmationView(fileName: apkFileName, packageName: apkPackageName, onInstall: { Task { await installAPK(url) } }, onCancel: { showInstallConfirmation = false; selectedAPKURL = nil }) } }
    }
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            selectedAPKURL = url; apkFileName = url.lastPathComponent; apkPackageName = extractPackageName(from: url.lastPathComponent); showInstallConfirmation = true
        case .failure(let error): viewModel.setupState.addLog("[!] File selection failed: \(error.localizedDescription)")
        }
    }
    private func extractPackageName(from fileName: String) -> String {
        var name = fileName.replacingOccurrences(of: ".apk", with: "").replacingOccurrences(of: "-release", with: "").replacingOccurrences(of: "-debug", with: "")
        return name.contains(".") ? name : "unknown.package"
    }
    private func installAPK(_ url: URL) async {
        guard selectedAPKURL != nil else { return }
        isInstalling = true; showInstallConfirmation = false
        viewModel.setupState.addLog("[*] Installing \(apkFileName)...")
        do { try await viewModel.relayClient.installAPK(localPath: url.path); viewModel.setupState.addLog("[+] \(apkFileName) installed successfully!") }
        catch { viewModel.setupState.addLog("[!] Install failed: \(error.localizedDescription)") }
        isInstalling = false; selectedAPKURL = nil; apkFileName = ""; apkPackageName = ""
    }
}
