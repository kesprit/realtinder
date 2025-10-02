import SwiftUI

struct DiscoverView: View {
    @State private var viewModel: ViewModel = .init(dependencies: .init())

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.pink.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    headerView
                    Spacer()
                    cardStackContent
                    Spacer()
                    actionButtons
                }
                .padding()
            }
            .sheet(item: $viewModel.selectedPerson) { person in
                PersonDetailsView(
                    person: person,
                    personState: viewModel.personStates[person.id]
                )
                .onDisappear {
                    Task {
                        await viewModel.refreshPersonState(personId: person.id)
                    }
                }
            }
            .task(viewModel.loadInitialPersons)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundColor(.pink)
            Text("Discover")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.top)
    }

    private var cardStackContent: some View {
        ZStack {
            if viewModel.persons.isEmpty && !viewModel.isLoading {
                Text("No more profiles")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                ForEach(
                    Array(viewModel.persons.prefix(2).enumerated()),
                    id: \.element.id
                ) { index, person in
                    PersonCardView(
                        person: person,
                        personState: viewModel.personStates[person.id],
                        onSwipe: { direction in
                            Task {
                                await viewModel.handleSwipe(person: person, direction: direction)
                            }
                        },
                        onTap: {
                            viewModel.selectedPerson = person
                            Task {
                                await viewModel.markAsSeen(person: person)
                            }
                        },
                        isTopCard: index == .zero
                    )
                    .zIndex(Double(1 - index))
                    .offset(y: index == 1 ? 10 : 0)
                    .scaleEffect(index == 1 ? 0.95 : 1.0)
                    .opacity(index == 1 ? 0.7 : 1.0)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: 600
        )
        .animation(
            .spring(response: 0.3, dampingFraction: 0.8),
            value: viewModel.persons.count
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 40) {
            Button {
                guard let firstPerson = viewModel.persons.first else { return }
                Task {
                    await viewModel.handleSwipe(
                        person: firstPerson,
                        direction: .left
                    )
                }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.red)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 5)
            }

            Button {
                guard let firstPerson = viewModel.persons.first else { return }
                Task {
                    await viewModel.handleSwipe(
                        person: firstPerson,
                        direction: .right
                    )
                }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 5)
            }
        }
        .padding(20)
    }
}

#Preview {
    DiscoverView()
}
