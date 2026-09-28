# MySect Company Secretary Platform

## 1. Purpose

MySect is planned as a multi-tenant platform connecting end customers with company-secretary firms and providing central administration for the MySect platform.

The product is not primarily an outsourced bookkeeping system. Its main purpose is company-secretarial operations, statutory compliance, document management, customer requests, approvals, and SSM-related filing workflows.

This document describes the proposed functionality for the three platform areas:

1. MySect Client
2. Company Secretary Workspace
3. MySect Admin / Moderator

## 2. Source and interpretation notes

The handwritten business sketch supplied for MySect is treated as a reference discussion, not as a confirmed technical or commercial specification.

The sketch appears to show:

- MySect clients at the front of the service.
- Multiple company-secretary firms handling client companies.
- A MySect moderator or administrator above the secretary firms.
- A licence model for secretary firms.
- A limit or allocation of companies managed by each secretary firm.
- Monthly fees associated with each managed company.
- A chat or messaging channel between clients and company secretaries.

The exact handwritten fee values, revenue split, and company allocation rules remain unconfirmed and must be decided before billing implementation.

## 3. Regulatory and operational context

For Malaysian companies, annual submissions contain information such as business activities, registered office, directors, company secretaries, members, and shareholding details.

SSM states that annual documents may be lodged through the Malaysian Business Reporting System (MBRS) by the appointed licensed company secretary or company agent.

The platform must therefore distinguish between:

- A customer who owns or represents a company.
- A company-secretary firm that performs professional work.
- A licensed secretary or authorised staff member who prepares or lodges work.
- MySect Admin, which operates the software platform but does not replace the professional secretary.

References:

- [SSM Annual Submission](https://www.ssm.com.my/Pages/Register_Business_Company/Company/Annual-Submission.aspx)
- [SSM List of Registered Secretaries](https://www.ssm.com.my/Pages/Licensed_Secretary_Auditors/List-Registered-Secretaries.aspx)
- [SSM MBRS annual-return information](https://crmsv.ssm4u.com.my/ssmkb/SSM4UExternal?language_id=2&name=annual+return)

## 4. Platform structure

```text
MySect Admin / Moderator
    ├── Secretary Firm A
    │     ├── Firm staff
    │     └── Managed companies
    ├── Secretary Firm B
    │     ├── Firm staff
    │     └── Managed companies
    └── Secretary Firm C
          ├── Firm staff
          └── Managed companies

MySect Client
    └── Owns or represents one or more companies
```

Each secretary firm must have isolated access to its own staff, customers, companies, documents, requests, and operational records. MySect Admin may have platform-wide oversight according to permission rules.

## 5. Platform 1: MySect Client

The client platform should allow a company owner, director, or authorised representative to understand the status of their company-secretarial work without needing to understand internal processing details.

### Client capabilities

- View one or more companies.
- View company profile and statutory information.
- View compliance status.
- View upcoming deadlines.
- Upload requested documents.
- Submit company-secretarial requests.
- Request resolutions or company changes.
- Review and approve drafts.
- Sign documents or upload signed copies.
- Download completed company documents.
- View invoices and payment status.
- Chat with the assigned secretary firm.
- Receive reminders and notifications.
- Track the status of every submitted request.

### Suggested client navigation

- Home
- My Companies
- Requests
- Documents
- Compliance Calendar
- Approvals
- Messages
- Invoices
- Profile and Settings

### Client language

The client should see simple statuses such as:

- Waiting for your documents
- Being prepared
- Waiting for your approval
- Ready for submission
- Submitted to SSM
- Completed
- More information required

Internal terms such as internal queue, maker-checker, or platform allocation should not be exposed unless necessary.

## 6. Platform 2: Company Secretary Workspace

The Company Secretary Workspace is the main operational product for secretary firms. It should be a responsive website first because the work involves company registers, tables, long forms, document review, resolutions, filing preparation, and multi-company management.

### Main objective

The workspace must answer:

> Which company requires action, who owns the task, what information is missing, and what is the next deadline?

### Secretary modules

#### 6.1 Operations Dashboard

Show:

- New client requests.
- Newly uploaded documents.
- Companies waiting for client information.
- Drafts waiting for internal review.
- Documents waiting for customer approval.
- Upcoming SSM deadlines.
- Overdue work.
- Unassigned tasks.
- Recent client messages.

#### 6.2 Company Portfolio

Each company record should show:

- Company name and registration number.
- Company type and status.
- Assigned secretary.
- Assigned staff.
- Customer representatives.
- Service package.
- Compliance status.
- Next filing deadline.
- Missing information.
- Recent activity.

#### 6.3 Company Workspace

The secretary should be able to view one company in a complete workspace containing:

- Company profile.
- Directors and officers.
- Shareholders and shareholding.
- Registered office.
- Beneficial ownership information.
- Statutory registers.
- Resolutions and minutes.
- Annual returns.
- Filing history.
- Documents.
- Customer requests.
- Approvals and signatures.
- Invoices.
- Messages.
- Audit history.

#### 6.4 Request Management

Clients may request services such as:

- Change of director.
- Appointment or resignation of secretary.
- Change of registered address.
- Change of business activity.
- Share transfer.
- Allotment of shares.
- Change of shareholder information.
- Resolution preparation.
- Annual return preparation.
- Company document request.
- Certified document request.
- General company-secretarial enquiry.

Each request must have an assigned company, request type, owner, status, due date, required documents, approval history, and final output.

#### 6.5 Document Intake and Review

Staff should be able to:

- Preview uploaded files.
- Classify the document.
- Link it to a company or request.
- Mark it as accepted or rejected.
- Request a replacement.
- Add internal notes.
- Send a customer-facing comment.
- Assign a reviewer.
- Track versions.

#### 6.6 Resolution and Template Management

The workspace should support controlled templates for resolutions, letters, minutes, and notices.

Templates should use company data where appropriate, but every generated document must be reviewed by authorised staff before it is sent to the customer or submitted.

#### 6.7 Compliance Calendar

The calendar should track:

- Annual return deadlines.
- Financial statement-related deadlines where applicable.
- AGM or meeting dates.
- Customer document due dates.
- Resolution deadlines.
- SSM submission dates.
- SSM queries and correction deadlines.
- Internal review deadlines.

#### 6.8 Filing Tracking

The platform should record:

- Filing type.
- Company.
- Responsible secretary.
- Preparation status.
- Customer approval status.
- Submission date.
- Submission reference.
- SSM response.
- Query or rejection reason.
- Resubmission history.
- Final document.

The first version should track filing work accurately. Direct integration with SSM or MBRS should only be implemented after the permitted technical and operational process is confirmed.

#### 6.9 Client Communication

The secretary firm needs a structured alternative to scattered WhatsApp messages and email.

Messages should be linked to:

- A company.
- A request.
- A document.
- A filing.
- A deadline.

The system should support internal notes separately from customer-visible messages.

#### 6.10 Firm Team Management

A secretary firm may have:

- Principal or firm administrator.
- Licensed company secretary.
- Senior reviewer.
- Secretary executive.
- Operations staff.

Permissions must control who can view, edit, approve, submit, assign, and delete records.

## 7. Platform 3: MySect Admin / Moderator

MySect Admin operates the network and platform. It does not replace the professional work of the company-secretary firm.

### Admin capabilities

- Approve and manage secretary firms.
- Store firm licence and practising-certificate information.
- Manage firm administrators and staff roles.
- Create subscription plans.
- Set company limits by plan.
- Assign or transfer companies between firms.
- Monitor firm activity.
- View overdue work and escalations.
- Manage platform fees and commission rules.
- Manage support cases.
- Manage service categories and request types.
- Manage global notifications.
- Review platform-wide reports.
- Suspend or reactivate firms.
- View audit logs.
- Configure platform policies.

### Admin must not automatically expose

- Internal secretary notes to customers.
- One secretary firm’s customer information to another firm.
- Private company documents beyond authorised access.
- Commercial information belonging to another secretary firm.

## 8. End-to-end workflow

```text
Client submits a request
        ↓
Secretary firm receives the request
        ↓
Secretary checks company records
        ↓
Missing information is requested
        ↓
Client uploads or approves documents
        ↓
Secretary prepares resolution or filing
        ↓
Internal review is completed
        ↓
Client signs or approves
        ↓
Licensed secretary submits to SSM when applicable
        ↓
Submission result is recorded
        ↓
Final documents are published to the client
```

### Recommended statuses

- New request
- Under review
- Waiting for client
- Drafting
- Waiting for signature
- Ready for submission
- Submitted to SSM
- Query from SSM
- Completed
- Rejected
- Cancelled
- Overdue

## 9. Website and mobile strategy

### Customer

The existing Flutter application can continue as the main customer mobile platform. A responsive web version may be added later for customers who prefer desktop access.

### Company Secretary

Build the full workspace as a responsive website first. This is the primary operating environment for the secretary firm.

A secretary mobile app can be added later for:

- Notifications.
- Customer chat.
- Quick approvals.
- Document photography.
- Deadline reminders.
- Reviewing urgent requests.
- Task assignment.

### Admin

Build Admin as a website. Admin functions require tables, filters, permissions, reports, and platform-level controls.

## 10. Suggested MVP

### Phase 1: Platform foundation

- Users and roles.
- MySect Admin account.
- Secretary firm accounts.
- Customer accounts.
- Company records.
- Customer-to-firm assignment.
- Basic permissions.
- Document storage.
- Notifications.
- Audit log.

### Phase 2: Core secretary workflow

- Client request submission.
- Secretary request queue.
- Document upload and review.
- Missing-information requests.
- Customer chat.
- Company profile.
- Compliance deadlines.
- Status tracking.

### Phase 3: Corporate-secretarial work

- Director and officer records.
- Shareholder and shareholding records.
- Statutory registers.
- Resolution templates.
- Approval and signature tracking.
- Annual-return preparation tracking.
- Filing history.

### Phase 4: Commercial operations

- Service packages.
- Firm licence limits.
- Invoices.
- Online payment.
- Company allocation limits.
- Platform fees and commission.
- Firm-level reports.

### Phase 5: Mobile companion

- Secretary notifications.
- Quick document capture.
- Customer chat.
- Approval actions.
- Urgent task handling.

## 11. Business decisions still required

Before implementing billing and marketplace behaviour, confirm:

1. What exactly does “RM per SSM per month” mean?
2. Is the fee paid by the customer, the secretary firm, or both?
3. Does MySect charge the secretary firm a software licence fee?
4. Is there a platform commission on each company or service request?
5. Who owns the customer relationship?
6. Can a company be transferred between secretary firms?
7. Who is responsible for customer support?
8. Does each firm set its own service pricing?
9. Does MySect process customer payments?
10. What happens when a secretary firm reaches its company limit?
11. What licence or practising-certificate information must be verified?
12. Will MySect integrate with SSM/MBRS, or only track submissions initially?
13. Which users may approve or lodge filings?
14. What records must remain available for audit or dispute handling?

## 12. Recommended product decision

The first company-secretary release should contain:

- MySect Client Flutter app.
- Company Secretary Workspace web application.
- MySect Admin web application.
- Shared backend with firm, staff, customer, company, and permission boundaries.

The Company Secretary Workspace should be the highest priority new platform because it is the missing operational layer between the existing customer experience and MySect Admin.

The secretary workspace should be a website first. A mobile companion should follow after the request, document, approval, and filing workflows are working reliably on the web.

## 13. Comparable product references

Existing Malaysian company-secretary platforms commonly provide client portals, document repositories, compliance timelines, invoices, requests, annual-return generation, statutory registers, and resolution management:

- [Cogency](https://cogency.my/)
- [Officio](https://getofficio.today/)
- [ezcosec](https://ezcosec.com/)

These references support the general workflow direction, but they do not define MySect’s final commercial model or regulatory process.
