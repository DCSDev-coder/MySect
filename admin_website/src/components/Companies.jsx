import React, { useState } from 'react';
import { Search, Plus, MoreVertical, Building2 } from 'lucide-react';

const Companies = () => {
  const [filter, setFilter] = useState('All');
  const companies = [
    { id: 1, name: 'Acme Corp', status: 'Active', members: 12, lastActive: '2 hrs ago' },
    { id: 2, name: 'Global Tech', status: 'Pending', members: 4, lastActive: '1 day ago' },
    { id: 3, name: 'Startup Inc', status: 'Active', members: 8, lastActive: '5 mins ago' },
  ];

  return (
    <div className="flex-1 flex flex-col h-full bg-[#F8F9FA] overflow-hidden">
      {/* Header */}
      <header className="px-8 py-6 flex items-center justify-between flex-shrink-0">
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Companies</h2>
          <p className="text-sm text-gray-500 mt-1">Manage and monitor all your client companies</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-[#D71920] text-white rounded-lg text-sm font-medium hover:bg-red-700 transition-colors">
          <Plus className="w-4 h-4 mr-2" />
          Add Company
        </button>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-8 pb-8">
        
        {/* Search & Filters */}
        <div className="flex items-center gap-4 mb-6">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search by name or registration no..." 
              className="w-full pl-10 pr-4 py-2.5 border border-gray-200 bg-white rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
            />
          </div>
          
          <div className="flex bg-white border border-gray-200 rounded-xl p-1">
            {['All', 'Active', 'Pending', 'Dormant'].map((status) => (
              <button
                key={status}
                onClick={() => setFilter(status)}
                className={`px-5 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                  filter === status
                    ? 'bg-gray-900 text-white'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                }`}
              >
                {status}
              </button>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Company</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Members</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Last Active</th>
                <th className="px-6 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {companies.filter(c => filter === 'All' || c.status === filter).map((company) => (
                <tr key={company.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center">
                      <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-[#062AAE] mr-3">
                        <Building2 className="w-5 h-5" />
                      </div>
                      <span className="font-medium text-gray-900">{company.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      company.status === 'Active' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {company.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">{company.members} users</td>
                  <td className="px-6 py-4 text-sm text-gray-500">{company.lastActive}</td>
                  <td className="px-6 py-4 text-right">
                    <button className="text-gray-400 hover:text-gray-600">
                      <MoreVertical className="w-5 h-5" />
                    </button>
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

export default Companies;
