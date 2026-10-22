import React, { useState } from 'react';
import { 
  HelpCircle, CheckCircle2, Search
} from 'lucide-react';

const SupportDisputes = ({ 
  disputes = [], 
  onResolveDispute 
}) => {
  const [disputeList, setDisputeList] = useState(disputes);
  const [selectedDispute, setSelectedDispute] = useState(disputes[0] || null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterPriority, setFilterPriority] = useState('All');
  const [resolutionText, setResolutionText] = useState('');

  const filtered = disputeList.filter(d => {
    const matchesSearch = d.ticketNo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          d.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          d.claimant.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesPri = filterPriority === 'All' || d.priority.includes(filterPriority);
    return matchesSearch && matchesPri;
  });

  const handleResolve = () => {
    if (!selectedDispute) return;
    const updated = {
      ...selectedDispute,
      status: 'Resolved by Admin Moderator',
      resolutionSummary: resolutionText || selectedDispute.resolutionSummary
    };
    setDisputeList(disputeList.map(d => d.id === selectedDispute.id ? updated : d));
    setSelectedDispute(updated);
    setResolutionText('');
    if (onResolveDispute) onResolveDispute(selectedDispute.id, updated.resolutionSummary);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <HelpCircle className="w-4 h-4" />
            <span>Support Arbitration & Dispute Resolution</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Platform Support Cases & Disputes</h1>
          <p className="text-sm text-gray-500">
            Mediate client-firm service disputes, investigate billing discrepancies, and maintain professional service standards across the network.
          </p>
        </div>

        <div className="text-xs bg-white border border-gray-200 rounded-lg p-2.5 px-4 shadow-xs">
          <span className="text-gray-500">Open Disputes:</span>{' '}
          <strong className="text-rose-600 font-bold">{disputeList.filter(d => !d.status.includes('Resolved')).length}</strong>
        </div>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 xl:grid-cols-12 gap-6 mt-6">
        {/* Left List (5 cols) */}
        <div className="xl:col-span-5 space-y-4">
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs space-y-3">
            <div className="relative">
              <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input 
                type="text"
                placeholder="Search ticket #, subject, claimant..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              />
            </div>

            <div className="flex gap-1.5 pt-1">
              {['All', 'Critical', 'Medium'].map((pri) => (
                <button
                  key={pri}
                  onClick={() => setFilterPriority(pri)}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors ${
                    filterPriority === pri 
                      ? 'bg-[#062AAE] text-white' 
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  {pri === 'All' ? 'All Tickets' : `${pri} Priority`}
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-3">
            {filtered.map((d) => {
              const isSelected = selectedDispute?.id === d.id;
              return (
                <div
                  key={d.id}
                  onClick={() => setSelectedDispute(d)}
                  className={`p-4 rounded-xl border transition-all cursor-pointer ${
                    isSelected 
                      ? 'bg-blue-50/50 border-[#062AAE] shadow-xs ring-1 ring-[#062AAE]' 
                      : 'bg-white border-gray-200 hover:border-gray-300 shadow-xs'
                  }`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <span className="text-xs font-mono font-bold text-gray-500">{d.ticketNo}</span>
                      <h4 className="font-semibold text-sm text-gray-900 mt-0.5">{d.subject}</h4>
                    </div>
                    <span className={`px-2.5 py-1 text-[11px] font-semibold rounded-full text-center inline-flex items-center justify-center shrink-0 leading-tight ${
                      d.priority === 'Critical' 
                        ? 'bg-rose-50 text-rose-700 border border-rose-200' 
                        : 'bg-amber-50 text-amber-700 border border-amber-200'
                    }`}>
                      {d.priority}
                    </span>
                  </div>

                  <p className="text-xs text-gray-600 mt-2 line-clamp-2">
                    Claimant: <strong>{d.claimant}</strong> vs <strong>{d.respondentFirm}</strong>
                  </p>

                  <div className="mt-3 flex items-center justify-between text-xs text-gray-500 pt-2 border-t border-gray-100">
                    <span>Category: {d.category}</span>
                    <span className={d.status.includes('Resolved') ? 'text-emerald-700 font-semibold' : 'text-amber-700 font-medium'}>
                      {d.status}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Right Detail (7 cols) */}
        <div className="xl:col-span-7">
          {selectedDispute ? (
            <div className="bg-white rounded-xl border border-gray-200 shadow-xs overflow-hidden sticky top-8">
              <div className="p-6 border-b border-gray-200 bg-gray-50/50">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-mono font-bold text-gray-600 bg-white px-2 py-0.5 rounded border border-gray-200">
                        {selectedDispute.ticketNo}
                      </span>
                      <span className="text-xs text-gray-500">Opened {selectedDispute.openedDate}</span>
                    </div>
                    <h2 className="text-lg font-bold text-gray-900 mt-2">{selectedDispute.subject}</h2>
                    <p className="text-xs text-gray-500 mt-0.5">Category: {selectedDispute.category}</p>
                  </div>

                  <span className={`px-3 py-1.5 text-xs font-semibold rounded-lg text-center inline-flex items-center justify-center leading-tight shrink-0 ${
                    selectedDispute.status.includes('Resolved') 
                      ? 'bg-emerald-100 text-emerald-800 border border-emerald-200' 
                      : 'bg-amber-100 text-amber-800 border border-amber-200'
                  }`}>
                    {selectedDispute.status}
                  </span>
                </div>
              </div>

              <div className="p-6 space-y-6 text-xs">
                <div className="grid grid-cols-2 gap-4">
                  <div className="p-3 bg-gray-50 rounded-xl border border-gray-200">
                    <span className="text-gray-400 block text-[11px]">Claimant / Complainant</span>
                    <strong className="text-gray-900 text-sm block mt-0.5">{selectedDispute.claimant}</strong>
                  </div>
                  <div className="p-3 bg-gray-50 rounded-xl border border-gray-200">
                    <span className="text-gray-400 block text-[11px]">Respondent Firm</span>
                    <strong className="text-gray-900 text-sm block mt-0.5">{selectedDispute.respondentFirm}</strong>
                  </div>
                </div>

                <div>
                  <h4 className="font-semibold text-gray-700 uppercase tracking-wider mb-1">Dispute Details & Investigation Findings</h4>
                  <div className="bg-gray-50 p-4 rounded-xl border border-gray-200 text-gray-700 leading-relaxed">
                    {selectedDispute.resolutionSummary}
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-200 space-y-3">
                  <h4 className="font-semibold text-gray-700 uppercase tracking-wider">Moderator Resolution Order</h4>
                  <textarea
                    rows={3}
                    placeholder="Enter formal arbitration decision or handover agreement..."
                    value={resolutionText}
                    onChange={(e) => setResolutionText(e.target.value)}
                    className="w-full p-3 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />

                  <div className="flex items-center justify-end gap-3 pt-2">
                    <button
                      onClick={handleResolve}
                      className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold shadow-xs flex items-center gap-1.5 transition-colors"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      Issue Moderator Resolution
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white p-12 rounded-xl border border-gray-200 text-center text-gray-500">
              Select a dispute ticket to view details.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SupportDisputes;
