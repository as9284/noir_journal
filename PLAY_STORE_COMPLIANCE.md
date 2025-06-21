# Google Play Store Content Guidelines Checklist for Noir Journal

## ✅ COMPLIANT AREAS

### Privacy & Security

- [x] Strong local encryption (PBKDF2)
- [x] No data collection/transmission
- [x] Biometric authentication
- [x] Screenshot protection
- [x] Secure backup system

### Permissions

- [x] Minimal permission requests
- [x] Justified biometric permissions
- [x] Storage permissions for backup only

### Functionality

- [x] Core journaling functionality works
- [x] No illegal content capabilities
- [x] Age-appropriate design

## ⚠️ REQUIRED ACTIONS

### 1. CRITICAL - Privacy Policy & Terms

- [x] Created privacy_policy.md (template)
- [x] Created terms_of_service.md (template)
- [x] Added in-app URL redirects to online policies
- [x] Host policies on public website (GitHub Pages)
- [x] Update URL constants in settings_sections.dart
- [ ] Add privacy policy URL to Play Console

### 2. Store Listing Content

- [ ] Write appropriate app description
- [ ] Set correct content rating (likely Everyone)
- [ ] Add screenshots without sensitive content
- [ ] Choose appropriate app category

### 3. Content Rating

**Recommended Rating: Everyone**

- No violent content
- No sexual content
- No substances
- No gambling
- User-generated content (journal entries) - mention this

### 4. App Description Guidelines

**Suggested Description:**
"Noir Journal - Privacy-Focused Digital Diary

A minimalistic journaling app designed with privacy as the core principle. All your thoughts and memories stay on your device, encrypted and secure.

KEY FEATURES:
• Complete Privacy - No cloud storage, no data collection
• Strong Encryption - Military-grade local encryption
• Biometric Security - Fingerprint/Face unlock
• Mood Tracking - Track your emotional journey
• Export Control - Create encrypted backups when you choose
• Dark Theme - Easy on the eyes
• Offline Only - Works completely offline

PRIVACY FIRST:
Your journal entries are encrypted and stored only on your device. No accounts, no tracking, no ads. You control your data completely.

Perfect for personal reflection, daily thoughts, gratitude journaling, and private memories."

## IMMEDIATE TODO:

1. ~~Host privacy policy and terms on a website~~ ✅ COMPLETED
2. ~~Update URL constants in lib/widgets/settings_sections.dart:~~ ✅ COMPLETED
   - ~~Replace 'https://your-website.com/privacy-policy' with actual URL~~ ✅ Now: https://as9284.github.io/noir-privacy/
   - ~~Replace 'https://your-website.com/terms-of-service' with actual URL~~ ✅ Now: https://as9284.github.io/noir-tos/
3. Update privacy policy URL in Play Console
4. Add developer contact information
5. Test URL opening functionality before release
