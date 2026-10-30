import React, { useState } from 'react';
import {
  LayoutDashboard, Building2, Briefcase, AlertCircle,
  Settings, LogOut, UserCheck, X
} from 'lucide-react';
import mysectLogo from '../assets/mysect_logo.png';

const Sidebar = ({
  activePage,
  setActivePage,
  pendingFirmsCount = 0,
  urgentItemsCount = 0,
  currentUser = null,
  onLogout = () => {},
  isOpen = false,
  onClose = () => {},
}) => {
  const menuItems = [
    {
      id: 'Overview',
      label: 'Overview',
      icon: LayoutDashboard
    },
    {
      id: 'Users',
      label: 'Users & Access',
      icon: UserCheck
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
      icon: Briefcase
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
    <>
      {/* Mobile Drawer Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/40 backdrop-blur-2xs z-40 lg:hidden transition-opacity"
          onClick={onClose}
          aria-hidden="true"
        />
      )}

      {/* Sidebar Container */}
      <div className={`
        fixed inset-y-0 left-0 z-50 w-64 bg-white border-r border-gray-200 h-screen flex flex-col shrink-0 select-none transition-transform duration-300 ease-in-out shadow-xl lg:shadow-none
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:static lg:translate-x-0 lg:z-auto
      `}>
        {/* Brand Header */}
        <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
          <img 
            src={mysectLogo} 
            alt="MySect - Your Secretary Company" 
            className="h-10 sm:h-12 w-auto max-w-[170px] sm:max-w-[190px] object-contain mx-auto lg:mx-0" 
          />
          <button
            onClick={onClose}
            className="lg:hidden p-1.5 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 cursor-pointer"
            aria-label="Close Sidebar"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Clean Navigation */}
        <div className="flex-1 px-3 py-6 space-y-1 overflow-y-auto no-scrollbar">
          {menuItems.map((item) => {
            const isActive = activePage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => {
                  setActivePage(item.id);
                  onClose();
                }}
                className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all cursor-pointer ${isActive
                    ? 'bg-[#062AAE] text-white shadow-xs'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`}
              >
                <div className="flex items-center gap-3">
                  <item.icon className={`w-5 h-5 shrink-0 ${isActive ? 'text-white' : 'text-gray-400'}`} />
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
        <div className="p-3.5 border-t border-gray-100 shrink-0">
          <div className="flex items-center justify-between p-2 rounded-xl bg-gray-50 border border-gray-100">
            <div className="flex items-center gap-2.5 overflow-hidden min-w-0">
              <div className="w-8 h-8 rounded-full bg-[#062AAE] text-white flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs">
                {currentUser?.avatar || 'AF'}
              </div>
              <div className="overflow-hidden min-w-0">
                <p className="text-xs font-semibold text-gray-900 truncate">
                  {currentUser?.name || 'Ahmad Faizal'}
                </p>
                <p className="text-[11px] text-gray-500 truncate">
                  {currentUser?.role || 'Super Admin'}
                </p>
              </div>
            </div>
            <button
              onClick={onLogout}
              title="Sign Out"
              className="px-2.5 py-1.5 text-xs font-semibold text-gray-600 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors cursor-pointer shrink-0 flex items-center gap-1.5 border border-transparent hover:border-rose-100"
            >
              <LogOut className="w-3.5 h-3.5" />
              <span className="text-[11px]">Logout</span>
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
