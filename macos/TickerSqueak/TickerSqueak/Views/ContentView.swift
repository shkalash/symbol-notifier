import SwiftUI

/// The main internal view of the application.
struct ContentView_Content: View {
    
    @StateObject private var viewModel = ContentViewModel()
   
    private let dependencies: any AppDependencies

    init(dependencies: any AppDependencies) {
        self.dependencies = dependencies
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main navigation tab picker
            IconTabPicker(selection: $viewModel.selectedTab, options: [
                PickerOption(label: "Pre-Market", imageName: "sunrise", tag: 0),
                PickerOption(label: "Tickers", imageName: "chart.bar", tag: 1),
                PickerOption(label: "Trade Ideas", imageName: "lightbulb.fill", tag: 2),
                PickerOption(label: "Hidden List", imageName: "timer", tag: 3),
                PickerOption(label: "Snooze List", imageName: "moon.zzz", tag: 4),
                PickerOption(label: "Ignore List", imageName: "eye.slash", tag: 5),
                PickerOption(label: "Settings", imageName: "gearshape", tag: 6),
            ])
            
            Divider()

            switch viewModel.selectedTab {
            case 0:
                PreMarketChecklistView_Content(dependencies: dependencies)
            
            case 1:
                    TickerListView_Content(
                        dependencies: dependencies,
                        onTickerClicked: { ticker in
                            dependencies.chartingService.open(ticker: ticker)
                        },
                        onOpenTradeIdea: { ticker in
                            dependencies.appCoordinator.requestNavigation(toTicker: ticker)
                            viewModel.selectedTab = 2
                        }
                    )
            case 2:
                TradeIdeasListView_Content(dependencies: dependencies)
            case 3:
                HiddenTickersView_Content(dependencies: dependencies)
            case 4:
                SnoozeListView_Content(dependencies: dependencies)
            case 5:
                IgnoreListView_Content(dependencies: dependencies)
            case 6:
                SettingsView_Content(dependencies: dependencies)
                    .padding(.top , 3)
                    .padding(.horizontal, 5)
            default:
                EmptyView()
            }
        }
    }
}


/// The public-facing "loader" view for use in the live application.
struct ContentView: View {

    @EnvironmentObject private var dependencies: DependencyContainer
    @EnvironmentObject private var dialogManager: DialogManager

    var body: some View {
        ContentView_Content(dependencies: dependencies)
        .sheet(item: $dialogManager.currentDialog) { dialogInfo in
            DialogView(dialogInfo: dialogInfo)
        }
        .withToasts()
    }
}

#Preview {

    let previewDependencies = PreviewDependencyContainer()
    
    return ContentView_Content(dependencies: previewDependencies)
        .environmentObject(previewDependencies)
        .frame(width:600, height: 400)
}
