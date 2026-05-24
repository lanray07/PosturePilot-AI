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
- Premium generated brand assets, app icons, and App Store preview posters

PosturePilot AI is not a medical device and does not provide medical advice, diagnosis, treatment, or injury prevention guarantees.

Remote AI calls should go through your backend:

```http
POST https://YOUR_BACKEND_URL.com/posturepilot-ai
```

Never store provider API keys in the iOS app bundle.

Brand assets can be regenerated with:

```bash
python Scripts/generate_brand_assets.py
```

App Store Connect screenshot sets can be regenerated with:

```bash
python Scripts/generate_app_store_screenshots.py
```

Submission form copy, legal pages, and App Store Connect field values live in:

```bash
AppStore/SubmissionForms.md
Legal/PrivacyPolicy.md
Legal/TermsOfUse.md
Legal/WellnessDisclaimer.md
```

Local safety checks:

```bash
python Scripts/scan_secrets.py
python Scripts/validate_app_store_metadata.py
```

GitHub Actions runs the same secret scan and an Xcode iOS Simulator build on macOS.
