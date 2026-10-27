import React, { useState } from 'react';
import {
  FileSearch, Search, Download
} from 'lucide-react';

const AuditLogs = ({ auditLogs = [] }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('All');

  const actionTypes = ['All', 'FIRM_STATUS_CHANGE', 'LICENCE_VERIFICATION', 'SLA_ESCALATION_TRIGGER', 'PLAN_LIMIT_UPDATED', 'FEE_RULE_MODIFIED'];

  const filtered = auditLogs.filter(log => {
    const matchesSearch = log.actor.toLowerCase().includes(searchTerm.toLowerCase()) ||
      log.targetEntity.toLowerCase().includes(searchTerm.toLowerCase()) ||
      log.details.toLowerCase().includes(searchTerm.toLowerCase()) ||
      log.actionType.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = filterType === 'All' || log.actionType === filterType;
    return matchesSearch && matchesType;
  });

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <FileSearch className="w-4 h-4" />
            <span>Statutory Compliance & Security Ledger</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Platform Audit Trail & Security Logs</h1>
          <p className="text-sm text-gray-500">
            Immutable system logs documenting administrative decisions, practising certificate verifications, portfolio transfers, and permission overrides.
          </p>
        </div>

        <button className="px-4 py-2 bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 rounded-lg text-sm font-semibold transition-colors shadow-xs flex items-center gap-2">
          <Download className="w-4 h-4" />
          Export Audit Trail (CSV)
        </button>
      </div>

      <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs mt-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by actor, entity, action type, IP..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          />
        </div>

        <div className="flex flex-wrap gap-1.5">
          {actionTypes.map((t) => (
            <button
              key={t}
              onClick={() => setFilterType(t)}
              className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors ${filterType === t
                ? 'bg-[#062AAE] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
            >
              {t.replace(/_/g, ' ')}
            </button>
          ))}
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden mt-6">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Timestamp</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Action Type</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Actor & IP</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 whitespace-nowrap">Target Entity</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600 min-w-[420px] w-1/2">Event Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {filtered.map((log) => (
                <tr key={log.id} className="hover:bg-gray-50">
                  <td className="px-5 py-4 font-mono text-gray-500 whitespace-nowrap text-xs">
                    {log.timestamp}
                  </td>
                  <td className="px-5 py-4 whitespace-nowrap">
                    <span className="px-2.5 py-1 text-[11px] font-bold rounded-md bg-blue-50 text-[#062AAE] border border-blue-100 whitespace-nowrap">
                      {log.actionType}
                    </span>
                  </td>
                  <td className="px-5 py-4 whitespace-nowrap">
                    <div className="font-semibold text-gray-900 text-xs">{log.actor}</div>
                    <div className="text-gray-400 font-mono text-[10px] mt-0.5">{log.ipAddress}</div>
                  </td>
                  <td className="px-5 py-4 font-medium text-gray-800 text-xs whitespace-nowrap">
                    {log.targetEntity}
                  </td>
                  <td className="px-5 py-4 text-gray-700 leading-relaxed text-xs sm:text-[13px] min-w-[420px]">
                    {log.details}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AuditLogs;
