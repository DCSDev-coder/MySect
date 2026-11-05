import React, { useState } from 'react';
import { Calendar as CalendarIcon, AlertCircle, Clock } from 'lucide-react';

const Deadlines = () => {
  const [filter, setFilter] = useState('All');
  const deadlines = [
    { id: 1, title: 'Annual General Meeting', company: 'Acme Corp', date: 'Oct 15, 2026', daysLeft: 17, type: 'Meeting' },
    { id: 2, title: 'Tax Filing Deadline', company: 'Global Tech', date: 'Oct 31, 2026', daysLeft: 33, type: 'Compliance' },
    { id: 3, title: 'Financial Year End', company: 'Startup Inc', date: 'Dec 31, 2026', daysLeft: 94, type: 'Filing' },
  ];

  return (
    <div className="flex-1 flex flex-col h-full bg-[#F8F9FA] overflow-hidden">
      <header className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between flex-shrink-0">
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Deadlines</h2>
          <p className="text-sm text-gray-500">Upcoming statutory compliance deadlines</p>
        </div>
        <div className="flex items-center space-x-4">
          <select 
            value={filter} 
            onChange={(e) => setFilter(e.target.value)} 
            className="border border-gray-200 bg-white rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          >
            <option value="All">All Types</option>
            <option value="Meeting">Meeting</option>
            <option value="Compliance">Compliance</option>
            <option value="Filing">Filing</option>
          </select>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto p-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {deadlines.filter(d => filter === 'All' || d.type === filter).map((deadline) => (
            <div key={deadline.id} className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 relative overflow-hidden">
              <div className={`absolute top-0 left-0 w-1 h-full ${
                deadline.daysLeft <= 30 ? 'bg-[#D71920]' : 'bg-[#062AAE]'
              }`} />
              
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center space-x-2 text-sm text-gray-500">
                  <CalendarIcon className="w-4 h-4" />
                  <span>{deadline.date}</span>
                </div>
                <span className="text-xs font-medium bg-gray-100 text-gray-600 px-2 py-1 rounded-md">
                  {deadline.type}
                </span>
              </div>
              
              <h3 className="text-lg font-bold text-gray-900 mb-1">{deadline.title}</h3>
              <p className="text-sm text-gray-500 mb-4">{deadline.company}</p>
              
              <div className="flex items-center mt-4 pt-4 border-t border-gray-50">
                {deadline.daysLeft <= 30 ? (
                  <AlertCircle className="w-5 h-5 text-[#D71920] mr-2" />
                ) : (
                  <Clock className="w-5 h-5 text-[#062AAE] mr-2" />
                )}
                <span className={`font-semibold ${
                  deadline.daysLeft <= 30 ? 'text-[#D71920]' : 'text-[#062AAE]'
                }`}>
                  {deadline.daysLeft} days left
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Deadlines;
