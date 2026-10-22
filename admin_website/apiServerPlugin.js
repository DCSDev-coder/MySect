import { initialCompanies, initialFirms } from './src/data/mockData.js';

// In-memory persistent state during dev server run
let companies = [...initialCompanies];
let firms = [...initialFirms];

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

        next();
      });
    }
  };
}
