import React from 'react';
import { 
  LayoutDashboard, Building2, ClipboardList, Clock, 
  FileText, Hammer, Calendar, Users, Search, ChevronDown 
} from 'lucide-react';
import mysectLogo from '../assets/mysect_main_logo.png';

const Sidebar = ({ activePage, setActivePage }) => {
  const menuItems = [
    { name: 'Dashboard', icon: LayoutDashboard },
    { name: 'Companies', icon: Building2 },
    { name: 'Tasks', icon: ClipboardList },
    { name: 'Deadlines', icon: Clock },
  ];

  return (
    <div className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col flex-shrink-0">
      <div className="p-6">
        <img src={mysectLogo} alt="mysect" className="h-8 w-auto object-contain" />
      </div>
      
      <div className="px-4 mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input 
            type="text" 
            placeholder="Search..." 
            className="w-full pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-3">
        <div className="mb-6">
          <p className="px-3 text-xs font-semibold text-gray-400 tracking-wider mb-2">OPERATIONS</p>
          <nav className="space-y-1">
            {menuItems.map((item) => {
              const isActive = activePage === item.name;
              return (
                <button
                  key={item.name}
                  onClick={() => setActivePage(item.name)}
                  className={`w-full flex items-center px-3 py-2.5 rounded-lg font-medium transition-colors ${
                    isActive 
                      ? 'bg-gray-50 text-[#062AAE]' 
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`}
                >
                  <item.icon className={`w-5 h-5 mr-3 ${isActive ? 'text-[#062AAE]' : 'text-gray-700'}`} />
                  {item.name}
                  {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-[#062AAE]"></div>}
                </button>
              );
            })}
          </nav>
        </div>

        <div>
          <p className="px-3 text-xs font-semibold text-gray-400 tracking-wider mb-2">MORE FEATURES</p>
          <nav className="space-y-1">
            <a href="#" className="flex items-center px-3 py-2.5 text-gray-400 hover:text-gray-600 rounded-lg font-medium transition-colors">
              <FileText className="w-5 h-5 mr-3" />
              Documents
            </a>
            <a href="#" className="flex items-center px-3 py-2.5 text-gray-400 hover:text-gray-600 rounded-lg font-medium transition-colors">
              <Hammer className="w-5 h-5 mr-3" />
              Resolutions
            </a>
            <a href="#" className="flex items-center px-3 py-2.5 text-gray-400 hover:text-gray-600 rounded-lg font-medium transition-colors">
              <Calendar className="w-5 h-5 mr-3" />
              Meetings
            </a>
            <a href="#" className="flex items-center px-3 py-2.5 text-gray-400 hover:text-gray-600 rounded-lg font-medium transition-colors">
              <Users className="w-5 h-5 mr-3" />
              Team
            </a>
          </nav>
        </div>
      </div>

      <div className="p-4 border-t border-gray-200">
        <div className="flex items-center cursor-pointer hover:bg-gray-50 p-2 rounded-lg transition-colors">
          <div className="w-9 h-9 rounded-full bg-[#062AAE] text-white flex items-center justify-center font-semibold text-sm">
            SA
          </div>
          <div className="ml-3 flex-1 overflow-hidden">
            <p className="text-sm font-semibold text-gray-900 truncate">Sarah Ahmad</p>
            <p className="text-xs text-gray-500 truncate">Data Center Specialists Sdn...</p>
          </div>
          <ChevronDown className="w-4 h-4 text-gray-400 ml-1" />
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
