# MySect App Build Blueprint
**Customer Mobile App, Secretary Firm Website, and MySect Admin Website**  
*Confirmed application scope, user journeys, screen inventory, information flow, architecture, and 3-month (12-week) delivery roadmap*

---

## Executive Summary & Core Decision

> **Executive Decision:** Build one shared platform powering three role-specific products. The first release (Phase 1 MVP, delivered in 12 weeks) proves one complete, end-to-end service workflow: **guided customer intake → Secretary case handling → document exchange → formal customer approval → case completion → Admin oversight.**

### Why MySect? (The Business Problem We Solve)
Today, communication between company owners and company-secretary firms is scattered across WhatsApp chats, emails, and manual document follow-ups. Customers struggle to track request statuses, while secretary staff spend hours chasing missing information and managing repetitive inquiries.

**MySect** replaces fragmented communication with a single, structured digital platform:
1. **For Customers (Company Owners & Directors):** A simple mobile app to view their companies, ask questions through a guided Digital Assistant, upload documents, and approve resolutions in one place.
2. **For Company-Secretary Firms:** A dedicated web workspace where incoming requests arrive pre-packaged with company context and missing-information checklists—allowing licensed secretaries to focus on professional execution rather than manual chasing.
3. **For MySect Platform Operators (Admin):** A central management portal to onboard partner secretary firms, assign companies, monitor service quality, and maintain a complete audit trail.

### Document Purpose & Scope Discipline
This blueprint defines the confirmed **3-month application build scope**. To keep engineering focused and avoid premature assumptions, it deliberately excludes unconfirmed vendor pricing, legal conclusions, direct government-system (SSM/MBRS) submission, subscription fee structures, external e-KYC providers, and cloud-service quotations until confirmed with business and legal partners.

---

## 1. The Three Connected Products

All three products run on **one shared backend and database**. Every action, document, and message is strictly controlled by user role, company authorisation, secretary-firm assignment, and case ownership.

| Product | Primary Users | Platform Type | Core Purpose |
| :--- | :--- | :--- | :--- |
| **1. Customer App** | Company owners, directors, and authorised representatives | Mobile Application (Flutter — iOS & Android) | View company details, submit guided requests via *Ask MySect*, upload documents, approve prepared items, and track progress. |
| **2. Secretary Website** | Partner company-secretary firms (Managers & Staff) | Responsive Web Application (Desktop & Tablet) | Receive structured cases prepared by the Digital Assistant, manage firm work queues, communicate with clients, and complete requests. |
| **3. MySect Admin Website** | MySect internal operations and support team | Responsive Web Application | Onboard and manage secretary firms, assign companies to firms, oversee escalated cases, configure rules, and audit platform activity. |

---

## 2. User Roles & Responsibilities

| Role | Who They Are | What They Can Do in MySect |
| :--- | :--- | :--- |
| **2.1 Customer** | Business owner, director, or authorised company contact | • View only the companies they are authorised to represent.<br>• Start requests and ask questions via the **Ask MySect** Digital Assistant.<br>• Track live request statuses and respond to information requests.<br>• Upload supporting documents and review/approve prepared documents.<br>• Receive push/email notifications and communicate with the assigned Secretary once a case chat is opened. |
| **2.2 Secretary Staff** | Licensed secretaries and operational staff at a partner firm | • View only companies and cases assigned to their firm (and permitted by their role).<br>• Receive structured cases prepared by the Digital Assistant.<br>• Accept ownership of a case and open direct human conversation with the customer.<br>• Request missing information or documents, upload prepared drafts, and request customer approval.<br>• Record internal notes, update case statuses, and mark work as completed. |
| **2.3 Secretary Firm Manager** | Partner or team lead at a company-secretary firm | • Manage firm staff accounts, roles, and access permissions.<br>• Assign managed companies and incoming cases to specific staff members.<br>• Monitor team workload, urgent items, and tracked deadlines.<br>• Manage firm templates, service settings, and operational reports. |
| **2.4 MySect Administrator** | MySect platform operations and support team | • Create, onboard, and manage partner Secretary Firms.<br>• Manage platform users, roles, and access permissions.<br>• Assign or transfer companies to partner Secretary Firms.<br>• Review escalated cases, support issues, and failed notifications.<br>• Configure service categories, notification templates, Digital Assistant intake rules, and audit logs. |

---

## 3. How Information Moves Through MySect (Core Workflows)

### 3.1 The "Ask MySect" Guided Intake Rule (AI Prepares, Humans Decide)
A critical design principle of MySect is that **customers cannot open unstructured human chat threads at random**. Instead:
1. **Digital Assistant Intake First:** Every new customer question or service request starts in **Ask MySect**. The Digital Assistant confirms which company the request belongs to, identifies the request type and urgency, and asks structured follow-up questions to collect missing details and files.
2. **Structured Case Handover:** Once intake is complete, the backend packages the conversation, company context, and uploaded files into a structured **Case** and alerts the assigned Secretary Firm.
3. **Human Secretary Control:** An assigned Secretary reviews the prepared summary, accepts ownership of the case, and—when needed—opens a dedicated human conversation thread with the customer. All professional advice, document preparation, approvals, and completion remain 100% controlled by the human Secretary.

### 3.2 End-to-End Customer Request Workflow (10 Steps)
1. **Customer Initiates:** Customer opens *Ask MySect* in the mobile app and asks a question or requests a service.
2. **Context Confirmation:** The app confirms the target company and classifies the request type.
3. **Guided Follow-Up:** The Digital Assistant asks structured follow-up questions to gather any missing information or supporting files.
4. **Case Creation:** The shared backend creates a structured Case record with an issue summary and checklist.
5. **Firm Notification:** The assigned Secretary Firm receives an immediate notification in their workspace.
6. **Case Ownership:** A Secretary staff member accepts and takes ownership of the case.
7. **Human Conversation (If Required):** The Secretary opens a direct human chat inside the case to clarify details with the customer.
8. **Document & Approval Exchange:** The Secretary requests documents or uploads prepared drafts; the customer uploads files or approves/rejects items inside the case.
9. **Case Completion:** The Secretary finalises the work and marks the case as completed.
10. **Final Record:** The Customer receives a completion notification and can view the full status, documents, and audit history at any time.

### 3.3 Company Assignment Workflow
1. **Company Setup:** MySect Admin creates or confirms a company record on the platform.
2. **Firm Assignment:** MySect Admin assigns the company to an active partner Secretary Firm.
3. **Staff Allocation:** The Secretary Firm Manager assigns responsible staff members to the company.
4. **Customer Linking:** Authorised customer representatives are linked to the company record.
5. **Audit Logging:** Every assignment and permission grant is permanently recorded in the audit history.

### 3.4 Document & Approval Workflow
1. **Secretary Action:** The Secretary either requests a required document from the customer or uploads a prepared document (e.g., draft resolution or form) for customer sign-off.
2. **Customer Alert:** The Customer receives a real-time notification in the mobile app.
3. **Customer Decision:** The Customer uploads the requested file, or reviews the prepared document and selects **Approve** or **Reject** (with a mandatory reason if rejected).
4. **Immutable Record:** The system records the exact action, user identity, and timestamp.
5. **Status Update:** The case status automatically updates for both the Customer and the Secretary.

---

## 4. Product 1: Customer Mobile App Pages

The Customer App is designed for clarity and ease of use on mobile devices, hiding internal processing complexity behind simple action items and clear statuses.

| App Section | Key Screens & Features | Business Purpose |
| :--- | :--- | :--- |
| **3.1 Access** | • Welcome & onboarding<br>• Sign in & Registration<br>• Password recovery<br>• Account verification | Securely authenticate company owners and verify their identity before showing company records. |
| **3.2 Home** | • Company summary switcher<br>• Open requests overview<br>• Items requiring customer action<br>• Important reminders & recent notifications | Give busy directors an immediate 5-second view of what needs their attention today. |
| **3.3 My Companies** | • Authorised company list & overview<br>• Company contacts<br>• Assigned Secretary Firm profile<br>• Company-specific requests, documents, and approvals | Allow customers who own multiple businesses to view each company's records and assigned secretary cleanly. |
| **3.4 Ask MySect** | • Start a question with the Digital Assistant<br>• Select or confirm the company<br>• Answer structured follow-up questions<br>• Upload supporting files<br>• Review issue summary & submit for Secretary attention | Turn vague customer questions into complete, structured service requests before they reach a human secretary. |
| **3.5 Requests** | • Request list & detailed view<br>• Live status & required information checklist<br>• Activity history & assigned Secretary<br>• Human conversation thread (once opened by Secretary) | Provide full transparency on request progress and keep all case communication in one place. |
| **3.6 Documents & Approvals** | • Company document list<br>• Upload requested documents<br>• View prepared documents & approval requests<br>• Approve or reject with a reason<br>• Full approval history | Replace lost email attachments with tracked document uploads and formal, timestamped customer approvals. |
| **3.7 Notifications & Profile** | • Notification centre<br>• Personal profile details<br>• Security & privacy settings<br>• Help and support | Let users manage their account security, notification preferences, and platform support. |

---

## 5. Product 2: Secretary Website Pages

The Secretary Website is a desktop-first operational workspace built for partner company-secretary firms to manage multiple client companies and staff efficiently.

| Workspace Module | Key Screens & Features | Operational Benefit for the Firm |
| :--- | :--- | :--- |
| **4.1 Access** | • Staff sign in<br>• Password recovery<br>• Additional security verification | Protect sensitive multi-company statutory records with strong staff authentication. |
| **4.2 Dashboard** | • New customer requests prepared by the Digital Assistant<br>• Assigned work summary<br>• Urgent and overdue cases<br>• Items waiting for customer info or approval<br>• Recent activity feed | Answer at a glance: *Which company needs action, what is urgent, and what is blocked by the client?* |
| **4.3 New Customer Requests** | • New incoming case queue<br>• AI-prepared issue summary & request category/urgency<br>• Company and customer context<br>• Missing-information checklist<br>• Actions: Accept, Assign, or Return for more information | Eliminate manual triage—staff review a pre-organised case summary and immediately assign or accept it. |
| **4.4 Work Queue** | • All firm cases in one filterable table<br>• Filters by owner, company, status, priority, and due date<br>• Bulk case assignment<br>• Quick status updates & internal notes | Give staff and managers complete control over daily workload across dozens or hundreds of companies. |
| **4.5 Case Workspace** | • Customer request summary & AI intake transcript<br>• Human conversation panel with the customer<br>• Internal staff-only notes<br>• Requested information, documents, and approvals<br>• Activity timeline & completion details | Everything needed to execute a case on a single screen—no switching between WhatsApp, email, and folders. |
| **4.6 Companies** | • Managed company list & company overview<br>• Customer contacts, directors/officers, and shareholders summary<br>• Assigned firm staff<br>• Full history of company requests, documents, and activity | Maintain a clean, up-to-date digital file for every client company assigned to the firm. |
| **4.7 Calendar & Team** | • Tracked compliance and work deadlines<br>• Work reminders<br>• Team members, roles, and access levels<br>• Staff workload view & assignment rules | Prevent missed deadlines and balance work evenly across the firm's secretarial staff. |
| **4.8 Firm Settings** | • Secretary Firm profile<br>• Staff account management<br>• Service categories & standard templates<br>• Notification preferences & security settings | Allow each partner firm to configure its own team structure, templates, and operational preferences. |

---

## 6. Product 3: MySect Admin Website Pages

The MySect Admin Website gives the platform operator central visibility and control over the network of secretary firms, client companies, and system rules without interfering in day-to-day professional secretarial judgment.

| Admin Module | Key Screens & Features | Platform Governance Purpose |
| :--- | :--- | :--- |
| **5.1 Dashboard** | • Active Secretary Firms & active companies count<br>• Open escalations & support cases<br>• Failed notifications alert<br>• Recent administrator activity | Monitor overall platform health, service bottlenecks, and operational alerts in real time. |
| **5.2 Secretary Firms** | • Partner firm directory<br>• Create, onboard, and edit firm profiles<br>• Firm active/suspended status<br>• Firm staff accounts, assigned companies, and operational history | Onboard new company-secretary partners smoothly and track each firm's portfolio. |
| **5.3 Companies & Assignments** | • Master company list & details<br>• Assign or transfer a company between Secretary Firms<br>• Authorised customer contacts & access review<br>• High-level case and document activity | Ensure every client company is cleanly mapped to a responsible Secretary Firm and authorised customer users. |
| **5.4 Users & Access** | • Customer, Secretary, and Administrator user directories<br>• Role and permission management<br>• Account status controls (active/suspended)<br>• Sign-in and access history | Enforce strict role-based security and troubleshoot user access issues quickly. |
| **5.5 Cases & Support** | • Platform-wide case search<br>• Escalated cases & customer support tickets<br>• Case assignment correction<br>• Service issue history | Help resolve disputes, reassign misrouted cases, and maintain high service standards across partner firms. |
| **5.6 Configuration & Audit** | • Service categories & standard case statuses<br>• Notification templates<br>• Digital Assistant intake question rules<br>• Feature switches, system activity, and full audit history | Adjust platform workflows and intake rules centrally without code changes, backed by a complete audit trail. |

---

## 7. Technical Architecture, Data Model & Security Rules

### 7.1 Four-Layer Application Architecture

| Layer | Confirmed Implementation Scope |
| :--- | :--- |
| **1. Frontend Applications** | • **Customer Mobile App:** Built with **Flutter** for cross-platform iOS and Android delivery.<br>• **Secretary Website:** Responsive web application optimised for desktop workflows.<br>• **MySect Admin Website:** Responsive web application for internal platform administration. |
| **2. Shared Backend Services** | • Central authentication and role-based access control.<br>• Company, firm, and staff assignment management.<br>• Case lifecycle and human conversation management.<br>• Document exchange, versioning, and customer approval workflows.<br>• Multi-channel notifications, Digital Assistant intake coordination, audit logging, and reporting. |
| **3. Data & Integration Adapters** | • **Application Database:** Stores all structured records (users, companies, assignments, cases, approvals, audit logs).<br>• **File-Storage Adapter:** Handles uploaded and generated documents cleanly.<br>• **Notification Adapter:** Connects to email, push notifications, or other approved channels.<br>• **Provider-Neutral Digital Assistant Adapter:** Allows the underlying AI model provider to be swapped or upgraded without rebuilding the application workflow. |
| **4. Deployment & Hosting** | • Hosted on the **existing Windows Server** environment using agreed containerised services.<br>• Strict separation between **Development**, **Testing**, and **Production** databases, file storage, and secrets.<br>• Automated backup and restore procedures verified before live pilot use. |

### 7.2 Core Data Records (15 Foundational Entities)
Every business record in the database is tagged with the **Company** and **Responsible Organisation (Secretary Firm)** so access permissions are enforced consistently at every layer:
- **Identity & Organisations:** `User`, `Role`, `Secretary Firm`, `Company`, `Company User`
- **Assignments:** `Firm Assignment` (Company ↔ Firm), `Staff Assignment` (Company/Case ↔ Staff)
- **Case & Communication:** `Case`, `Case Message` (Customer/AI/Secretary chat), `Internal Note` (Staff-only)
- **Documents, Approvals & Governance:** `Document Record`, `Document Version`, `Approval Request`, `Notification`, `Audit Event`

### 7.3 Strict Access & Data Isolation Rules
1. **Customer Isolation:** A Customer can view and interact *only* with companies they are explicitly authorised to access.
2. **Firm Isolation:** Secretary staff can view *only* companies and cases assigned to their specific Secretary Firm, filtered further by their staff role.
3. **Admin Scope:** MySect Admin access is restricted by administrator role permissions.
4. **Document Protection:** Every uploaded or generated file inherits the exact company and case permissions of its parent record—no public or unauthenticated file links.
5. **AI Context Boundary:** The Digital Assistant can access *only* information that the requesting user is already authorised to view.
6. **Complete Auditability:** Every sign-in, permission change, case assignment, document action, and approval is written to an immutable `Audit Event` log.

---

## 8. Three-Month (12-Week) Delivery Plan & Acceptance Criteria

The 12-week schedule is structured into four sequential milestones aimed at launching a reliable, end-to-end working pilot.

| Phase & Timeline | Focus Area | Key Deliverables |
| :--- | :--- | :--- |
| **Phase 1: Weeks 1–2** | **Confirm & Prepare** | • Freeze the first priority customer service workflow.<br>• Confirm final page list, role permissions, database schema, and case status names.<br>• Create clickable screen flows for stakeholder alignment.<br>• Prepare isolated development, testing, and container deployment environments. |
| **Phase 2: Weeks 3–6** | **Shared Backend & Customer App** | • Build authentication, role permissions, and company/firm assignment APIs.<br>• Build Customer App: **Home**, **My Companies**, and **Ask MySect** guided intake.<br>• Implement automated structured case creation, live status tracking, initial document upload, and notifications. |
| **Phase 3: Weeks 7–9** | **Secretary Website** | • Build **Secretary Dashboard**, **New Customer Requests** queue, and **Work Queue**.<br>• Build **Case Workspace** with AI intake summary, human conversation, internal notes, and information requests.<br>• Implement end-to-end document exchange and formal customer approval/rejection workflows. |
| **Phase 4: Weeks 10–12** | **Admin Website & Pilot Readiness** | • Build **Admin Website**: Secretary Firm management, user management, company assignment, case oversight, and audit views.<br>• Execute comprehensive role/company permission testing and backup/restore verification.<br>• Set up pilot partner data and complete User Acceptance Testing (UAT). |

### Pilot Acceptance Criteria (Definition of Done for Month 3)
Before the first working version is signed off for pilot use, all 11 criteria below must pass verification:
- [x] **1. Customer Access:** Customer can sign in securely and view an authorised company.
- [x] **2. Guided Intake:** Customer can complete the *Ask MySect* guided intake and generate a structured case.
- [x] **3. Accurate Routing:** The assigned Secretary Firm receives the new case immediately.
- [x] **4. Case Execution:** Secretary staff can accept, assign, update, and complete the case.
- [x] **5. Human Handoff:** Secretary can open a human conversation with the customer after taking case ownership.
- [x] **6. Document Exchange:** Customer and Secretary can request, upload, and view documents through the case.
- [x] **7. Formal Approval:** Customer approval or rejection (with reason) is recorded with a timestamp.
- [x] **8. Admin Control:** MySect Admin can create firms, manage users, and assign companies to firms.
- [x] **9. Security Isolation:** Cross-company and cross-firm access restriction tests pass 100%.
- [x] **10. Audit Trail:** All important user, case, and admin actions appear accurately in the audit history.
- [x] **11. Operational Resilience:** Database and file backup and restore procedures are tested and verified.

---

## 9. Decisions Deliberately Deferred (For Partner & Commercial Alignment)

To protect the 3-month timeline and ensure technical work is never blocked by pending commercial negotiations, the system is architected with clean adapters so the following decisions can be plugged in once confirmed by the business owner, company-secretary partner, legal adviser, or selected vendor:

| Deferred Decision Area | Why It Is Deferred in Phase 1 | How the Architecture Supports It Later |
| :--- | :--- | :--- |
| **1. Digital Assistant Provider & Pricing** | Final commercial token/API pricing and model vendor selection are still under evaluation. | Built behind a provider-neutral AI adapter so vendors can be swapped without changing app screens. |
| **2. Cloud Storage Vendor & Pricing** | Final storage quotation and vendor contract are pending confirmation. | File-storage adapter works with local/container storage now and cloud object storage later. |
| **3. External Identity Verification (e-KYC)** | Legal and operational necessity of third-party e-KYC vs. secretary verification is being reviewed. | User verification statuses are already in the data model; an e-KYC step can be added to registration later. |
| **4. Payment Gateway & Marketplace Model** | Revenue split, transaction fees, and payment provider terms require commercial agreement. | Phase 1 focuses on core service execution; billing modules can be activated once fee models are finalised. |
| **5. Customer & Secretary Subscription Pricing** | Tiered pricing and company allocation limits per firm require business partner alignment. | Firm and company assignment records are ready to enforce plan limits once commercial tiers are set. |
| **6. Direct Government (SSM / MBRS) Integration** | Direct filing requires regulatory approval and confirmed technical specifications. | Phase 1 tracks filing preparation and customer approvals; staff lodge via MBRS manually as they do today. |
| **7. Final Legal & Statutory Compliance Workflow** | Specific resolution wordings and statutory sign-off rules require licensed secretary sign-off. | Flexible case checklists and document approval flows adapt to any confirmed statutory template. |
| **8. Secretary Mobile App** | Secretarial work is document- and table-heavy, making a desktop web workspace the priority. | Shared backend APIs can power a companion mobile app for secretaries in a future phase if needed. |
| **9. Advanced Reporting & Automation** | Deep analytics require real operational data from initial pilot usage first. | Structured case timestamps and audit logs capture all raw data needed for future BI dashboards. |

---

## Final Build Recommendation

> **Focus on One Complete End-to-End Flow First:**  
> Build and test one complete request workflow across all three products (**Customer App → Secretary Website → Admin Website**) before expanding into additional service categories. The true measure of Month 3 success is not the raw number of static screens built—it is a **secure, reliable end-to-end journey** that a real Customer, Partner Secretary Firm, and MySect Administrator can use together from start to finish.
