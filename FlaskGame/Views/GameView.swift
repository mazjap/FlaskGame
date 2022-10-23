import SwiftUI

struct GameView: View {
    @Environment(\.isPhone) private var isPhone
    @Environment(\.applicationName) private var applicationName
    
    @StateObject private var adController = AdController()
    @ObservedObject private var flaskController: FlaskController
    @ObservedObject private var settings: SettingsController
    
    @State private var selectedId: UUID? = nil
    @State private var showNewGameAlert: Bool = false
    @State private var alertError: AppError? = nil
    @State private var showSettings: Bool = false
    @State private var offsetWave: Bool = false
    
    private var nspace: Namespace.ID
    
    private let maxRowItems = 6
    private let maxRows = 4
    
    private let flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
    private var flaskWidth: CGFloat { flaskHeight / 4 }
    private var selectionOffset: CGFloat = 20
    
    private var flaskRows: [([Flask], Set<UUID>)] {
        let flasks = flaskController.flasks.values
        
        let rowCount = minmax(
            1,
            maxRows,
            flasks.count / maxRowItems + (
                flasks.count % maxRowItems == 0
                    ? 0
                    : 1
            )
        )
        
        let rowLimit = (flasks.count / rowCount) + (
            flasks.count % rowCount == 0
                ? 0
                : 1
        )
        
        return flasks
            .sorted(by: { $0.id.uuidString > $1.id.uuidString })
            .enumerated()
            .reduce(
                into: Array(
                    repeating: [Flask](),
                    count: rowCount
                ), { arr, flask in
                    arr[flask.offset / rowLimit].append(flask.element)
                }
            )
            .map {
                (
                    $0,
                    $0.reduce(
                        into: Set<UUID>(),
                        { $0.insert($1.id) }
                    )
                )
            }
    }
    
    private var background: Color {
        let def = settings.secondaryBackgroundColor
        
        guard settings.shouldAnimate,
              settings.backgroundMatchesFlask,
              let flask = flaskController.flask(with: selectedId)
        else {
            return def
        }
        
        return flaskController.flask(with: flaskController.pouringFlasks[flask.id])?.topColor?.color ?? flask.topColor?.color ?? def
    }
    
    init(flasks: FlaskController, settings: SettingsController, namespace: Namespace.ID) {
        self._settings = .init(wrappedValue: settings)
        self._flaskController = .init(wrappedValue: flasks)
        self.nspace = namespace
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                background
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                        .layoutPriority(1)
                    
                    ForEach(flaskRows, id: \.1) { (arr, _) in
                        flaskRow(for: arr)
                        
                        Spacer()
                            .frame(minHeight: selectionOffset * 1.25)
                    }
                    
                    Spacer()
                        .layoutPriority(1)
                }
                .padding(.horizontal, 20)
                .navigationTitle(applicationName)
                .navigationBarHidden(isPhone)
                .toolbar {
                    ToolbarItemGroup(placement: isPhone ? .bottomBar : .automatic) {
                        HStack {
                            let showAdOption = flaskController.extraFlask == nil && adController.additionalFlaskAd != nil && alertError == nil
                            
                            Button {
                                showSettings = true
                            } label: {
                                Label("Settings", systemImage: "gear.circle")
                            }
                            
                            Spacer()
                                .layoutPriority(showAdOption ? 0 : 1)
                            
                            Button {
                                flaskController.undo()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward.circle")
                            }
                            
                            Spacer()
                                .layoutPriority(0)
                            
                            Button {
                                showNewGameAlert = true
                            } label: {
                                Label("New Game", systemImage: "plus.circle")
                            }
                            
                            Spacer()
                                .layoutPriority(0)
                            
                            Button {
                                setId()
                                flaskController.restart()
                            } label: {
                                Label("Restart", systemImage: "restart.circle")
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
                }
                .labelStyle(.vertical(ordered: .iconThenTitle))
            }
            .ignoresSafeArea()
            .alert("Select Difficulty", isPresented: $showNewGameAlert, actions: {
                ForEach(Difficulty.allCases, id: \.rawValue) { dif in
                    Button {
                        newGame(difficulty: dif)
                    } label: {
                        Text(dif.rawValue.capitalized)
                    }
                }
                
                Button(role: .cancel) {
                    showNewGameAlert = false
                } label: {
                    Text("Cancel")
                }
            })
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView(settings: settings)
                    .statusBar(hidden: inDebug)
            }
        }
        .navigationViewStyle(.stack)
        .modifier(FallingConfettiModifier(animate: settings.shouldAnimate, didWin: Binding { flaskController.didWinGame }))
        .statusBar(hidden: inDebug)
        .task {
            adController.delegate = flaskController
            adController.asyncRefreshAd { error in
                nserror(error)
                guard let error = error as? AppError else { return }
                alertError = error
            }
            startAnimation()
        }
        .onChange(of: settings.shouldAnimate) { _ in
            startAnimation()
        }
    }
    
    private func flaskView(for flask: Flask) -> some View {
        let aspectRatio: Double = {
            switch flask {
            case .tiny:
                return 1
            case .normal:
                return 0.25
            }
        }()
        
        return FlaskView(flask: flask, offsetWave: $offsetWave, defaultBackground: settings.secondaryBackgroundColor)
            .offset(y: flask.id == selectedId ? -selectionOffset : 0)
            .matchedGeometryEffect(id: flask.id, in: nspace)
            .aspectRatio(aspectRatio, contentMode: .fit)
    }
    
    private func flaskRow(for flasks: [Flask]) -> some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                ForEach(flasks) { flask in
                    flaskView(for: flask)
                        .accessibilityLabel("\(selectedId == flask.id ? "Selected " : "")Flask. \(flask.colorsAccessibilityLabel)")
                        .onTapGesture {
                            flaskTapped(with: flask.id)
                        }
                        .frame(maxWidth: geometry.size.width / Double(maxRowItems + 1))
                    
                    Spacer()
                }
            }
        }
        .frame(height: flaskHeight)
    }
    
    private func flaskTapped(with id: UUID) {
        guard let selectedFlask = flaskController.flask(with: id) else { return }
        guard let previouslySelectedFlask = flaskController.flask(with: selectedId) else {
            setId(id)
            return
        }
        
        if previouslySelectedFlask == selectedFlask {
            setId()
        } else {
            if flaskController.dumpFlask(previouslySelectedFlask.id, into: selectedFlask.id) {
                setId()
            }
        }
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
}

struct FlaskPreferenceKey: PreferenceKey {
    static var defaultValue: [Anchor<CGRect>] = []
        
    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(flasks: .init(), settings: .init(store: DummyStore()), namespace: Namespace().wrappedValue)
    }
}
