import React, { useState } from 'react';
import { AlertTriangle, HelpCircle, Bell, FileSpreadsheet } from 'lucide-react';
import EscalationsMonitor from './EscalationsMonitor';
import SupportDisputes from './SupportDisputes';
import GlobalNotifications from './GlobalNotifications';
import ServiceCatalogue from './ServiceCatalogue';

const OperationsView = ({
  escalations = [],
  firms = [],
  disputes = [],
  notifications = [],
  services = [],
  onResolveEscalation,
  onReassignEscalation,
  onResolveDispute,
  onPublishNotification,
  onSaveService,
}) => {
  const [activeTab, setActiveTab] = useState('escalations');

  const openEscalationsCount = escalations.filter(e => !e.status.includes('Resolved')).length;
  const openDisputesCount = disputes.filter(d => !d.status.includes('Resolved')).length;

  return (
    <div className="flex-1 flex flex-col h-screen overflow-hidden bg-[#F8F9FA]">
      {/* Clean Top Navigation Bar for Operations */}
      <div className="bg-white border-b border-gray-200 px-8 pt-6 pb-0 shrink-0">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Operations & Network Services</h1>
          <p className="text-sm text-gray-500 mt-0.5">
            Manage escalations, overdue Section 68 returns, disputes, service catalogues, and broadcasts.
          </p>
        </div>

        {/* Clean Pill Tabs */}
        <div className="flex items-center gap-2 mt-6 overflow-x-auto overflow-y-hidden no-scrollbar pb-0">
          <button
            onClick={() => setActiveTab('escalations')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'escalations'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <AlertTriangle className="w-4 h-4" />
            <span>Escalations & Overdue</span>
            {openEscalationsCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-rose-100 text-rose-800">
                {openEscalationsCount}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveTab('disputes')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'disputes'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <HelpCircle className="w-4 h-4" />
            <span>Support & Disputes</span>
            {openDisputesCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-amber-100 text-amber-800">
                {openDisputesCount}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveTab('announcements')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'announcements'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <Bell className="w-4 h-4" />
            <span>Announcements & Notices</span>
          </button>

          <button
            onClick={() => setActiveTab('catalogue')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'catalogue'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <FileSpreadsheet className="w-4 h-4" />
            <span>Service Catalogue & SLAs</span>
          </button>
        </div>
      </div>

      {/* Tab Content Area */}
      <div className="flex-1 overflow-y-auto">
        {activeTab === 'escalations' && (
          <EscalationsMonitor
            escalations={escalations}
            firms={firms}
            onResolveEscalation={onResolveEscalation}
            onReassignEscalation={onReassignEscalation}
          />
        )}

        {activeTab === 'disputes' && (
          <SupportDisputes
            disputes={disputes}
            onResolveDispute={onResolveDispute}
          />
        )}

        {activeTab === 'announcements' && (
          <GlobalNotifications
            notifications={notifications}
            onPublishNotification={onPublishNotification}
          />
        )}

        {activeTab === 'catalogue' && (
          <ServiceCatalogue
            services={services}
            onSaveService={onSaveService}
          />
        )}
      </div>
    </div>
  );
};

export default OperationsView;
