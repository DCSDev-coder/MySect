import React, { useState } from 'react';
import { Menu } from 'lucide-react';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import UsersManagement from './components/UsersManagement';
import SecretaryFirms from './components/SecretaryFirms';
import CompanyManagement from './components/CompanyManagement';
import OperationsView from './components/OperationsView';
import SettingsView from './components/SettingsView';
import Login from './components/Login';
import mysectLogo from './assets/mysect_logo.png';

import {
  initialFirms,
  initialCompanies,
  initialPlans,
  initialEscalations,
  initialPlatformFeeRules,
  initialSupportDisputes,
  initialServiceCatalogue,
  initialGlobalNotifications,
  initialAuditLogs,
  platformPolicies,
  initialUsers
} from './data/mockData';

function App() {
  const [currentUser, setCurrentUser] = useState(() => {
    try {
      const saved = localStorage.getItem('mysect_admin_user');
      if (saved && saved !== 'LOGGED_OUT') {
        return JSON.parse(saved);
      }
    } catch (e) {
      console.error('Failed to parse cached user:', e);
    }
    return null;
  });

  const [activePage, setActivePage] = useState('Overview');
  const [firms, setFirms] = useState(initialFirms);
  const [companies, setCompanies] = useState(initialCompanies);
  const [plans, setPlans] = useState(initialPlans);
  const [escalations, setEscalations] = useState(initialEscalations);
  const [feeRules, setFeeRules] = useState(initialPlatformFeeRules);
  const [disputes, setDisputes] = useState(initialSupportDisputes);
  const [services, setServices] = useState(initialServiceCatalogue);
  const [notifications, setNotifications] = useState(initialGlobalNotifications);
  const [auditLogs, setAuditLogs] = useState(initialAuditLogs);
  const [policies, setPolicies] = useState(platformPolicies);
  const [users, setUsers] = useState(initialUsers);
  const [selectedFirmForDetail, setSelectedFirmForDetail] = useState(null);

  // User & Access Management Handlers (Blueprint Section 5.4)
  const handleToggleUserStatus = (userId, newStatus) => {
    setUsers(prev => prev.map(u => u.id === userId ? { ...u, status: newStatus } : u));
    logAudit('USER_STATUS_CHANGE', userId, `User status updated to ${newStatus}`);
  };

  const handleResetUser2FA = (userId) => {
    setUsers(prev => prev.map(u => u.id === userId ? { ...u, twoFactorEnabled: true } : u));
    logAudit('USER_2FA_RESET', userId, 'One-time security credentials reset dispatched to user');
  };

  const handleCreateUser = (newUser) => {
    setUsers(prev => [newUser, ...prev]);
    logAudit('USER_CREATED', newUser.email, `Created new ${newUser.userType} user (${newUser.role})`);
  };

  const handleUpdateUser = (userId, updatedFields) => {
    setUsers(prev => prev.map(u => u.id === userId ? { ...u, ...updatedFields } : u));
    logAudit('USER_UPDATED', userId, `Updated user attributes and role permissions`);
  };

  // Helper to log audit actions
  const logAudit = (actionType, targetEntity, details) => {
    const newLog = {
      id: 'aud-' + Math.floor(1000 + Math.random() * 9000),
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      actor: currentUser ? `${currentUser.name} (${currentUser.email})` : 'Admin Operator (admin@mysect.com.my)',
      ipAddress: '10.200.14.88 (HQ VPN)',
      actionType,
      targetEntity,
      details,
    };
    setAuditLogs(prev => [newLog, ...prev]);
  };

  const handleLogin = (user, rememberMe = true) => {
    setCurrentUser(user);
    if (rememberMe) {
      localStorage.setItem('mysect_admin_user', JSON.stringify(user));
    } else {
      localStorage.removeItem('mysect_admin_user');
    }
    logAudit('ADMIN_LOGIN', user.name, `Operator signed in successfully (${user.role} - ${user.department}).`);
  };

  const handleLogout = () => {
    const actorName = currentUser?.name || 'Operator';
    localStorage.setItem('mysect_admin_user', 'LOGGED_OUT');
    setCurrentUser(null);
    logAudit('ADMIN_LOGOUT', actorName, 'Operator administrative session signed out.');
  };

  // 1. Firm management handlers
  const handleApproveFirm = (firmId) => {
    const firm = firms.find(f => f.id === firmId);
    setFirms(prev => prev.map(f => f.id === firmId ? { ...f, status: 'Active' } : f));
    logAudit('FIRM_APPROVED', firm?.name || firmId, 'Secretary firm verified and approved for client intake.');
  };

  const handleSuspendFirm = (firmId, reason) => {
    const firm = firms.find(f => f.id === firmId);
    setFirms(prev => prev.map(f => f.id === firmId ? { ...f, status: 'Suspended', suspensionReason: reason } : f));
    logAudit('FIRM_SUSPENDED', firm?.name || firmId, `Firm suspended by Admin. Reason: ${reason}`);
  };

  const handleReactivateFirm = (firmId) => {
    const firm = firms.find(f => f.id === firmId);
    setFirms(prev => prev.map(f => f.id === firmId ? { ...f, status: 'Active', suspensionReason: null } : f));
    logAudit('FIRM_REACTIVATED', firm?.name || firmId, 'Firm compliance reinstated and status restored to Active.');
  };

  const handleUpdateFirmPlan = (firmId, planId, planName, newLimit) => {
    const firm = firms.find(f => f.id === firmId);
    setFirms(prev => prev.map(f => f.id === firmId ? { ...f, planId, planName, companyLimit: newLimit } : f));
    logAudit('FIRM_PLAN_UPDATED', firm?.name || firmId, `Updated plan to ${planName} with company limit of ${newLimit}.`);
  };

  const handleVerifyCertificate = (firmId, certId) => {
    const firm = firms.find(f => f.id === firmId);
    setFirms(prev => prev.map(f => {
      if (f.id === firmId) {
        return {
          ...f,
          practisingCertificates: (f.practisingCertificates || []).map(c => 
            c.id === certId ? { ...c, verified: true, status: 'Valid' } : c
          )
        };
      }
      return f;
    }));
    logAudit('LICENCE_VERIFICATION', `${firm?.name} (Cert: ${certId})`, 'Practising certificate verified against statutory registry.');
  };

  // 2. Company assignment & transfer
  const handleTransferCompany = (companyId, targetFirmId, targetFirmName, reason) => {
    const comp = companies.find(c => c.id === companyId);
    setCompanies(prev => prev.map(c => {
      if (c.id === companyId) {
        return {
          ...c,
          assignedFirmId: targetFirmId,
          assignedFirmName: targetFirmName,
          status: 'Active',
          transferReason: null,
        };
      }
      return c;
    }));

    // Update capacity counts
    setFirms(prev => prev.map(f => {
      if (f.id === targetFirmId) return { ...f, companiesCount: f.companiesCount + 1 };
      if (f.id === comp?.assignedFirmId) return { ...f, companiesCount: Math.max(0, f.companiesCount - 1) };
      return f;
    }));

    logAudit('COMPANY_TRANSFERRED', `${comp?.name} (${comp?.ssmNo})`, `Transferred to ${targetFirmName}. Reason: ${reason}`);
  };

  const handleCreateCompany = (newCompany) => {
    setCompanies(prev => [newCompany, ...prev]);
    if (newCompany.assignedFirmId) {
      setFirms(prev => prev.map(f => f.id === newCompany.assignedFirmId ? { ...f, companiesCount: f.companiesCount + 1 } : f));
    }
    logAudit('COMPANY_ONBOARDED', `${newCompany.name} (${newCompany.ssmNo})`, `New client company onboarded and assigned to ${newCompany.assignedFirmName}.`);
  };

  // 3. Plan management
  const handleCreatePlan = (newPlan) => {
    setPlans(prev => [...prev, newPlan]);
    logAudit('PLAN_CREATED', newPlan.name, `Created subscription tier with limit of ${newPlan.companyLimit} companies.`);
  };

  const handleUpdatePlan = (planId, updatedPlan) => {
    setPlans(prev => prev.map(p => p.id === planId ? { ...p, ...updatedPlan } : p));
    logAudit('PLAN_LIMIT_UPDATED', updatedPlan.name || planId, `Adjusted plan limits (Limit: ${updatedPlan.companyLimit} Co, Fee: MYR ${updatedPlan.monthlyPrice}).`);
  };

  // 4. Escalations & Disputes
  const handleResolveEscalation = (escId, note) => {
    const esc = escalations.find(e => e.id === escId);
    setEscalations(prev => prev.map(e => e.id === escId ? { ...e, status: 'Resolved by Admin' } : e));
    logAudit('ESCALATION_RESOLVED', esc?.caseNumber || escId, `Operator resolved escalation: ${note}`);
  };

  const handleReassignEscalation = (escId, targetFirm) => {
    const esc = escalations.find(e => e.id === escId);
    setEscalations(prev => prev.map(e => e.id === escId ? { ...e, assignedFirm: targetFirm, status: 'Reassigned' } : e));
    logAudit('ESCALATION_REASSIGNED', esc?.caseNumber || escId, `Reassigned case handling to ${targetFirm}.`);
  };

  const handleResolveDispute = (dispId, notes) => {
    setDisputes(prev => prev.map(d => d.id === dispId ? { ...d, status: 'Resolved by Admin', resolutionSummary: notes } : d));
    logAudit('DISPUTE_ARBITRATED', dispId, `Issued moderator resolution: ${notes}`);
  };

  // 5. Notifications & Services
  const handlePublishNotification = (newNotif) => {
    setNotifications(prev => [newNotif, ...prev]);
    logAudit('BROADCAST_PUBLISHED', newNotif.title, `Published broadcast notification to ${newNotif.targetAudience}.`);
  };

  const handleSaveService = (newSrv) => {
    setServices(prev => prev.map(s => s.id === newSrv.id ? newSrv : s));
    logAudit('SERVICE_CATALOGUE_UPDATED', newSrv.title, `Updated SLA turnaround to ${newSrv.standardTurnaroundDays} days.`);
  };

  // 6. Policy & Fee Rules
  const handleSavePolicies = (newPolicies) => {
    setPolicies(newPolicies);
    logAudit('POLICY_CONFIG_UPDATED', 'Platform Policies', 'Updated e-KYC, TM Cloud storage retention, and AI safeguards.');
  };

  const handleSaveRule = (newRule) => {
    setFeeRules(prev => prev.map(r => r.id === newRule.id ? newRule : r));
    logAudit('FEE_RULE_MODIFIED', newRule.ruleName, `Configured platform fee rate to ${newRule.rateAmount} (${newRule.currency}).`);
  };

  const renderPage = () => {
    switch (activePage) {
      case 'Overview':
        return (
          <Dashboard 
            firms={firms}
            companies={companies}
            escalations={escalations}
            setActivePage={setActivePage}
            onApproveFirm={handleApproveFirm}
          />
        );
      case 'Firms':
        return (
          <SecretaryFirms 
            firms={firms}
            plans={plans}
            onApproveFirm={handleApproveFirm}
            onSuspendFirm={handleSuspendFirm}
            onReactivateFirm={handleReactivateFirm}
            onUpdateFirmPlan={handleUpdateFirmPlan}
            onVerifyCertificate={handleVerifyCertificate}
            selectedFirmFromDash={selectedFirmForDetail}
          />
        );
      case 'Companies':
        return (
          <CompanyManagement 
            companies={companies}
            firms={firms}
            onTransferCompany={handleTransferCompany}
            onCreateCompany={handleCreateCompany}
          />
        );
      case 'Users':
        return (
          <UsersManagement 
            users={users}
            firms={firms}
            companies={companies}
            onToggleStatus={handleToggleUserStatus}
            onReset2FA={handleResetUser2FA}
            onCreateUser={handleCreateUser}
            onUpdateUser={handleUpdateUser}
            logAudit={logAudit}
          />
        );
      case 'Operations':
        return (
          <OperationsView 
            escalations={escalations}
            firms={firms}
            disputes={disputes}
            notifications={notifications}
            services={services}
            onResolveEscalation={handleResolveEscalation}
            onReassignEscalation={handleReassignEscalation}
            onResolveDispute={handleResolveDispute}
            onPublishNotification={handlePublishNotification}
            onSaveService={handleSaveService}
          />
        );
      case 'Settings':
        return (
          <SettingsView 
            plans={plans}
            firms={firms}
            companies={companies}
            feeRules={feeRules}
            auditLogs={auditLogs}
            policies={policies}
            onCreatePlan={handleCreatePlan}
            onUpdatePlan={handleUpdatePlan}
            onSaveRule={handleSaveRule}
            onSavePolicies={handleSavePolicies}
          />
        );
      default:
        return (
          <Dashboard 
            firms={firms}
            companies={companies}
            escalations={escalations}
            setActivePage={setActivePage}
            onApproveFirm={handleApproveFirm}
          />
        );
    }
  };

  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const pendingFirmsCount = firms.filter(f => f.status === 'Pending Verification').length;
  const urgentItemsCount = escalations.filter(e => !e.status.includes('Resolved')).length + disputes.filter(d => !d.status.includes('Resolved')).length;

  if (!currentUser) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <div className="flex h-screen overflow-hidden bg-[#F8F9FA] text-gray-900 font-sans antialiased">
      <Sidebar 
        activePage={activePage} 
        setActivePage={setActivePage}
        pendingFirmsCount={pendingFirmsCount}
        urgentItemsCount={urgentItemsCount}
        currentUser={currentUser}
        onLogout={handleLogout}
        isOpen={isMobileMenuOpen}
        onClose={() => setIsMobileMenuOpen(false)}
      />
      <div className="flex-1 flex flex-col h-screen overflow-hidden min-w-0">
        {/* Mobile Top Header (Visible on screens < lg) */}
        <div className="lg:hidden bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between shrink-0 z-30 shadow-2xs">
          <button
            onClick={() => setIsMobileMenuOpen(true)}
            className="p-1.5 -ml-1 text-gray-700 hover:text-gray-900 rounded-lg hover:bg-gray-100 cursor-pointer"
            aria-label="Open Navigation Menu"
          >
            <Menu className="w-5 h-5 text-gray-800" />
          </button>

          <img 
            src={mysectLogo} 
            alt="MySect" 
            className="h-7 w-auto object-contain" 
          />

          <button
            onClick={() => setIsMobileMenuOpen(true)}
            className="w-8 h-8 rounded-full bg-[#062AAE] text-white flex items-center justify-center font-bold text-xs shadow-2xs cursor-pointer hover:opacity-90 active:scale-95 transition-transform"
            title="Open menu & profile"
            aria-label="Open profile menu"
          >
            {currentUser?.avatar || (currentUser?.name ? currentUser.name.substring(0, 2).toUpperCase() : 'AF')}
          </button>
        </div>

        {/* Dynamic Page Component */}
        <div className="flex-1 flex flex-col overflow-hidden min-w-0">
          {renderPage()}
        </div>
      </div>
    </div>
  );
}

export default App;
