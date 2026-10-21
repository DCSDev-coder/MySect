import React from 'react';
import { 
  BarChart3, HardDrive, Cpu, 
  Building2, Download
} from 'lucide-react';

const PlatformReports = ({ firms = [], companies = [] }) => {
  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <BarChart3 className="w-4 h-4" />
            <span>Platform Analytics & Regulatory Reporting</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Platform-Wide Reports & Infrastructure Metrics</h1>
          <p className="text-sm text-gray-500">
            Comprehensive oversight on network adoption, SLA benchmarks, AI automated intake rates, and TM Cloud storage utilization.
          </p>
        </div>

        <button className="px-4 py-2 bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 rounded-lg text-sm font-semibold transition-colors shadow-xs flex items-center gap-2">
          <Download className="w-4 h-4" />
          Export Audit PDF Report
        </button>
      </div>

      {/* Grid of Report Modules */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6">
        
        {/* Network Growth */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Network Scale</span>
            <Building2 className="w-4 h-4 text-[#062AAE]" />
          </div>
          <div className="mt-4 text-3xl font-bold text-gray-900">
            {firms.reduce((acc, f) => acc + (f.companiesCount || 0), 0) + companies.length}
          </div>
          <p className="text-xs text-gray-500 mt-1">Total Active Managed Sdn Bhd</p>

          <div className="mt-4 pt-4 border-t border-gray-100 space-y-2 text-xs">
            <div className="flex justify-between text-gray-600">
              <span>Licensed Secretary Firms:</span>
              <strong className="text-gray-900">{firms.filter(f => f.status === 'Active').length} Active</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Average Portfolio per Firm:</span>
              <strong className="text-gray-900">62 Companies</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Platform Capacity Headroom:</span>
              <strong className="text-emerald-600 font-semibold">41.8% Available</strong>
            </div>
          </div>
        </div>

        {/* AI Intake & Handoff Rate */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">AI Intake Efficiency</span>
            <Cpu className="w-4 h-4 text-amber-500" />
          </div>
          <div className="mt-4 text-3xl font-bold text-gray-900">88.4%</div>
          <p className="text-xs text-gray-500 mt-1">Intake questions resolved / structured before human</p>

          <div className="mt-4 pt-4 border-t border-gray-100 space-y-2 text-xs">
            <div className="flex justify-between text-gray-600">
              <span>Primary Model:</span>
              <strong className="text-gray-900">Gemini 2.5 Flash-Lite</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Secretary Draft Assistant:</span>
              <strong className="text-gray-900">Mistral Small 4</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Average Monthly Token Bill:</span>
              <strong className="text-emerald-700">~US$ 18.40 / mo</strong>
            </div>
          </div>
        </div>

        {/* TM Cloud Object Storage */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">TM Cloud Storage</span>
            <HardDrive className="w-4 h-4 text-blue-500" />
          </div>
          <div className="mt-4 text-3xl font-bold text-gray-900">412 GB</div>
          <p className="text-xs text-gray-500 mt-1">Utilized out of 1,000 GB contracted tier</p>

          <div className="w-full bg-gray-100 h-2 rounded-full mt-3 overflow-hidden">
            <div className="h-full bg-blue-600 rounded-full" style={{ width: '41.2%' }}></div>
          </div>

          <div className="mt-4 pt-4 border-t border-gray-100 space-y-2 text-xs">
            <div className="flex justify-between text-gray-600">
              <span>Data Centre:</span>
              <strong className="text-gray-900">TM One Cloud Alpha (MY)</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Statutory 7-Year Retention:</span>
              <strong className="text-emerald-600 font-semibold">Enforced</strong>
            </div>
            <div className="flex justify-between text-gray-600">
              <span>Current Backup Status:</span>
              <strong className="text-gray-900">Daily Snapshot OK</strong>
            </div>
          </div>
        </div>

      </div>

      {/* Firm Performance Leaderboard */}
      <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden mt-8">
        <div className="p-5 border-b border-gray-200 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Secretary Firm Performance & Turnaround Leaderboard</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Comparative benchmark of turnaround speed, client feedback rating, and SLA compliance.
            </p>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Firm Name</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Portfolio Size</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">SLA Compliance Rate</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Average Turnaround</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Customer Rating</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Standing</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {firms.filter(f => f.status === 'Active').map((firm, idx) => (
                <tr key={firm.id} className="hover:bg-gray-50">
                  <td className="px-5 py-4">
                    <div className="font-semibold text-gray-900">{firm.name}</div>
                    <div className="text-gray-400 text-[11px]">{firm.cosecLicenseNo}</div>
                  </td>
                  <td className="px-5 py-4 font-medium text-gray-800">
                    {firm.companiesCount} Companies
                  </td>
                  <td className="px-5 py-4">
                    <span className="font-bold text-emerald-700">{firm.slaComplianceRate}%</span>
                    <div className="w-24 bg-gray-100 h-1.5 rounded-full mt-1 overflow-hidden">
                      <div 
                        className="h-full bg-emerald-500 rounded-full" 
                        style={{ width: `${firm.slaComplianceRate}%` }}
                      ></div>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-gray-700">
                    2.8 Days (Target: 5.0)
                  </td>
                  <td className="px-5 py-4">
                    <span className="font-bold text-gray-900">★ {firm.rating}</span> / 5.0
                  </td>
                  <td className="px-5 py-4">
                    <span className="px-2.5 py-1 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                      Tier 1 Exemplary
                    </span>
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

export default PlatformReports;
