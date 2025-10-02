# Realtinder

## Tech Stack ⚙️
Architecture: MVVM (Model-View-ViewModel) with Clean Architecture
Programming Language: Swift 6
Dependency Injection: My personal solution with a property wrapper
Persistence: Local storage with a JSON file

## Technical Choices 🛠️
The chosen architecture follows the MVVM pattern combined with Clean Architecture principles. This choice was made because:
- It is scalable and easy to maintain.
- It aligns with BeReal's current architecture.
- It ensures a separation of concerns, making the code more modular.

## Architecture Layers 🏗️
### Presentation Layer
Contains Views and ViewModels.

### Domain Layer
Contains UseCases, Entities and Repositories' protocols

### Data Layer:
Contains Repositories' implementations and DataSources.

## Feature List 📝
- Discovery screen implementation
- PersonDetails screen implementation
- Update data when a person is viewed nor liked
- Gesture handling for card person in discovery screen
- Local data persistence (to be implemented)

## Feature Prioritization 📊
The features are prioritized based on importance and development complexity:

1. Discovery screen implementation
2. PersonDetails screen implementation
3. Gesture handling for card person in discovery screen
4. Liked/Unliked and viewed state management
5. Local data persistence

## Implementation Steps
- Set up the base MVVM and Clean Architecture structure.
- Implement dependency injection.
- Define the necessary data structures and entities.
- Develop screens with mock data.
- Implement unit tests.
- Write documentation (including this README).

## Potential Improvements 🚀
- Implement Views and ViewModels.
- Add more unit tests to ensure code reliability and SwiftTest new Apple's framework>
- Create a DIConfig for previews and testing purposes.
- Improve dependency injection>
- Replace AsyncImage with image downloading and caching mechanism to improve performance.
- Implement local data persistence with a database instead of a JSON file.
- Integrate real data with APIs network calls.
- Continue layers separation by managing different models between layers, for example LocalEntity and RemoteEntity.
