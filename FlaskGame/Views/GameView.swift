import SwiftUI

struct GameView: View {
    @StateObject private var flaskController = FlaskController()
    
    @State private var selectedIndex: Int? = nil
    @State private var showAlert: Bool = false
    @State private var offsetWave: Bool = false
    
    private var flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.secondaryBackground
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
                .overlayPreferenceValue(FlaskPreferenceKey.self) { preferences in
                    GeometryReader { geometry in
                        if let fromFlask = flaskController.flask(at: selectedIndex),
                           let toFlask = flaskController.flask(with: flaskController.pouringFlasks[fromFlask.id]) {
                            preferences.map {
                                flaskView(for: fromFlask)
                                    .frame(
                                        width: geometry[$0].width,
                                        height: geometry[$0].height
                                    )
                                    .offset(
                                        x: geometry[$0].minX,
                                        y: geometry[$0].minY
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .navigationTitle((Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? "Flask Me The Salt")
                .navigationBarHidden(true)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            
                            Button {
                                flaskController.undo()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward.circle")
                            }
                            
                            Button {
                                showAlert = true
                            } label: {
                                Label("New Game", systemImage: "plus.app")
                            }
                            
                            Button {
                                selectedIndex = nil
                                flaskController.restart()
                            } label: {
                                Label("Restart", systemImage: "restart.circle")
                            }
                        }
                        .labelStyle(.vertical(ordered: .iconThenTitle))
                    }
                }
                .modifier(WinViewModifier(didWin: Binding { flaskController.didWinGame }))
                .alert("Select Difficulty", isPresented: $showAlert, actions: {
                    ForEach(Difficulty.allCases, id: \.rawValue) { dif in
                        Button {
                            newGame(difficulty: dif)
                        } label: {
                            Text(dif.rawValue.capitalized)
                        }
                    }
                })
            }
        }
        .task {
            newGame(difficulty: .easy)
        }
    }
    
    private func flaskView(for flask: Flask) -> some View {
        FlaskView(flask: flask, offsetWave: $offsetWave)
            .offset(y: flask.index == selectedIndex ? -selectionOffset : 0)
            .aspectRatio(0.25, contentMode: .fit)
    }
    
    private func flaskRow<Arr>(for flasks: Arr) -> some View where Arr: RandomAccessCollection, Arr.Element == Flask {
        HStack {
            ForEach(flasks) { flask in
                flaskView(for: flask)
                    .onTapGesture {
                        flaskTapped(at: flask.index)
                    }
                    .opacity(flaskController.pouringFlasks[flask.id] == nil ? 1 : 0)
                    .anchorPreference(key: FlaskPreferenceKey.self, value: .bounds) {
                        guard let selectedIndex = selectedIndex,
                              let selectedFlask = flaskController.flask(at: selectedIndex),
                              let receivingUUID = flaskController.pouringFlasks[selectedFlask.id],
                              flask.id == receivingUUID
                        else {
                            return nil
                        }
                        
                        return $0
                    }
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(height: flaskHeight)
    }
    
    private func flaskTapped(at index: Int) {
        guard let selectedFlask = flaskController.flask(at: index) else { return }
        
        if let previouslySelectedFlask = flaskController.flask(at: selectedIndex) {
            if previouslySelectedFlask == selectedFlask {
                setIndex()
            } else {
                flaskController.dumpFlask(previouslySelectedFlask.index, into: selectedFlask.index)
                
                setIndex()
            }
        } else {
            setIndex(index)
        }
    }
    
    private func setIndex(_ index: Int? = nil) {
        animate {
            selectedIndex = index
        }
    }
    
    private func newGame(difficulty: Difficulty) {
        flaskController.newGame(difficulty: difficulty)
        offsetWave = false
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            offsetWave = true
        }
    }
}

struct FlaskPreferenceKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
        
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
