# MySect 90-Second Pitch Video Script & Storyboard
**Using the Current Client Mobile App (`mobile_app`) & Secretary/Admin Web Portal (`admin_website`)**

- **Target Duration:** 75–90 seconds
- **Target Audience:** Potential Business Partners, Licensed Company-Secretary Firms, and Investors
- **Core Message:** *MySect replaces scattered WhatsApp messages and lost email attachments with one connected platform—combining a simple Client Mobile App, a structured Secretary Firm Workspace, and central Admin governance.*

---

## Pre-Recording Setup & Pro-Tips for the Current UI

Before hitting record on your screen capture tool (e.g., QuickTime / OBS / Screen Studio), keep these three tips in mind so your current UI prototype matches your **MySect App Build Blueprint** seamlessly:

1. **Best Client Screens to Feature:**
   - **Splash & Intro / Login:** `loading_screen.dart` → `intro_1.dart` → `login_page.dart`
   - **Home Top Section (Company Switcher & Action Cards):** `home_page.dart` (Focus on the **Company Dropdown**, **Documents Needed**, and **Replies Needed** cards at the top).
   - **SSM Statutory Request Flow:** `transactions_page.dart` → `submit_ssm_filing_page.dart` → `ssm_filing_detail_page.dart` (This already has real Malaysian **Companies Act 2016** workflows: *Section 68 Annual Return*, *Section 58 Director Change*, *Section 46 Registered Address Change*).
   - **Document Vault & Attention Folder:** `files_page.dart` → `attention_page.dart` / `corporate_page.dart` → `document_viewer_page.dart`
   - **Client–Secretary Chat:** `chat_page.dart` → `active_chat_page.dart`
2. **Bonus "Wow" Moment (Split-Screen):**
   - Open `admin_website` (`SecretaryWorkspace.jsx` and `Dashboard.jsx`) alongside the mobile simulator in Scene 5 and Scene 6. Showing a document or SSM request submitted on the phone appearing in the Secretary's Web Workspace immediately proves the multi-product platform vision.
3. **What to Skip or Scroll Past in the Current Prototype:**
   - Avoid zooming in on the bottom calendar items in `home_page.dart` that currently have placeholder *"IRAS / ACRA / GST"* text, and skip the bookkeeping/eCommerce screens (`Shopify/Amazon` in `more_page.dart`) so the pitch stays 100% focused on **Malaysian Company-Secretarial & SSM Compliance**.

---

## Scene-by-Scene Storyboard & Voiceover Script (90 Seconds)

| Scene & Time | Visual / Screen Recording Action | On-Screen Caption (Text Overlay) | Voiceover (VO) Script |
| :--- | :--- | :--- | :--- |
| **Scene 1: The Hook & Problem**<br>*(0:00 – 0:12)*<br>**12 sec** | • Start with the animated **MySect Logo Loader** (`loading_screen.dart`) transitioning into the **Onboarding / Login screen** (`intro_1.dart` → `login_page.dart`).<br>• Smoothly sign in to land on the **Client Home Screen** (`home_page.dart`). | **Company-Secretarial Work Shouldn't Live in Scattered WhatsApp Chats.**<br>*Introducing MySect — Your Digital Secretary Platform* | *"For Malaysian business owners and company-secretary firms, managing statutory compliance is still stuck in scattered WhatsApp messages, lost email attachments, and endless manual chasing. MySect changes that."* |
| **Scene 2: Multi-Company Clarity at a Glance**<br>*(0:12 – 0:25)*<br>**13 sec** | • On `home_page.dart`, tap the **Company Switcher dropdown** at the top (*Data Center Specialists Sdn Bhd* → switch/view companies).<br>• Highlight the two action cards: **"Documents Needed"** and **"Replies Needed"** (`document_needed_page.dart` / `replies_needed_page.dart`). | **One App for Every Company You Own.**<br>*Instant visibility into pending actions & deadlines* | *"With the MySect Customer App, directors managing one or multiple Sdn Bhd companies see everything that needs their attention in five seconds—which documents are needed, which replies are pending, and what deadlines are coming up."* |
| **Scene 3: Guided Request & Case Creation**<br>*(0:25 – 0:42)*<br>**17 sec** | • Tap into **Chat / Ask MySect** (`chat_page.dart` → `active_chat_page.dart`) to show a guided question, **then** tap the **SSM Filing / Request screen** (`submit_ssm_filing_page.dart`).<br>• Select **"Section 58 Notice of Director Change"** or **"Section 68 Annual Return"**, showing how the app automatically lists the **Required Documents checklist** (*Form 48A, Director NRIC, Board Resolution*) and tap **Submit**. | **Structured Intake — No More Incomplete Requests.**<br>*Guided checklists for Section 58, Section 68 & Corporate Changes* | *"Instead of vague messages, every request starts with guided intake. Whether a client needs a Section 58 Director Change or an Annual Return, MySect confirms the company, prompts for the exact required documents, and packages a complete case for their Secretary."* |
| **Scene 4: Tracked Document Vault & Sign-Off**<br>*(0:42 – 0:57)*<br>**15 sec** | • Navigate to the **Files tab** (`files_page.dart`).<br>• Tap the **"Attention"** badge (`attention_page.dart`) and **"Corporate"** folder (`corporate_page.dart`).<br>• Open a prepared PDF/resolution in `document_viewer_page.dart` and show the status tracking in `ssm_filing_detail_page.dart`. | **Centralised Document Vault & Formal Approvals.**<br>*Every draft, upload, and approval timestamped in one place* | *"Every corporate document, board resolution, and approval lives in a secure, company-isolated vault. Clients can see exactly which items need their signature or re-upload, with every action timestamped for a clean audit trail."* |
| **Scene 5: Seamless Handoff to the Secretary Firm**<br>*(0:57 – 1:15)*<br>**18 sec** | • **Split-Screen View:** Keep the Flutter **Client App** (`ssm_filing_detail_page.dart` / `active_chat_page.dart`) on the left, and show the **Secretary Workspace Web App** (`SecretaryWorkspace.jsx` in `admin_website`) on the right.<br>• Click **Approve / Review Document** on the web portal and show the status updating back on the client mobile app. | **AI Prepares the Case. Licensed Secretaries Stay in Control.**<br>*Connected in real time to the Partner Secretary Workspace* | *"Behind the scenes, partner company-secretary firms receive a pre-organised case in their dedicated web workspace. Licensed secretaries accept ownership, open direct human conversation when needed, review documents, and complete the work in half the time."* |
| **Scene 6: Central Admin Governance & Closing Call to Action**<br>*(1:15 – 1:30)*<br>**15 sec** | • Briefly cut to the **MySect Admin Dashboard** (`Dashboard.jsx` & `SecretaryFirms.jsx` in `admin_website`) showing active partner firms, assigned companies, and audit logs.<br>• End on a clean closing title card with the **MySect Logo** and tagline: *"MySect — Your Secretary Company"*. | **One Shared Platform. Three Role-Specific Products.**<br>*Customer App • Secretary Workspace • MySect Admin* | *"Backed by MySect Admin for multi-firm onboarding, company assignment, and full audit governance, MySect connects clients and company secretaries on one trusted platform. Let's build the future of corporate secretarial services together."* |

---

## Quick 5-Minute Recording Checklist

1. **Launch the Client Mobile App (`mobile_app`)** in the iOS Simulator (iPhone 15 Pro / 16 Pro frame looks best for pitch videos):
   ```bash
   cd /Users/marketingdeveloper/DCStack_Development/MySect/mobile_app
   flutter run
   ```
2. **Launch the Secretary & Admin Web Portal (`admin_website`)** in Chrome for the Scene 5 & 6 split-screen:
   ```bash
   cd /Users/marketingdeveloper/DCStack_Development/MySect/admin_website
   npm run dev
   ```
3. **Record in 6 Short Clips (12–18 seconds each):**
   - Don't try to record all 90 seconds in one single take. Record **Scene 1 to Scene 6** as 6 separate screen recordings following the table above, then drop them into CapCut, iMovie, Final Cut, or Canva with the On-Screen Captions and Voiceover.
