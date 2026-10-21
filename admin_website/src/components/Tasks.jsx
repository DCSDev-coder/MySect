import React, { useState } from 'react';
import { CheckCircle2, Clock, MoreVertical, Plus } from 'lucide-react';

const Tasks = () => {
  const [filter, setFilter] = useState('All');
  const tasks = [
    { id: 1, title: 'Review annual return', company: 'Acme Corp', priority: 'High', status: 'In Progress' },
    { id: 2, title: 'Draft board resolution', company: 'Global Tech', priority: 'Medium', status: 'Pending' },
    { id: 3, title: 'Update register of members', company: 'Startup Inc', priority: 'Low', status: 'Completed' },
  ];

  return (
    <div className="flex-1 flex flex-col h-full bg-[#F8F9FA] overflow-hidden">
      <header className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between flex-shrink-0">
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Tasks</h2>
          <p className="text-sm text-gray-500">Track and manage your tasks</p>
        </div>
        <div className="flex items-center space-x-4">
          <select 
            value={filter} 
            onChange={(e) => setFilter(e.target.value)} 
            className="border border-gray-200 bg-white rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          >
            <option value="All">All Statuses</option>
            <option value="In Progress">In Progress</option>
            <option value="Pending">Pending</option>
            <option value="Completed">Completed</option>
          </select>
          <button className="flex items-center px-4 py-2 bg-[#D71920] text-white rounded-lg text-sm font-medium hover:bg-red-700 transition-colors">
            <Plus className="w-4 h-4 mr-2" />
            New Task
          </button>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto p-8">
        <div className="space-y-4">
          {tasks.filter(t => filter === 'All' || t.status === filter).map((task) => (
            <div key={task.id} className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
              <div className="flex items-center flex-1">
                <button className={`w-6 h-6 rounded-full border-2 flex items-center justify-center mr-4 ${
                  task.status === 'Completed' ? 'bg-green-500 border-green-500' : 'border-gray-300'
                }`}>
                  {task.status === 'Completed' && <CheckCircle2 className="w-4 h-4 text-white" />}
                </button>
                <div>
                  <h3 className={`font-semibold ${task.status === 'Completed' ? 'text-gray-400 line-through' : 'text-gray-900'}`}>
                    {task.title}
                  </h3>
                  <p className="text-sm text-gray-500 mt-1">{task.company}</p>
                </div>
              </div>
              <div className="flex items-center space-x-6">
                <span className={`px-2.5 py-1 rounded-md text-xs font-medium ${
                  task.priority === 'High' ? 'bg-red-50 text-red-700' : 
                  task.priority === 'Medium' ? 'bg-yellow-50 text-yellow-700' : 
                  'bg-blue-50 text-[#062AAE]'
                }`}>
                  {task.priority}
                </span>
                <button className="text-gray-400 hover:text-gray-600">
                  <MoreVertical className="w-5 h-5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Tasks;
