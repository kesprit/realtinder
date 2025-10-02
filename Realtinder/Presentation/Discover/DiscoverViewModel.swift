import Foundation

extension DiscoverView {
    @MainActor
    @Observable
    final class ViewModel {
        private let dependencies: Dependencies
        
        init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }
    }
}

extension DiscoverView.ViewModel {
    struct Dependencies {
        
    }
}
