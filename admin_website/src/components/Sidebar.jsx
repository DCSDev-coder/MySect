import React from 'react';
import { 
  LayoutDashboard, Building2, Users, AlertCircle, 
  Settings
} from 'lucide-react';
import mysectLogo from '../assets/mysect_main_logo.png';

const Sidebar = ({ 
  activePage, 
  setActivePage,
  pendingFirmsCount = 0,
  urgentItemsCount = 0,
}) => {
  const menuItems = [
    { 
      id: 'Overview', 
      label: 'Overview', 
      icon: LayoutDashboard 
    },
    { 
      id: 'Firms', 
      label: 'Secretary Firms', 
      icon: Building2,
      badge: pendingFirmsCount > 0 ? pendingFirmsCount : null,
      badgeColor: 'bg-amber-100 text-amber-800'
    },
    { 
      id: 'Companies', 
      label: 'Companies', 
      icon: Users 
    },
    { 
      id: 'Operations', 
      label: 'Operations & Issues', 
      icon: AlertCircle,
      badge: urgentItemsCount > 0 ? urgentItemsCount : null,
      badgeColor: 'bg-rose-100 text-rose-800'
    },
    { 
      id: 'Settings', 
      label: 'Plans & Settings', 
      icon: Settings 
    },
  ];

  return (
    <div className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col shrink-0 select-none">
      {/* Brand Header */}
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-center gap-2.5">
          <img src={mysectLogo} alt="MySect" className="h-7 w-auto object-contain" />
          <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 bg-gray-100 text-gray-700 rounded-md">
            Admin
          </span>
        </div>
      </div>

      {/* Clean 5-Item Navigation */}
      <div className="flex-1 px-3 py-6 space-y-1">
        {menuItems.map((item) => {
          const isActive = activePage === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActivePage(item.id)}
              className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                isActive 
                  ? 'bg-[#062AAE] text-white shadow-xs' 
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <div className="flex items-center gap-3">
                <item.icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-gray-400'}`} />
                <span>{item.label}</span>
              </div>
              {item.badge && (
                <span className={`px-2 py-0.5 text-xs font-bold rounded-full ${
                  isActive ? 'bg-white/20 text-white' : item.badgeColor
                }`}>
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Operator Profile Footer */}
      <div className="p-4 border-t border-gray-100">
        <div className="flex items-center gap-3 p-2 rounded-xl bg-gray-50">
          <div className="w-8 h-8 rounded-full bg-[#062AAE] text-white flex items-center justify-center font-bold text-xs shrink-0">
            HQ
          </div>
          <div className="flex-1 overflow-hidden">
            <p className="text-xs font-semibold text-gray-900 truncate">Platform Moderator</p>
            <p className="text-[11px] text-gray-500 truncate">admin@mysect.com.my</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
