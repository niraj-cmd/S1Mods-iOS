import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: ScooterViewModel
    @State private var showPackageSelection = false
    @State private var isStepsExpanded = true

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VehicleConnectionCard(viewModel: viewModel, isRunning: viewModel.setupState.isRunning)
                if let summary = viewModel.connectionState.vehicleSummary { MyScooterCard(summary: summary) }
                if viewModel.setupState.isRunning { RunningProgressCard(viewModel: viewModel, isStepsExpanded: $isStepsExpanded) }
                else if viewModel.setupState.isSuccess { SuccessBannerCard(viewModel: viewModel, showPackageSelection: $showPackageSelection) }
                else if let error = viewModel.setupState.errorMessage { ErrorBannerCard(viewModel: viewModel, error: error, showPackageSelection: $showPackageSelection) }
                else { IdleStartButton(showPackageSelection: $showPackageSelection) }
                SetupStepsAccordion(viewModel: viewModel, isExpanded: $isStepsExpanded, isRunning: viewModel.setupState.isRunning, isSuccess: viewModel.setupState.isSuccess)
                Spacer().frame(height: 100)
            }.padding(.horizontal, 16).padding(.top, 4)
        }.background(Color.bgDark)
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView(viewModel: viewModel, onStart: { showPackageSelection = false; Task { await viewModel.runFullSetup() } })
        }
    }
}
