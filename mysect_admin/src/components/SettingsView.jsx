import React, { useState } from 'react';
import { CreditCard, DollarSign, Sliders, FileSearch, BarChart3 } from 'lucide-react';
import SubscriptionPlans from './SubscriptionPlans';
import FeesCommissions from './FeesCommissions';
import PlatformSettings from './PlatformSettings';
import AuditLogs from './AuditLogs';
import PlatformReports from './PlatformReports';

const SettingsView = ({
  plans = [],
  firms = [],
  companies = [],
  feeRules = [],
  auditLogs = [],
  policies = {},
  onCreatePlan,
  onUpdatePlan,
  onSaveRule,
  onSavePolicies,
}) => {
  const [activeTab, setActiveTab] = useState('plans');

  return (
    <div className="flex-1 flex flex-col h-full overflow-hidden bg-[#F8F9FA]">
      {/* Clean Top Navigation Bar for Settings */}
      <div className="bg-white border-b border-gray-200 px-4 sm:px-8 pt-4 sm:pt-6 pb-0 shrink-0">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Plans, Policies & Audit</h1>
          <p className="text-xs sm:text-sm text-gray-500 mt-0.5">
            Configure subscription tiers, company limits, platform fees, e-KYC policies, and view statutory audit records.
          </p>
        </div>

        {/* Clean Pill Tabs */}
        <div className="flex items-center gap-2 mt-6 overflow-x-auto overflow-y-hidden no-scrollbar pb-0">
          <button
            onClick={() => setActiveTab('plans')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'plans'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <CreditCard className="w-4 h-4" />
            <span>Subscription Plans & Limits</span>
          </button>

          <button
            onClick={() => setActiveTab('fees')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'fees'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <DollarSign className="w-4 h-4" />
            <span>Fees & Commissions</span>
          </button>

          <button
            onClick={() => setActiveTab('policies')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'policies'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <Sliders className="w-4 h-4" />
            <span>Platform Policies & e-KYC</span>
          </button>

          <button
            onClick={() => setActiveTab('reports')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'reports'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <BarChart3 className="w-4 h-4" />
            <span>Reports & Analytics</span>
          </button>

          <button
            onClick={() => setActiveTab('audit')}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-semibold border-b-2 transition-all -mb-[2px] ${
              activeTab === 'audit'
                ? 'border-[#062AAE] text-[#062AAE]'
                : 'border-transparent text-gray-500 hover:text-gray-800'
            }`}
          >
            <FileSearch className="w-4 h-4" />
            <span>Audit Trail</span>
          </button>
        </div>
      </div>

      {/* Tab Content Area */}
      <div className="flex-1 overflow-y-auto">
        {activeTab === 'plans' && (
          <SubscriptionPlans
            plans={plans}
            firms={firms}
            onCreatePlan={onCreatePlan}
            onUpdatePlan={onUpdatePlan}
          />
        )}

        {activeTab === 'fees' && (
          <FeesCommissions
            feeRules={feeRules}
            onSaveRule={onSaveRule}
          />
        )}

        {activeTab === 'policies' && (
          <PlatformSettings
            initialPolicies={policies}
            onSavePolicies={onSavePolicies}
          />
        )}

        {activeTab === 'reports' && (
          <PlatformReports
            firms={firms}
            companies={companies}
          />
        )}

        {activeTab === 'audit' && (
          <AuditLogs
            auditLogs={auditLogs}
          />
        )}
      </div>
    </div>
  );
};

export default SettingsView;
