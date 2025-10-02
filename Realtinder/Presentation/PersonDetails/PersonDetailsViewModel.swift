import Foundation

extension PersonDetailsView {
    @MainActor
    @Observable
    final class ViewModel {
        private let dependencies: Dependencies
        
        init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }
    }
}

extension PersonDetailsView.ViewModel {
    struct Dependencies {
        
    }
}
