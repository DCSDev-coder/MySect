# MySect Platform Blueprint

## Executive summary

MySect is planned as a Malaysian company-secretary service platform connecting customers with company-secretary firms and providing a central administration layer for the MySect network.

The first release should contain three products:

1. MySect Client: Flutter mobile application for company owners and authorised representatives.
2. Secretary Workspace: responsive web application for company-secretary firms.
3. MySect Admin: web application for platform operations, firm management, billing, oversight, and support.

The current MySect Flutter repository is a customer-facing UI prototype. It does not yet provide the production backend, secretary workspace, admin workspace, authentication, tenant isolation, persistent data, or real document workflow.

The recommended technical direction is:

- Backend hosted on the existing Windows Server environment.
- Linux application containers running inside a Linux VM on the Windows Server host.
- Docker Engine and Docker Compose for deployment.
- PostgreSQL for structured data.
- TM Cloud Object Storage for company and customer files.
- AI-first customer intake followed by human secretary escalation.
- A provider-neutral AI integration so MySect can change model vendors later.

This blueprint is a planning document. Pricing, TM Cloud service selection, SSM integration, AI provider, and legal/compliance responsibilities require confirmation before production commitments.

## 1. Product goals

### 1.1 Customer goal

Customers should be able to understand what is happening with their company, provide the required information, approve documents, and communicate with their assigned company-secretary firm without needing to understand internal processing.

### 1.2 Secretary-firm goal

Secretary firms should be able to manage many companies from one workspace, with a clear queue of work, missing information, deadlines, approvals, filings, and customer conversations.

### 1.3 MySect Admin goal

MySect Admin should operate the platform network by onboarding and verifying secretary firms, assigning companies, managing subscriptions, monitoring service quality, resolving disputes, and auditing platform activity.

### 1.4 Business goal

MySect should create a repeatable platform model in which:

- Customers receive a clearer digital service.
- Secretary firms reduce manual coordination.
- MySect earns recurring software revenue and may later earn marketplace or transaction revenue.

## 2. Scope and regulatory context

The initial scope is company-secretarial service, not full bookkeeping or accounting outsourcing.

Typical work includes:

- Company profile maintenance.
- Directors and officers.
- Shareholders and shareholding.
- Registered office information.
- Statutory records.
- Resolutions and minutes.
- Annual returns.
- Company changes.
- Beneficial ownership information.
- Customer approvals and signatures.
- SSM submission tracking.

SSM states that annual submissions contain information such as business activities, registered office, directors, company secretaries, members, and shareholding. SSM also states that annual documents may be lodged through MBRS by the appointed licensed company secretary or company agent.

References:

- https://www.ssm.com.my/Pages/Register_Business_Company/Company/Annual-Submission.aspx
- https://www.ssm.com.my/Pages/Licensed_Secretary_Auditors/List-Registered-Secretaries.aspx
- https://crmsv.ssm4u.com.my/ssmkb/SSM4UExternal?language_id=2&name=annual+return

MySect should track and support professional work. It should not represent the software operator as the licensed company secretary unless the business and legal structure explicitly require that.

## 3. Three-platform model

```text
Customer / company representative
                |
                v
        MySect Client App
                |
                v
       Secretary Firm Workspace
                |
                v
           MySect Admin
```

### 3.1 MySect Client

The customer application should contain:

- Home dashboard.
- My Companies.
- Company details.
- Requests.
- Documents.
- Compliance Calendar.
- Approvals.
- AI Assistant.
- Notifications.
- Invoices and payments.
- Profile and settings.

The customer should not start a human secretary chat directly. The customer begins with the AI Assistant, which gathers the issue, checks the existing request history, and creates a secretary case when human work is needed.

### 3.2 Secretary Workspace

The secretary website should contain:

- Operations Dashboard.
- AI Escalations.
- Work Queue.
- Companies.
- Requests.
- Documents.
- Compliance Calendar.
- Resolutions and templates.
- Statutory Records.
- Annual Returns.
- Filing Tracking.
- Human Conversations.
- Invoices.
- Team management.
- Firm reports.
- Secretary AI Assistant.
- Firm settings.

### 3.3 MySect Admin

The Admin website should contain:

- Admin Dashboard.
- Secretary Firms.
- Licence and practising-certificate records.
- Customers.
- Companies.
- Firm and company assignments.
- Requests and escalations.
- Compliance monitoring.
- Subscriptions.
- Billing and payments.
- Support and disputes.
- Platform reports.
- Audit Logs.
- AI monitoring.
- Service catalogue.
- Platform settings.

## 4. Communication and AI-first intake

### 4.1 Customer communication rule

The default communication model is:

```text
Customer asks MySect AI
        |
        v
AI identifies company and issue
        |
        v
AI answers or gathers missing information
        |
        v
AI creates a structured case when human work is needed
        |
        v
Assigned secretary receives a notification
        |
        v
Secretary opens the human conversation
```

Customers should see:

- Ask MySect AI.
- My Requests.
- Human conversation only after a secretary opens or accepts the case.

### 4.2 AI conversation versus secretary case

These must be separate records:

- AI Conversation: the initial customer interaction.
- Service Case: the structured work item created from the interaction.
- Human Conversation: the secretary-led communication after escalation.

Not every AI conversation should become a secretary case.

### 4.3 Escalation conditions

The AI should create a case when:

- The customer requests a company-secretarial service.
- A document needs preparation or review.
- The matter involves statutory or legal consequences.
- The AI cannot answer with sufficient confidence.
- The customer asks for a secretary.
- The customer is unhappy or reports an urgent problem.
- An SSM query, rejection, or filing issue is reported.
- A deadline is close.
- The customer repeats the same unresolved question.

The AI must not submit an SSM filing, approve a resolution, delete a statutory record, or make a legal decision without authorised human action.

## 5. Core workflows

### 5.1 Customer request workflow

```text
Customer starts with AI
        |
        v
AI identifies company and request type
        |
        v
AI collects required fields and documents
        |
        v
Secretary case is created
        |
        v
Secretary reviews and assigns work
        |
        v
Draft or filing is prepared
        |
        v
Internal review is completed
        |
        v
Customer approves or signs
        |
        v
Secretary submits or completes the work
        |
        v
Final record and document are published
```

### 5.2 Recommended case statuses

- New.
- Under review.
- Waiting for customer.
- Drafting.
- Internal review.
- Waiting for signature.
- Ready for submission.
- Submitted.
- SSM query.
- Resubmission required.
- Completed.
- Rejected.
- Cancelled.
- Overdue.

### 5.3 Document workflow

1. Customer uploads a document.
2. Backend records metadata.
3. File is stored in TM Cloud.
4. Worker scans and processes the file.
5. Secretary reviews the document.
6. Secretary accepts, rejects, or requests replacement.
7. Document is linked to a company and case.
8. Final version is published to the customer.

## 6. Technical architecture

### 6.1 Application layers

```text
Flutter Client App
Secretary Web App
Admin Web App
        |
        v
HTTPS API and WebSocket Gateway
        |
        v
Modular Backend Application
        |
------------------------------------------------
| PostgreSQL | Redis | Workers | AI Provider    |
------------------------------------------------
        |
        v
TM Cloud Object Storage and Backups
```

### 6.2 Recommended implementation style

Start with a modular monolith rather than microservices. Keep clear backend modules, but deploy the first release as one API service plus workers.

Suggested stack:

- Flutter for the client app.
- React and TypeScript for Secretary and Admin websites.
- Node.js and TypeScript for the backend.
- PostgreSQL for structured data.
- Redis for short-lived cache, rate limits, and job coordination.
- Docker Compose for deployment.
- WebSocket or server-sent events for notifications and human chat.
- REST or typed API contracts between clients and backend.

### 6.3 Backend modules

- Authentication and sessions.
- Organisations and memberships.
- Roles and permissions.
- Customers.
- Secretary firms.
- Companies.
- Company assignments.
- Service catalogue.
- Requests and cases.
- Tasks and deadlines.
- Documents and versions.
- Statutory records.
- Resolutions.
- Approvals and signatures.
- Filings.
- Messages and conversations.
- Notifications.
- Subscriptions and billing.
- AI conversations and actions.
- Audit events.

## 7. Tenant and permission model

```text
MySect Admin
    Can manage the platform and authorised cross-tenant operations

Secretary Firm
    Can manage its own staff and assigned companies

Secretary Staff
    Can manage assigned work according to role

Customer
    Can manage their own companies, requests, documents, and approvals
```

Every important record should include:

- tenant_id.
- organisation_id.
- company_id.
- created_by.
- assigned_to.
- visibility.
- created_at.
- updated_at.

Access must be checked at the backend for every read, write, download, and AI retrieval operation.

## 8. Windows Server and Docker deployment

### 8.1 Recommended production layout

```text
Internet
   |
   v
Firewall and HTTPS
   |
   v
Windows Server host
   |
   v
Hyper-V Linux VM
   |
   v
Docker Engine and Docker Compose
   |
   +-- API
   +-- Secretary Web
   +-- Admin Web
   +-- Worker
   +-- PostgreSQL
   +-- Redis
   +-- Reverse Proxy
   |
   v
TM Cloud Object Storage
```

Docker Desktop should not be used as the production runtime on Windows Server. Docker states that Docker Desktop is not supported on Windows Server. Microsoft documents that Linux containers require virtualization when hosted from Windows, so the recommended arrangement is a Linux VM with Docker Engine inside the Windows Server host.

References:

- https://docs.docker.com/desktop/setup/install/windows-install/
- https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/linux-containers
- https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment

### 8.2 Docker services

Initial services:

- api.
- web-secretary.
- web-admin.
- worker.
- postgres.
- redis.
- reverse-proxy.
- migration-runner.

Later services:

- notification-worker.
- document-processing-worker.
- ai-gateway.
- monitoring.
- backup-worker.

### 8.3 Environments

Use separate environments:

```text
Development -> Staging / QA -> Production
```

Production and staging must not share:

- Database.
- Secrets.
- Object-storage bucket.
- AI keys.
- Notification credentials.

### 8.4 Deployment controls

- Build versioned Docker images.
- Store images in a private registry.
- Run migrations as a controlled step.
- Back up before production deployment.
- Run API and storage health checks.
- Keep a rollback image.
- Monitor container restarts.
- Restrict server administration.
- Rotate secrets.
- Patch the host and VM.

## 9. TM Cloud file storage

TM One Cloud Alpha publicly lists Object Storage, PostgreSQL RDS, API Gateway, IAM, monitoring, key management, backup, and security services. The application should confirm the exact contracted service with TM before implementation.

References:

- https://www.tmone.com.my/cloud-services/
- https://www.tmone.com.my/cloud-services/cloud-infrastructure/

The application should store original files in TM Cloud and document metadata in PostgreSQL.

### 9.1 Upload pattern

```text
Client requests upload permission
        |
        v
Backend checks tenant and case permission
        |
        v
Backend returns temporary signed upload URL
        |
        v
Client uploads directly to TM Cloud
        |
        v
Backend records file metadata
        |
        v
Worker scans and processes the file
```

### 9.2 TM Cloud questions to confirm

- Object Storage API and S3 compatibility.
- Signed upload and download URLs.
- Encryption at rest and in transit.
- Versioning.
- Object lock or immutability.
- Malware scanning.
- Retention and deletion controls.
- Backup and disaster recovery.
- Availability SLA.
- Egress charges.
- API request charges.
- Audit logging.
- Data residency.

Unifi Cloud Storage is a separate packaged storage product. Its published plans cover user and storage tiers, but the application should not assume it provides the API, tenancy, lifecycle, and access controls required for MySect without confirmation.

Reference:

- https://biz.unifi.com.my/tncfaq/cloudstorage/FAQ_Unifi_Cloud_Storage.pdf

## 10. AI architecture

### 10.1 AI roles

#### Customer AI

Use AI for:

- Understanding the customer issue.
- Identifying the company.
- Identifying request type.
- Asking structured questions.
- Checking required documents.
- Explaining case status.
- Creating a structured secretary case.
- Notifying the assigned secretary.

#### Secretary AI

Use AI for:

- Conversation summaries.
- Missing-information suggestions.
- Draft customer replies.
- Internal checklists.
- Document summaries.
- Company history summaries.
- First drafts of resolutions.
- Deadline explanations.

#### Admin AI

Use AI for:

- Firm performance summaries.
- Overdue case summaries.
- Licence expiry alerts.
- Support trend analysis.
- AI usage reporting.

### 10.2 AI controls

The AI must not:

- Read another tenant's data.
- Submit directly to SSM.
- Approve a statutory document.
- Delete company records.
- Change permissions.
- Make an unreviewed legal conclusion.
- Claim that a secretary was notified unless the backend created the case and notification successfully.

### 10.3 AI implementation

Use a provider-neutral interface:

```text
AiProvider
    GeminiProvider
    MistralProvider
    OpenAiProvider
    SelfHostedProvider
```

The backend should expose controlled functions:

- getCustomerCompanies.
- getRequestStatus.
- getRequiredDocuments.
- createSecretaryCase.
- attachDocumentToCase.
- notifyAssignedSecretary.
- openHumanConversation.

The AI should call backend functions, not access the database or storage directly.

### 10.4 AI knowledge and retrieval

Knowledge sources may include:

- MySect help content.
- Secretary operating procedures.
- Approved SSM guidance.
- Service catalogue.
- Request status.
- Customer-specific company data.
- Approved templates.

Original files should remain in TM Cloud. The system should retrieve only authorised extracted text or metadata for each AI request.

Malaysia's Personal Data Protection Department identifies principles covering notice, disclosure, security, retention, integrity, and access. Sensitive company documents should not be sent to an external AI provider until processing, retention, and cross-border terms are reviewed.

References:

- https://www.pdp.gov.my/ppdpv1/en/principles-of-personal-data-protection/
- https://www.pdp.gov.my/ppdpv1/en/faq/

## 11. AI provider options

The following prices are public planning references checked on 28 September 2026. They may change and do not include implementation, TM Cloud, OCR, support, or monitoring.

| Provider / model | Input per 1M tokens | Output per 1M tokens | Proposed use |
|---|---:|---:|---|
| Gemini 2.5 Flash-Lite | US$0.10 | US$0.40 | Customer intake and high-volume FAQ |
| Mistral Small 4 | US$0.15 | US$0.60 | Customer or secretary assistant |
| DeepSeek Flash | US$0.15 off-peak / US$0.30 peak | US$0.60 off-peak / US$1.20 peak | Cost experiment only after privacy review |
| OpenAI GPT-6 Luna | US$0.10 | US$0.50 | Strong low-cost fallback |
| OpenAI GPT-6 Sol | US$2.00 | US$10.00 | Complex secretary drafting and summaries |

References:

- https://ai.google.dev/gemini-api/docs/pricing
- https://mistral.ai/pricing/api/
- https://api-docs.deepseek.com/quick_start/pricing/
- https://developers.openai.com/api/docs/pricing

### 11.1 Recommended decision

Start with Gemini 2.5 Flash-Lite for customer intake because the chatbot needs structured questions, classification, multilingual understanding, and case creation rather than advanced long-form reasoning.

Use Mistral Small 4 or Gemini 2.5 Flash for secretary-side summaries and drafts after testing with real Malay and English examples.

Keep the provider-neutral interface so MySect can change providers without rewriting the case workflow.

### 11.2 Example model-only cost

Assumption:

- 10,000 customer conversations per month.
- 4,000 input tokens per conversation.
- 800 output tokens per conversation.

Approximate model-only cost:

| Model | Monthly estimate |
|---|---:|
| Gemini Flash-Lite | US$7.20 |
| OpenAI Luna | US$8.00 |
| Mistral Small 4 | US$10.80 |
| DeepSeek Flash | About US$11-US$23 depending on timing |

The model token bill is likely to be smaller than product development, storage, support, OCR, security, and operations.

### 11.3 Self-hosted AI

Self-hosting an open-weight model inside the TM environment may improve control over sensitive data, but it requires GPU capacity, model-serving software, monitoring, patching, and operational support.

Self-hosting is not automatically cheaper at pilot volume. It should be evaluated after the system has measured real usage or when the privacy requirement makes external APIs unsuitable.

## 12. Subscription and revenue model

### 12.1 Customer

Recommended pilot approach:

- Free MySect customer account.
- Customer pays the secretary firm for professional services.
- MySect may later collect and distribute service payments.
- No mandatory customer subscription at the beginning.

### 12.2 Two separate billing relationships

The proposed two-subscription model is correct, but the relationships must remain separate in the data model, invoices, payment accounts, and support process.

```text
MySect Admin  --platform subscription-->  Secretary Firm
Secretary Firm --professional service-->  Customer Company
```

#### A. MySect platform subscription: MySect -> Secretary Firm

- The Secretary Firm selects Starter, Growth, Professional, or Enterprise.
- MySect bills the firm monthly or annually.
- MySect controls plan limits, staff seats, company limits, AI allowance, storage allowance, and support tier.
- Failed payment may place the firm into grace period, read-only mode, or suspension; customer records remain retained.
- MySect Admin can grant a trial, discount, credit note, manual invoice, or temporary override.
- The Secretary Firm sees its own subscription, invoices, payment method, and payment status.

#### B. Professional-service subscription: Secretary Firm -> Customer

- The Secretary Firm defines its own service package, price, billing frequency, inclusions, and renewal terms.
- The customer accepts the service agreement and pays the Secretary Firm.
- The Secretary Firm owns the service invoice, refund, cancellation, and service-delivery dispute.
- MySect records payment status and entitlement for workflow purposes, but should not become the legal merchant of record in the first release unless a marketplace and payout model has been approved.
- One-off filing fees, government fees, late fees, and exceptional work should be separate invoice line items rather than hidden inside the recurring subscription.

#### Payment architecture

Use a payment-provider abstraction so the platform can start with one provider and change later:

```text
Billing Service -> Payment Provider Adapter -> Webhook Handler -> Subscription Ledger
                                                     |
                                                     v
                                      entitlements, invoices, notifications, audit log
```

The first implementation should support:

- Card payment for recurring subscriptions.
- Bank or FPX checkout for one-off invoices, because FPX is customer-authenticated and does not support recurring payments according to Stripe's Malaysia documentation.
- Provider-hosted checkout or tokenized payment methods; never store raw card numbers.
- Webhook-driven status updates with idempotency keys.
- Invoice states: draft, issued, paid, past due, failed, refunded, void, and cancelled.
- A separate ledger for MySect platform revenue and Secretary Firm service revenue.
- Refunds and disputes routed to the merchant responsible for the invoice.

Stripe is a practical first provider to evaluate for Malaysia because its published Malaysia pricing supports cards and bank transactions, Stripe Billing supports recurring subscriptions, and Stripe Connect supports platform-style connected accounts. The exact merchant-of-record, payout, tax, KYC, and Connect terms must be confirmed before using MySect to collect customer money. Current published reference points are:

- https://stripe.com/en-my/pricing
- https://stripe.com/en-my/billing/pricing
- https://stripe.com/en-my/payment-method/fpx
- https://stripe.com/en-my/connect/pricing

#### Recommended rollout

1. Release MySect-to-Secretary Firm recurring billing first.
2. Let Secretary Firms issue and collect customer invoices directly during the pilot; MySect stores invoice status and service entitlements.
3. Add customer payment collection inside MySect only after legal, tax, payout, KYC, refund, and dispute responsibilities are approved.
4. If a marketplace model is approved, use connected accounts or an equivalent provider arrangement so customer funds are attributable to the correct Secretary Firm.

This keeps the first launch commercially clear: MySect sells software to Secretary Firms; Secretary Firms sell professional services to Customers.

### 12.2 Secretary firm

Suggested subscription structure:

| Plan | Indicative scope | Planning price |
|---|---|---:|
| Starter | Small firm, limited companies and staff | RM199-RM299/month |
| Growth | Larger portfolio and more staff | RM499-RM799/month |
| Professional | Larger portfolio, reports, AI, priority support | RM999-RM1,999/month |
| Enterprise | Custom limits, branding, SLA, support | Custom |

These are planning hypotheses, not approved prices.

Possible additional revenue:

- Active-company platform fee.
- Service-request commission.
- AI usage package.
- Premium storage.
- Custom branding.
- Priority support.
- Enterprise integration.

For the initial pilot, use a simple secretary-firm subscription and avoid adding commission until the operational workflow is proven.

## 13. Two-year planning budget

Assumptions:

- Malaysia-first launch.
- Three products.
- One shared backend.
- 10-20 secretary firms by the end of year two.
- Up to approximately 1,000 active companies.
- No direct MBRS submission integration at first.
- Production backup, monitoring, security, and support.

| Area | Two-year planning range |
|---|---:|
| Product and engineering | RM1.2m-RM2.1m |
| Windows Server, VM, and infrastructure | RM50k-RM230k |
| TM Cloud storage and backup | RM30k-RM150k |
| AI services and processing | RM24k-RM180k |
| Security, legal, and compliance | RM80k-RM200k |
| Customer and technical support | RM150k-RM360k |
| Contingency | RM150k-RM300k |
| **Total planning range** | **RM1.68m-RM3.52m** |

A lean pilot may cost less if the existing team provides engineering capacity and the first release delays AI, marketplace payments, mobile secretary features, and advanced SSM integration.

## 14. Team and responsibilities

Recommended core team:

- Product owner.
- Company-secretary domain expert.
- Backend engineer.
- Secretary and Admin web engineer.
- Flutter engineer.
- QA engineer.
- UI/UX designer.
- DevOps and security engineer.
- Customer support and operations.
- Legal and compliance adviser.

The domain expert is essential. The team should not design statutory workflows only from screenshots or competitor pages.

## 15. Implementation roadmap

### Phase 0: Business and compliance validation

Duration: 4-6 weeks.

Confirm:

- Exact services offered.
- Customer ownership.
- Secretary-firm responsibility.
- Licence verification.
- Per-company fees.
- Subscription rules.
- Payment ownership.
- Digital signature process.
- SSM integration scope.
- Data retention.
- AI data-processing policy.

### Phase 1: Backend foundation

Duration: 8-12 weeks.

Build:

- Authentication.
- Organisations and roles.
- Customers.
- Secretary firms.
- Companies.
- Assignments.
- Audit logging.
- PostgreSQL.
- TM Cloud storage adapter.
- Notifications.

### Phase 2: Customer and Secretary MVP

Duration: 12-16 weeks.

Customer:

- My Companies.
- AI intake.
- Requests.
- Documents.
- Status tracking.
- Notifications.

Secretary:

- Dashboard.
- AI Escalations.
- Work Queue.
- Companies.
- Requests.
- Document review.
- Customer communication.
- Compliance calendar.

### Phase 3: Corporate-secretarial operations

Duration: 12-16 weeks.

Build:

- Directors and officers.
- Shareholders and shareholding.
- Statutory registers.
- Resolution templates.
- Approval and signature tracking.
- Filing tracking.
- Annual-return checklist.

### Phase 4: Admin and commercial system

Duration: 8-12 weeks.

Build:

- Firm onboarding.
- Licence records.
- Company assignment.
- Subscription plans.
- Invoices.
- Payments.
- SLA reports.
- Support and disputes.

### Phase 5: Pilot and launch

Duration: 8-12 weeks.

Pilot with 1-3 secretary firms and 20-50 companies. Use manual controls for legally important work while the system proves the workflow.

Measure:

- Request completion time.
- Customer response time.
- Missing-document rate.
- On-time completion.
- Secretary workload.
- AI classification accuracy.
- AI escalation accuracy.
- Storage and AI cost.
- Support incidents.

### Year two

Use year two for:

- More secretary firms.
- Better templates.
- Secretary mobile companion.
- Payment automation.
- Firm performance tools.
- Company transfer workflow.
- Advanced reports.
- Stronger document processing.
- SSM integration only after confirmation.
- Security testing and independent review.

## 16. Launch gates

MySect should not be called production-ready until:

- Customers can securely access their companies.
- Secretary firms can access only assigned companies.
- Requests move through a complete workflow.
- Files are stored and retrieved securely.
- Document versions are auditable.
- Customer approvals are recorded.
- Secretary actions are recorded.
- Admin can manage firms and assignments.
- Subscription rules are tested.
- Backups and recovery are tested.
- AI tenant isolation is verified.
- AI does not submit filings automatically.
- Pilot users complete real end-to-end requests.
- Staff know which actions remain manual and professionally accountable.

## 17. Decisions required before UI design

1. Which company-secretarial services launch first?
2. Who owns the customer relationship?
3. Does MySect collect customer payments?
4. What does the proposed per-company fee mean?
5. How are secretary firms verified?
6. Can customers transfer between firms?
7. Which actions require customer signatures?
8. Which actions require licensed-secretary approval?
9. Does the first version track SSM submissions or integrate with MBRS?
10. Which TM Cloud storage product will be contracted?
11. Where may AI process sensitive company information?
12. What is the first pilot size and target launch date?

## Final recommendation

Build the shared backend and Secretary Workspace around the AI-first case workflow:

```text
Customer AI intake
    -> structured secretary case
    -> secretary review
    -> customer approval
    -> submission or completion
    -> audited final record
```

Keep the Customer product simple, make the Secretary Workspace the operational centre, and make Admin responsible for firm governance, subscriptions, assignments, and oversight.
