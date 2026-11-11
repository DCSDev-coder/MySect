# MySect Enterprise Platform Requirements & Architectural Blueprint

**Document Reference:** SEC-REQ-2026-V2  
**Classification:** Confidential — Internal & Stakeholder Review  
**Effective Date:** 9 November 2026  
**Target Delivery Window:** Q1 2027 (12-Week Production MVP)  
**Stakeholder Audience:** Project Owner, Executive Board, Lead Architect, Frontend Engineering Team, Backend Engineering Team, Legal & Compliance Advisors, and Partner Secretarial Firms  

---

## Executive Summary

**MySect** is an enterprise-grade digital operating platform designed to modernize and automate the Malaysian corporate secretarial (CoSec) industry. Operating under the regulatory jurisdiction of the **Companies Act 2016** and guidelines enforced by the **Suruhanjaya Syarikat Malaysia (SSM)**, MySect connects corporate business owners and company directors with licensed secretarial firms via an integrated, multi-role digital ecosystem.

The ecosystem comprises three dedicated client interfaces powered by a unified, secure backend and an on-premise/hybrid AI reasoning gateway:
1. **MySect Client (`mysect_app`)**: Native Flutter mobile application for company owners, directors, and authorized corporate representatives.
2. **Secretary Workspace (`mysect_secretary`)**: Responsive, high-density Flutter desktop and tablet workspace engineered for licensed company secretaries (MAICSA / MIA) and compliance review teams.
3. **Platform Operations (`mysect_admin`)**: React & Vite single-page management application for platform operators, multi-tenant governance, billing oversight, firm onboarding, and audit logging.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MYSECT PLATFORM ECOSYSTEM                         │
└─────────────────────────────────────────────────────────────────────────────┘
       ┌──────────────────────┐             ┌────────────────────────┐
       │   Client Mobile      │             │  Secretary Workspace   │
       │  (Flutter Android/iOS)             │ (Flutter Desktop/Web)  │
       └──────────┬───────────┘             └───────────┬────────────┘
                  │                                     │
                  │       HTTPS / WSS / REST API        │
                  ▼                                     ▼
       ┌─────────────────────────────────────────────────────────────┐
       │             Reverse Proxy / SSL Termination                 │
       │              (Caddy / Nginx TLS 1.3 / HSTS)                 │
       └──────────────────────────────┬──────────────────────────────┘
                                      │
                                      ▼
       ┌─────────────────────────────────────────────────────────────┐
       │            Unified Core Backend (mysect_backend)            │
       │       Multi-Tenant Gatekeeper • RBAC • Audit Engine         │
       └───────┬──────────────────────┬──────────────────────┬───────┘
               │                      │                      │
               ▼                      ▼                      ▼
    ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐
    │  Relational DB     │ │  AI Gateway Engine │ │  Storage Adapter   │
    │ (mysect_database)  │ │ (Local LLM / Cloud)│ │  (mysect_storage)  │
    │   MySQL 8.4 LTS    │ │ DeepSeek/Gemma/Qwen│ │ S3 / TM Cloud /    │
    │ Transaction Ledger │ │  Ollama & Gemini   │ │ Local Encrypted    │
    └────────────────────┘ └────────────────────┘ └────────────────────┘
```

---

## 1. Architectural Strategy & Design Justification

### 1.1 The Tri-Frontend Topology
A common design anti-pattern in legal-tech applications is forcing all user roles into a single monolithic responsive website or a single shared mobile codebase. MySect intentionally decouples into three role-specific client applications:

| System Component | Technology Stack | Primary Form Factor | Architectural & UX Justification |
|---|---|---|---|
| **Customer App** (`mysect_app`) | Flutter 3.x (Dart) | iOS & Android Mobile | **Executive Velocity:** Corporate directors and SMEs operate on mobile devices. They require instant push notifications for statutory deadlines, rapid biometrics, and one-tap document approvals without navigating complex corporate secretarial registers. |
| **Secretary Workspace** (`mysect_secretary`) | Flutter 3.x Desktop & Responsive Web | Desktop (macOS / Windows) & Tablet | **Data-Dense Operational Throughput:** Secretarial staff process multi-page statutory PDF lodgements (e.g., Section 68 Annual Returns, Section 14 Incorporation, CP204 tax estimates, M&A constitutions), side-by-side dossier comparisons, and high-frequency data entry. High screen density, multi-windowing, and keyboard navigation are critical. |
| **Admin Portal** (`mysect_admin`) | React 18 + Vite, TailwindCSS | Modern Desktop Browsers | **Rapid Governance & Analytics:** Super-admin operations require dynamic reporting dashboards, multi-tenant firm controls, user account freezes, and audit-log inspection. React/Vite offers rich administrative components, rapid development cycles, and low-footprint static web hosting. |

### 1.2 Central Unified Backend (`mysect_backend`)
All frontends connect strictly to a central versioned API (`/api/v1/*`). Direct database connectivity from any frontend client is strictly prohibited.
* **Multi-Tenant Isolation**: Every database query is cryptographically scoped to the caller's verified `tenant_id` and `company_id`. Cross-tenant data leakage is prevented at the ORM/data access layer.
* **Role-Based Access Control (RBAC)**: Fine-grained permission trees distinguish Platform Admins, Firm Managing Secretaries, Staff Reviewers, Company Directors, and Authorized Agents.
* **Statutory State Machine**: Transitions between case submission, secretary review, document signing, and SSM lodgement are enforced server-side. Frontends cannot arbitrarily alter case states.

### 1.3 Database Architecture: Dedicated MySQL 8.4 LTS (`mysect_database`)
* **Strict Relational Integrity**: Corporate secretarial data is governed by statutory mandates (Companies Act 2016). Every filing, officer appointment, share allocation, and resolution has rigid foreign-key relationships.
* **ACID Transactions**: Financial ledger items, retainer subscriptions, and statutory approval timestamps require absolute atomicity to prevent double-filings or orphaned records.
* **Operational Stability**: Self-hosted MySQL 8.4 LTS operates with predictable memory overhead on Windows Server virtualization, boasts mature automated backup tooling (`mysqldump` / binary logging), and integrates with enterprise monitoring tools.
* **Clear Role Distinction**: phpMyAdmin is categorized exclusively as a local database administration utility for staging environments; it is never exposed to the public internet or treated as an architectural layer.

### 1.4 Private Document Storage Adapter (`mysect_storage`)
Corporate statutory files (Form 9/13, Form 24/49, Section 14, Board Resolutions, Director NRIC/Passport copies) carry severe legal and privacy liabilities under the Malaysian Personal Data Protection Act 2010 (PDPA).
* **Zero Binary Ingestion in MySQL**: Storing binary large objects (BLOBs) in MySQL degrades query caching, bloats index tables, and increases backup latency. MySQL stores only file metadata: SHA-256 integrity hash, MIME type, payload byte size, uploading user ID, timestamp, and an opaque storage UUID.
* **Storage Adapter Abstraction Layer**: The backend implements a pluggable `StorageProvider` interface:
  * **Phase 1 (Staging & Early Pilot)**: Local secure volume storage with server-side AES-256 envelope encryption.
  * **Phase 2 (Production Scale)**: S3-compatible private object store (e.g., TM Cloud Object Storage or self-hosted MinIO).
* **Time-Limited Ephemeral Pre-Signed URLs**: Clients never receive direct file system paths or public S3 URLs. Access is granted exclusively via cryptographically signed tokens with a 5-minute time-to-live (TTL).

### 1.5 Host & Deployment Architecture (Windows Server + Docker)
The enterprise infrastructure resides on the organization’s Windows Server environment:
* **Production Runtime Engine**: Production containers run on a supported Linux container subsystem (WSL2 backend with Ubuntu LTS or dedicated Hyper-V Linux VM running Docker CE Engine). Docker Desktop is prohibited for production runtime due to licensing, resource management, and daemon restart limitations.
* **Docker Compose Orchestration**: Service topologies (`mysect_backend`, `mysect_admin`, `mysect_secretary_web`, `mysect_database`, `mysect_ai_gateway`, `mysect_reverse_proxy`) are declared in declarative compose manifests with strict resource limits (CPU/Memory quotas) and persistent data volume mounts.
* **Reverse Proxy & TLS Termination**: An automated reverse proxy (Caddy or Nginx) enforces HTTPS/TLS 1.3, HTTP Strict Transport Security (HSTS), rate-limiting, and WebSocket connection upgrades for real-time notifications.

---

## 2. Artificial Intelligence Strategy & Economic Model

### 2.1 The AI Functional Mandate in MySect
The AI subsystem serves as a high-precision corporate secretarial triage and extraction assistant. It does **not** replace the licensed company secretary.
* **Smart Case Intake**: Guides directors through natural language inquiries (e.g., *"We want to add a new director who is a foreigner"*), identifies the exact statutory transaction, confirms the registered company, and requests mandatory prerequisites (e.g., Form 49 particulars, passport scan, residential address).
* **Document Extraction & Pre-Screening**: Reads uploaded PDF filings, verifies resolution dates against statutory notification windows (e.g., 14-day notice under Section 202 of the Companies Act 2016), and flags omissions.
* **Executive Case Summarization**: Generates standardized secretarial dossiers for the assigned secretary, reducing case triage time from 20 minutes to under 60 seconds.
* **Safety Boundaries**: The AI is strictly barred from making legal filings, executing statutory signatures, approving legal drafts, or communicating cross-company data.

### 2.2 Comprehensive AI Model Comparison & Cost Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AI MODEL SELECTION MATRIX                          │
├────────────────────────────┬─────────────────────────────┬──────────────────┤
│ Option A: Cloud API        │ Option B: Local On-Prem OSS │ Option C: Hybrid │
│ • Lowest friction setup    │ • Zero data privacy leakage │ • Cloud dev /    │
│ • Pay-as-you-go OPEX       │ • Predictable CAPEX hardware│   Local prod     │
│ • External cloud processing│ • Full Malaysian data sovere│ • Provider-agnos-│
│   (Gemini / DeepSeek API)  │   (DeepSeek R1/Qwen 2.5/Oll)│   tic LLM gateway│
└────────────────────────────┴─────────────────────────────┴──────────────────┘
```

The table below outlines real-world price ranges, hardware demands, and operational trade-offs for prospective AI models:

| Model Tier | Model / Engine | Context Window | Cloud Token Pricing (Per 1M Tokens) | Hardware Requirements (Local Deployment) | Hardware CAPEX / Hosting Cost | Compliance & Data Sovereignty | Operational Recommendation |
|---|---|---|---|---|---|---|---|
| **Cloud Managed API** | **Google Gemini 2.0 Flash / 1.5 Flash** | 1,000,000 tokens | **Input:** \$0.075 - \$0.10<br>**Output:** \$0.30 - \$0.40 | None (Managed Cloud API) | ~\$5 - \$20 / month (Based on 1,000 cases/mo) | Data processed on Google Cloud. Requires signed Data Processing Agreement (DPA). | **Recommended for Fast Prototype & Pilot Testing.** Exceptional speed, native multimodal PDF parsing, virtually zero upfront infrastructure cost. |
| **Cloud Managed API** | **DeepSeek-V3 / R1 (Official Cloud API)** | 64,000 tokens | **Input:** \$0.14 - \$0.27<br>**Output:** \$0.28 - \$1.10 | None (Managed Cloud API) | ~\$8 - \$30 / month | Data processed on DeepSeek Cloud infrastructure. | **Exceptional Reasoning Value.** Strong logic and structured JSON extraction at industry-low per-token costs. |
| **Local On-Premises** *(Entry Tier)* | **DeepSeek-R1-Distill-Qwen-8B** or **Qwen 2.5-7B** | 32,000 tokens | **\$0.00** (Free Open Source) | 16GB System RAM + Existing CPU (or 1x RTX 3060 12GB VRAM) | **\$0** (if hosted on current host CPU) or **~\$350** GPU | **100% Malaysian On-Premise Data Sovereignty.** No client information ever touches an external network. | **Good for Basic Questionnaire Intake.** Fast, low resource footprint, but weaker at parsing complex scanned multi-page statutory PDF tables. |
| **Local On-Premises** *(Target Production Tier)* | **DeepSeek-R1-Distill-Qwen-14B** or **Qwen 2.5-14B / Gemma 2-27B** | 32,000 - 64,000 tokens | **\$0.00** (Free Open Source) | Minimum 32GB RAM + 1x NVIDIA RTX 4090 (24GB VRAM) or RTX 3090 | **~\$1,600** one-time hardware investment | **Complete PDPA & Statutory Confidentiality Guarantee.** Enterprise data privacy for banking/audit stakeholders. | **Highly Recommended Local Target.** Superb bilingual reasoning (English & Bahasa Malaysia), high extraction accuracy for SSM Forms, excellent local response latency. |
| **Local On-Premises** *(Enterprise Deep Tier)* | **DeepSeek-R1-Distill-32B** or **Qwen 2.5-32B (Q4_K_M)** | 64,000 - 128,000 tokens | **\$0.00** (Free Open Source) | 64GB RAM + 2x RTX 4090 (48GB VRAM) or 1x RTX A5000/A6000 | **~\$3,800 - \$5,000** one-time hardware investment | **Maximum Legal & Compliance Security.** Fully self-contained on-premise AI cluster. | **Long-Term Enterprise Scaling.** Capable of comprehensive legal constitution analysis and historical resolution indexing across thousands of client companies. |

### 2.3 Local AI Runtime Architecture: Ollama / vLLM Gateway
To run local models without destabilizing the Windows Server:
1. **Containerized Engine**: Deploy **Ollama** or **vLLM** inside a GPU-accelerated Docker container mapped to host NVIDIA CUDA drivers.
2. **Provider-Agnostic Adapter Pattern**: The backend interacts exclusively with an abstraction layer adhering to the standard OpenAI-compatible REST API specification (`/v1/chat/completions`):
```text
  Backend AI Service
          │
          ▼
  AI Gateway Configuration
  (AI_BASE_URL=http://localhost:11434/v1, AI_MODEL=deepseek-r1:14b)
          │
          ├─► Mode "local": Routes to on-prem Ollama daemon (Zero token bill, strict privacy)
          └─► Mode "cloud": Routes to Gemini / DeepSeek API (Zero local GPU load)
```
*Benefit: The engineering team can switch from cloud prototyping to on-premise local inference with zero application code changes, simply altering environment configuration variables.*

---

## 3. Detailed Frontend Prototype Audit & Scope Realignment

### 3.1 Customer Mobile Application (`mysect_app`)
* **Current State**: Built with Flutter 3.x. Demonstrates high visual fidelity with corporate navy theming (`#0F2D59`), company switcher, Section 68 filing tracker, retainer countdown cards, document upload screens, and a mock chat interface.
* **Audit & Defect Analysis**:
  1. *Scope Creep*: Contains secondary modules—e-commerce integrations, full multi-currency invoicing, referral affiliate tracking, mailbox management, and personal bank accounts. These are non-core to secretarial operations and create engineering drag.
  2. *Chat Implementation Gap*: [`active_chat_page.dart`](file:///Users/marketingdeveloper/DCStack_Development/MySect/mysect_app/lib/mobile_app/chat/active_chat_page.dart) operates as a generic, unconstrained chat with static text prompts. It must be refactored into a guided **AI Questionnaire Wizard** that transitions into a read-only or human-enabled conversation only when accepted by a secretary.
  3. *Unpersisted Mock State*: Currently falls back to hardcoded mock lists (`Data Center Specialists Sdn Bhd`, `5Luxe Scents Co.`) when disconnected from port 5173.

### 3.2 Secretary Desktop & Tablet Workspace (`mysect_secretary`)
* **Current State**: Responsive Flutter application featuring desktop sidebar navigation, client company folders, document intake queue, credential profile displays (MIA/MAICSA license fields), and subscription tier settings.
* **Audit & Defect Analysis**:
  1. *Filing Lifecycle Gaps*: Displays filing records but lacks explicit UI states for: *Requesting Missing Statutory Info*, *Issuing Board Resolution for Signature*, and *Marking SSM Submission Acknowledged*.
  2. *Document Preview Limitation*: Lacks an integrated, high-speed split-pane PDF viewer necessary for desktop secretaries to review director IDs side-by-side with generated filing forms.
  3. *Dual-Form-Factor Complexity*: Responsive layout supports mobile and desktop. For Phase 1 MVP, the team must prioritize the **desktop/web view** where real secretarial work occurs, locking mobile view to read-only oversight.

### 3.3 Platform Administration Portal (`mysect_admin`)
* **Current State**: Built with React 18, Vite, and TailwindCSS. Implements mock APIs via Vite plugin middleware (`apiServerPlugin.js`) and in-memory mock data (`mockData.js`).
* **Audit & Defect Analysis**:
  1. *Ephemeral In-Memory State*: Any changes made in the admin UI (suspending a firm, reassigning a company) reset whenever the Vite development process restarts.
  2. *Authentication Security*: Uses unencrypted browser `localStorage` for role tokens. Must be upgraded to HTTP-only secure cookie sessions or signed JWTs with short expiry and refresh rotation.
  3. *Document Privacy Violation Risk*: Admin UI currently displays mock document URLs and customer attachments. Admin access to client corporate documents must be strictly gated and audit-logged to prevent compliance breaches.

---

## 4. Malaysian Legal & Regulatory Framework

To ensure legal viability in Malaysia, MySect must operate within the statutory boundaries established by regulatory authorities:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 MALAYSIAN STATUTORY COMPLIANCE BOUNDARIES                   │
├────────────────────────────┬────────────────────────────────────────────────┤
│ Regulatory Pillar          │ Architectural & Legal Requirement              │
├────────────────────────────┼────────────────────────────────────────────────┤
│ Companies Act 2016         │ Section 241: Company Secretary must be         │
│                            │ qualified (MAICSA / MIA / Licensed by SSM).    │
│                            │ Platform must verify and display qualifications│
│                            │ on all issued statutory documents.             │
├────────────────────────────┼────────────────────────────────────────────────┤
│ MBRS & MyCoID Integration  │ SSM does not currently offer public write-APIs │
│                            │ for direct third-party filing lodgement.       │
│                            │ Platform manages preparation & client approval;│
│                            │ licensed secretary executes submission in MBRS.│
├────────────────────────────┼────────────────────────────────────────────────┤
│ Digital Signature Act 1997 │ Statutory board resolutions require verifiable │
│ & Electronic Commerce Act  │ consent records: captured biometric/signature  │
│                            │ image, signer identity, verified phone/email,  │
│                            │ timestamp, and document SHA-256 hash.          │
├────────────────────────────┼────────────────────────────────────────────────┤
│ Personal Data Protection   │ Processing of Director IC/Passport scans       │
│ Act 2010 (PDPA)            │ requires strict encryption at rest, access     │
│                            │ logging, and automated retention/expiry rules. │
└────────────────────────────┴────────────────────────────────────────────────┘
```

---

## 5. End-to-End Operating Workflow

The diagram below details the operational trajectory of a client request through the MySect architecture:

```
[Customer / Company Director]
              │
              │  1. Selects Company & Starts Statutory Request
              ▼
    ┌────────────────────┐
    │  AI Intake Engine  │ ◄── Validates request, checks missing items,
    │  (mysect_backend)  │     asks targeted questions, collects uploads
    └─────────┬──────────┘
              │
              │  2. Structured Case Dossier Generated
              ▼
    ┌────────────────────┐
    │ Secretary Queue    │ ◄── Licensed Secretary reviews dossier,
    │ (mysect_secretary) │     verifies statutory dates, accepts case
    └─────────┬──────────┘
              │
              │  3. Secretary drafts Resolution / Statutory Return
              ▼
    ┌────────────────────┐
    │ Customer Approval  │ ◄── Director reviews draft, signs electronically,
    │    (mysect_app)    │     backend seals record with SHA-256 hash
    └─────────┬──────────┘
              │
              │  4. Approved Pack Delivered to Secretary
              ▼
    ┌────────────────────┐
    │ Statutory Lodgement│ ◄── Secretary lodges via SSM MBRS portal,
    │   (External SSM)   │     attaches receipt/acknowledgement to MySect
    └─────────┬──────────┘
              │
              │  5. Case Closed & Push Notification Dispatched
              ▼
[Customer Retains Permanent Corporate Dossier]
```

---

## 6. Functional Scope: MVP Commitments vs. Post-MVP Deferrals

To ensure delivery within the 12-week schedule, non-essential modules identified in the prototype audit are categorized into strict phases:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PHASED FEATURE ROADMAP                           │
├──────────────────────────────────────┬──────────────────────────────────────┤
│ IN-SCOPE: Phase 1 Production MVP     │ DEFERRED: Post-MVP Roadmap           │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ • Multi-tenant Auth (JWT / RBAC)     │ • Multi-currency Client Invoicing    │
│ • Company Dossier & Officer Registry │ • E-Commerce & Accounting Connectors │
│ • AI-Guided Statutory Intake Wizard  │ • Full Commercial e-KYC Facial API   │
│ • Section 68 Annual Return Lodgement │ • Marketplace Firm Payout Engine     │
│ • Document Approvals & Audit Trail   │ • Referral & Affiliate Network       │
│ • Ephemeral Storage Adapter (Local/S3│ • Direct Automated SSM Lodgement API │
│ • Secretary Desktop Queue & Dossier  │ • In-app Mailbox & Post-Scanning     │
│ • Admin Firm Verification & Auditing │ • Native Mobile Secretary App        │
└──────────────────────────────────────┴──────────────────────────────────────┘
```

---

## 7. Data Model & Relational Schema (MySQL 8.4 LTS)

The core relational database schema encapsulates multi-tenant segregation, statutory data, and compliance records:

```sql
-- Multi-Tenant Core: Secretarial Firms
CREATE TABLE secretarial_firms (
    id VARCHAR(36) PRIMARY KEY,
    firm_name VARCHAR(255) NOT NULL,
    registration_no VARCHAR(100) NOT NULL,
    license_no VARCHAR(100) NOT NULL, -- MAICSA / MIA / SSM License
    status ENUM('pending', 'verified', 'suspended') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Client Companies
CREATE TABLE companies (
    id VARCHAR(36) PRIMARY KEY,
    firm_id VARCHAR(36) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    ssm_registration_no VARCHAR(50) NOT NULL,
    incorporation_date DATE NOT NULL,
    company_type ENUM('sdn_bhd', 'bhd', 'llp') DEFAULT 'sdn_bhd',
    retainer_status ENUM('active', 'expiring', 'suspended') DEFAULT 'active',
    retainer_expiry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (firm_id) REFERENCES secretarial_firms(id) ON DELETE RESTRICT
);

-- User Accounts & Role Mapping
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    nric_passport_no VARCHAR(50) NOT NULL,
    user_role ENUM('platform_admin', 'firm_secretary', 'firm_staff', 'client_director', 'client_agent') NOT NULL,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Statutory Service Cases & Filings
CREATE TABLE statutory_cases (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) NOT NULL,
    created_by_user_id VARCHAR(36) NOT NULL,
    assigned_secretary_id VARCHAR(36),
    case_type ENUM('annual_return_s68', 'director_change', 'address_change', 'share_transfer', 'general_inquiry') NOT NULL,
    status ENUM('ai_intake', 'waiting_secretary_review', 'action_required_client', 'ready_for_lodgement', 'completed', 'cancelled') DEFAULT 'ai_intake',
    ai_dossier_summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(id)
);

-- Document Metadata Ledger (Files stored in Storage Adapter)
CREATE TABLE document_records (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) NOT NULL,
    case_id VARCHAR(36),
    uploaded_by_user_id VARCHAR(36) NOT NULL,
    document_category ENUM('statutory_form', 'board_resolution', 'director_id', 'financial_report', 'other') NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    storage_uuid VARCHAR(255) NOT NULL, -- Pointer to Object Store
    sha256_checksum VARCHAR(64) NOT NULL, -- Integrity Checksum
    retention_expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (case_id) REFERENCES statutory_cases(id)
);

-- Legal Document Approvals
CREATE TABLE document_approvals (
    id VARCHAR(36) PRIMARY KEY,
    document_id VARCHAR(36) NOT NULL,
    approved_by_user_id VARCHAR(36) NOT NULL,
    decision ENUM('approved', 'rejected') NOT NULL,
    rejection_reason TEXT,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NOT NULL,
    digital_signature_hash VARCHAR(64) NOT NULL,
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES document_records(id),
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id)
);

-- Immutable Platform Audit Log
CREATE TABLE platform_audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36),
    tenant_firm_id VARCHAR(36),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255),
    ip_address VARCHAR(45),
    metadata_json JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 8. Twelve-Week Implementation Roadmap (Gantt Schedule)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       12-WEEK PRODUCTION MVP SCHEDULE                       │
├───────────────────────────────────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┤
│ Workstream Activity               │W01│W02│W03│W04│W05│W06│W07│W08│W09│W10│W11│W12│
├───────────────────────────────────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
│ Scope Freeze & Stakeholder Signoff│ ■ │ ■ │   │   │   │   │   │   │   │   │   │   │
│ DB Migration & Core Backend Setup │   │ ■ │ ■ │ ■ │   │   │   │   │   │   │   │   │
│ Docker / Windows Server Infra     │   │   │ ■ │ ■ │   │   │   │   │   │   │   │   │
│ Multi-Tenant Auth & RBAC Engine   │   │   │ ■ │ ■ │ ■ │   │   │   │   │   │   │   │
│ AI Gateway (Ollama/Gemini Adapter)│   │   │   │ ■ │ ■ │ ■ │   │   │   │   │   │   │
│ Customer App Backend Integration  │   │   │   │   │ ■ │ ■ │ ■ │   │   │   │   │   │
│ Secretary Workspace Queue & Review│   │   │   │   │   │ ■ │ ■ │ ■ │   │   │   │   │
│ Document Storage Adapter & Signing│   │   │   │   │   │   │ ■ │ ■ │ ■ │   │   │   │
│ Admin Portal Real API Integration │   │   │   │   │   │   │   │ ■ │ ■ │ ■ │   │   │
│ End-to-End Pilot Testing & UAT    │   │   │   │   │   │   │   │   │   │ ■ │ ■ │
│ Security Hardening & Go-Live Prep │   │   │   │   │   │   │   │   │   │   │ ■ │
└───────────────────────────────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
```

---

## 9. Pilot Acceptance & Verification Gateways

Before transitioning from staging to live production pilot with real corporate data, all twelve verification gateways must be certified:

1. **Strict Multi-Tenant Isolation**: Verified that under no circumstance can a user from Firm A view, search, or access companies, filings, or documents belonging to Firm B.
2. **Elimination of Hardcoded Client Credentials**: Confirmed zero database connection strings, secret keys, or cloud access tokens inside compiled Flutter binaries or web asset bundles.
3. **AI Guardrails Verification**: Confirmed that the AI intake engine refuses to provide unauthorized tax/legal advice, cannot execute legal signatures, and gracefully escalates ambiguous inquiries to human secretaries.
4. **Local AI Latency Benchmark**: For on-premise deployments, verified that model inference latency does not exceed 4 seconds for questionnaire generation and 8 seconds for document summarization.
5. **Signed URL Ephemerality**: Confirmed that document download URLs expire exactly after 300 seconds and cannot be shared across unauthorized browsers.
6. **Digital Audit Record Integrity**: Confirmed that every document approval records the signer's identity, IP address, user agent, document SHA-256 hash, and exact UTC timestamp.
7. **Container Restart Resilience**: Confirmed that restarting Docker containers on Windows Server preserves all MySQL database transactions, uploaded documents, and active user sessions without data loss.
8. **Automated Backup & Recovery**: Verified that the automated MySQL binary dump and file backup pipeline can successfully restore a clean state within 30 minutes (RTO < 30m, RPO < 1h).
9. **Role Permission Boundary Audit**: Confirmed that Platform Admins cannot inspect confidential client chats or corporate dossier attachments without explicit, logged escalation tickets.
10. **Statutory Filing State Machine**: Verified that statutory filings cannot skip required approvals or bypass accredited secretary certification.
11. **Mobile Network Resilience**: Confirmed that `mysect_app` displays graceful offline indicators and retry mechanisms when encountering low-bandwidth cellular conditions.
12. **Malaysian PDPA Compliance Signoff**: Formally verified customer consent banners, data retention policies, and director IC document handling procedures with legal counsel.

---

## 10. Document Approval & Governance Signoff

| Role | Name | Title / Organization | Date | Signature / Status |
|---|---|---|:---:|:---:|
| **Project Sponsor** | | Executive Director, MySect Platform | | `[ PENDING APPROVAL ]` |
| **Lead Architect** | | Head of Engineering & Infrastructure | | `[ PENDING APPROVAL ]` |
| **Frontend Lead** | | Principal Mobile & Web Engineer | | `[ PENDING APPROVAL ]` |
| **Legal & Compliance** | | Licensed Company Secretary (MAICSA/MIA) | | `[ PENDING APPROVAL ]` |
