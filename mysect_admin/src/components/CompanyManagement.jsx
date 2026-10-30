import React, { useState } from 'react';
import { 
  Users, ArrowRightLeft, Search, 
  CheckCircle2, ShieldCheck, Smartphone, Plus,
  Building2, Calendar, FileText, ExternalLink,
  Check, RefreshCw, X, CreditCard
} from 'lucide-react';

const getSubscriptionExpiryStatus = (dateStr) => {
  if (!dateStr) return { label: 'Active', isExpiring: false, isExpired: false, color: 'emerald', daysRemaining: 365 };
  const expiry = new Date(dateStr);
  const now = new Date('2026-10-22');
  const diffTime = expiry.getTime() - now.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  if (diffDays < 0) {
    return { label: `Expired (${Math.abs(diffDays)}d ago)`, isExpiring: true, isExpired: true, color: 'rose', daysRemaining: diffDays };
  } else if (diffDays <= 45) {
    return { label: `Renews in ${diffDays}d`, isExpiring: true, isExpired: false, color: 'amber', daysRemaining: diffDays };
  } else {
    return { label: 'Active', isExpiring: false, isExpired: false, color: 'emerald', daysRemaining: diffDays };
  }
};

const CompanyManagement = ({ 
  companies = [], 
  firms = [], 
  onTransferCompany,
  onCreateCompany 
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterFirm, setFilterFirm] = useState('All');
  const [filterStatus, setFilterStatus] = useState('All');
  const [showTransferModal, setShowTransferModal] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [selectedCompany, setSelectedCompany] = useState(null);
  
  // Transfer form state
  const [targetFirmId, setTargetFirmId] = useState('');
  const [transferReason, setTransferReason] = useState('');
  const [effectiveDate, setEffectiveDate] = useState('2026-10-25');
  const [statutoryHandoverChecked, setStatutoryHandoverChecked] = useState(false);
  const [clientConsentChecked, setClientConsentChecked] = useState(false);

  // New Company form state
  const [newCompanyName, setNewCompanyName] = useState('');
  const [newSsmNo, setNewSsmNo] = useState('');
  const [newCompanyType, setNewCompanyType] = useState('Sdn Bhd (Sendirian Berhad)');
  const [newPaidUpCapital, setNewPaidUpCapital] = useState('MYR 100,000');
  const [newAssignedFirmId, setNewAssignedFirmId] = useState(firms[0]?.id || 'firm-01');
  const [newClientContact, setNewClientContact] = useState('');
  const [newClientEmail, setNewClientEmail] = useState('');
  const [newOfficialEmail, setNewOfficialEmail] = useState('');
  const [newRegisteredAddress, setNewRegisteredAddress] = useState('');
  const [newSubscriptionExpiresAt, setNewSubscriptionExpiresAt] = useState('2027-10-22');
  const [newSubscriptionPlan, setNewSubscriptionPlan] = useState('Growth Plan');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [syncMessage, setSyncMessage] = useState(null);

  const filteredCompanies = companies.filter(c => {
    const matchesSearch = c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          c.ssmNo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          (c.clientContact && c.clientContact.toLowerCase().includes(searchTerm.toLowerCase())) ||
                          (c.assignedFirmName && c.assignedFirmName.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesFirm = filterFirm === 'All' || c.assignedFirmId === filterFirm;
    const matchesStatus = filterStatus === 'All'
      ? true
      : filterStatus === 'Expiring Soon'
        ? getSubscriptionExpiryStatus(c.subscriptionExpiresAt).isExpiring
        : c.status === filterStatus;
    return matchesSearch && matchesFirm && matchesStatus;
  });

  const handleOpenTransfer = (company, e) => {
    if (e) e.stopPropagation();
    setSelectedCompany(company);
    const availableFirms = firms.filter(f => f.status === 'Active' && f.id !== company.assignedFirmId);
    setTargetFirmId(availableFirms[0]?.id || '');
    setTransferReason(company.transferReason || 'Client portfolio reallocation / Secretary firm handover');
    setStatutoryHandoverChecked(false);
    setClientConsentChecked(false);
    setShowTransferModal(true);
  };

  const handleConfirmTransfer = async () => {
    if (!selectedCompany || !targetFirmId) return;
    const destFirm = firms.find(f => f.id === targetFirmId);
    if (!destFirm) return;

    // Call API endpoint to update backend store if running
    try {
      await fetch(`/api/companies/${selectedCompany.id}/transfer`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          targetFirmId: destFirm.id,
          targetFirmName: destFirm.name,
          transferReason
        })
      });
    } catch (_) {}

    if (onTransferCompany) {
      onTransferCompany(selectedCompany.id, destFirm.id, destFirm.name, transferReason);
    }

    setShowTransferModal(false);
  };

  const handleCreateNewCompany = async (e) => {
    e.preventDefault();
    if (!newCompanyName.trim()) return;

    setIsSubmitting(true);
    const firmObj = firms.find(f => f.id === newAssignedFirmId) || firms[0];
    const generatedSsm = newSsmNo.trim() || `202601${Math.floor(100000 + Math.random() * 900000)} (1582910-K)`;

    const newCompanyObj = {
      id: `comp-${String(companies.length + 1).padStart(2, '0')}`,
      name: newCompanyName.trim(),
      ssmNo: generatedSsm,
      type: newCompanyType,
      incorporationDate: new Date().toISOString().split('T')[0],
      assignedFirmId: firmObj?.id || 'firm-01',
      assignedFirmName: firmObj?.name || 'SectPro Corporate Services Sdn Bhd',
      assignedSecretary: firmObj?.staff?.[0]?.name || 'Lim Mei Ling (MIA)',
      assignedSecretaryLicense: 'MIA CA 48192',
      assignedFirmContact: firmObj?.phone || '+60 3-2148 9920',
      assignedFirmEmail: firmObj?.email || 'azman@sectpro.com.my',
      status: 'Active',
      subscriptionExpiresAt: newSubscriptionExpiresAt || '2027-10-22',
      subscriptionPlan: newSubscriptionPlan || 'Growth Plan',
      subscriptionStatus: 'Active',
      billingCycle: 'Annual Prepaid',
      directorsCount: 1,
      shareholdersCount: 1,
      paidUpCapital: newPaidUpCapital,
      annualReturnDeadline: '2027-01-15',
      financialStatementsDeadline: '2027-02-28',
      pendingRequestsCount: 0,
      clientContact: newClientContact.trim() || 'Managing Director',
      clientEmail: newClientEmail.trim() || 'director@company.com.my',
      officialEmail: newOfficialEmail.trim() || 'info@company.com.my',
      registeredAddress: newRegisteredAddress.trim() || (firmObj?.address || 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur'),
      businessAddress: newRegisteredAddress.trim() || 'Kuala Lumpur, Malaysia',
      mobileAppConnected: true,
      lastMobileSync: `${new Date().toISOString().replace('T', ' ').substring(0, 16)} (Active)`,
      directors: [
        { name: newClientContact.trim() || 'Managing Director', role: 'Director', appointedDate: new Date().toISOString().split('T')[0] }
      ],
      shareholders: [
        { shareholder: newClientContact.trim() || 'Managing Director', type: 'Ordinary', numberOfShares: '100,000', totalShares: '100,000', percentage: '100%' }
      ],
      statutoryDocuments: [
        { id: `doc-${Date.now()}-1`, title: 'Company Constitution (M&AA)', category: 'Statutory', date: new Date().toISOString().split('T')[0], size: '1.8 MB' },
        { id: `doc-${Date.now()}-2`, title: 'SSM Section 14 Certificate of Incorporation', category: 'SSM Filing', date: new Date().toISOString().split('T')[0], size: '750 KB' }
      ]
    };

    // Post to API if backend available
    try {
      await fetch('/api/companies', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newCompanyObj)
      });
    } catch (_) {}

    if (onCreateCompany) {
      onCreateCompany(newCompanyObj);
    }

    setIsSubmitting(false);
    setShowAddModal(false);
    // Reset form
    setNewCompanyName('');
    setNewSsmNo('');
    setNewClientContact('');
    setNewClientEmail('');
    setNewOfficialEmail('');
    setNewRegisteredAddress('');
    setNewSubscriptionExpiresAt('2027-10-22');
    setNewSubscriptionPlan('Growth Plan');
  };

  const handlePingMobileSync = async (company) => {
    try {
      await fetch(`/api/companies/${company.id}/sync`, { method: 'POST' });
      setSyncMessage(`Ping sent to ${company.name} mobile client session.`);
      setTimeout(() => setSyncMessage(null), 3000);
    } catch (_) {
      setSyncMessage(`Mobile client active for ${company.name}.`);
      setTimeout(() => setSyncMessage(null), 3000);
    }
  };

  const targetFirmObj = firms.find(f => f.id === targetFirmId);

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Toast Notification */}
      {syncMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-emerald-600 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg flex items-center gap-2">
          <Check className="w-4 h-4" />
          <span>{syncMessage}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <Users className="w-4 h-4" />
            <span>Company Directory & Secretary Custody</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Managed Companies & Mobile Client Connections</h1>
          <p className="text-sm text-gray-500">
            Oversee company portfolios, assign newly onboarded businesses, and monitor live connectivity with the MySect Client Mobile App.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="text-xs bg-white border border-gray-200 rounded-lg p-2.5 px-4 shadow-xs flex items-center gap-2">
            <span className="text-gray-500 whitespace-nowrap">Total Companies:</span>{' '}
            <strong className="text-gray-900 text-sm whitespace-nowrap">{companies.length}</strong>
            <span className="mx-1 text-gray-300">|</span>
            <span className="text-emerald-600 font-medium whitespace-nowrap">
              {companies.filter(c => c.mobileAppConnected).length} mobile connected
            </span>
            <span className="mx-1 text-gray-300">|</span>
            <span className="text-amber-600 font-medium whitespace-nowrap">
              {companies.filter(c => getSubscriptionExpiryStatus(c.subscriptionExpiresAt).isExpiring).length} renewal due
            </span>
          </div>

          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-1.5 px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white text-xs font-semibold rounded-lg shadow-sm transition-colors cursor-pointer whitespace-nowrap shrink-0"
          >
            <Plus className="w-4 h-4" />
            <span>Onboard Company</span>
          </button>
        </div>
      </div>

      {/* Filters Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs mt-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            type="text"
            placeholder="Search company name, SSM number, client user..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-2 text-xs text-gray-500">
            <span>Filter Firm:</span>
            <select
              value={filterFirm}
              onChange={(e) => setFilterFirm(e.target.value)}
              className="py-1.5 px-3 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
            >
              <option value="All">All Secretary Firms</option>
              {firms.map(f => (
                <option key={f.id} value={f.id}>{f.name}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 text-xs text-gray-500">
            <span>Status:</span>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="py-1.5 px-3 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
            >
              <option value="All">All Statuses</option>
              <option value="Active">Active</option>
              <option value="Transfer Pending">Transfer Pending</option>
              <option value="Expiring Soon">Renewal Due (Expiring Soon)</option>
            </select>
          </div>
        </div>
      </div>

      {/* Companies Table */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-xs overflow-hidden mt-6">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Company & SSM Registration</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Assigned Secretary Firm</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Mobile Client Status</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Client Contact</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Subscription Expiry</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Next SSM Deadline</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Status</th>
                <th className="px-5 py-3.5 text-center font-semibold text-gray-600 whitespace-nowrap">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {filteredCompanies.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-5 py-8 text-center text-gray-500">
                    No companies found matching the filter criteria.
                  </td>
                </tr>
              ) : (
                filteredCompanies.map((company) => (
                  <tr 
                    key={company.id} 
                    onClick={() => {
                      setSelectedCompany(company);
                      setShowDetailModal(true);
                    }}
                    className="hover:bg-gray-50/80 transition-colors cursor-pointer group"
                  >
                    <td className="px-5 py-4">
                      <div className="font-semibold text-sm text-gray-900 group-hover:text-[#062AAE] transition-colors flex items-center gap-1.5">
                        <span>{company.name}</span>
                        <ExternalLink className="w-3 h-3 text-gray-400 group-hover:text-[#062AAE] opacity-0 group-hover:opacity-100 transition-opacity" />
                      </div>
                      <div className="text-gray-500 font-mono text-[11px] mt-0.5">{company.ssmNo}</div>
                      <div className="text-[11px] text-gray-400 mt-0.5">
                        {company.type} • Capital: {company.paidUpCapital}
                      </div>
                    </td>

                    <td className="px-5 py-4">
                      <div className="font-medium text-gray-900">{company.assignedFirmName}</div>
                      <div className="text-gray-500 text-[11px]">CoSec: {company.assignedSecretary}</div>
                    </td>

                    <td className="px-5 py-4 whitespace-nowrap">
                      {company.mobileAppConnected ? (
                        <div>
                          <div className="flex items-center gap-1.5">
                            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                            <span className="font-semibold text-emerald-800 text-[11px] bg-emerald-50 px-2 py-0.5 rounded-md border border-emerald-200">
                              Mobile Connected
                            </span>
                          </div>
                          <div className="text-[10px] text-gray-500 mt-1">
                            {company.lastMobileSync || 'Active now'}
                          </div>
                        </div>
                      ) : (
                        <div>
                          <span className="text-[11px] bg-amber-50 text-amber-700 px-2 py-0.5 rounded-md border border-amber-200 font-medium">
                            Invite Pending
                          </span>
                          <div className="text-[10px] text-gray-400 mt-1">Not yet logged in</div>
                        </div>
                      )}
                    </td>

                    <td className="px-5 py-4">
                      <div className="text-gray-900 font-medium">{company.clientContact}</div>
                      <div className="text-gray-500 text-[11px]">{company.clientEmail}</div>
                    </td>

                    <td className="px-5 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-1.5 font-semibold text-gray-900 whitespace-nowrap">
                        <Calendar className="w-3.5 h-3.5 text-[#062AAE] shrink-0" />
                        <span className="whitespace-nowrap">{company.subscriptionExpiresAt || '2027-06-14'}</span>
                      </div>
                      <div className="flex items-center gap-1.5 mt-0.5 whitespace-nowrap">
                        <span className="text-[11px] text-gray-500 whitespace-nowrap">
                          {company.subscriptionPlan || 'Growth Plan'}
                        </span>
                        {(() => {
                          const sub = getSubscriptionExpiryStatus(company.subscriptionExpiresAt);
                          if (sub.isExpiring) {
                            return (
                              <span className="text-[10px] font-semibold bg-amber-50 text-amber-700 border border-amber-200 px-1.5 py-0.2 rounded whitespace-nowrap">
                                {sub.label}
                              </span>
                            );
                          }
                          return (
                            <span className="text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 px-1.5 py-0.2 rounded whitespace-nowrap">
                              Active
                            </span>
                          );
                        })()}
                      </div>
                    </td>

                    <td className="px-5 py-4 whitespace-nowrap">
                      <div className="font-semibold text-gray-800">
                        {company.annualReturnDeadline}
                      </div>
                      <div className="text-[11px] text-gray-500">Annual Return (S.68)</div>
                    </td>

                    <td className="px-5 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center gap-1.5 px-3 py-1 text-xs font-semibold rounded-full whitespace-nowrap ${
                        company.status === 'Active' 
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                          : 'bg-amber-50 text-amber-700 border border-amber-200'
                      }`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${company.status === 'Active' ? 'bg-emerald-500' : 'bg-amber-500'}`} />
                        <span>{company.status}</span>
                      </span>
                    </td>

                    <td className="px-5 py-4 text-center whitespace-nowrap" onClick={(e) => e.stopPropagation()}>
                      <div className="flex items-center justify-center gap-1.5">
                        <button
                          onClick={() => {
                            setSelectedCompany(company);
                            setShowDetailModal(true);
                          }}
                          className="px-2.5 py-1.5 rounded-lg text-xs font-medium text-gray-600 hover:bg-gray-100 border border-gray-200 cursor-pointer"
                        >
                          Profile
                        </button>
                        <button
                          onClick={(e) => handleOpenTransfer(company, e)}
                          className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors flex items-center gap-1 cursor-pointer ${
                            company.status === 'Transfer Pending'
                              ? 'bg-amber-500 hover:bg-amber-600 text-white shadow-xs'
                              : 'bg-white border border-gray-200 hover:bg-gray-100 text-gray-700'
                          }`}
                        >
                          <ArrowRightLeft className="w-3 h-3" />
                          <span>{company.status === 'Transfer Pending' ? 'Resolve' : 'Transfer'}</span>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal 1: Onboard / Add New Company */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl border border-gray-200">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <Building2 className="w-5 h-5 text-[#062AAE]" />
                <h3 className="text-lg font-bold text-gray-900">Onboard Company to Platform</h3>
              </div>
              <button 
                onClick={() => setShowAddModal(false)}
                className="text-gray-400 hover:text-gray-600 text-sm cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <p className="text-xs text-gray-500 mt-2">
              Add a new business entity to MySect Admin. Once registered, it will be instantly available in the client mobile app.
            </p>

            <form onSubmit={handleCreateNewCompany} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Company Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Apex HyperScale Solutions Sdn Bhd"
                  value={newCompanyName}
                  onChange={(e) => setNewCompanyName(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">SSM Registration No.</label>
                  <input
                    type="text"
                    placeholder="e.g. 202601099881 (1582910-K)"
                    value={newSsmNo}
                    onChange={(e) => setNewSsmNo(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Company Type</label>
                  <select
                    value={newCompanyType}
                    onChange={(e) => setNewCompanyType(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="Sdn Bhd (Sendirian Berhad)">Sdn Bhd (Sendirian Berhad)</option>
                    <option value="Berhad (Public Limited)">Berhad (Public Limited)</option>
                    <option value="PLT (Limited Liability Partnership)">PLT (LLP)</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Assign Secretary Firm *</label>
                  <select
                    value={newAssignedFirmId}
                    onChange={(e) => setNewAssignedFirmId(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    {firms.filter(f => f.status === 'Active').map(f => (
                      <option key={f.id} value={f.id}>{f.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Paid-Up Capital</label>
                  <input
                    type="text"
                    placeholder="e.g. MYR 250,000"
                    value={newPaidUpCapital}
                    onChange={(e) => setNewPaidUpCapital(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Mobile Client User (Director) *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Adam Bin Hamzah"
                    value={newClientContact}
                    onChange={(e) => setNewClientContact(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Client Mobile Login Email *</label>
                  <input
                    type="email"
                    required
                    placeholder="e.g. adam@dcs.com.my"
                    value={newClientEmail}
                    onChange={(e) => setNewClientEmail(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Registered Office Address</label>
                <input
                  type="text"
                  placeholder="e.g. Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur"
                  value={newRegisteredAddress}
                  onChange={(e) => setNewRegisteredAddress(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Subscription Plan Tier</label>
                  <select
                    value={newSubscriptionPlan}
                    onChange={(e) => setNewSubscriptionPlan(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="Starter Plan">Starter Plan (RM 249/mo)</option>
                    <option value="Growth Plan">Growth Plan (RM 599/mo)</option>
                    <option value="Professional Plan">Professional Plan (RM 1,299/mo)</option>
                    <option value="Enterprise Plan">Enterprise Plan (RM 2,899/mo)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Subscription Expiry Date</label>
                  <input
                    type="date"
                    value={newSubscriptionExpiresAt}
                    onChange={(e) => setNewSubscriptionExpiresAt(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div className="bg-emerald-50 border border-emerald-200 p-3 rounded-xl flex items-center gap-2 text-xs text-emerald-800">
                <Smartphone className="w-4 h-4 text-emerald-600 shrink-0" />
                <span>
                  This company will automatically be registered as <strong>Mobile App Connected</strong> and sync directly with the client app.
                </span>
              </div>

              <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-100 rounded-lg cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-2 text-xs font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded-lg shadow-sm flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>{isSubmitting ? 'Registering...' : 'Complete Onboarding & Sync Mobile'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal 2: Company Profile & Mobile Connection Inspector */}
      {showDetailModal && selectedCompany && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-xl border border-gray-200 max-h-[90vh] overflow-y-auto">
            <div className="flex items-start justify-between pb-4 border-b border-gray-100">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-xl font-bold text-gray-900">{selectedCompany.name}</h3>
                  <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 text-xs font-semibold rounded-full whitespace-nowrap ${
                    selectedCompany.status === 'Active' 
                      ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                      : 'bg-amber-50 text-amber-700 border border-amber-200'
                  }`}>
                    <span className={`w-1.5 h-1.5 rounded-full ${selectedCompany.status === 'Active' ? 'bg-emerald-500' : 'bg-amber-500'}`} />
                    <span>{selectedCompany.status}</span>
                  </span>
                </div>
                <div className="text-xs text-gray-500 font-mono mt-1">
                  SSM: {selectedCompany.ssmNo} • {selectedCompany.type}
                </div>
              </div>
              <button 
                onClick={() => setShowDetailModal(false)}
                className="text-gray-400 hover:text-gray-600 p-1 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Mobile App Connection Highlight Box */}
            <div className="mt-4 bg-gradient-to-r from-blue-50/80 to-indigo-50/80 border border-blue-200 rounded-xl p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-xl bg-[#062AAE] text-white flex items-center justify-center shadow-xs">
                    <Smartphone className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-gray-900 flex items-center gap-1.5">
                      <span>MySect Mobile App Client Connection</span>
                      {selectedCompany.mobileAppConnected && (
                        <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                      )}
                    </h4>
                    <p className="text-[11px] text-gray-600">
                      Client Portal User: <strong>{selectedCompany.clientContact}</strong> ({selectedCompany.clientEmail})
                    </p>
                  </div>
                </div>

                <button
                  onClick={() => handlePingMobileSync(selectedCompany)}
                  className="px-3 py-1.5 bg-white border border-blue-200 text-[#062AAE] hover:bg-blue-50 text-xs font-semibold rounded-lg shadow-2xs flex items-center gap-1.5 cursor-pointer"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  <span>Sync Heartbeat</span>
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3 mt-3 pt-3 border-t border-blue-100 text-[11px]">
                <div>
                  <span className="text-gray-500">Mobile Status:</span>{' '}
                  <strong className="text-emerald-700">
                    {selectedCompany.mobileAppConnected ? 'Active & Live Connected' : 'Invite Sent'}
                  </strong>
                </div>
                <div>
                  <span className="text-gray-500">Last Synced Time:</span>{' '}
                  <strong className="text-gray-900">{selectedCompany.lastMobileSync || 'Active now'}</strong>
                </div>
              </div>
            </div>

            {/* Secretary Firm Custody Card */}
            <div className="mt-4 bg-gray-50 border border-gray-200 rounded-xl p-4">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-[11px] font-semibold uppercase tracking-wider text-gray-500">Corporate Secretary Custody</div>
                  <h4 className="text-sm font-bold text-gray-900 mt-0.5">{selectedCompany.assignedFirmName}</h4>
                  <p className="text-xs text-gray-600 mt-0.5">
                    CoSec In-Charge: <strong>{selectedCompany.assignedSecretary}</strong> ({selectedCompany.assignedSecretaryLicense || 'Licensed Practitioner'})
                  </p>
                </div>
                <button
                  onClick={(e) => {
                    setShowDetailModal(false);
                    handleOpenTransfer(selectedCompany, e);
                  }}
                  className="px-3 py-1.5 bg-white border border-gray-200 hover:bg-gray-100 text-xs font-medium text-gray-700 rounded-lg flex items-center gap-1 cursor-pointer"
                >
                  <ArrowRightLeft className="w-3.5 h-3.5" />
                  <span>Transfer Firm</span>
                </button>
              </div>
            </div>

            {/* Platform Subscription & Retainer Status */}
            <div className="mt-4 bg-white border border-gray-200 rounded-xl p-4 shadow-2xs">
              <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#062AAE] flex items-center justify-center shrink-0">
                    <CreditCard className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-gray-900">Platform Subscription & Retainer</h4>
                    <p className="text-[11px] text-gray-500">Corporate secretarial service tier & renewal deadline</p>
                  </div>
                </div>
                {(() => {
                  const sub = getSubscriptionExpiryStatus(selectedCompany.subscriptionExpiresAt);
                  return (
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 text-xs font-semibold rounded-full whitespace-nowrap ${
                      sub.isExpiring 
                        ? 'bg-amber-50 text-amber-700 border border-amber-200' 
                        : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                    }`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${sub.isExpiring ? 'bg-amber-500' : 'bg-emerald-500'}`} />
                      <span className="whitespace-nowrap">{sub.label}</span>
                    </span>
                  );
                })()}
              </div>

              <div className="grid grid-cols-3 gap-3 mt-3 text-xs">
                <div className="p-2.5 bg-gray-50 rounded-lg">
                  <span className="text-gray-500 block text-[11px]">Subscription Plan</span>
                  <strong className="text-gray-900 mt-0.5 block">{selectedCompany.subscriptionPlan || 'Growth Plan'}</strong>
                  <span className="text-[10px] text-gray-400">CoSec SLA included</span>
                </div>
                <div className="p-2.5 bg-gray-50 rounded-lg">
                  <span className="text-gray-500 block text-[11px]">Subscription Expiry Date</span>
                  <strong className="text-gray-900 mt-0.5 block whitespace-nowrap">{selectedCompany.subscriptionExpiresAt || '2027-06-14'}</strong>
                  <span className="text-[10px] text-gray-400">Next renewal billing</span>
                </div>
                <div className="p-2.5 bg-gray-50 rounded-lg">
                  <span className="text-gray-500 block text-[11px]">Billing Cycle</span>
                  <strong className="text-gray-900 mt-0.5 block">{selectedCompany.billingCycle || 'Annual Prepaid'}</strong>
                  <span className="text-[10px] text-emerald-600 font-medium">Auto-invoice active</span>
                </div>
              </div>
            </div>

            {/* Statutory Details Grid */}
            <div className="mt-4 grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 bg-white border border-gray-200 rounded-xl">
                <span className="text-gray-500 block text-[11px]">Paid-Up Share Capital</span>
                <strong className="text-gray-900 text-sm mt-0.5 block">{selectedCompany.paidUpCapital}</strong>
              </div>
              <div className="p-3 bg-white border border-gray-200 rounded-xl">
                <span className="text-gray-500 block text-[11px]">Incorporation Date</span>
                <strong className="text-gray-900 text-sm mt-0.5 block">{selectedCompany.incorporationDate}</strong>
              </div>
              <div className="p-3 bg-white border border-gray-200 rounded-xl col-span-2">
                <span className="text-gray-500 block text-[11px]">Registered Office Address</span>
                <p className="text-gray-800 mt-0.5 font-medium">{selectedCompany.registeredAddress || 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur'}</p>
              </div>
            </div>

            {/* Shareholders & Directors */}
            <div className="mt-4">
              <h5 className="text-xs font-bold text-gray-900 mb-2">Shareholders & Capital Allocation</h5>
              <div className="space-y-1.5">
                {(selectedCompany.shareholders || []).map((sh, idx) => (
                  <div key={idx} className="flex items-center justify-between p-2.5 bg-gray-50 rounded-lg text-xs">
                    <div>
                      <strong className="text-gray-900">{sh.shareholder || sh.name}</strong>
                      <span className="text-gray-500 ml-2">({sh.type || 'Ordinary'} Shares)</span>
                    </div>
                    <div className="text-right">
                      <strong className="text-[#062AAE]">{sh.numberOfShares || sh.shares} shares</strong>
                      <span className="text-gray-500 ml-1.5">({sh.percentage})</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Compliance Deadlines */}
            <div className="mt-4 pt-4 border-t border-gray-100 flex flex-wrap items-center justify-between text-xs gap-2">
              <div className="flex items-center gap-2 text-gray-600 whitespace-nowrap">
                <Calendar className="w-4 h-4 text-[#062AAE]" />
                <span className="whitespace-nowrap">Annual Return Due: <strong className="whitespace-nowrap">{selectedCompany.annualReturnDeadline}</strong></span>
              </div>
              <div className="text-gray-500 whitespace-nowrap">
                Statutory Financial Statements: <strong className="whitespace-nowrap">{selectedCompany.financialStatementsDeadline}</strong>
              </div>
            </div>

            <div className="mt-6 flex justify-end">
              <button
                onClick={() => setShowDetailModal(false)}
                className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-medium rounded-lg cursor-pointer"
              >
                Close Inspector
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal 3: Transfer Company Between Secretary Firms */}
      {showTransferModal && selectedCompany && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl border border-gray-200">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <ArrowRightLeft className="w-5 h-5 text-[#062AAE]" />
                <h3 className="text-lg font-bold text-gray-900">Transfer Company Between Firms</h3>
              </div>
              <button 
                onClick={() => setShowTransferModal(false)}
                className="text-gray-400 hover:text-gray-600 text-sm cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <p className="text-xs text-gray-500 mt-2">
              Reassign corporate secretarial custody of <strong>{selectedCompany.name}</strong> ({selectedCompany.ssmNo}) to another verified firm in the MySect network.
            </p>

            <div className="mt-4 space-y-4">
              
              {/* Origin vs Destination */}
              <div className="grid grid-cols-2 gap-3 bg-gray-50 p-3.5 rounded-xl border border-gray-200 text-xs">
                <div>
                  <span className="text-gray-500 block">Current Originating Firm:</span>
                  <strong className="text-gray-900 block mt-1">{selectedCompany.assignedFirmName}</strong>
                  <span className="text-[11px] text-gray-400 mt-0.5 block">CoSec: {selectedCompany.assignedSecretary}</span>
                </div>

                <div className="border-l border-gray-200 pl-3">
                  <span className="text-gray-500 block">Proposed Destination Firm:</span>
                  <strong className="text-[#062AAE] block mt-1">{targetFirmObj?.name || 'Select firm below'}</strong>
                  {targetFirmObj && (
                    <span className="text-[11px] text-gray-500 block mt-0.5">
                      Quota: {targetFirmObj.companiesCount} / {targetFirmObj.companyLimit} Co. ({targetFirmObj.companyLimit - targetFirmObj.companiesCount} slots remaining)
                    </span>
                  )}
                </div>
              </div>

              {/* Destination Firm Selector */}
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Select Destination Secretary Firm</label>
                <select
                  value={targetFirmId}
                  onChange={(e) => setTargetFirmId(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                >
                  {firms.filter(f => f.status === 'Active' && f.id !== selectedCompany.assignedFirmId).map(f => (
                    <option key={f.id} value={f.id}>
                      {f.name} — ({f.companiesCount}/{f.companyLimit} used, SLA {f.slaComplianceRate}%)
                    </option>
                  ))}
                </select>
              </div>

              {/* Effective Transfer Date & Reason */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Effective Transfer Date</label>
                  <input
                    type="date"
                    value={effectiveDate}
                    onChange={(e) => setEffectiveDate(e.target.value)}
                    className="w-full p-2 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">SSM Form 58 Lodgement Window</label>
                  <span className="text-[11px] text-gray-500 block pt-2">Must be lodged within 14 days of appointment</span>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Reason for Portfolio Transfer</label>
                <textarea
                  rows={2}
                  value={transferReason}
                  onChange={(e) => setTransferReason(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  placeholder="e.g. Previous firm licence expiry, customer-initiated secretary change..."
                />
              </div>

              {/* Statutory Handover Checklist */}
              <div className="bg-blue-50/60 p-3.5 rounded-xl border border-blue-200 text-xs space-y-2">
                <h4 className="font-semibold text-[#062AAE] flex items-center gap-1.5">
                  <ShieldCheck className="w-4 h-4" />
                  Statutory Handover Protocol (Companies Act 2016)
                </h4>

                <label className="flex items-start gap-2 text-gray-700 cursor-pointer pt-1">
                  <input
                    type="checkbox"
                    checked={statutoryHandoverChecked}
                    onChange={(e) => setStatutoryHandoverChecked(e.target.checked)}
                    className="mt-0.5 rounded text-[#062AAE] focus:ring-[#062AAE]"
                  />
                  <span>
                    Form 58 / Section 58 Notice of Change of Secretary prepared, and statutory register handover agreed between firms.
                  </span>
                </label>

                <label className="flex items-start gap-2 text-gray-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={clientConsentChecked}
                    onChange={(e) => setClientConsentChecked(e.target.checked)}
                    className="mt-0.5 rounded text-[#062AAE] focus:ring-[#062AAE]"
                  />
                  <span>
                    Client board resolution or authorised director consent verified on record.
                  </span>
                </label>
              </div>

            </div>

            <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
              <button
                onClick={() => setShowTransferModal(false)}
                className="px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-100 rounded-lg cursor-pointer"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmTransfer}
                disabled={!targetFirmId || !statutoryHandoverChecked || !clientConsentChecked}
                className="px-4 py-2 text-xs font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] disabled:opacity-50 disabled:cursor-not-allowed rounded-lg shadow-sm flex items-center gap-1.5 cursor-pointer"
              >
                <CheckCircle2 className="w-4 h-4" />
                <span>Execute Transfer & Log Audit</span>
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default CompanyManagement;
