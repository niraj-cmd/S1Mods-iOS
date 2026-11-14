import SwiftUI

struct TerminalView: View {
    @ObservedObject var viewModel: ScooterViewModel
    @State private var command = ""
    @State private var showCommandHistory = false
    @State private var commandHistory: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) { Circle().fill(Color.red).frame(width: 10, height: 10); Circle().fill(Color.yellow).frame(width: 10, height: 10); Circle().fill(Color.green).frame(width: 10, height: 10) }
                Text("Terminal — \(viewModel.connectionState.ip.isEmpty ? "No target" : viewModel.connectionState.ip)").font(.system(size: 11, design: .monospaced)).foregroundColor(.textMuted)
                Spacer()
                HStack(spacing: 12) {
                    Button(action: { viewModel.setupState.clearLogs() }) { Image(systemName: "trash").font(.system(size: 14)).foregroundColor(.textMuted) }
                    Button(action: { copyLogs() }) { Image(systemName: "doc.on.doc").font(.system(size: 14)).foregroundColor(.textMuted) }
                    Button(action: { showCommandHistory = true }) { Image(systemName: "clock.arrow.circlepath").font(.system(size: 14)).foregroundColor(.textMuted) }
                }
            }.padding(.horizontal, 16).padding(.vertical, 10).background(Color.terminalBg)
            Divider().background(Color.terminalBorder)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(viewModel.setupState.logs.enumerated()), id: \.offset) { index, log in
                            Text(log).font(.system(size: 11, design: .monospaced)).foregroundColor(logColor(for: log)).frame(maxWidth: .infinity, alignment: .leading).textSelection(.enabled).id(index)
                        }
                        if viewModel.setupState.isRunning {
                            HStack(spacing: 8) { Text("root@ola:~#").font(.system(size: 11, design: .monospaced)).foregroundColor(.textSecondary); Text("\(viewModel.setupState.currentStep?.title ?? "Working...")").font(.system(size: 11, design: .monospaced)).foregroundColor(.textMuted).italic() }.id(viewModel.setupState.logs.count)
                        }
                    }.padding(12)
                }.background(Color.terminalBg)
                .onChange(of: viewModel.setupState.logs.count) { _ in withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(viewModel.setupState.logs.count - 1, anchor: .bottom) } }
            }

            Divider().background(Color.terminalBorder)

            HStack(spacing: 8) {
                Text("root@ola:~#").font(.system(size: 12, design: .monospaced)).foregroundColor(.textSecondary).padding(.leading, 12)
                TextField("Enter command...", text: $command, onCommit: executeCommand).font(.system(size: 12, design: .monospaced)).foregroundColor(.textPrimary).textInputAutocapitalization(.never).disableAutocorrection(true).submitLabel(.go)
                Button(action: executeCommand) { Image(systemName: "arrow.up.circle.fill").font(.system(size: 22)).foregroundColor(command.isEmpty ? .textMuted : .accentMint) }.disabled(command.isEmpty).padding(.trailing, 12)
            }.padding(.vertical, 10).background(Color.terminalBg)
        }.background(Color.terminalBg)
        .sheet(isPresented: $showCommandHistory) { CommandHistoryView(history: commandHistory) { cmd in command = cmd; showCommandHistory = false } }
    }
    private func executeCommand() {
        let cmd = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cmd.isEmpty else { return }
        commandHistory.append(cmd)
        command = ""
        Task { await viewModel.runShellCommand(cmd) }
    }
    private func copyLogs() { let full = viewModel.setupState.logs.joined(separator: "\n"); UIPasteboard.general.string = full }
    private func logColor(for log: String) -> Color {
        if log.contains("[+]") || log.contains("SUCCESS") || log.contains("CONGRATULATIONS") { return .statusOk }
        else if log.contains("[!]") || log.contains("failed") || log.contains("ERROR") { return .statusDanger }
        else if log.contains("[*]") { return .accentSky }
        else { return .textPrimary }
    }
}
