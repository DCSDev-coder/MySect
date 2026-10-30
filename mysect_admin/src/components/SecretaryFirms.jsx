import React, { useState } from 'react';
import { 
  Building2, CheckCircle2, AlertTriangle, 
  Search, Check, ExternalLink, Edit, ShieldAlert, Award, Clock
} from 'lucide-react';

const SecretaryFirms = ({ 
  firms = [], 
  plans = [],
  onApproveFirm,
  onSuspendFirm,
  onReactivateFirm,
  onUpdateFirmPlan,
  onVerifyCertificate,
  selectedFirmFromDash = null
}) => {
  const [filterStatus, setFilterStatus] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFirm, setSelectedFirm] = useState(selectedFirmFromDash || firms[0] || null);
  const [showPlanModal, setShowPlanModal] = useState(false);
  const [showSuspendModal, setShowSuspendModal] = useState(false);
  const [suspensionReason, setSuspensionReason] = useState('');
  const [selectedNewPlan, setSelectedNewPlan] = useState('');
  const [newCompanyLimit, setNewCompanyLimit] = useState(100);

  const filteredFirms = firms.filter(firm => {
    const matchesStatus = filterStatus === 'All' || firm.status === filterStatus;
    const matchesSearch = firm.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          firm.ssmRegistration.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          firm.cosecLicenseNo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          firm.contactPerson.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const handleSelectFirm = (firm) => {
    setSelectedFirm(firm);
  };

  const handleOpenPlanModal = () => {
    if (!selectedFirm) return;
    setSelectedNewPlan(selectedFirm.planId);
    setNewCompanyLimit(selectedFirm.companyLimit);
    setShowPlanModal(true);
  };

  const handleSavePlan = () => {
    if (selectedFirm && onUpdateFirmPlan) {
      const planObj = plans.find(p => p.id === selectedNewPlan);
      onUpdateFirmPlan(selectedFirm.id, selectedNewPlan, planObj?.name || 'Custom Plan', Number(newCompanyLimit));
      setShowPlanModal(false);
      // update local selection
      setSelectedFirm({
        ...selectedFirm,
        planId: selectedNewPlan,
        planName: planObj?.name || 'Custom Plan',
        companyLimit: Number(newCompanyLimit)
      });
    }
  };

  const handleConfirmSuspend = () => {
    if (selectedFirm && onSuspendFirm) {
      onSuspendFirm(selectedFirm.id, suspensionReason || 'Regulatory compliance violation or licence expiration');
      setShowSuspendModal(false);
      setSuspensionReason('');
      setSelectedFirm({
        ...selectedFirm,
        status: 'Suspended',
        suspensionReason: suspensionReason || 'Regulatory compliance violation or licence expiration'
      });
    }
  };

  return (
    <div className="flex-1 flex flex-col h-screen overflow-hidden bg-[#F8F9FA]">
      {/* Pinned Top Navigation Bar */}
      <div className="bg-white border-b border-gray-200 px-8 py-5 shrink-0">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
              <Building2 className="w-4 h-4" />
              <span>Secretary Firm Network Governance</span>
            </div>
            <h1 className="text-2xl font-bold text-gray-900 mt-1">Secretary Firms & Licencing Directory</h1>
            <p className="text-sm text-gray-500 mt-0.5">
              Verify practising certificates, onboard firms, manage administrators, configure company limits, and monitor regulatory standing.
            </p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <div className="text-xs bg-gray-50 border border-gray-200 rounded-lg p-2.5 px-4 shadow-xs whitespace-nowrap shrink-0">
              <span className="text-gray-500">Total Network Firms:</span>{' '}
              <strong className="text-gray-900 text-sm">{firms.length}</strong>
              <span className="mx-2 text-gray-300">|</span>
              <span className="text-amber-600 font-medium">
                {firms.filter(f => f.status === 'Pending Verification').length} pending approval
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Scrollable Content Area */}
      <div className="flex-1 overflow-y-auto p-8">
        {/* Main Layout: List on Left, Detail Panel on Right */}
        <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
        
        {/* Left List: 5 cols */}
        <div className="xl:col-span-5 space-y-4">
          
          {/* Search & Tabs */}
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs space-y-3">
            <div className="relative">
              <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input 
                type="text"
                placeholder="Search firm name, SSM Reg, CoSec license..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              />
            </div>

            {/* Filter Tabs */}
            <div className="flex flex-wrap gap-1.5 pt-1">
              {['All', 'Pending Verification', 'Active', 'Suspended'].map((status) => (
                <button
                  key={status}
                  onClick={() => setFilterStatus(status)}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors ${
                    filterStatus === status 
                      ? 'bg-[#062AAE] text-white' 
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  {status}
                  {status === 'Pending Verification' && (
                    <span className="ml-1.5 px-1.5 py-0.2 bg-amber-400 text-amber-950 rounded-full font-bold text-[10px]">
                      {firms.filter(f => f.status === 'Pending Verification').length}
                    </span>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Firm Cards List */}
          <div className="space-y-3">
            {filteredFirms.length === 0 ? (
              <div className="bg-white p-8 rounded-xl border border-gray-200 text-center text-sm text-gray-500">
                No secretary firms matching the selected filter.
              </div>
            ) : (
              filteredFirms.map((firm) => {
                const isSelected = selectedFirm?.id === firm.id;
                const percentQuota = Math.round((firm.companiesCount / firm.companyLimit) * 100);
                return (
                  <div 
                    key={firm.id}
                    onClick={() => handleSelectFirm(firm)}
                    className={`p-4 rounded-xl border transition-all cursor-pointer ${
                      isSelected 
                        ? 'bg-blue-50/50 border-[#062AAE] shadow-sm ring-1 ring-[#062AAE]' 
                        : 'bg-white border-gray-200 hover:border-gray-300 shadow-xs'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <h3 className="font-semibold text-sm text-gray-900">{firm.name}</h3>
                        <p className="text-xs text-gray-500 mt-0.5">SSM: {firm.ssmRegistration}</p>
                      </div>
                      <span className={`px-2 py-0.5 text-xs font-medium rounded-full ${
                        firm.status === 'Active' 
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                          : firm.status === 'Pending Verification'
                          ? 'bg-amber-50 text-amber-700 border border-amber-200'
                          : 'bg-rose-50 text-rose-700 border border-rose-200'
                      }`}>
                        {firm.status}
                      </span>
                    </div>

                    <div className="mt-3 flex items-center justify-between text-xs text-gray-600 pt-2 border-t border-gray-100">
                      <div>
                        <span>Plan: <strong className="text-gray-800">{firm.planName}</strong></span>
                      </div>
                      <div>
                        <span>Capacity: <strong className="text-gray-800">{firm.companiesCount} / {firm.companyLimit}</strong> ({percentQuota}%)</span>
                      </div>
                    </div>

                    <div className="mt-2 flex items-center justify-between text-xs text-gray-500">
                      <span>Principal: {firm.contactPerson}</span>
                      <span className="flex items-center gap-1 text-emerald-600 font-medium">
                        <Award className="w-3.5 h-3.5" /> SLA {firm.slaComplianceRate}%
                      </span>
                    </div>
                  </div>
                );
              })
            )}
          </div>

        </div>

        {/* Right Detail Pane: 7 cols */}
        <div className="xl:col-span-7">
          {selectedFirm ? (
            <div className="bg-white rounded-xl border border-gray-200 shadow-xs overflow-hidden sticky top-8">
              
              {/* Firm Profile Banner */}
              <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-mono font-bold text-[#062AAE] bg-blue-50 px-2 py-0.5 rounded">
                        {selectedFirm.cosecLicenseNo}
                      </span>
                      <span className={`px-2.5 py-0.5 text-xs font-semibold rounded-full ${
                        selectedFirm.status === 'Active' 
                          ? 'bg-emerald-100 text-emerald-800'
                          : selectedFirm.status === 'Pending Verification'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-rose-100 text-rose-800'
                      }`}>
                        {selectedFirm.status}
                      </span>
                    </div>
                    <h2 className="text-xl font-bold text-gray-900 mt-2">{selectedFirm.name}</h2>
                    <p className="text-xs text-gray-500 mt-1 flex flex-wrap items-center gap-x-1.5 gap-y-0.5">
                      <span>Registration: <strong className="text-gray-700">{selectedFirm.ssmRegistration}</strong></span>
                      <span className="text-gray-300 hidden sm:inline">•</span>
                      <span className="whitespace-nowrap">
                        Joined <strong className="text-gray-700 font-medium">{selectedFirm.joinedDate}</strong>
                      </span>
                    </p>
                  </div>

                  {/* Actions for Firm Status */}
                  <div className="flex flex-wrap items-center gap-2">
                    {selectedFirm.status === 'Pending Verification' && (
                      <button
                        onClick={() => {
                          if (onApproveFirm) onApproveFirm(selectedFirm.id);
                          setSelectedFirm({ ...selectedFirm, status: 'Active' });
                        }}
                        className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-xs flex items-center justify-center gap-1.5 transition-colors whitespace-nowrap"
                      >
                        <CheckCircle2 className="w-4 h-4" />
                        Approve & Activate Firm
                      </button>
                    )}

                    {selectedFirm.status === 'Active' && (
                      <button
                        onClick={() => setShowSuspendModal(true)}
                        className="w-[128px] py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-lg text-xs font-medium transition-colors inline-flex items-center justify-center gap-1.5 whitespace-nowrap"
                      >
                        <ShieldAlert className="w-4 h-4 shrink-0" />
                        <span>Suspend Firm</span>
                      </button>
                    )}

                    {selectedFirm.status === 'Suspended' && (
                      <button
                        onClick={() => {
                          if (onReactivateFirm) onReactivateFirm(selectedFirm.id);
                          setSelectedFirm({ ...selectedFirm, status: 'Active' });
                        }}
                        className="w-[128px] py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-lg text-xs font-semibold shadow-xs inline-flex items-center justify-center gap-1.5 transition-colors whitespace-nowrap"
                      >
                        <CheckCircle2 className="w-4 h-4 shrink-0" />
                        <span>Reactivate Firm</span>
                      </button>
                    )}

                    <button
                      onClick={handleOpenPlanModal}
                      className="w-[128px] py-2 bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 rounded-lg text-xs font-medium transition-colors inline-flex items-center justify-center gap-1.5 whitespace-nowrap"
                    >
                      <Edit className="w-3.5 h-3.5 shrink-0" />
                      <span>Adjust Limits</span>
                    </button>
                  </div>
                </div>

                {/* If suspended, show alert banner */}
                {selectedFirm.status === 'Suspended' && (
                  <div className="mt-4 p-3 bg-rose-50 border border-rose-200 rounded-lg text-xs text-rose-800 flex items-start gap-2">
                    <AlertTriangle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                    <div>
                      <strong>Suspension Notice:</strong> {selectedFirm.suspensionReason}
                      <div className="mt-1 text-rose-700">
                        {selectedFirm.companiesCount} companies currently managed must be audited or transferred to prevent Section 68 statutory default.
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Detail Content Sections */}
              <div className="p-6 space-y-6 max-h-[calc(100vh-280px)] overflow-y-auto">
                
                {/* 1. Subscription & Company Capacity */}
                <div>
                  <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">
                    Subscription & Company Capacity Limits
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 bg-gray-50 p-4 rounded-xl border border-gray-200">
                    <div>
                      <span className="text-xs text-gray-500">Current Plan</span>
                      <p className="text-sm font-bold text-gray-900 mt-0.5">{selectedFirm.planName}</p>
                      <span className="text-[11px] text-gray-500">Tier Code: {selectedFirm.planId}</span>
                    </div>

                    <div>
                      <span className="text-xs text-gray-500">Companies Allocation</span>
                      <p className="text-sm font-bold text-gray-900 mt-0.5">
                        {selectedFirm.companiesCount} / {selectedFirm.companyLimit} Co.
                      </p>
                      <div className="w-full bg-gray-200 h-1.5 rounded-full mt-1.5 overflow-hidden">
                        <div 
                          className="h-full bg-[#062AAE] rounded-full"
                          style={{ width: `${Math.min((selectedFirm.companiesCount / selectedFirm.companyLimit) * 100, 100)}%` }}
                        ></div>
                      </div>
                    </div>

                    <div>
                      <span className="text-xs text-gray-500">Monthly Platform Revenue</span>
                      <p className="text-sm font-bold text-emerald-700 mt-0.5">
                        MYR {selectedFirm.monthlyPlatformFee?.toFixed(2)}
                      </p>
                      <span className="text-[11px] text-gray-500">Status: {selectedFirm.billingStatus}</span>
                    </div>
                  </div>
                </div>

                {/* 2. Practising Certificate & Licence Records */}
                <div>
                  <div className="flex items-center justify-between gap-4 mb-3">
                    <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                      Licence & Practising Certificates (CA 2016)
                    </h3>
                    <span className="text-xs text-gray-500 whitespace-nowrap shrink-0">
                      {(selectedFirm.practisingCertificates || []).length} registered credential(s)
                    </span>
                  </div>

                  <div className="space-y-3">
                    {(selectedFirm.practisingCertificates || []).map((cert) => (
                      <div key={cert.id} className="p-4 bg-white border border-gray-200 rounded-xl shadow-2xs hover:border-blue-200 transition-colors">
                        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                          <div className="min-w-0">
                            <div className="flex items-center gap-2 flex-wrap">
                              <span className="font-semibold text-sm text-gray-900">{cert.holderName}</span>
                              <span className="px-2 py-0.5 text-xs font-semibold bg-blue-50 text-[#062AAE] border border-blue-200 rounded whitespace-nowrap">
                                {cert.body}
                              </span>
                              <span className={`px-2 py-0.5 text-xs font-medium rounded-full whitespace-nowrap ${
                                cert.status === 'Valid' 
                                  ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                                  : cert.status === 'Expiring Soon'
                                  ? 'bg-amber-50 text-amber-700 border border-amber-200'
                                  : 'bg-rose-50 text-rose-700 border border-rose-200'
                              }`}>
                                {cert.status}
                              </span>
                            </div>
                            <p className="text-xs text-gray-500 mt-1">
                              Certificate No: <strong className="text-gray-800 whitespace-nowrap">{cert.certNo}</strong> • Expiry Date: <strong className={`whitespace-nowrap ${cert.status === 'Expired' ? 'text-rose-600' : 'text-gray-800'}`}>{cert.expiryDate}</strong>
                            </p>
                          </div>

                          <div className="flex items-center gap-2 shrink-0">
                            <a 
                              href={cert.documentUrl} 
                              target="_blank" 
                              rel="noreferrer"
                              className="px-2.5 py-1 text-xs text-gray-600 bg-gray-50 hover:bg-gray-100 border border-gray-200 rounded flex items-center gap-1 whitespace-nowrap shrink-0"
                            >
                              <ExternalLink className="w-3.5 h-3.5 shrink-0" />
                              <span>Inspect Certificate</span>
                            </a>

                            {cert.verified ? (
                              <span className="px-2.5 py-1 text-xs font-medium text-emerald-700 bg-emerald-50 rounded flex items-center gap-1 whitespace-nowrap shrink-0">
                                <Check className="w-3.5 h-3.5 shrink-0" /> Verified
                              </span>
                            ) : (
                              <button
                                onClick={() => {
                                  if (onVerifyCertificate) onVerifyCertificate(selectedFirm.id, cert.id);
                                  cert.verified = true;
                                  setSelectedFirm({ ...selectedFirm });
                                }}
                                className="px-2.5 py-1 text-xs font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded shadow-2xs whitespace-nowrap shrink-0"
                              >
                                Mark Verified
                              </button>
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* 3. Firm Administrators & Staff Roles */}
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                      Firm Administrators & Staff Access
                    </h3>
                    <span className="text-xs text-gray-500">
                      {(selectedFirm.staff || []).length} team member(s)
                    </span>
                  </div>

                  <div className="overflow-x-auto border border-gray-200 rounded-xl">
                    <table className="min-w-full divide-y divide-gray-200 text-xs">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-4 py-2.5 text-left font-semibold text-gray-600 whitespace-nowrap">Staff Name</th>
                          <th className="px-4 py-2.5 text-left font-semibold text-gray-600 whitespace-nowrap">Assigned Role</th>
                          <th className="px-4 py-2.5 text-left font-semibold text-gray-600 whitespace-nowrap">Email</th>
                          <th className="px-4 py-2.5 text-left font-semibold text-gray-600 whitespace-nowrap">e-KYC Status</th>
                          <th className="px-4 py-2.5 text-left font-semibold text-gray-600 whitespace-nowrap">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-100 bg-white">
                        {(selectedFirm.staff || []).map((member) => (
                          <tr key={member.id} className="hover:bg-gray-50">
                            <td className="px-4 py-3 font-medium text-gray-900 whitespace-nowrap">{member.name}</td>
                            <td className="px-4 py-3 text-gray-700 whitespace-nowrap">
                              <span className="inline-block px-2.5 py-1 bg-gray-100 rounded-md text-gray-800 whitespace-nowrap font-medium text-[11px]">
                                {member.role}
                              </span>
                            </td>
                            <td className="px-4 py-3 text-gray-500 whitespace-nowrap">{member.email}</td>
                            <td className="px-4 py-3 whitespace-nowrap">
                              {member.ekycVerified ? (
                                <span className="inline-flex items-center gap-1 text-emerald-700 font-medium whitespace-nowrap">
                                  <Check className="w-3 h-3" /> Verified
                                </span>
                              ) : (
                                <span className="inline-flex items-center gap-1 text-amber-700 font-medium whitespace-nowrap">
                                  <Clock className="w-3 h-3" /> Pending e-KYC
                                </span>
                              )}
                            </td>
                            <td className="px-4 py-3 whitespace-nowrap">
                              <span className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold whitespace-nowrap ${
                                member.status === 'Active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-gray-100 text-gray-600'
                              }`}>
                                {member.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* 4. Firm Contact & Office Details */}
                <div className="bg-gray-50 p-4 rounded-xl border border-gray-200 text-xs space-y-2">
                  <h4 className="font-semibold text-gray-900">Registered Office & Contact Details</h4>
                  <p className="text-gray-600">{selectedFirm.address}</p>
                  <div className="flex flex-wrap gap-4 pt-1 text-gray-600">
                    <span>Phone: <strong className="text-gray-900">{selectedFirm.phone}</strong></span>
                    <span>Email: <strong className="text-gray-900">{selectedFirm.email}</strong></span>
                  </div>
                </div>

              </div>
            </div>
          ) : (
            <div className="bg-white p-12 rounded-xl border border-gray-200 text-center text-gray-500">
              Select a secretary firm from the directory to review its licence and management controls.
            </div>
          )}
        </div>

      </div>

      {/* Modal: Adjust Plan & Company Limits */}
      {showPlanModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-200">
            <h3 className="text-lg font-bold text-gray-900">Adjust Plan & Company Limits</h3>
            <p className="text-xs text-gray-500 mt-1">
              Select an approved platform subscription tier or configure custom company capacity for {selectedFirm?.name}.
            </p>

            <div className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Subscription Plan Tier</label>
                <select
                  value={selectedNewPlan}
                  onChange={(e) => {
                    setSelectedNewPlan(e.target.value);
                    const p = plans.find(plan => plan.id === e.target.value);
                    if (p) setNewCompanyLimit(p.companyLimit);
                  }}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                >
                  {plans.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} ({p.companyLimit} companies limit - MYR {p.monthlyPrice}/mo)
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Max Managed Company Limit</label>
                <input
                  type="number"
                  value={newCompanyLimit}
                  onChange={(e) => setNewCompanyLimit(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
                <span className="text-[11px] text-gray-500 mt-1 block">
                  Current active companies in firm: {selectedFirm?.companiesCount}
                </span>
              </div>
            </div>

            <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
              <button
                onClick={() => setShowPlanModal(false)}
                className="px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={handleSavePlan}
                className="px-4 py-2 text-xs font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded-lg shadow-sm"
              >
                Update Firm Limits
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Confirm Suspension */}
      {showSuspendModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-200">
            <div className="flex items-center gap-3 text-rose-600">
              <ShieldAlert className="w-6 h-6" />
              <h3 className="text-lg font-bold text-gray-900">Suspend Secretary Firm</h3>
            </div>
            <p className="text-xs text-gray-600 mt-2">
              Suspending <strong>{selectedFirm?.name}</strong> will revoke firm staff access to filing tools and mark their managed portfolio ({selectedFirm?.companiesCount} companies) for transfer review.
            </p>

            <div className="mt-4">
              <label className="block text-xs font-semibold text-gray-700 mb-1">Reason for Suspension</label>
              <textarea
                rows={3}
                placeholder="e.g. Practising Certificate expired, failure to respond to SSM statutory queries..."
                value={suspensionReason}
                onChange={(e) => setSuspensionReason(e.target.value)}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-rose-500"
              />
            </div>

            <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
              <button
                onClick={() => setShowSuspendModal(false)}
                className="px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmSuspend}
                className="px-4 py-2 text-xs font-semibold text-white bg-rose-600 hover:bg-rose-700 rounded-lg shadow-sm"
              >
                Confirm Suspension
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
    </div>
  );
};

export default SecretaryFirms;
