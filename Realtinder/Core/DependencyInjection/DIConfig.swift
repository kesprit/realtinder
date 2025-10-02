import Foundation

final class DIConfig {
    static func configure(container: DIContainerProtocol = DIContainer.shared) {
        // Core
        configureCore(container: container)
        
        // Data Sources
        configureDataSources(container: container)
        
        // Repositories
        configureRepositories(container: container)
        
        // Use Cases
        configureUseCases(container: container)
    }
    
    // MARK: - Private configuration methods
    
    private static func configureCore(container: DIContainerProtocol) { }
    
    private static func configureDataSources(container: DIContainerProtocol) {
        container
            .register(type: RemotePersonDataSource.self, component: MockRemotePersonDataSource())
        container
            .register(type: LocalPersonStateDataSource.self, component: LocalPersonStateDataSourceImpl())
    }
    
    private static func configureRepositories(container: DIContainerProtocol) {
        container.register(type: PersonRepository.self, component: PersonRepositoryImpl())
    }
    
    private static func configureUseCases(container: DIContainerProtocol) {
        container
            .register(type: FetchPersonsUseCase.self, component: FetchPersonsUseCaseImpl())
        container
            .register(type: GetPersonStateUseCase.self, component: GetPersonStateUseCaseimpl())
        container
            .register(type: UpdatePersonStateUseCase.self, component: UpdatePersonStateUseCaseImpl())
    }
}

@propertyWrapper
struct Injection<Value> {
    var wrappedValue: Value {
        DIContainer.shared.resolve(type: Value.self)
    }
}
