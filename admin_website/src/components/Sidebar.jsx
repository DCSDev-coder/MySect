import React, { useState } from 'react';
import {
  LayoutDashboard, Building2, Users, AlertCircle,
  Settings, LogOut
} from 'lucide-react';
import mysectLogo from '../assets/mysect_logo.png';

const Sidebar = ({
  activePage,
  setActivePage,
  pendingFirmsCount = 0,
  urgentItemsCount = 0,
  currentUser = null,
  onLogout = () => {},
}) => {
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
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
      <div className="px-6 pt-[30px] pb-6 border-b border-gray-100 flex items-center justify-center">
        <img 
          src={mysectLogo} 
          alt="MySect - Your Secretary Company" 
          className="h-9 w-auto max-w-[170px] object-contain" 
        />
      </div>

      {/* Clean 5-Item Navigation */}
      <div className="flex-1 px-3 py-6 space-y-1">
        {menuItems.map((item) => {
          const isActive = activePage === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActivePage(item.id)}
              className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${isActive
                  ? 'bg-[#062AAE] text-white shadow-xs'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`}
            >
              <div className="flex items-center gap-3">
                <item.icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-gray-400'}`} />
                <span>{item.label}</span>
              </div>
              {item.badge && (
                <span className={`px-2 py-0.5 text-xs font-bold rounded-full ${isActive ? 'bg-white/20 text-white' : item.badgeColor
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
        <div className="flex items-center justify-between p-2.5 rounded-xl bg-gray-50 border border-gray-100">
          <div className="flex items-center gap-2.5 overflow-hidden">
            <div className="w-8 h-8 rounded-full bg-[#062AAE] text-white flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs">
              {currentUser?.avatar || 'AF'}
            </div>
            <div className="overflow-hidden">
              <p className="text-xs font-semibold text-gray-900 truncate">
                {currentUser?.name || 'Ahmad Faizal'}
              </p>
              <p className="text-[11px] text-gray-500 truncate">
                {currentUser?.role || 'Super Admin'}
              </p>
            </div>
          </div>
          <button
            onClick={() => setShowLogoutConfirm(true)}
            title="Sign out of Admin Console"
            className="p-1.5 text-gray-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors cursor-pointer shrink-0"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Logout Confirmation Modal */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-2xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-xs w-full p-6 shadow-2xl border border-gray-100 animate-in fade-in zoom-in-95 duration-150">
            <div className="w-10 h-10 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center mb-3">
              <LogOut className="w-5 h-5" />
            </div>
            <h3 className="text-sm font-bold text-gray-900">Sign Out of MySect Admin?</h3>
            <p className="text-xs text-gray-500 mt-1 leading-relaxed">
              Your administrative session will be terminated and audit logs will record your sign-out.
            </p>
            <div className="flex items-center gap-2.5 mt-5">
              <button
                type="button"
                onClick={() => setShowLogoutConfirm(false)}
                className="flex-1 py-2 px-3 border border-gray-200 rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowLogoutConfirm(false);
                  onLogout();
                }}
                className="flex-1 py-2 px-3 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-semibold shadow-xs cursor-pointer"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Sidebar;
