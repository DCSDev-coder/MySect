import React, { useState } from 'react';
import { 
  Sliders, ShieldCheck, HardDrive, Cpu, 
  Lock, CheckCircle2, Save
} from 'lucide-react';

const PlatformSettings = ({ 
  initialPolicies = {}, 
  onSavePolicies 
}) => {
  const [policies, setPolicies] = useState({
    ekycStrictRequirement: true,
    ekycProvider: 'Epsilon ID V3 (Malaysia MyKad + Facial Liveness)',
    tmCloudDataResidency: 'TM One Cloud Alpha (Kuala Lumpur Data Centre DC1/DC2)',
    statutoryRetentionYears: 7,
    crossBorderAiPolicy: 'Strict Local (Sensitive company records scrubbed before model reasoning)',
    defaultAiProvider: 'Gemini 2.5 Flash-Lite (Intake) + Mistral Small (Drafting)',
    adminMfaEnforced: true,
    sessionTimeoutMinutes: 30,
    maxCompanyLimitPerStaffRatio: 50,
    ...initialPolicies,
  });

  const [savedNotice, setSavedNotice] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (onSavePolicies) onSavePolicies(policies);
    setSavedNotice(true);
    setTimeout(() => setSavedNotice(false), 3000);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <Sliders className="w-4 h-4" />
            <span>Platform Governance & Compliance Settings</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Platform Policies & Security Configuration</h1>
          <p className="text-sm text-gray-500">
            Enforce e-KYC standards, TM Cloud data residency rules, PDPA AI safeguards, and platform administrative parameters.
          </p>
        </div>

        {savedNotice && (
          <span className="px-3.5 py-1.5 bg-emerald-50 text-emerald-700 text-xs font-semibold rounded-lg flex items-center gap-1.5 border border-emerald-200">
            <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            Policies Successfully Applied
          </span>
        )}
      </div>

      <form onSubmit={handleSubmit} className="mt-6 max-w-4xl space-y-6 text-xs">
        
        {/* 1. Identity & e-KYC Verification Policy */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-[#062AAE]" />
            e-KYC & Secretary Identity Verification Policy (Blueprint Section 12)
          </h3>
          <p className="text-gray-500 mt-1">
            Governs mandatory identity checking for firm principals and appointed licensed company secretaries before platform activation.
          </p>

          <div className="mt-4 space-y-4">
            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={policies.ekycStrictRequirement}
                onChange={(e) => setPolicies({ ...policies, ekycStrictRequirement: e.target.checked })}
                className="rounded text-[#062AAE] focus:ring-[#062AAE] w-4 h-4"
              />
              <div>
                <span className="font-semibold text-gray-900 block">Strict e-KYC Enforcement</span>
                <span className="text-gray-500 block text-[11px]">
                  Firms cannot accept new client companies until the primary licensed secretary passes identity and liveness check.
                </span>
              </div>
            </label>

            <div>
              <label className="block font-semibold text-gray-700 mb-1">Contracted e-KYC Provider</label>
              <select
                value={policies.ekycProvider}
                onChange={(e) => setPolicies({ ...policies, ekycProvider: e.target.value })}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              >
                <option value="Epsilon ID V3 (Malaysia MyKad + Facial Liveness)">
                  Epsilon ID V3 by LangitDigital (Malaysia MyKad, MyPR, Passport + Liveness)
                </option>
                <option value="TrueIdentity by Truestack">
                  TrueIdentity by Truestack (Malaysia Hosted SDK)
                </option>
                <option value="MasChain eKYC">
                  MasChain eKYC (Blockchain verified credential trail)
                </option>
              </select>
            </div>
          </div>
        </div>

        {/* 2. Data Residency & TM Cloud Storage Rules */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2">
            <HardDrive className="w-4 h-4 text-blue-500" />
            Data Residency & Statutory Document Retention (Blueprint Section 9)
          </h3>
          <p className="text-gray-500 mt-1">
            Statutory record retention under Companies Act 2016 Section 47.
          </p>

          <div className="mt-4 grid grid-cols-2 gap-4">
            <div>
              <label className="block font-semibold text-gray-700 mb-1">Cloud Object Storage Location</label>
              <input
                type="text"
                disabled
                value={policies.tmCloudDataResidency}
                className="w-full p-2.5 bg-gray-100 border border-gray-200 rounded-lg text-xs text-gray-600 font-medium"
              />
              <span className="text-[11px] text-gray-400 mt-1 block">Malaysia sovereign cloud residency guaranteed</span>
            </div>

            <div>
              <label className="block font-semibold text-gray-700 mb-1">Statutory Document Retention Period (Years)</label>
              <input
                type="number"
                value={policies.statutoryRetentionYears}
                onChange={(e) => setPolicies({ ...policies, statutoryRetentionYears: Number(e.target.value) })}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              />
              <span className="text-[11px] text-gray-400 mt-1 block">Minimum 7 years required by SSM regulations</span>
            </div>
          </div>
        </div>

        {/* 3. AI Privacy & Provider Safeguards */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2">
            <Cpu className="w-4 h-4 text-amber-500" />
            AI Guardrails & Privacy Policy (Blueprint Section 10 & 11)
          </h3>
          <p className="text-gray-500 mt-1">
            Rules preventing unauthorized cross-tenant data leakage or unreviewed legal filings by AI.
          </p>

          <div className="mt-4 space-y-4">
            <div>
              <label className="block font-semibold text-gray-700 mb-1">Cross-Border AI Processing Rule</label>
              <select
                value={policies.crossBorderAiPolicy}
                onChange={(e) => setPolicies({ ...policies, crossBorderAiPolicy: e.target.value })}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              >
                <option value="Strict Local (Sensitive company records scrubbed before model reasoning)">
                  Strict Local (PDPA Compliant - PII scrubbed before sending prompts to external APIs)
                </option>
                <option value="Private Dedicated Instance">
                  Private Dedicated VPC Instance (Self-Hosted on TM Cloud)
                </option>
              </select>
            </div>

            <div>
              <label className="block font-semibold text-gray-700 mb-1">Active AI Providers Matrix</label>
              <input
                type="text"
                disabled
                value={policies.defaultAiProvider}
                className="w-full p-2.5 bg-gray-100 border border-gray-200 rounded-lg text-xs text-gray-600 font-medium"
              />
            </div>
          </div>
        </div>

        {/* 4. Administrator Security & Operational Constraints */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6">
          <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2">
            <Lock className="w-4 h-4 text-gray-700" />
            Security & Capacity Safety Limits
          </h3>

          <div className="mt-4 grid grid-cols-2 gap-4">
            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={policies.adminMfaEnforced}
                onChange={(e) => setPolicies({ ...policies, adminMfaEnforced: e.target.checked })}
                className="rounded text-[#062AAE] focus:ring-[#062AAE] w-4 h-4"
              />
              <div>
                <span className="font-semibold text-gray-900 block">Enforce Admin Multi-Factor Authentication</span>
                <span className="text-gray-500 block text-[11px]">Require authenticator app verification for all HQ operators</span>
              </div>
            </label>

            <div>
              <label className="block font-semibold text-gray-700 mb-1">Admin Idle Session Timeout (Minutes)</label>
              <input
                type="number"
                value={policies.sessionTimeoutMinutes}
                onChange={(e) => setPolicies({ ...policies, sessionTimeoutMinutes: Number(e.target.value) })}
                className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg text-xs font-medium focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
              />
            </div>
          </div>
        </div>

        {/* Save Button */}
        <div className="pt-2">
          <button
            type="submit"
            className="px-6 py-2.5 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-xs font-bold transition-colors shadow-sm flex items-center gap-2"
          >
            <Save className="w-4 h-4" />
            Save Platform Policy Changes
          </button>
        </div>

      </form>
    </div>
  );
};

export default PlatformSettings;
