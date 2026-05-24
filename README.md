# PosturePilot AI

PosturePilot AI is a SwiftUI iOS wellness app scaffold for posture habits, desk ergonomics, focus sessions, movement reminders, and local analytics.

The app uses:

- SwiftUI `NavigationStack` and tab navigation
- MVVM screen state
- SwiftData local persistence
- StoreKit 2 subscription scaffolding
- Mock AI posture analysis enabled by default
- Camera, CoreMotion, WidgetKit, and Apple Watch placeholders
- Local notifications
- Swift Charts analytics

PosturePilot AI is not a medical device and does not provide medical advice, diagnosis, treatment, or injury prevention guarantees.

Remote AI calls should go through your backend:

```http
POST https://YOUR_BACKEND_URL.com/posturepilot-ai
```

Never store provider API keys in the iOS app bundle.
