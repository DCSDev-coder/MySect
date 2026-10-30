# MySect Platform — Comprehensive Presentation & Feature Walkthrough

**Author:** MySect Product & Engineering Team  
**Date:** October 2026  
**Document Purpose:** Presentation Guide & Plain-English Feature Reference  

---

## 1. Executive Summary: What is MySect?

**MySect** is an integrated corporate secretarial management platform designed for the Malaysian business ecosystem.

Historically, communication between business owners (Company Directors) and licensed Company Secretaries has been scattered across WhatsApp messages, untracked emails, and paper documents. This causes missed statutory filing deadlines, penalties from the Companies Commission of Malaysia (SSM), and compliance confusion.

MySect solves this by uniting three distinct user groups under one interconnected digital platform:
1. **The Client (Mobile App):** Business owners and directors who want easy, hassle-free compliance.
2. **The Secretary (Web Workspace):** Licensed company secretaries who need an organized desk to review documents and file with SSM.
3. **The Admin (HQ Console):** Platform operators who oversee firms, assign companies, and guarantee system security.

```
+---------------------------------------------------------------------------------+
|                                 MYSECT PLATFORM                                 |
+---------------------------------------------------------------------------------+
|                                                                                 |
|   +-----------------------+     +-----------------------+     +---------------+ |
|   | 1. CLIENT MOBILE APP  | <-> | 2. SECRETARY WORKSPACE| <-> | 3. SUPER ADMIN| |
|   | (Business Directors)  |     | (Licensed Secretaries)|     | (HQ Console)  | |
|   +-----------------------+     +-----------------------+     +---------------+ |
|     • View company status         • Review client files         • Verify firms  |
|     • Track SSM deadlines         • Approve / Query documents   • Transfer cos. |
|     • Upload documents            • Log SSM submissions         • Access control|
|     • Contact secretary           • Manage practice clients     • Audit trail   |
|                                                                                 |
+---------------------------------------------------------------------------------+
```

---

## 2. Platform 1: The Client Mobile App (`mobile_app`)
*Target User:* **SME Business Owners, Managing Directors, and Authorized Company Representatives.**  
*Primary Goal:* Remove the mystery of company compliance and allow directors to know their statutory standing in under 5 seconds.

```
+-----------------------------------------------------------------------+
|                         CLIENT MOBILE APP                             |
+-----------------------------------------------------------------------+
|  [Header: Company Switcher & Notifications]                           |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [1. HOME / DASHBOARD]                                           |  |
|  | • Company Health Badge ("Good Standing")                        |  |
|  | • Next Urgent Deadline Countdown (e.g., Annual Return in 18d)    |  |
|  | • Quick Action Cards (Pending Uploads, Waiting for Review)      |  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [2. COMPLIANCE CALENDAR]                                        |  |
|  | • Interactive monthly calendar showing statutory milestones    |  |
|  | • Section 68 Annual Return lodgement dates                      |  |
|  | • Section 248 Audited Financial Statements due date             |  |
|  | • CP204 Tax estimate reminder milestones                        |  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [3. DOCUMENT VAULT / REPOSITORY]                                |  |
|  | • Categorized Folders: Accounting, Corporate, Statutory         |  |
|  | • "Attention Needed" folder for flagged files                   |  |
|  | • Built-in file viewer & direct upload button                   |  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [4. STATUTORY FILING TRACKER]                                   |  |
|  | • Step-by-step submission wizard                                |  |
|  | • Live Progress Pill: "Waiting for Sec" -> "Approved" -> "SSM"|  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [5. PROFILE & SECRETARY CONTACT]                                |  |
|  | • Direct contact card of assigned Licensed Secretary            |  |
|  | • Practicing certificate info (MIA / MAICSA license no.)        |  |
|  +-----------------------------------------------------------------+  |
+-----------------------------------------------------------------------+
```

### Screen-by-Screen Breakdown:

### 2.1 Home & Dashboard
* **What it shows:** 
  * The selected company name, registration number, and SSM incorporation date.
  * A **Compliance Health Banner** that immediately reassures the director whether their company is in *"Good Standing"* or has an overdue obligation.
  * **Urgent Action Cards:** Clear notification badges such as *"1 File Needs to be Submitted"* or *"Waiting for Secretary Review"*.
* **Why it matters:** Business owners don't have time to read complex legal acts. This screen tells them immediately: *"Is my company safe today, or do I need to take action?"*

### 2.2 Compliance Calendar
* **What it shows:** 
  * An interactive visual calendar marking Malaysian statutory dates:
    1. **Section 68 Annual Return (AR):** Yearly renewal mandated by SSM.
    2. **Section 248 Financial Statements:** Audited/unaudited accounts circulation.
    3. **Section 58 Notices:** Changes in company officers (directors/secretaries).
    4. **CP204 Statutory Tax Schedule:** Inland Revenue Board (LHDN) tax estimate deadlines.
* **Why it matters:** Late filings with SSM result in compound fines starting at RM50 to thousands of ringgit. The calendar gives countdown badges (e.g., *"Due in 18 days"*) so deadlines are never missed.

### 2.3 Document Vault & Repository
* **What it shows:** 
  * A neat digital filing cabinet divided into four clear folders:
    * **Corporate:** Constitution, Form 9 (Certificate of Incorporation), Section 14 Superform.
    * **Statutory:** Lodged Annual Returns, Section 58 director registers, board resolutions.
    * **Accounting:** Audited accounts, tax computation reports.
    * **Attention Needed:** Documents that the secretary reviewed and requested revisions or re-signatures on.
* **Why it matters:** Directors no longer need to dig through messy email threads or WhatsApp attachments when a bank or auditor requests their corporate records.

### 2.4 Statutory Filing Tracker (Transactions)
* **What it shows:** 
  * A visual progress tracker for every request submitted to the secretary:
    1. `Uploaded` $\rightarrow$ Customer sent the file.
    2. `In Review` $\rightarrow$ Licensed secretary is checking legal validity.
    3. `More Info Needed` $\rightarrow$ Secretary requested clarification or re-upload.
    4. `Certified & Approved` $\rightarrow$ Secretary approved the statutory paperwork.
    5. `Lodged with SSM` $\rightarrow$ Official SSM lodgement complete with reference receipt.
* **Why it matters:** Complete transparency. Clients can track their progress 24/7 without having to call or message the secretary.

### 2.5 Secretary Contact & Profile
* **What it shows:** 
  * Name and contact information of the assigned licensed company secretary (e.g., *Lim Mei Ling - MIA CA 48192*).
  * Direct office phone, registered address, and official firm name.
* **Why it matters:** Gives peace of mind that an authorized, qualified practitioner is handling their company.

---

## 3. Platform 2: The Secretary Workspace (`mysect_secretary`)
*Target User:* **Licensed Company Secretaries (MIA, MAICSA, LS) and Corporate Secretarial Firm Staff.**  
*Primary Goal:* Provide an efficient, error-free operational desk to manage client filings, review incoming files, and maintain practice compliance.

```
+---------------------------------------------------------------------------------------+
|                             SECRETARY WORKSPACE (WEB)                                 |
+---------------------------------------------------------------------------------------+
|  [Header: MySect Logo | Active Firm: SectPro Corporate Services | Secretary Profile]  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | [1. OPERATIONS DASHBOARD]                                                       |  |
|  | • Metrics: Active Assigned Companies (24) | Pending Review (3) | SSM Lodged (19) |  |
|  | • Urgent Action Queue: Highest-priority client documents waiting for vetting    |  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | [2. CLIENT DOCUMENT REVIEW QUEUE]                                               |  |
|  | • Filter by: Pending Review | Clarification Needed | Approved | Rejected         |  |
|  | • Document Details View: Document metadata, client remarks, file preview        |  |
|  | • Action Bar: [Approve & Certify] or [Request More Details / Clarification]     |  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | [3. CLIENT COMPANIES PORTFOLIO]                                                 |  |
|  | • Master table of all assigned businesses                                       |  |
|  | • Health status, paid-up capital, director roster, and next statutory due date  |  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | [4. STATUTORY FILING & LODGEMENT LOG]                                           |  |
|  | • SSM reference numbers, MBRS lodgement receipts, and submission dates          |  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | [5. FIRM SUBSCRIPTION & 2FA SECURITY]                                           |  |
|  | • Active plan tier (Starter, Growth, Pro, Enterprise) & company quota limits    |  |
|  | • 6-digit statutory 2-Factor Authentication (2FA) sign-in                       |  |
|  +---------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------+
```

### Screen-by-Screen Breakdown:

### 3.1 Operations Dashboard
* **What it shows:** 
  * High-level practice counters: Total companies managed, pending document reviews, approved lodgements, and upcoming annual filing deadlines.
  * An **Urgent Queue** highlighting client submissions that need immediate attention.
* **Why it matters:** Company secretaries manage dozens or hundreds of client companies simultaneously. This dashboard acts as their morning briefing, preventing tasks from slipping through the cracks.

### 3.2 Client Document Review Queue
* **What it shows:** 
  * A dedicated inbox showing all documents uploaded by client directors.
  * Secretary tools:
    * **File Preview:** Direct on-screen document inspection.
    * **Approve & Certify Button:** Marks the document as legally sound and moves the workflow forward.
    * **Request More Details Button:** Sends an instant clarification prompt back to the client’s mobile app (e.g., *"Please provide signed Director's Circular Resolution"*).
* **Why it matters:** Eliminates messy email chains. Every review decision, approval, and clarification request is recorded with a clear timestamp.

### 3.3 Client Companies Portfolio Tab
* **What it shows:** 
  * The complete list of businesses assigned to the firm.
  * Key data points per company: SSM Registration Number, Company Type (Sdn Bhd), Paid-Up Capital, Registered Address, Active Directors, and upcoming statutory filing dates.
* **Why it matters:** Replaces bulky paper physical statutory registers with an instantly searchable, cloud-backed company directory.

### 3.4 Statutory Filing & Lodgement Tracker
* **What it shows:** 
  * The history of all filings submitted to SSM (Annual Returns, Form 58, Share Allocations).
  * Records the official SSM lodgement transaction number, date filed, and filing officer name.
* **Why it matters:** Provides definitive proof of timely submission in case of an SSM compliance audit.

### 3.5 Firm Profile, Subscription & 2FA Security
* **What it shows:** 
  * The firm's practicing credentials (e.g., MIA / MAICSA registration).
  * Current platform plan tier (*Starter, Growth, Professional, Enterprise*) and company quota usage.
  * **2-Factor Authentication (2FA):** 6-digit OTP verification protecting client corporate secrets.
* **Why it matters:** Ensures bank-grade security and statutory data protection in compliance with the Personal Data Protection Act 2010 (PDPA).

---

## 4. Platform 3: The Super Admin Platform Console (`mysect_admin`)
*Target User:* **MySect HQ Platform Administrators, Operations Heads, and System Auditors.**  
*Primary Goal:* Maintain overall platform governance, onboard trusted secretarial practices, allocate companies, and ensure legal and regulatory compliance.

```
+---------------------------------------------------------------------------------------+
|                             SUPER ADMIN CONSOLE (WEB)                                 |
+---------------------------------------------------------------------------------------+
|  [Sidebar Navigation]              [Main Operating Workspace]                        |
|                                                                                       |
|  1. Overview                       +-----------------------------------------------+  |
|  2. Users & Access                 | [OVERVIEW DASHBOARD]                          |  |
|  3. Secretary Firms                | • Total Companies: 34  • Active Firms: 3      |  |
|  4. Companies                      | • Pending Verifications: 2  • System Health: OK| |
|  5. Operations & Issues            +-----------------------------------------------+  |
|  6. Plans & Settings                                                                  |
|                                    +-----------------------------------------------+  |
|                                    | [USERS & ACCESS CONTROL (RBAC)]               |  |
|                                    | • Operator, Secretary & Client directory      |  |
|                                    | • Toggle Active/Suspended status • Reset 2FA  |  |
|                                    | • Complete Audit Trail of user activities     |  |
|                                    +-----------------------------------------------+  |
|                                                                                       |
|                                    +-----------------------------------------------+  |
|                                    | [SECRETARY FIRMS GOVERNANCE]                  |  |
|                                    | • Practice vetting & certificate verification |  |
|                                    | • Approve, Suspend, or Reactivate partner firm|  |
|                                    +-----------------------------------------------+  |
|                                                                                       |
|                                    +-----------------------------------------------+  |
|                                    | [COMPANY PORTFOLIO & ASSIGNMENTS]             |  |
|                                    | • Assign client company to partner firm       |  |
|                                    | • Inter-firm company transfer with audit notes|  |
|                                    +-----------------------------------------------+  |
|                                                                                       |
|  [Operator Profile: AF]            +-----------------------------------------------+  |
|  [Log Out Button]                  | [OPERATIONS: ESCALATIONS & ANNOUNCEMENTS]     |  |
|                                    | • Overdue lodgement monitor • Support disputes|  |
|                                    | • System-wide broadcast announcements         |  |
|                                    +-----------------------------------------------+  |
+---------------------------------------------------------------------------------------+
```

### Screen-by-Screen Breakdown:

### 4.1 Overview Dashboard
* **What it shows:** 
  * Live platform vitals: Total active client companies, onboarded secretarial practices, pending firm verifications, and urgent unresolved issues.
  * System operational status and storage telemetry.
* **Why it matters:** Gives MySect HQ executive visibility into how the platform is performing across Malaysia in real time.

### 4.2 Users & Access Control (RBAC)
* **What it shows:** 
  * Master user directory categorized by role: Super Admin, Compliance Lead, Licensed Secretary, and Client Director.
  * User security controls:
    * **Status Toggle:** Instantly activate or suspend user accounts if unauthorized behavior is detected.
    * **Reset 2FA:** Dispatches one-time recovery codes to users locked out of their accounts.
    * **Audit History:** Full log of every sign-in, IP address, and role change.
* **Why it matters:** Enforces strict role-based data isolation so unauthorized personnel can never view private company data.

### 4.3 Secretary Firms Governance
* **What it shows:** 
  * Onboarding queue for new secretarial firms applying to join the MySect network.
  * **Licence Verification:** Displays practicing certificates (MIA / MAICSA registration numbers) for admin verification.
  * **Governance Controls:** 1-click actions to *Approve*, *Suspend*, or *Reactivate* a partner firm based on compliance standing.
* **Why it matters:** Guarantees that only legally qualified, certified company secretaries are permitted to handle client company affairs.

### 4.4 Companies & Firm Assignment
* **What it shows:** 
  * Master catalog of all registered Malaysian companies on the platform.
  * **Assignment Engine:** Assigns each company to an authorized secretary firm.
  * **Inter-Firm Transfer:** If a client switches secretaries, the admin can smoothly transfer the company portfolio to a new firm while logging statutory reasons for the handover.
* **Why it matters:** Prevents orphaned companies and ensures every business has an accountable secretarial team at all times.

### 4.5 Operations & Issues
* **What it shows:** 
  * **Escalations & Overdue:** Automatically flags any filing approaching statutory deadline danger zones.
  * **Support & Disputes:** Facilitates resolution if a client and secretary have an operational dispute.
  * **Announcements & Notices:** Broadcasts urgent statutory notices (e.g., SSM system maintenance or tax deadline extensions) to all platform users.
* **Why it matters:** Keeps the network running smoothly and proactively prevents late-filing fines.

### 4.6 Plans & Platform Settings
* **What it shows:** 
  * Subscription plan configurations (*Starter, Growth, Professional, Enterprise*).
  * Company quotas per firm (e.g., Professional plan allows up to 250 client companies).
* **Why it matters:** Powers the commercial and business model of MySect.

---

## 5. Quick Comparison Table: Who Uses What?

| Feature / Capability | Client App (Mobile) | Secretary Workspace (Web) | Super Admin (Console) |
| :--- | :---: | :---: | :---: |
| **Primary User** | Company Director / Owner | Licensed Secretary / Staff | MySect HQ Management |
| **Primary Device** | Smartphone (iOS / Android) | Laptop / Desktop / Tablet | Desktop / Laptop |
| **Check Compliance Health** | Yes (Own company only) | Yes (All assigned clients) | Yes (Platform-wide) |
| **Upload Documents** | Yes (Direct upload) | Yes (Drafts & resolutions) | No (Privacy isolated) |
| **Review & Approve Documents** | Approves drafted paperwork | Vets & certifies client files | No (Legal boundary) |
| **File with SSM** | Initiates request | Prepares & lodges filing | Monitors completion |
| **Onboard New Secretary Firms** | No | No | Yes (Reviews credentials) |
| **Assign Companies to Firms** | No | No | Yes (Full assignment engine) |
| **Security & Authentication** | Email & Password | 2FA Statutory Code | 2FA Statutory Code |
| **Audit Log Visibility** | Own company history | Assigned firm cases | Complete immutable audit log |

---

## 6. Three-Minute Presentation Script (Presenter Cheatsheet)

Use this script during your demo or slide presentation:

> **[Slide 1 — The Problem & Solution]**  
> *"Good morning everyone. Managing corporate secretarial compliance in Malaysia has traditionally been messy—chasing missing documents over WhatsApp, lost paper files, and surprise SSM compound penalties. MySect changes that by connecting Directors, licensed Secretaries, and Platform Administrators on one unified system."*

> **[Slide 2 — The Client Mobile App]**  
> *"First, for business owners, we have the **MySect Mobile App**. In just 5 seconds, a director can open the app, see their compliance health score, view an interactive calendar counting down their next Annual Return deadline, and upload documents securely. No legal jargon—just clear status updates from upload to official SSM lodgement."*

> **[Slide 3 — The Secretary Workspace]**  
> *"Second, for licensed company secretaries, we built the **Secretary Workspace**. Running smoothly on web and mobile browsers, it gives secretaries a centralized inbox of incoming client documents. With one click, they can approve paperwork or request clarification. They can also manage their entire company portfolio, track filing reference numbers, and log in securely with 2-Factor Authentication."*

> **[Slide 4 — The Super Admin Console]**  
> *"Finally, overseeing everything is the **Super Admin Console**. This is MySect HQ's governance hub. Admins verify practicing certificates to ensure only qualified secretaries join, allocate companies between firms, control user permissions, and monitor overdue escalations across the entire country with an immutable audit trail."*

> **[Slide 5 — Conclusion & Release Status]**  
> *"All three products are feature-complete, deployed live on `mysect.my`, and fully responsive across both mobile and desktop screens. MySect delivers transparency for directors, efficiency for secretaries, and governance for platform operators. Thank you!"*

---

*Document compiled for MySect Project Documentation & Stakeholder Presentation.*
