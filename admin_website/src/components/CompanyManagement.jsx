import React, { useState } from 'react';
import { 
  Users, ArrowRightLeft, Search, 
  CheckCircle2, ShieldCheck
} from 'lucide-react';

const CompanyManagement = ({ 
  companies = [], 
  firms = [], 
  onTransferCompany 
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterFirm, setFilterFirm] = useState('All');
  const [filterStatus, setFilterStatus] = useState('All');
  const [showTransferModal, setShowTransferModal] = useState(false);
  const [selectedCompany, setSelectedCompany] = useState(null);
  
  // Transfer form state
  const [targetFirmId, setTargetFirmId] = useState('');
  const [transferReason, setTransferReason] = useState('');
  const [effectiveDate, setEffectiveDate] = useState('2026-10-25');
  const [statutoryHandoverChecked, setStatutoryHandoverChecked] = useState(false);
  const [clientConsentChecked, setClientConsentChecked] = useState(false);

  const filteredCompanies = companies.filter(c => {
    const matchesSearch = c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          c.ssmNo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          c.clientContact.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFirm = filterFirm === 'All' || c.assignedFirmId === filterFirm;
    const matchesStatus = filterStatus === 'All' || c.status === filterStatus;
    return matchesSearch && matchesFirm && matchesStatus;
  });

  const handleOpenTransfer = (company) => {
    setSelectedCompany(company);
    // default target firm to first active firm different from current
    const availableFirms = firms.filter(f => f.status === 'Active' && f.id !== company.assignedFirmId);
    setTargetFirmId(availableFirms[0]?.id || '');
    setTransferReason(company.transferReason || 'Client portfolio reallocation / Secretary firm handover');
    setStatutoryHandoverChecked(false);
    setClientConsentChecked(false);
    setShowTransferModal(true);
  };

  const handleConfirmTransfer = () => {
    if (!selectedCompany || !targetFirmId) return;
    const destFirm = firms.find(f => f.id === targetFirmId);
    if (!destFirm) return;

    if (onTransferCompany) {
      onTransferCompany(selectedCompany.id, destFirm.id, destFirm.name, transferReason);
    }

    setShowTransferModal(false);
  };

  const targetFirmObj = firms.find(f => f.id === targetFirmId);

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <Users className="w-4 h-4" />
            <span>Company Directory & Portfolio Allocation</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Managed Companies & Firm Assignments</h1>
          <p className="text-sm text-gray-500">
            Oversee company portfolios, assign newly onboarded businesses, and execute formal company secretarial transfers between firms.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="text-xs bg-white border border-gray-200 rounded-lg p-2.5 px-4 shadow-xs">
            <span className="text-gray-500">Total Companies:</span>{' '}
            <strong className="text-gray-900 text-sm">{companies.length}</strong>
            <span className="mx-2 text-gray-300">|</span>
            <span className="text-amber-600 font-medium">
              {companies.filter(c => c.status === 'Transfer Pending').length} pending transfer
            </span>
          </div>
        </div>
      </div>

      {/* Filters Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs mt-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            type="text"
            placeholder="Search company name, SSM number, director..."
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
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Appointed Secretary</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Client Representative</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Next SSM Deadline</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Status</th>
                <th className="px-5 py-3.5 text-right font-semibold text-gray-600">Assignment Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {filteredCompanies.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-gray-500">
                    No companies found matching the filter criteria.
                  </td>
                </tr>
              ) : (
                filteredCompanies.map((company) => (
                  <tr key={company.id} className="hover:bg-gray-50/80 transition-colors">
                    <td className="px-5 py-4">
                      <div className="font-semibold text-sm text-gray-900">{company.name}</div>
                      <div className="text-gray-500 font-mono text-[11px] mt-0.5">{company.ssmNo}</div>
                      <div className="text-[11px] text-gray-400 mt-0.5">
                        {company.type} • Capital: {company.paidUpCapital}
                      </div>
                    </td>

                    <td className="px-5 py-4">
                      <div className="font-medium text-gray-900">{company.assignedFirmName}</div>
                      <div className="text-gray-500 text-[11px]">ID: {company.assignedFirmId}</div>
                    </td>

                    <td className="px-5 py-4 text-gray-700">
                      <div className="font-medium">{company.assignedSecretary}</div>
                      <div className="text-[11px] text-gray-400">CoSec in-charge</div>
                    </td>

                    <td className="px-5 py-4">
                      <div className="text-gray-900 font-medium">{company.clientContact}</div>
                      <div className="text-gray-500 text-[11px]">{company.clientEmail}</div>
                    </td>

                    <td className="px-5 py-4">
                      <div className="font-semibold text-gray-800">
                        {company.annualReturnDeadline}
                      </div>
                      <div className="text-[11px] text-gray-500">Annual Return (S.68)</div>
                    </td>

                    <td className="px-5 py-4">
                      <span className={`px-2.5 py-1 text-xs font-semibold rounded-full ${
                        company.status === 'Active' 
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                          : 'bg-amber-50 text-amber-700 border border-amber-200'
                      }`}>
                        {company.status}
                      </span>
                    </td>

                    <td className="px-5 py-4 text-right">
                      <button
                        onClick={() => handleOpenTransfer(company)}
                        className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors flex items-center gap-1.5 ml-auto ${
                          company.status === 'Transfer Pending'
                            ? 'bg-amber-500 hover:bg-amber-600 text-white shadow-xs'
                            : 'bg-white border border-gray-200 hover:bg-gray-100 text-gray-700'
                        }`}
                      >
                        <ArrowRightLeft className="w-3.5 h-3.5" />
                        {company.status === 'Transfer Pending' ? 'Resolve Transfer' : 'Transfer Firm'}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: Transfer Company Between Secretary Firms */}
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
                className="text-gray-400 hover:text-gray-600 text-sm"
              >
                ✕
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
                className="px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmTransfer}
                disabled={!targetFirmId || !statutoryHandoverChecked || !clientConsentChecked}
                className="px-4 py-2 text-xs font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] disabled:opacity-50 disabled:cursor-not-allowed rounded-lg shadow-sm flex items-center gap-1.5"
              >
                <CheckCircle2 className="w-4 h-4" />
                Execute Transfer & Log Audit
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default CompanyManagement;
