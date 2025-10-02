import Foundation

enum DIError: Error {
    case componentNotRegistered(String)
    case componentTypeMismatch(String)
    
    var localizedDescription: String {
        switch self {
        case .componentNotRegistered(let type):
            return "No component registered for type: \(type)"
        case .componentTypeMismatch(let type):
            return "Component type mismatch for type: \(type)"
        }
    }
}

protocol DIContainerProtocol: Sendable {
    func register<T>(type: T.Type, component: Any)
    func resolve<T>(type: T.Type) -> T
    func resolveOptional<T>(type: T.Type) -> T?
    func tryResolve<T>(type: T.Type) throws -> T
}

final class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()
    
    private init() {}
    
    private let lock = NSLock()
    private var components: [String: Any] = [:]
    
    func register<T>(type: T.Type, component: Any) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        components[key] = component
    }
    
    func resolve<T>(type: T.Type) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        guard let component = components[key] as? T else {
            fatalError("No component registered for type: \(key)")
        }
        return component
    }
    
    func resolveOptional<T>(type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        return components[key] as? T
    }
    
    func tryResolve<T>(type: T.Type) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        guard let component = components[key] else {
            throw DIError.componentNotRegistered(key)
        }
        
        guard let typedComponent = component as? T else {
            throw DIError.componentTypeMismatch(key)
        }
        
        return typedComponent
    }
}
