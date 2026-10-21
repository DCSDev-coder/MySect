import React, { useState } from 'react';
import { 
  AlertTriangle, CheckCircle2, AlertCircle, 
  Search, RefreshCw
} from 'lucide-react';

const EscalationsMonitor = ({ 
  escalations = [], 
  firms = [], 
  onResolveEscalation,
  onReassignEscalation
}) => {
  const [filterSeverity, setFilterSeverity] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedEscalation, setSelectedEscalation] = useState(escalations[0] || null);
  const [interventionNote, setInterventionNote] = useState('');
  const [showReassignModal, setShowReassignModal] = useState(false);
  const [targetFirm, setTargetFirm] = useState(firms[0]?.name || '');

  const filteredEscalations = escalations.filter(e => {
    const matchesSev = filterSeverity === 'All' || e.severity.includes(filterSeverity);
    const matchesSearch = e.companyName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          e.caseNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          e.type.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesSev && matchesSearch;
  });

  const handleResolve = () => {
    if (!selectedEscalation) return;
    if (onResolveEscalation) {
      onResolveEscalation(selectedEscalation.id, interventionNote || 'Admin mediator resolved issue with client and secretary.');
    }
    setSelectedEscalation({
      ...selectedEscalation,
      status: 'Resolved by Admin'
    });
    setInterventionNote('');
  };

  const handleReassign = () => {
    if (!selectedEscalation || !targetFirm) return;
    if (onReassignEscalation) {
      onReassignEscalation(selectedEscalation.id, targetFirm);
    }
    setSelectedEscalation({
      ...selectedEscalation,
      assignedFirm: targetFirm,
      status: 'Reassigned & Monitoring'
    });
    setShowReassignModal(false);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-rose-600">
            <AlertTriangle className="w-4 h-4" />
            <span>Platform Service Oversight & Escalations</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Overdue Work & AI Escalation Monitoring</h1>
          <p className="text-sm text-gray-500">
            Real-time queue of Section 68 overdue filings, SSM queries, and AI chatbot escalations requiring operator intervention.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="text-xs bg-white border border-gray-200 rounded-lg p-2.5 px-4 shadow-xs">
            <span className="text-gray-500">Active Escalations:</span>{' '}
            <strong className="text-rose-600 text-sm font-bold">{escalations.length}</strong>
            <span className="mx-2 text-gray-300">|</span>
            <span className="text-gray-700 font-medium">SLA Default Guard</span>
          </div>
        </div>
      </div>

      {/* Grid: Escalation Cards List & Action Room */}
      <div className="grid grid-cols-1 xl:grid-cols-12 gap-6 mt-6">
        
        {/* Left List (5 cols) */}
        <div className="xl:col-span-5 space-y-4">
          
          {/* Search & Severity Filters */}
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs space-y-3">
            <div className="relative">
              <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input 
                type="text"
                placeholder="Search case #, company, type..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-rose-500"
              />
            </div>

            <div className="flex flex-wrap gap-1.5 pt-1">
              {['All', 'High', 'Medium'].map((sev) => (
                <button
                  key={sev}
                  onClick={() => setFilterSeverity(sev)}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors ${
                    filterSeverity === sev 
                      ? 'bg-rose-600 text-white' 
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  {sev === 'All' ? 'All Escalations' : `${sev} Severity`}
                </button>
              ))}
            </div>
          </div>

          {/* List of Cases */}
          <div className="space-y-3">
            {filteredEscalations.map((esc) => {
              const isSelected = selectedEscalation?.id === esc.id;
              return (
                <div 
                  key={esc.id}
                  onClick={() => setSelectedEscalation(esc)}
                  className={`p-4 rounded-xl border transition-all cursor-pointer ${
                    isSelected 
                      ? 'bg-rose-50/40 border-rose-500 shadow-xs ring-1 ring-rose-500' 
                      : 'bg-white border-gray-200 hover:border-gray-300 shadow-xs'
                  }`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <span className="text-xs font-mono font-bold text-gray-500">{esc.caseNumber}</span>
                      <h3 className="font-semibold text-sm text-gray-900 mt-0.5">{esc.companyName}</h3>
                    </div>
                    <span className={`px-2 py-0.5 text-[11px] font-semibold rounded-full ${
                      esc.severity.includes('High') 
                        ? 'bg-rose-100 text-rose-800 border border-rose-200' 
                        : 'bg-amber-100 text-amber-800 border border-amber-200'
                    }`}>
                      {esc.severity}
                    </span>
                  </div>

                  <p className="text-xs text-gray-600 mt-2 line-clamp-2">{esc.summary}</p>

                  <div className="mt-3 flex items-center justify-between text-xs text-gray-500 pt-2 border-t border-gray-100">
                    <span>Firm: <strong className="text-gray-800">{esc.assignedFirm}</strong></span>
                    <span className="font-medium text-rose-700">{esc.status}</span>
                  </div>
                </div>
              );
            })}
          </div>

        </div>

        {/* Right Detail & Intervention Pane (7 cols) */}
        <div className="xl:col-span-7">
          {selectedEscalation ? (
            <div className="bg-white rounded-xl border border-gray-200 shadow-xs overflow-hidden sticky top-8">
              
              {/* Case Banner */}
              <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-rose-50/50 to-white">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-mono font-bold text-gray-700 bg-white px-2 py-0.5 rounded border border-gray-200">
                        {selectedEscalation.caseNumber}
                      </span>
                      <span className="px-2 py-0.5 text-xs font-semibold rounded-full bg-rose-100 text-rose-800">
                        {selectedEscalation.severity}
                      </span>
                      <span className="text-xs text-gray-500">
                        Created {selectedEscalation.createdAt}
                      </span>
                    </div>
                    <h2 className="text-lg font-bold text-gray-900 mt-2">{selectedEscalation.companyName}</h2>
                    <p className="text-xs text-rose-700 font-medium mt-0.5">
                      Issue: {selectedEscalation.type} • Triggered by: {selectedEscalation.escalatedBy}
                    </p>
                  </div>

                  <span className={`px-2.5 py-1 text-xs font-bold rounded-lg ${
                    selectedEscalation.status.includes('Resolved') 
                      ? 'bg-emerald-100 text-emerald-800' 
                      : 'bg-amber-100 text-amber-800'
                  }`}>
                    {selectedEscalation.status}
                  </span>
                </div>
              </div>

              {/* Detail Content */}
              <div className="p-6 space-y-6">
                
                {/* Summary & Customer Signal */}
                <div>
                  <h4 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
                    Incident Case Summary & Customer Impact
                  </h4>
                  <div className="bg-gray-50 p-4 rounded-xl border border-gray-200 text-xs text-gray-800 leading-relaxed">
                    {selectedEscalation.summary}
                  </div>
                </div>

                {/* Key Stakeholder Details */}
                <div className="grid grid-cols-2 gap-4 text-xs">
                  <div className="p-3 bg-gray-50 rounded-xl border border-gray-200">
                    <span className="text-gray-500 block">Assigned Secretary Firm</span>
                    <strong className="text-gray-900 text-sm block mt-0.5">{selectedEscalation.assignedFirm}</strong>
                    <span className="text-gray-500 text-[11px] block mt-1">Subject to platform SLA targets</span>
                  </div>

                  <div className="p-3 bg-gray-50 rounded-xl border border-gray-200">
                    <span className="text-gray-500 block">Customer Representative</span>
                    <strong className="text-gray-900 text-sm block mt-0.5">{selectedEscalation.customerContact}</strong>
                    <span className="text-gray-500 text-[11px] block mt-1">Escalated via Mobile Intake</span>
                  </div>
                </div>

                {/* Recommended Resolution Path */}
                <div className="bg-amber-50/70 p-4 rounded-xl border border-amber-200 text-xs">
                  <h4 className="font-semibold text-amber-900 flex items-center gap-1.5">
                    <AlertCircle className="w-4 h-4 text-amber-600" />
                    System Recommended Action
                  </h4>
                  <p className="text-amber-800 mt-1 leading-relaxed">
                    {selectedEscalation.suggestedAction}
                  </p>
                </div>

                {/* Admin Intervention Section */}
                <div className="pt-4 border-t border-gray-200 space-y-3">
                  <h4 className="text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Operator Intervention Tools
                  </h4>

                  <textarea
                    rows={3}
                    placeholder="Enter formal mediation notes or instructions to the firm principal..."
                    value={interventionNote}
                    onChange={(e) => setInterventionNote(e.target.value)}
                    className="w-full p-3 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />

                  <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
                    <button
                      onClick={() => setShowReassignModal(true)}
                      className="px-3.5 py-2 bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 rounded-lg text-xs font-semibold transition-colors flex items-center gap-1.5"
                    >
                      <RefreshCw className="w-3.5 h-3.5" />
                      Reassign to Another Firm
                    </button>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={handleResolve}
                        className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-xs flex items-center gap-1.5 transition-colors"
                      >
                        <CheckCircle2 className="w-4 h-4" />
                        Mark Escalation Resolved
                      </button>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          ) : (
            <div className="bg-white p-12 rounded-xl border border-gray-200 text-center text-gray-500">
              Select an escalation case from the list to review details and intervene.
            </div>
          )}
        </div>

      </div>

      {/* Modal: Reassign Case */}
      {showReassignModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-200 text-xs">
            <h3 className="text-base font-bold text-gray-900">Reassign Escalated Case</h3>
            <p className="text-gray-500 mt-1">
              Select a verified secretary firm to take over handling for <strong>{selectedEscalation?.companyName}</strong>.
            </p>

            <div className="mt-4">
              <label className="block font-semibold text-gray-700 mb-1">Target Firm</label>
              <select
                value={targetFirm}
                onChange={(e) => setTargetFirm(e.target.value)}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              >
                {firms.filter(f => f.status === 'Active').map(f => (
                  <option key={f.id} value={f.name}>{f.name} (SLA: {f.slaComplianceRate}%)</option>
                ))}
              </select>
            </div>

            <div className="mt-6 flex items-center justify-end gap-3 pt-3 border-t border-gray-100">
              <button
                onClick={() => setShowReassignModal(false)}
                className="px-4 py-2 font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={handleReassign}
                className="px-4 py-2 font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded-lg shadow-sm"
              >
                Confirm Reassignment
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default EscalationsMonitor;
