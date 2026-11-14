import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ScooterViewModel()
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            if !viewModel.connectionState.isConnected && !viewModel.setupState.isRunning {
                ConnectVehicleScreen(viewModel: viewModel)
            } else {
                ConnectedContentView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showOnboarding) {
            OnboardingView(onComplete: { viewModel.completeOnboarding() })
        }
        .sheet(isPresented: $viewModel.showAbout) { AboutView() }
        .sheet(isPresented: $viewModel.showSettings) { SettingsView(viewModel: viewModel) }
        .onAppear { if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") { viewModel.showOnboarding = true } }
    }
}
