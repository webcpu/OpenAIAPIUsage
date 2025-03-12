import Cocoa

// MARK: - AppDelegate - Minimal

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Create a coordinator that orchestrates everything
    private var coordinator: ApplicationCoordinator?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let tokenStorage = UserDefaultsTokenStorage()
        
        // Prepare fetchers for the aggregator
        let fetchers: [UsageFetcher] = [
            OpenAIUsageFetcher(tokenStorage: tokenStorage),
            AnthropicUsageFetcher(tokenStorage: tokenStorage)
        ]
        
        // Initialize main coordinator
        coordinator = ApplicationCoordinator(
            tokenStorage: tokenStorage,
            fetchers: fetchers
        )
        
        // Start the app’s core flow
        coordinator?.start()
    }
}
