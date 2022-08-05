import SwiftUI

struct GameView: View {
    @Environment(\.isPhone) private var isPhone
    @Environment(\.applicationName) private var applicationName
    
//    @StateObject private var adController = AdController()
    @ObservedObject private var flaskController: FlaskController
    @ObservedObject private var settings: SettingsController
    
    @State private var selectedIndex: Int? = nil
    @State private var showAlert: Bool = false
    @State private var showSettings: Bool = false
    @State private var offsetWave: Bool = false
    
    private var nspace: Namespace.ID
    
    private let flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
    private var flaskWidth: CGFloat { flaskHeight / 4 }
    private var selectionOffset: CGFloat = 20
    
    private var flaskRows: [([Flask], Set<UUID>)] {
        let maxRowItems = 6
        let maxRows = 5
        
        let rowCount = minmax(
            1,
            maxRows,
            flaskController.flasks.count / maxRowItems + (
                flaskController.flasks.count % maxRowItems == 0
                    ? 0
                    : 1
            )
        )
        
        let rowLimit = (flaskController.flasks.count / rowCount) + (
            flaskController.flasks.count % rowCount == 0
                ? 0
                : 1
        )
        
        return flaskController.flasks
            .reduce(into: Array(repeating: [Flask](), count: rowCount), { arr, flask in
                arr[flask.index / rowLimit].append(flask)
            })
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
              let flask = flaskController.flask(at: selectedIndex)
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
//                .overlayPreferenceValue(FlaskPreferenceKey.self) { preferences in
//                    GeometryReader { geometry in
//                        ForEach(preferences, id: \.self) { anchor in
//                            if let fromFlask = flaskController.flask(at: selectedIndex), let anchor = preferences.last {
//                                let (width, height, dx, dy, rotation): (CGFloat, CGFloat, CGFloat, CGFloat, Angle) = {
//                                    let percentageComplete = min(1, Double(fromFlask.colors.count) / 4)
//                                    let items = (
//                                        geometry[anchor].width,
//                                        geometry[anchor].height,
//                                        geometry[anchor].minX - 30,
//                                        geometry[anchor].minY + 100,
//                                        Angle.degrees(90 * percentageComplete)
//                                    )
//                                    print(items)
//
//                                    return items
//                                }()
//    //                            flaskView(for: fromFlask)
//                                Color.red
//                                    .frame(
//                                        width: width,
//                                        height: height
//                                    )
//                                    .offset(
//                                        x: dx,
//                                        y: dy
//                                    )
//                                    .rotationEffect(rotation)
//                                    .zIndex(2)
//                            }
//                        }
//                    }
//                }
                .padding(.horizontal, 20)
                .navigationTitle(applicationName)
                .navigationBarHidden(isPhone)
                .toolbar {
                    ToolbarItemGroup(placement: isPhone ? .bottomBar : .automatic) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear.circle")
                        }
                        
                        HStack {
                            Button {
                                flaskController.undo()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward.circle")
                            }
                            
                            Button {
                                showAlert = true
                            } label: {
                                Label("New Game", systemImage: "plus.circle")
                            }
                            
                            Button {
                                selectedIndex = nil
                                flaskController.restart()
                            } label: {
                                Label("Restart", systemImage: "restart.circle")
                            }
                            
//                            Button {
//                                do {
//                                    try adController.displayAd()
//                                } catch {
//                                    nserror(error)
//                                }
//                            } label: {
//                                Label {
//                                    Text("New Flask")
//                                } icon: {
//                                    HStack {
//                                        Image(systemName: "plus")
//                                        FlaskShape()
//                                            .aspectRatio(0.25, contentMode: .fit)
//                                    }
//                                }
//                            }
                            
                            if !isPhone {
                                Spacer()
                            }
                        }
                    }
                }
                .labelStyle(.vertical(ordered: .iconThenTitle))
            }
            .ignoresSafeArea()
            .alert("Select Difficulty", isPresented: $showAlert, actions: {
                ForEach(Difficulty.allCases, id: \.rawValue) { dif in
                    Button {
                        newGame(difficulty: dif)
                    } label: {
                        Text(dif.rawValue.capitalized)
                    }
                }
                
                Button(role: .cancel) {
                    showAlert = false
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
        .modifier(WinViewModifier(animate: settings.shouldAnimate, didWin: Binding { flaskController.didWinGame }))
        .statusBar(hidden: inDebug)
        .task {
            startAnimation()
        }
        .onChange(of: settings.shouldAnimate) { _ in
            startAnimation()
        }
    }
    
    private func flaskView(for flask: Flask) -> some View {
        FlaskView(flask: flask, offsetWave: $offsetWave, defaultBackground: settings.secondaryBackgroundColor)
            .offset(y: flask.index == selectedIndex ? -selectionOffset : 0)
            .matchedGeometryEffect(id: flask.id, in: nspace)
    }
    
    private func flaskRow<Arr>(for flasks: Arr) -> some View where Arr: RandomAccessCollection, Arr.Element == Flask {
        HStack {
            Spacer()
            
            ForEach(flasks) { flask in
                GeometryReader { _ in
//                    if flaskController.pouringFlasks[flask.id] == nil {
                        flaskView(for: flask)
                            .accessibilityLabel("Flask \(flask.index) \(selectedIndex == flask.index ? "selected" : ""). \(flask.colorsAccessibilityLabel)")
                            .onTapGesture {
                                flaskTapped(at: flask.index)
                            }
//                            .anchorPreference(key: FlaskPreferenceKey.self, value: .bounds) {
//                                guard let selectedIndex = selectedIndex,
//                                      let selectedFlask = flaskController.flask(at: selectedIndex),
//                                      let receivingUUID = flaskController.pouringFlasks[selectedFlask.id],
//                                      flask.id == receivingUUID
//                                else {
//                                    return []
//                                }
//
//                                return [$0]
//                            }
//                    } else {
//                        Spacer()
//                    }
                }
                .frame(width: flaskWidth)
                
                Spacer()
            }
        }
        .frame(height: flaskHeight)
    }
    
    private func flaskTapped(at index: Int) {
        guard let selectedFlask = flaskController.flask(at: index) else { return }
        guard let previouslySelectedFlask = flaskController.flask(at: selectedIndex) else {
            setIndex(index)
            return
        }
        
        if previouslySelectedFlask == selectedFlask {
            setIndex()
        } else {
            if flaskController.dumpFlask(previouslySelectedFlask.index, into: selectedFlask.index) {
                setIndex()
            }
        }
    }
    
    private func setIndex(_ index: Int? = nil) {
        animate {
            selectedIndex = index
        }
    }
    
    private func newGame(difficulty: Difficulty) {
        selectedIndex = nil
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
