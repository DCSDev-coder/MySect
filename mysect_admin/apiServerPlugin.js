import { initialCompanies, initialFirms, initialClientDocuments } from './src/data/mockData.js';

// In-memory persistent state during dev server run
let companies = [...initialCompanies];
let firms = [...initialFirms];
let documents = initialClientDocuments.filter(d => d.id !== 'DOC-2026-006');
let complianceTasks = [
  {
    id: 'task-sec-01',
    companyId: 'comp-01',
    companyName: 'Data Center Specialists Sdn Bhd (M)',
    title: 'Section 68 Annual Return Lodgement',
    subtitle: 'Filing to SSM with audited financial reports',
    dueDate: new Date(new Date().getFullYear(), new Date().getMonth(), 14).toISOString().split('T')[0],
    category: 'Section 68 Annual Return',
    status: 'Pending',
    createdBy: 'Lim Mei Ling (MIA CA 48192)',
    instructions: 'Upload certified true copies of audited accounts and board declaration for Section 68 lodgement.'
  },
  {
    id: 'task-sec-02',
    companyId: 'comp-01',
    companyName: 'Data Center Specialists Sdn Bhd (M)',
    title: 'Statutory Tax Estimate (CP204)',
    subtitle: 'LHDN statutory company tax schedule lodgement',
    dueDate: new Date(new Date().getFullYear(), new Date().getMonth(), 28).toISOString().split('T')[0],
    category: 'Tax Filing (CP204)',
    status: 'Pending',
    createdBy: 'Lim Mei Ling (MIA CA 48192)',
    instructions: 'Submit revised CP204 tax estimate to LHDN Malaysia.'
  },
  {
    id: 'task-sec-03',
    companyId: 'comp-03',
    companyName: '5Luxe Scents Co.',
    title: 'Statutory Financial Statements Submission',
    subtitle: 'Annual Financial Statements to SSM',
    dueDate: new Date(new Date().getFullYear(), new Date().getMonth(), 20).toISOString().split('T')[0],
    category: 'Financial Statements',
    status: 'Pending',
    createdBy: 'Sarah binti Ahmad (MAICSA 6028192)',
    instructions: 'Prepare directors report and circulation to shareholders.'
  }
];
let ssmFilings = [
  {
    id: 'SSM-01',
    referenceNo: 'SSM/S68/2026/04812',
    companyId: 'comp-01',
    companyName: 'Data Center Specialists Sdn Bhd (M)',
    companySsmNo: '202101039281 (1429581-X)',
    assignedSecretary: 'Lim Mei Ling (MIA)',
    assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
    filingType: 'Section 68 Annual Return',
    title: 'Section 68 Annual Return Lodgement 2026',
    description: 'Annual Return submission with unaudited management accounts and audited director report for statutory filing.',
    submittedDate: '2026-10-20T14:30:00.000Z',
    deadline: '2026-11-14',
    status: 'waitingSecretaryReview',
    attachedFiles: [
      'DCS_Management_Accounts_FY2026.pdf (2.4 MB)',
      'Director_Declaration_Form.pdf (850 KB)',
      'Bank_Statement_Confirmation.pdf (1.1 MB)'
    ],
    timeline: [
      {
        title: 'SSM File Submitted by Client',
        description: 'Uploaded management accounts and statutory declarations.',
        timestamp: '20 Oct 2026, 2:30 PM',
        isCompleted: true,
        isCurrent: false
      },
      {
        title: 'Waiting for Secretary Review',
        description: 'Assigned to Lim Mei Ling (MIA) at SectPro Corporate Services.',
        timestamp: 'In Progress',
        isCompleted: false,
        isCurrent: true
      },
      {
        title: 'Secretary Preparation & Customer Approval',
        description: 'Drafting Section 68 e-Filing schedule and resolution.',
        timestamp: 'Pending review',
        isCompleted: false,
        isCurrent: false
      },
      {
        title: 'Lodged to SSM MBRS Portal',
        description: 'Official submission to Suruhanjaya Syarikat Malaysia.',
        timestamp: 'Scheduled',
        isCompleted: false,
        isCurrent: false
      }
    ]
  }
];

export function apiServerPlugin() {
  return {
    name: 'mysect-api-server',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        // Set CORS headers so both Flutter Mobile, Emulator, Desktop, and Web can connect
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');

        if (req.method === 'OPTIONS') {
          res.statusCode = 204;
          res.end();
          return;
        }

        const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
        const pathname = url.pathname;

        // Health check
        if (pathname === '/api/health') {
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify({
            status: 'ok',
            server: 'MySect Admin Platform API',
            activeCompaniesCount: companies.length,
            timestamp: new Date().toISOString()
          }));
          return;
        }

        // Auth routes
        if (pathname === '/api/auth/login' && req.method === 'POST') {
          let body = '';
          req.on('data', chunk => { body += chunk; });
          req.on('end', () => {
            try {
              const { email = '', password = '' } = JSON.parse(body || '{}');
              const token = 'tok_adm_' + Math.random().toString(36).substring(2);
              const user = {
                id: 'usr-admin-01',
                email: email || 'admin@mysect.com.my',
                name: email.includes('admin') ? 'Ahmad Faizal' : (email.split('@')[0] || 'Operator'),
                role: 'Super Admin',
                department: 'HQ Platform Operations',
                avatar: 'AF',
                token,
                loginTime: new Date().toISOString()
              };
              res.setHeader('Content-Type', 'application/json');
              res.end(JSON.stringify({ success: true, token, user }));
            } catch (err) {
              res.statusCode = 400;
              res.setHeader('Content-Type', 'application/json');
              res.end(JSON.stringify({ error: err.message }));
            }
          });
          return;
        }

        if (pathname === '/api/auth/logout' && req.method === 'POST') {
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify({ success: true, message: 'Signed out successfully' }));
          return;
        }

        // Get firms
        if (pathname === '/api/firms' && req.method === 'GET') {
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify(firms));
          return;
        }

        // Companies routes
        if (pathname === '/api/companies') {
          if (req.method === 'GET') {
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(companies));
            return;
          }

          if (req.method === 'POST') {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              try {
                const newComp = JSON.parse(body || '{}');
                const id = 'comp-' + String(companies.length + 1).padStart(2, '0');
                const created = {
                  id,
                  name: newComp.name || 'New Company Sdn Bhd',
                  ssmNo: newComp.ssmNo || ('202601' + Math.floor(100000 + Math.random() * 900000) + ' (999999-X)'),
                  type: newComp.type || 'Sdn Bhd',
                  incorporationDate: newComp.incorporationDate || new Date().toISOString().split('T')[0],
                  assignedFirmId: newComp.assignedFirmId || 'firm-01',
                  assignedFirmName: newComp.assignedFirmName || 'SectPro Corporate Services Sdn Bhd',
                  assignedSecretary: newComp.assignedSecretary || 'Lim Mei Ling (MIA)',
                  assignedSecretaryLicense: newComp.assignedSecretaryLicense || 'MIA CA 48192',
                  assignedFirmContact: newComp.assignedFirmContact || '+60 3-2148 9920',
                  assignedFirmEmail: newComp.assignedFirmEmail || 'azman@sectpro.com.my',
                  status: newComp.status || 'Active',
                  directorsCount: newComp.directors?.length || 1,
                  shareholdersCount: newComp.shareholders?.length || 1,
                  paidUpCapital: newComp.paidUpCapital || 'MYR 100,000',
                  annualReturnDeadline: newComp.annualReturnDeadline || '2027-01-15',
                  financialStatementsDeadline: newComp.financialStatementsDeadline || '2027-02-28',
                  pendingRequestsCount: 0,
                  clientContact: newComp.clientContact || 'Director',
                  clientEmail: newComp.clientEmail || 'client@company.my',
                  officialEmail: newComp.officialEmail || 'info@company.my',
                  registeredAddress: newComp.registeredAddress || 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur',
                  businessAddress: newComp.businessAddress || 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur',
                  mobileAppConnected: true,
                  lastMobileSync: new Date().toISOString().replace('T', ' ').substring(0, 16) + ' (Active)',
                  directors: newComp.directors || [{ name: newComp.clientContact || 'Director', role: 'Managing Director' }],
                  shareholders: newComp.shareholders || [{ shareholder: newComp.clientContact || 'Director', type: 'Ordinary', numberOfShares: '100,000', totalShares: '100,000', percentage: '100%' }],
                  statutoryDocuments: newComp.statutoryDocuments || [
                    { id: 'doc-new-1', title: 'Company Constitution (M&AA)', category: 'Statutory', date: new Date().toISOString().split('T')[0], size: '1.8 MB' },
                    { id: 'doc-new-2', title: 'SSM Section 14 Certificate of Incorporation', category: 'SSM Filing', date: new Date().toISOString().split('T')[0], size: '750 KB' }
                  ]
                };
                companies.push(created);
                res.statusCode = 201;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify(created));
              } catch (err) {
                res.statusCode = 400;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: err.message }));
              }
            });
            return;
          }
        }

        // Single company route /api/companies/:id
        const compMatch = pathname.match(/^\/api\/companies\/([^/]+)(\/(.*))?$/);
        if (compMatch) {
          const compId = compMatch[1];
          const subAction = compMatch[3]; // e.g. 'transfer', 'sync'

          const companyIndex = companies.findIndex(c => c.id === compId || c.name.toLowerCase() === decodeURIComponent(compId).toLowerCase());
          if (companyIndex === -1) {
            res.statusCode = 404;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({ error: 'Company not found' }));
            return;
          }

          if (!subAction && req.method === 'GET') {
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(companies[companyIndex]));
            return;
          }

          if (subAction === 'transfer' && (req.method === 'PUT' || req.method === 'POST')) {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              try {
                const data = JSON.parse(body || '{}');
                companies[companyIndex] = {
                  ...companies[companyIndex],
                  assignedFirmId: data.targetFirmId || companies[companyIndex].assignedFirmId,
                  assignedFirmName: data.targetFirmName || companies[companyIndex].assignedFirmName,
                  status: 'Active',
                  transferReason: null
                };
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify(companies[companyIndex]));
              } catch (err) {
                res.statusCode = 400;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: err.message }));
              }
            });
            return;
          }

          if (subAction === 'sync' && req.method === 'POST') {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              companies[companyIndex].mobileAppConnected = true;
              companies[companyIndex].lastMobileSync = new Date().toISOString().replace('T', ' ').substring(0, 16) + ' (Mobile Synced)';
              res.setHeader('Content-Type', 'application/json');
              res.end(JSON.stringify({
                synced: true,
                company: companies[companyIndex]
              }));
            });
            return;
          }
        }

        // ==========================================
        // Compliance Tasks & Datelines API Routes
        // ==========================================
        if (pathname === '/api/compliance-tasks') {
          if (req.method === 'GET') {
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(complianceTasks));
            return;
          }
          if (req.method === 'POST') {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              try {
                const newTask = JSON.parse(body || '{}');
                const existingIdx = complianceTasks.findIndex(t => t.id === newTask.id);
                if (existingIdx !== -1) {
                  complianceTasks[existingIdx] = { ...complianceTasks[existingIdx], ...newTask };
                  res.setHeader('Content-Type', 'application/json');
                  res.end(JSON.stringify(complianceTasks[existingIdx]));
                } else {
                  complianceTasks.unshift(newTask);
                  res.statusCode = 201;
                  res.setHeader('Content-Type', 'application/json');
                  res.end(JSON.stringify(newTask));
                }
              } catch (err) {
                res.statusCode = 400;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: err.message }));
              }
            });
            return;
          }
        }
        if (pathname.startsWith('/api/compliance-tasks/') && req.method === 'DELETE') {
          const taskId = pathname.replace('/api/compliance-tasks/', '');
          complianceTasks = complianceTasks.filter(t => t.id !== taskId);
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify({ success: true, deletedId: taskId }));
          return;
        }

        // ==========================================
        // SSM Filings & Progress API Routes
        // ==========================================
        if (pathname === '/api/ssm-filings') {
          if (req.method === 'GET') {
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(ssmFilings));
            return;
          }
        }
        if (pathname.startsWith('/api/ssm-filings/') && req.method === 'PATCH') {
          const ref = decodeURIComponent(pathname.replace('/api/ssm-filings/', ''));
          let body = '';
          req.on('data', chunk => { body += chunk; });
          req.on('end', () => {
            try {
              const patch = JSON.parse(body || '{}');
              const idx = ssmFilings.findIndex(f => f.referenceNo === ref || f.id === ref);
              if (idx !== -1) {
                ssmFilings[idx] = { ...ssmFilings[idx], ...patch };
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify(ssmFilings[idx]));
              } else {
                ssmFilings.unshift(patch);
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify(patch));
              }
            } catch (e) {
              res.statusCode = 400;
              res.end(JSON.stringify({ error: e.message }));
            }
          });
          return;
        }

        // ==========================================
        // Secretary Document Intake & Review API Routes
        // ==========================================

        // 1. GET all documents & POST new uploaded document
        if (pathname === '/api/documents') {
          if (req.method === 'GET') {
            const companyIdFilter = url.searchParams.get('companyId');
            const statusFilter = url.searchParams.get('status');
            let results = [...documents];

            if (companyIdFilter) {
              results = results.filter(d => d.companyId === companyIdFilter);
            }
            if (statusFilter) {
              results = results.filter(d => d.status.toLowerCase() === statusFilter.toLowerCase());
            }

            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(results));
            return;
          }

          if (req.method === 'POST') {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              try {
                const payload = JSON.parse(body || '{}');
                const newId = 'DOC-2026-' + String(documents.length + 1).padStart(3, '0');
                const newDoc = {
                  id: newId,
                  title: payload.title || payload.originalName || 'Client_Uploaded_Document.pdf',
                  originalName: payload.originalName || payload.title || 'Client_Uploaded_Document.pdf',
                  category: payload.category || 'General Statutory Filing',
                  fileSize: payload.fileSize || '1.5 MB',
                  fileType: payload.fileType || 'application/pdf',
                  companyId: payload.companyId || 'comp-01',
                  companyName: payload.companyName || 'Data Center Specialists Sdn Bhd (M)',
                  companySsmNo: payload.companySsmNo || '202101039281 (1429581-X)',
                  assignedFirmId: payload.assignedFirmId || 'firm-01',
                  assignedFirmName: payload.assignedFirmName || 'SectPro Corporate Services Sdn Bhd',
                  assignedSecretary: payload.assignedSecretary || 'Lim Mei Ling (MIA CA 48192)',
                  uploadedBy: payload.uploadedBy || 'Client User (Director)',
                  uploadedByRole: payload.uploadedByRole || 'Managing Director (Client)',
                  uploadedAt: new Date().toISOString().replace('T', ' ').substring(0, 16),
                  storageLocation: 'TM Cloud',
                  storageUrl: `tmcloud://alpha-dc1/vault/${payload.companyId || 'comp-01'}/${payload.title || 'doc.pdf'}`,
                  sha256Hash: Math.random().toString(16).substring(2) + Math.random().toString(16).substring(2),
                  status: 'Pending Review',
                  linkedFilingRef: payload.linkedFilingRef || 'SSM/GEN/2026/' + Math.floor(1000 + Math.random() * 9000),
                  submissionNotes: payload.submissionNotes || 'Uploaded via MySect Mobile App for Secretary verification.',
                  reviewDetails: null,
                  auditTrail: [
                    {
                      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
                      action: 'FILE_UPLOADED',
                      actor: `${payload.uploadedBy || 'Client Director'} (${payload.uploadedByRole || 'Client'})`,
                      details: 'Uploaded document via MySect Mobile App.'
                    }
                  ]
                };

                documents.unshift(newDoc);
                res.statusCode = 201;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify(newDoc));
              } catch (err) {
                res.statusCode = 400;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: err.message }));
              }
            });
            return;
          }
        }

        // 2. Single document & Review decision routes
        const docReviewMatch = pathname.match(/^\/api\/documents\/([^/]+)(\/review)?$/);
        if (docReviewMatch) {
          const docId = docReviewMatch[1];
          const isReviewAction = !!docReviewMatch[2];

          const docIndex = documents.findIndex(d => d.id === docId);
          if (docIndex === -1) {
            res.statusCode = 404;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({ error: 'Document not found' }));
            return;
          }

          if (!isReviewAction && req.method === 'GET') {
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(documents[docIndex]));
            return;
          }

          // Secretary review action: Approved, Rejected, More Details Needed
          if (isReviewAction && (req.method === 'POST' || req.method === 'PATCH' || req.method === 'PUT')) {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
              try {
                const {
                  decision = 'Approved', // 'Approved' | 'Rejected' | 'More Details Needed'
                  reviewedBy = 'Lim Mei Ling (MIA CA 48192)',
                  remarks = '',
                  rejectionReason = '',
                  requestedDetails = '',
                  internalNotes = ''
                } = JSON.parse(body || '{}');

                const targetDoc = documents[docIndex];
                const nowStr = new Date().toISOString().replace('T', ' ').substring(0, 16);

                targetDoc.status = decision;
                targetDoc.reviewDetails = {
                  reviewedBy,
                  reviewedAt: nowStr,
                  decision,
                  internalNotes,
                  remarks: decision === 'Approved' ? remarks : undefined,
                  rejectionReason: decision === 'Rejected' ? rejectionReason : undefined,
                  requestedDetails: decision === 'More Details Needed' ? requestedDetails : undefined
                };

                let auditAction = 'FILE_REVIEWED';
                let auditDetail = `Secretary ${reviewedBy} marked file as ${decision}.`;

                if (decision === 'Approved') {
                  auditAction = 'FILE_APPROVED';
                  auditDetail = `Secretary ${reviewedBy} approved the file for SSM compliance. Remarks: ${remarks || 'None'}`;
                } else if (decision === 'Rejected') {
                  auditAction = 'FILE_REJECTED';
                  auditDetail = `Secretary ${reviewedBy} rejected the file. Reason: ${rejectionReason}`;
                } else if (decision === 'More Details Needed') {
                  auditAction = 'DETAILS_REQUESTED';
                  auditDetail = `Secretary ${reviewedBy} requested more details from client: ${requestedDetails}`;
                }

                targetDoc.auditTrail.push({
                  timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
                  action: auditAction,
                  actor: reviewedBy,
                  details: auditDetail
                });

                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({
                  success: true,
                  document: targetDoc,
                  message: `Document status updated to ${decision}`
                }));
              } catch (err) {
                res.statusCode = 400;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: err.message }));
              }
            });
            return;
          }
        }

        next();
      });
    }
  };
}
