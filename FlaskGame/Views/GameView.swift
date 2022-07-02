import SwiftUI

struct GameView: View {
    @StateObject private var flaskController = FlaskController()
    
    @State private var selectedIndex: Int? = nil
    @State private var showAlert: Bool = false
    @State private var waveOffset: CGFloat = 0
    
    private var flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
    
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
            VStack {
                Spacer()
                    .layoutPriority(1)
                
                ForEach(flaskRows, id: \.1) { (arr, _) in
                    flaskRow(for: arr)
                    
                    Spacer()
                }
                
                Spacer()
                    .layoutPriority(1)
            }
            .overlayPreferenceValue(FlaskPreferenceKey.self, { anchor in
//                anchor
            })
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
            .alert("Select Difficulty", isPresented: $showAlert, actions: {
                ForEach(Difficulty.allCases, id: \.rawValue) { dif in
                    Button {
                        flaskController.newGame(difficulty: dif)
                    } label: {
                        Text(dif.rawValue.capitalized)
                    }
                }
            })
            .animation(.easeInOut(duration: 0.1), value: selectedIndex)
            .onAppear {
                waveOffset = 5
            }
        }
    }
    
    private func flaskView(for flask: Flask) -> some View {
        FlaskView(flask: flask, animationOffset: $waveOffset)
            .offset(y: flask.index == selectedIndex ? -20 : 0)
            .onTapGesture {
                flaskTapped(at: flask.index)
            }
            .anchorPreference(key: FlaskPreferenceKey.self, value: .bounds) { $0 }
            .animation(.easeInOut.repeatForever(autoreverses: false), value: waveOffset)
            .aspectRatio(0.25, contentMode: .fit)
    }
    
    private func flaskRow<Arr>(for flasks: Arr) -> some View where Arr: RandomAccessCollection, Arr.Element == Flask {
        HStack {
            ForEach(flasks) { flask in
                if flaskController.pouringFlasks[flask.id] == nil {
                    flaskView(for: flask)
                } else {
                    Spacer()
                }
            }
        }
        .frame(height: flaskHeight)
    }
    
    private func flaskTapped(at index: Int) {
        guard let selectedFlask = flaskController.flask(at: index) else { return }
        
        if let previouslySelectedFlask = flaskController.flask(at: selectedIndex) {
            if previouslySelectedFlask == selectedFlask {
                selectedIndex = nil
            } else {
                flaskController.dumpFlask(previouslySelectedFlask.index, into: selectedFlask.index)
                selectedIndex = nil
            }
        } else {
            selectedIndex = index
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
