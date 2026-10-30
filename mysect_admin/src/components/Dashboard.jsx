import React from 'react';
import { 
  Building2, Users, AlertTriangle, TrendingUp, 
  CheckCircle2, ArrowRight
} from 'lucide-react';

const Dashboard = ({ 
  firms = [], 
  companies = [], 
  escalations = [], 
  setActivePage,
  onApproveFirm,
}) => {
  const activeFirms = firms.filter(f => f.status === 'Active');
  const pendingFirms = firms.filter(f => f.status === 'Pending Verification');
  const urgentEscalations = escalations.filter(e => !e.status.includes('Resolved'));
  const totalCompanies = firms.reduce((acc, f) => acc + (f.companiesCount || 0), 0) + companies.length;

  return (
    <div className="flex-1 flex flex-col h-screen overflow-hidden bg-[#F8F9FA]">
      {/* Pinned Top Navigation Bar */}
      <div className="bg-white border-b border-gray-200 px-8 py-5 shrink-0">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Platform Overview</h1>
            <p className="text-sm text-gray-500 mt-0.5">
              Key metrics and actions requiring attention across the MySect network.
            </p>
          </div>

          {pendingFirms.length > 0 && (
            <button 
              onClick={() => setActivePage('Firms')}
              className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-sm font-semibold transition-colors shadow-xs flex items-center gap-2 cursor-pointer"
            >
              Review {pendingFirms.length} Pending Firm{pendingFirms.length > 1 ? 's' : ''}
              <ArrowRight className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Scrollable Content Area */}
      <div className="flex-1 overflow-y-auto p-8">
        {/* 4 Clean Stats */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div 
          onClick={() => setActivePage('Firms')}
          className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs hover:border-gray-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between text-gray-500">
            <span className="text-xs font-semibold uppercase tracking-wider">Secretary Firms</span>
            <Building2 className="w-4 h-4 text-[#062AAE]" />
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-gray-900">{activeFirms.length}</span>
            {pendingFirms.length > 0 && (
              <span className="text-xs font-semibold px-2 py-0.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-full">
                {pendingFirms.length} pending
              </span>
            )}
          </div>
          <p className="text-xs text-gray-400 mt-1">Verified partner firms</p>
        </div>

        <div 
          onClick={() => setActivePage('Companies')}
          className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs hover:border-gray-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between text-gray-500">
            <span className="text-xs font-semibold uppercase tracking-wider">Managed Companies</span>
            <Users className="w-4 h-4 text-emerald-600" />
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-gray-900">{totalCompanies}</span>
            <span className="text-xs font-semibold text-emerald-600 flex items-center">
              +14% mo/mo
            </span>
          </div>
          <p className="text-xs text-gray-400 mt-1">Active Sdn Bhd portfolios</p>
        </div>

        <div 
          onClick={() => setActivePage('Operations')}
          className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs hover:border-gray-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between text-gray-500">
            <span className="text-xs font-semibold uppercase tracking-wider">Open Issues</span>
            <AlertTriangle className="w-4 h-4 text-rose-500" />
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-gray-900">{urgentEscalations.length}</span>
            <span className="text-xs font-semibold text-rose-600">Requires review</span>
          </div>
          <p className="text-xs text-gray-400 mt-1">Overdue filings & escalations</p>
        </div>

        <div 
          onClick={() => setActivePage('Settings')}
          className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs hover:border-gray-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between text-gray-500">
            <span className="text-xs font-semibold uppercase tracking-wider">Monthly Platform Revenue</span>
            <TrendingUp className="w-4 h-4 text-indigo-600" />
          </div>
          <div className="mt-3 flex items-baseline gap-1">
            <span className="text-xs text-gray-400 font-semibold">MYR</span>
            <span className="text-3xl font-extrabold text-gray-900">32,840</span>
          </div>
          <p className="text-xs text-gray-400 mt-1">Subscriptions & company fees</p>
        </div>
      </div>

      {/* 2 Calm Content Sections */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
        
        {/* Left: Pending Firm Verifications */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <div className="flex items-center justify-between pb-4 border-b border-gray-100">
            <div>
              <h2 className="text-base font-bold text-gray-900">Pending Firm Approvals</h2>
              <p className="text-xs text-gray-500 mt-0.5">Firms awaiting credentials verification before onboarding.</p>
            </div>
            <button 
              onClick={() => setActivePage('Firms')}
              className="text-xs font-semibold text-[#062AAE] hover:underline"
            >
              View directory &rarr;
            </button>
          </div>

          <div className="divide-y divide-gray-100 mt-2">
            {pendingFirms.length === 0 ? (
              <div className="py-8 text-center text-xs text-gray-400">
                <CheckCircle2 className="w-6 h-6 text-emerald-500 mx-auto mb-1.5" />
                No pending firm approvals. All partner firms are verified.
              </div>
            ) : (
              pendingFirms.map((firm) => (
                <div key={firm.id} className="py-3.5 flex items-center justify-between gap-4">
                  <div>
                    <h3 className="text-sm font-semibold text-gray-900">{firm.name}</h3>
                    <p className="text-xs text-gray-500 mt-0.5">
                      SSM: {firm.ssmRegistration} • Principal: {firm.contactPerson}
                    </p>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      onClick={() => onApproveFirm && onApproveFirm(firm.id)}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold transition-colors shadow-2xs"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => setActivePage('Firms')}
                      className="px-3 py-1.5 bg-gray-50 hover:bg-gray-100 text-gray-700 rounded-lg text-xs font-medium transition-colors border border-gray-200"
                    >
                      Details
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right: Urgent Overdue Filings & Escalations */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <div className="flex items-center justify-between pb-4 border-b border-gray-100">
            <div>
              <h2 className="text-base font-bold text-gray-900">Urgent Issues & Overdue Work</h2>
              <p className="text-xs text-gray-500 mt-0.5">Section 68 deadlines or AI chatbot escalations.</p>
            </div>
            <button 
              onClick={() => setActivePage('Operations')}
              className="text-xs font-semibold text-rose-600 hover:underline"
            >
              Open resolution room &rarr;
            </button>
          </div>

          <div className="divide-y divide-gray-100 mt-2">
            {urgentEscalations.slice(0, 3).map((esc) => (
              <div key={esc.id} className="py-3.5 flex items-start justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-mono font-bold text-gray-500">{esc.caseNumber}</span>
                    <span className="px-1.5 py-0.5 text-[10px] font-bold bg-rose-50 text-rose-700 rounded border border-rose-200">
                      {esc.severity.split('-')[0].trim()}
                    </span>
                  </div>
                  <h3 className="text-sm font-semibold text-gray-900 mt-1">{esc.companyName}</h3>
                  <p className="text-xs text-gray-500 mt-0.5 line-clamp-1">{esc.summary}</p>
                </div>

                <button
                  onClick={() => setActivePage('Operations')}
                  className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-lg text-xs font-semibold shrink-0 transition-colors"
                >
                  Review
                </button>
              </div>
            ))}
          </div>
        </div>

      </div>

      {/* Capacity & System Safeguards Footer */}
      <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6 mt-6">
        <h2 className="text-sm font-bold text-gray-900">Firm Capacity & Infrastructure</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-4 text-xs">
          <div>
            <div className="flex justify-between text-gray-600 mb-1">
              <span>SectPro Corporate Services</span>
              <strong className="text-gray-900">84 / 100 Co.</strong>
            </div>
            <div className="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
              <div className="h-full bg-[#062AAE] rounded-full" style={{ width: '84%' }}></div>
            </div>
          </div>

          <div>
            <div className="flex justify-between text-gray-600 mb-1">
              <span>Apex Corporate Partners</span>
              <strong className="text-gray-900">192 / 250 Co.</strong>
            </div>
            <div className="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
              <div className="h-full bg-[#062AAE] rounded-full" style={{ width: '76.8%' }}></div>
            </div>
          </div>

          <div>
            <div className="flex justify-between text-gray-600 mb-1">
              <span>Cloud Storage (Malaysia)</span>
              <strong className="text-gray-900">412 GB / 1 TB</strong>
            </div>
            <div className="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
              <div className="h-full bg-blue-500 rounded-full" style={{ width: '41.2%' }}></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </div>
  );
};

export default Dashboard;
