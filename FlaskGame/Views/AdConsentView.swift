import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import UserMessagingPlatform

struct AdConsentView: View {
    @Binding private var disclosureStage: TrackingDisclosureStage
    @State private var errorMessage: String?
    
    init(disclosureStage: Binding<TrackingDisclosureStage>) {
        self._disclosureStage = disclosureStage
    }
    
    var body: some View {
        ZStack {
            if disclosureStage != .complete {
                Color.primaryBackground.ignoresSafeArea()
            }
            
            if let errorMessage = errorMessage {
                ErrorView(message: errorMessage) {
                    // Skip to complete on error
                    disclosureStage = .complete
                }
            } else if disclosureStage.isATT {
                ATTDetailView(showingProgressView: disclosureStage == .presentingATTAuth) {
                    handleATTRequest()
                }
            } else if disclosureStage.isUMP {
                UMPDetailView(showingProgressView: disclosureStage == .presentingUMPAuth) {
                    handleUMPRequest()
                }
            }
        }
        .task {
            await initializeConsentFlow()
        }
    }
    
    private func initializeConsentFlow() async {
        // Initialize UMP configuration
        let parameters = UMPRequestParameters()
        
        #if DEBUG
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["71375547-3974-4961-88AA-8C69A4BE9CFD"]
        debugSettings.geography = .EEA // Test as if in Europe
        parameters.debugSettings = debugSettings
        #endif
        
        do {
            try await UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters)
        } catch {
            nslog("UMP consent info update failed: \(error)")
        }
    }
    
    private func handleATTRequest() {
        disclosureStage = .presentingATTAuth
        
        Task {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            nslog("ATT authorization status: \(status.rawValue)")
            
            // Check if UMP consent is required
            if UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required {
                disclosureStage = .displayingUMPInformation
            } else {
                disclosureStage = .complete
            }
        }
    }
    
    private func handleUMPRequest() {
        disclosureStage = .presentingUMPAuth
        
        Task {
            do {
                guard let viewController = UIApplication.shared.rootViewController else {
                    throw AppError.noData("No root view controller available")
                }
                
                try await UMPConsentForm.loadAndPresentIfRequired(from: viewController)
                disclosureStage = .complete
            } catch {
                nslog("UMP consent form error: \(error)")
                errorMessage = "Privacy consent configuration error. Continuing without consent form."
                
                // Wait a moment then proceed
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    disclosureStage = .complete
                }
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Configuration Notice")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Continue") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ATTDetailView: View {
    let showingProgressView: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "eye.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Data Usage")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("To support free gameplay, we use ads that may track activity to deliver more relevant content. You can choose whether to allow tracking.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                onNext()
            } label: {
                HStack {
                    Spacer()
                    
                    if showingProgressView {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(showingProgressView)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct UMPDetailView: View {
    let showingProgressView: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Privacy Settings")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("To keep this game free, we show ads tailored to your interests using anonymous data. Your privacy choices help us ensure relevant advertising and comply with regulations.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                onNext()
            } label: {
                HStack {
                    Spacer()
                    
                    if showingProgressView {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Review Privacy Options")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(showingProgressView)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    AdConsentView(disclosureStage: .constant(.displayingATTInformation))
}

