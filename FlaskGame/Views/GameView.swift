import SwiftUI

struct GameView: View {
    @Environment(\.isPhone) private var isPhone
    @Environment(\.applicationName) private var applicationName
    
    @StateObject private var adController = AdController()
    @ObservedObject private var flaskController: FlaskController
    @ObservedObject private var settings: SettingsController
    
    @State private var selectedId: UUID? = nil
    @State private var presentedAlert: GameAlertType? = nil
    @State private var showSettings: Bool = false
    @State private var offsetWave: Bool = false
    
    private var nspace: Namespace.ID
    
    private let maxRowItems = 6
    private let maxRows = 4
    
    private let flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
    private var flaskWidth: CGFloat { flaskHeight / 4 }
    private var selectionOffset: CGFloat = 20
    
    init(flasks: FlaskController, settings: SettingsController, namespace: Namespace.ID) {
        self._settings = .init(wrappedValue: settings)
        self._flaskController = .init(wrappedValue: flasks)
        self.nspace = namespace
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    background
                        .ignoresSafeArea()
                    
                    let horizontalGridSpacing = geometry.size.width * 0.2 / Double(maxRowItems + 1)
                    let gridItemWidth = geometry.size.width * 0.75 / Double(maxRowItems)
                    
                    let verticalSpacing = geometry.size.height / 25
                    
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(
                                .fixed(gridItemWidth),
                                spacing: horizontalGridSpacing,
                                alignment: .center
                            ),
                            count: maxRowItems
                        ),
                        alignment: .center,
                        spacing: verticalSpacing
                    ) {
                        ForEach(flasks) { flaskLayout in
                            switch flaskLayout {
                            case let .flask(flask):
                                flaskView(for: flask)
                            case .spacer:
                                Spacer()
                            }
                        }
                    }
                    .navigationTitle(applicationName)
                    .navigationBarHidden(isPhone)
                    .toolbar {
                        ToolbarItemGroup(placement: isPhone ? .bottomBar : .automatic) {
                            toolbarContent
                        }
                    }
                    .labelStyle(.vertical(ordered: .iconThenTitle))
                }
            }
            .ignoresSafeArea()
            .alert(
                presentedAlert.localizedTitle,
                isPresented: $presentedAlert.isPresented,
                presenting: presentedAlert
            ) { alertType in
                if case .newGame = alertType {
                    ForEach(Difficulty.allCases, id: \.rawValue) { dif in
                        Button {
                            newGame(difficulty: dif)
                        } label: {
                            Text(dif.rawValue.capitalized)
                        }
                    }
                } else if case .restart = alertType {
                    Button("Restart", role: .destructive) { flaskController.restart() }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: { alertType in
                if case let .error(error) = alertType {
                    Text(error.localizedDescription)
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView(settings: settings)
                    .statusBar(hidden: inDebug)
            }
        }
        .modifier(FallingConfettiModifier(
            animate: settings.shouldAnimate,
            didWin: Binding { flaskController.didWinGame }
        ))
        .statusBar(hidden: inDebug)
        .task {
            startAnimation()
            
            do {
                adController.delegate = flaskController
                try await adController.refreshAd()
            } catch let error as AppError {
                await MainActor.run {
                    presentedAlert = .error(error)
                }
            } catch {}
        }
        .onChange(of: settings.shouldAnimate) { _ in
            startAnimation()
        }
    }
    
    private var background: Color {
        let def = settings.secondaryBackgroundColor
        
        guard settings.shouldAnimate,
              settings.backgroundMatchesFlask,
              let flask = flaskController.flask(with: selectedId)
        else { return def }
        
        return flaskController.flask(with: flaskController.pouringFlasks[flask.id])?.topColor?.color ?? flask.topColor?.color ?? def
    }
    
    private var toolbarContent: some View {
        HStack {
            let extraFlaskCurrentlyExist = flaskController.extraFlask != nil
            let adIsAvailable = adController.additionalFlaskAd != nil
            let presentedAlertIsAnError = presentedAlert.map { $0.isError } ?? false
            
            let showAdOption = !extraFlaskCurrentlyExist && adIsAvailable && !presentedAlertIsAnError
            
            Button {
                showSettings = true
            } label: {
                Label("Settings", systemImage: "gear.circle")
            }
            
            Spacer()
                .layoutPriority(showAdOption ? 0 : 1)
            
            Button {
                setId()
                presentedAlert = .restart
            } label: {
                Label("Restart", systemImage: "restart.circle")
            }
            
            Spacer()
                .layoutPriority(0)
            
            Button {
                presentedAlert = .newGame
            } label: {
                Label("New Game", systemImage: "plus.circle")
            }
            
            Spacer()
                .layoutPriority(0)
            
            Button {
                flaskController.undo()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward.circle")
            }
            
            Spacer()
                .layoutPriority(0)
            
            if showAdOption {
                Button {
                    do {
                        try adController.displayAd()
                    } catch {
                        nserror(error)
                    }
                } label: {
                    Label {
                        Text("Add Flask")
                    } icon: {
                        Image("new.flask")
                    }
                }
            }
        }
    }
    
    private func flaskView(for flask: Flask) -> some View {
        FlaskView(
            flask: flask,
            isSelected: selectedId == flask.id,
            offsetWave: $offsetWave
        )
        .offset(y: flask.id == selectedId ? -selectionOffset : 0)
        .matchedGeometryEffect(id: flask.id, in: nspace)
        .accessibilityLabel("\(selectedId == flask.id ? "Selected " : "")Flask. \(flask.colorsAccessibilityLabel)")
        .onTapGesture {
            flaskTapped(with: flask.id)
        }
    }
    
    private func flaskTapped(with id: UUID) {
        guard let selectedFlask = flaskController.flask(with: id) else { return }
        guard let previouslySelectedFlask = flaskController.flask(with: selectedId) else {
            setId(id)
            return
        }
        guard previouslySelectedFlask == selectedFlask || flaskController.dumpFlask(previouslySelectedFlask.id, into: selectedFlask.id) else { return }
        
        setId()
    }
    
    private func setId(_ id: UUID? = nil) {
        animate {
            selectedId = id
        }
    }
    
    private func newGame(difficulty: Difficulty) {
        setId()
        offsetWave = false
        
        flaskController.newGame(difficulty: difficulty)
        
        startAnimation()
    }
    
    private func startAnimation() {
        withAnimation(
            settings.shouldAnimate
                ? .easeInOut(duration: 2).repeatForever(autoreverses: true)
                : .linear(duration: 0)
        ) {
            offsetWave = settings.shouldAnimate
        }
    }
    
    private var flasks: [FlaskLayout] {
        let flasks = flaskController.flasks.values
            .sorted(by: { $0.id.uuidString > $1.id.uuidString })
        
        let overflow = flasks.count % maxRowItems
        
        if overflow == 0 {
            return flasks.map { .flask($0) }
        } else {
            let spacerCount = maxRowItems - overflow
            let firstOverflowHalf = spacerCount / 2
            let secondOverflowHalf = spacerCount - firstOverflowHalf
            
            let (flasksThatFit, flasksThatOverflow) = flasks.split(at: flasks.count - overflow)
            
            return flasksThatFit.map { .flask($0) }
                + (0..<firstOverflowHalf).map { .spacer($0) }
                + flasksThatOverflow.map { .flask($0) }
                + (firstOverflowHalf..<(firstOverflowHalf + secondOverflowHalf)).map { .spacer($0) }
        }
    }
}

enum FlaskLayout: Identifiable {
    case flask(Flask)
    case spacer(Int)
    
    var id: String {
        switch self {
        case let .flask(flask):
            return flask.id.uuidString
        case let .spacer(index):
            return "Spacer-\(index)"
        }
    }
}

#Preview {
    GameView(flasks: .init(), settings: .init(store: DummyStore()), namespace: Namespace().wrappedValue)
}
