import React, { useState } from 'react';
import {
  Users, UserCheck, Shield, ShieldAlert, ShieldCheck,
  Search, Plus, Filter, Lock, Unlock, KeyRound,
  Building2, Briefcase, Smartphone, Mail, Phone,
  CheckCircle2, XCircle, AlertCircle, X, ChevronRight,
  Clock, RefreshCw
} from 'lucide-react';

const UsersManagement = ({
  users = [],
  firms = [],
  companies = [],
  onToggleStatus = () => {},
  onReset2FA = () => {},
  onCreateUser = () => {},
  onUpdateUser = () => {},
  logAudit = () => {},
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState('All');
  const [selectedStatus, setSelectedStatus] = useState('All');

  // Modals state
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [toastMessage, setToastMessage] = useState('');

  // Form states for inviting user
  const [newUserName, setNewUserName] = useState('');
  const [newUserEmail, setNewUserEmail] = useState('');
  const [newUserPhone, setNewUserPhone] = useState('');
  const [newUserType, setNewUserType] = useState('Secretary');
  const [newUserRole, setNewUserRole] = useState('Licensed Secretary');
  const [newUserOrg, setNewUserOrg] = useState('');
  const [newUser2FA, setNewUser2FA] = useState(true);

  // Form states for editing user
  const [editRole, setEditRole] = useState('');
  const [editStatus, setEditStatus] = useState('Active');
  const [edit2FA, setEdit2FA] = useState(true);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3500);
  };

  // KPIs
  const totalUsers = users.length;
  const adminUsers = users.filter(u => u.userType === 'Administrator');
  const secretaryUsers = users.filter(u => u.userType === 'Secretary');
  const customerUsers = users.filter(u => u.userType === 'Customer');
  const activeUsers = users.filter(u => u.status === 'Active');
  const suspendedUsers = users.filter(u => u.status === 'Suspended');

  // Filtered users list
  const filteredUsers = users.filter(u => {
    const q = searchQuery.toLowerCase();
    const matchesSearch =
      u.name.toLowerCase().includes(q) ||
      u.email.toLowerCase().includes(q) ||
      (u.organization && u.organization.toLowerCase().includes(q)) ||
      (u.role && u.role.toLowerCase().includes(q));

    const matchesType =
      selectedType === 'All' || u.userType === selectedType;

    const matchesStatus =
      selectedStatus === 'All' || u.status === selectedStatus;

    return matchesSearch && matchesType && matchesStatus;
  });

  const handleOpenInvite = () => {
    setNewUserName('');
    setNewUserEmail('');
    setNewUserPhone('');
    setNewUserType('Secretary');
    setNewUserRole('Licensed Secretary');
    setNewUserOrg(firms[0]?.name || 'MySect Platform HQ');
    setNewUser2FA(true);
    setShowInviteModal(true);
  };

  const handleCreateSubmit = (e) => {
    e.preventDefault();
    if (!newUserName.trim() || !newUserEmail.trim()) {
      alert('Please fill in user name and email address.');
      return;
    }

    const created = {
      id: `usr-${Date.now()}`,
      name: newUserName.trim(),
      email: newUserEmail.trim(),
      phone: newUserPhone.trim() || '+60 12-000 0000',
      userType: newUserType,
      role: newUserRole.trim(),
      organization: newUserOrg.trim() || 'MySect Network',
      status: 'Active',
      twoFactorEnabled: newUser2FA,
      lastLogin: 'Never',
      lastLoginIp: '-',
      joinedDate: new Date().toISOString().split('T')[0],
      permissions: ['Standard Access']
    };

    onCreateUser(created);
    setShowInviteModal(false);
    showToast(`User account created and invitation sent to ${created.email}`);
  };

  const handleOpenEdit = (user) => {
    setSelectedUser(user);
    setEditRole(user.role || '');
    setEditStatus(user.status || 'Active');
    setEdit2FA(!!user.twoFactorEnabled);
    setShowEditModal(true);
  };

  const handleEditSubmit = (e) => {
    e.preventDefault();
    if (!selectedUser) return;

    onUpdateUser(selectedUser.id, {
      role: editRole,
      status: editStatus,
      twoFactorEnabled: edit2FA
    });

    setShowEditModal(false);
    showToast(`Updated user profile and permissions for ${selectedUser.name}`);
  };

  const handleToggleStatusAction = (user) => {
    const newStatus = user.status === 'Active' ? 'Suspended' : 'Active';
    onToggleStatus(user.id, newStatus);
    showToast(`Account status for ${user.name} changed to ${newStatus}`);
  };

  const handleReset2FAAction = (user) => {
    onReset2FA(user.id);
    showToast(`2FA security credentials reset for ${user.name}. One-time verification token dispatched.`);
  };

  return (
    <div className="flex-1 flex flex-col h-screen overflow-hidden bg-[#F8F9FA]">
      {/* Pinned Top Navigation Bar */}
      <div className="bg-white border-b border-gray-200 px-8 py-5 shrink-0">
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-gray-900">Users & Access Control</h1>
              <span className="px-2.5 py-0.5 text-xs font-semibold bg-blue-50 text-[#062AAE] border border-blue-200 rounded-full">
                Blueprint §5.4
              </span>
            </div>
            <p className="text-sm text-gray-500 mt-0.5">
              Enforce strict role-based access across Platform Admins, Secretary Firm staff, and Corporate Client portals.
            </p>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={handleOpenInvite}
              className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-sm font-semibold transition-colors shadow-xs flex items-center gap-2 cursor-pointer"
            >
              <Plus className="w-4 h-4" />
              <span>Invite New User</span>
            </button>
          </div>
        </div>
      </div>

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-5 right-8 z-50 bg-gray-900 text-white text-xs font-medium px-4 py-2.5 rounded-xl shadow-xl flex items-center gap-2 animate-fade-in border border-gray-800">
          <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Scrollable Content Area */}
      <div className="flex-1 overflow-y-auto p-8 space-y-6">
        {/* Top 4 KPI Metrics */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs">
            <div className="flex items-center justify-between text-gray-500">
              <span className="text-xs font-semibold uppercase tracking-wider">Total Users</span>
              <Users className="w-4 h-4 text-[#062AAE]" />
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-3xl font-extrabold text-gray-900">{totalUsers}</span>
              <span className="text-xs font-semibold text-emerald-600">
                {activeUsers.length} active
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1">Across platform network</p>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs">
            <div className="flex items-center justify-between text-gray-500">
              <span className="text-xs font-semibold uppercase tracking-wider">Platform Admins</span>
              <ShieldCheck className="w-4 h-4 text-purple-600" />
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-3xl font-extrabold text-gray-900">{adminUsers.length}</span>
              <span className="text-xs font-semibold px-2 py-0.5 bg-purple-50 text-purple-700 border border-purple-200 rounded-full">
                2FA Enforced
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1">Super Admin & Compliance HQ</p>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs">
            <div className="flex items-center justify-between text-gray-500">
              <span className="text-xs font-semibold uppercase tracking-wider">Secretary Staff</span>
              <Building2 className="w-4 h-4 text-blue-600" />
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-3xl font-extrabold text-gray-900">{secretaryUsers.length}</span>
              <span className="text-xs font-semibold text-blue-600">
                {firms.length} Partner Firms
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1">Licensed CoSecs & Reviewers</p>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs">
            <div className="flex items-center justify-between text-gray-500">
              <span className="text-xs font-semibold uppercase tracking-wider">Corporate Client Users</span>
              <Smartphone className="w-4 h-4 text-emerald-600" />
            </div>
            <div className="mt-3 flex items-baseline gap-2">
              <span className="text-3xl font-extrabold text-gray-900">{customerUsers.length}</span>
              <span className="text-xs font-semibold text-emerald-600">
                Mobile Connected
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1">Directors & Authorized Officers</p>
          </div>
        </div>

        {/* Directory Controls & Table */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden">
          {/* Header & Filter Bar */}
          <div className="p-5 border-b border-gray-100 flex flex-col md:flex-row md:items-center justify-between gap-4">
            {/* Search Bar */}
            <div className="relative flex-1 max-w-md">
              <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Search user name, email, organization, or role..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 text-xs bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE] transition-all"
              />
            </div>

            {/* Filter Pills */}
            <div className="flex items-center gap-2 overflow-x-auto no-scrollbar">
              <span className="text-xs text-gray-400 mr-1 flex items-center gap-1 shrink-0">
                <Filter className="w-3.5 h-3.5" /> Filter:
              </span>
              {[
                { id: 'All', label: 'All Users' },
                { id: 'Administrator', label: 'Admins' },
                { id: 'Secretary', label: 'Secretary Staff' },
                { id: 'Customer', label: 'Corporate Clients' },
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setSelectedType(tab.id)}
                  className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors shrink-0 cursor-pointer ${
                    selectedType === tab.id
                      ? 'bg-[#062AAE] text-white shadow-2xs'
                      : 'bg-gray-50 text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  {tab.label}
                </button>
              ))}

              <div className="h-4 w-[1px] bg-gray-200 mx-1 shrink-0" />

              {[
                { id: 'All', label: 'All Status' },
                { id: 'Active', label: 'Active Only' },
                { id: 'Suspended', label: 'Suspended' },
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setSelectedStatus(tab.id)}
                  className={`px-2.5 py-1 text-xs font-medium rounded-lg transition-colors shrink-0 cursor-pointer ${
                    selectedStatus === tab.id
                      ? 'bg-gray-800 text-white'
                      : 'bg-gray-50 text-gray-500 hover:bg-gray-100'
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>

          {/* Users Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-gray-50/80 border-b border-gray-100 text-gray-500 font-semibold uppercase tracking-wider text-[11px]">
                <tr>
                  <th className="py-3.5 px-5">User & Contact</th>
                  <th className="py-3.5 px-4">User Type & Role</th>
                  <th className="py-3.5 px-4">Organization / Affiliation</th>
                  <th className="py-3.5 px-4">Security & 2FA</th>
                  <th className="py-3.5 px-4">Last Sign-In</th>
                  <th className="py-3.5 px-4">Account Status</th>
                  <th className="py-3.5 px-5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan="7" className="py-12 text-center text-gray-400">
                      <Users className="w-8 h-8 mx-auto mb-2 opacity-40" />
                      <p className="text-sm font-semibold text-gray-700">No matching users found</p>
                      <p className="text-xs text-gray-400 mt-0.5">Try adjusting your search query or filter criteria.</p>
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((u) => {
                    const isAdmin = u.userType === 'Administrator';
                    const isSecretary = u.userType === 'Secretary';
                    const isCustomer = u.userType === 'Customer';
                    const isSuspended = u.status === 'Suspended';

                    return (
                      <tr key={u.id} className="hover:bg-gray-50/60 transition-colors">
                        {/* Name & Contact */}
                        <td className="py-3.5 px-5">
                          <div className="flex items-center gap-3">
                            <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs ${
                              isAdmin 
                                ? 'bg-purple-100 text-purple-800' 
                                : isSecretary 
                                ? 'bg-blue-100 text-[#062AAE]' 
                                : 'bg-emerald-100 text-emerald-800'
                            }`}>
                              {u.name.substring(0, 2).toUpperCase()}
                            </div>
                            <div>
                              <strong className="text-gray-900 font-bold block">{u.name}</strong>
                              <div className="text-gray-500 text-[11px] flex items-center gap-2 mt-0.5">
                                <span>{u.email}</span>
                                <span>•</span>
                                <span>{u.phone}</span>
                              </div>
                            </div>
                          </div>
                        </td>

                        {/* User Type & Role */}
                        <td className="py-3.5 px-4">
                          <div>
                            <span className={`inline-block px-2 py-0.5 text-[10.5px] font-bold rounded-full mb-1 ${
                              isAdmin
                                ? 'bg-purple-50 text-purple-700 border border-purple-200'
                                : isSecretary
                                ? 'bg-blue-50 text-[#062AAE] border border-blue-200'
                                : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                            }`}>
                              {u.userType}
                            </span>
                            <div className="text-gray-800 font-semibold text-xs">{u.role}</div>
                            {u.licenseNo && (
                              <div className="text-[10px] text-gray-400 font-mono mt-0.5">Lic: {u.licenseNo}</div>
                            )}
                          </div>
                        </td>

                        {/* Organization / Affiliation */}
                        <td className="py-3.5 px-4">
                          <div className="text-gray-900 font-medium">{u.organization || 'MySect HQ'}</div>
                          {isCustomer && u.mobileAppStatus && (
                            <span className="inline-flex items-center gap-1 text-[10.5px] text-emerald-700 font-medium mt-0.5">
                              <Smartphone className="w-3 h-3 text-emerald-600" />
                              {u.mobileAppStatus}
                            </span>
                          )}
                        </td>

                        {/* Security & 2FA */}
                        <td className="py-3.5 px-4">
                          <div className="flex items-center gap-1.5">
                            {u.twoFactorEnabled ? (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 text-[10.5px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-full whitespace-nowrap">
                                <ShieldCheck className="w-3 h-3 text-emerald-600 shrink-0" />
                                2FA Enforced
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 text-[10.5px] font-semibold bg-amber-50 text-amber-700 border border-amber-200 rounded-full whitespace-nowrap">
                                <ShieldAlert className="w-3 h-3 text-amber-600 shrink-0" />
                                2FA Inactive
                              </span>
                            )}
                          </div>
                        </td>

                        {/* Last Sign-in */}
                        <td className="py-3.5 px-4">
                          <div className="text-gray-900 font-medium whitespace-nowrap">{u.lastLogin}</div>
                          {u.lastLoginIp && u.lastLoginIp !== '-' && (
                            <div className="text-[10px] text-gray-400 font-mono mt-0.5">IP: {u.lastLoginIp}</div>
                          )}
                        </td>

                        {/* Account Status */}
                        <td className="py-3.5 px-4">
                          <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 text-[11px] font-semibold rounded-full whitespace-nowrap ${
                            u.status === 'Active'
                              ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                              : u.status === 'Suspended'
                              ? 'bg-rose-50 text-rose-700 border border-rose-200'
                              : 'bg-amber-50 text-amber-700 border border-amber-200'
                          }`}>
                            <span className={`w-1.5 h-1.5 rounded-full ${
                              u.status === 'Active' ? 'bg-emerald-500' : u.status === 'Suspended' ? 'bg-rose-500' : 'bg-amber-500'
                            }`} />
                            <span>{u.status}</span>
                          </span>
                        </td>

                        {/* Actions */}
                        <td className="py-3.5 px-5 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              onClick={() => handleOpenEdit(u)}
                              className="px-2.5 py-1 text-xs font-semibold text-gray-700 hover:text-[#062AAE] bg-gray-50 hover:bg-blue-50 border border-gray-200 rounded-lg transition-colors cursor-pointer"
                              title="Edit user role & permissions"
                            >
                              Manage
                            </button>

                            <button
                              onClick={() => handleToggleStatusAction(u)}
                              className={`p-1.5 rounded-lg border transition-colors cursor-pointer ${
                                isSuspended
                                  ? 'bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100'
                                  : 'bg-rose-50 border-rose-200 text-rose-700 hover:bg-rose-100'
                              }`}
                              title={isSuspended ? 'Reactivate Account' : 'Suspend Account'}
                            >
                              {isSuspended ? <Unlock className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Footer Ledger Notice */}
          <div className="p-4 bg-gray-50/90 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
            <span>
              Showing <strong>{filteredUsers.length}</strong> of <strong>{totalUsers}</strong> platform users
            </span>
            <span className="text-[11px] text-gray-400">
              Per statutory regulations, MySect Platform Admins audit access & permissions without accessing confidential client corporate files.
            </span>
          </div>
        </div>
      </div>

      {/* Modal 1: Invite / Create User */}
      {showInviteModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-gray-200">
            <div className="flex items-start justify-between pb-4 border-b border-gray-100">
              <div>
                <h3 className="text-lg font-bold text-gray-900">Invite New Platform User</h3>
                <p className="text-xs text-gray-500 mt-0.5">
                  Generate account access and dispatch secure credentials link.
                </p>
              </div>
              <button
                onClick={() => setShowInviteModal(false)}
                className="text-gray-400 hover:text-gray-600 p-1 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateSubmit} className="mt-4 space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Full Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Nurul Farhana binti Rosli"
                  value={newUserName}
                  onChange={(e) => setNewUserName(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Email Address *</label>
                  <input
                    type="email"
                    required
                    placeholder="name@organization.com"
                    value={newUserEmail}
                    onChange={(e) => setNewUserEmail(e.target.value)}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Phone Number</label>
                  <input
                    type="text"
                    placeholder="+60 12-345 6789"
                    value={newUserPhone}
                    onChange={(e) => setNewUserPhone(e.target.value)}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">User Category</label>
                  <select
                    value={newUserType}
                    onChange={(e) => {
                      const t = e.target.value;
                      setNewUserType(t);
                      if (t === 'Administrator') {
                        setNewUserRole('Platform Support');
                        setNewUserOrg('MySect Platform HQ');
                      } else if (t === 'Secretary') {
                        setNewUserRole('Licensed Secretary');
                        setNewUserOrg(firms[0]?.name || 'Partner Secretary Firm');
                      } else {
                        setNewUserRole('Managing Director');
                        setNewUserOrg(companies[0]?.name || 'Client Corporate Entity');
                      }
                    }}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  >
                    <option value="Administrator">Platform Administrator</option>
                    <option value="Secretary">Secretary Firm Staff</option>
                    <option value="Customer">Corporate Client User</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Assigned Role</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Senior Reviewer"
                    value={newUserRole}
                    onChange={(e) => setNewUserRole(e.target.value)}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Organization / Entity Affiliation</label>
                <input
                  type="text"
                  placeholder="e.g. SectPro Corporate Services Sdn Bhd"
                  value={newUserOrg}
                  onChange={(e) => setNewUserOrg(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                />
              </div>

              <div className="p-3 bg-blue-50/70 border border-blue-200 rounded-xl flex items-center justify-between">
                <div>
                  <span className="font-semibold text-gray-900 block">Enforce 2-Factor Authentication</span>
                  <span className="text-[11px] text-gray-500">Require 6-digit security code on every sign-in</span>
                </div>
                <input
                  type="checkbox"
                  checked={newUser2FA}
                  onChange={(e) => setNewUser2FA(e.target.checked)}
                  className="w-4 h-4 text-[#062AAE] rounded cursor-pointer"
                />
              </div>

              <div className="pt-3 border-t border-gray-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowInviteModal(false)}
                  className="px-4 py-2 border border-gray-200 rounded-xl text-gray-600 hover:bg-gray-50 font-semibold cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  Create & Send Invite
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal 2: Manage User & Permissions */}
      {showEditModal && selectedUser && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-gray-200">
            <div className="flex items-start justify-between pb-4 border-b border-gray-100">
              <div>
                <h3 className="text-lg font-bold text-gray-900">Manage User Access</h3>
                <p className="text-xs text-gray-500 mt-0.5">
                  Update role permissions, account status, and 2FA credentials.
                </p>
              </div>
              <button
                onClick={() => setShowEditModal(false)}
                className="text-gray-400 hover:text-gray-600 p-1 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleEditSubmit} className="mt-4 space-y-4 text-xs">
              <div className="p-3 bg-gray-50 rounded-xl border border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <strong className="text-gray-900 block text-sm">{selectedUser.name}</strong>
                    <span className="text-gray-500 text-xs">{selectedUser.email}</span>
                  </div>
                  <span className={`px-2 py-0.5 text-xs font-bold rounded-full ${
                    selectedUser.userType === 'Administrator' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                  }`}>
                    {selectedUser.userType}
                  </span>
                </div>
                <div className="mt-2 text-[11px] text-gray-500">
                  Affiliation: <strong>{selectedUser.organization}</strong>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Role Title</label>
                <input
                  type="text"
                  value={editRole}
                  onChange={(e) => setEditRole(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Account Status</label>
                  <select
                    value={editStatus}
                    onChange={(e) => setEditStatus(e.target.value)}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  >
                    <option value="Active">Active (Granted Access)</option>
                    <option value="Suspended">Suspended (Access Blocked)</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">2FA Enforcement</label>
                  <select
                    value={edit2FA ? 'enabled' : 'disabled'}
                    onChange={(e) => setEdit2FA(e.target.value === 'enabled')}
                    className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE]/20 focus:border-[#062AAE]"
                  >
                    <option value="enabled">Enforced (Active)</option>
                    <option value="disabled">Disabled</option>
                  </select>
                </div>
              </div>

              {/* Security Reset Action */}
              <div className="p-3 bg-amber-50/70 border border-amber-200 rounded-xl flex items-center justify-between">
                <div>
                  <span className="font-semibold text-gray-900 block flex items-center gap-1.5">
                    <KeyRound className="w-3.5 h-3.5 text-amber-600" />
                    Reset 2FA Security Token
                  </span>
                  <span className="text-[11px] text-gray-500">Revoke current active sessions and issue a new verification code.</span>
                </div>
                <button
                  type="button"
                  onClick={() => handleReset2FAAction(selectedUser)}
                  className="px-3 py-1.5 bg-white border border-amber-300 hover:bg-amber-100 text-amber-800 text-xs font-semibold rounded-lg shadow-2xs transition-colors cursor-pointer"
                >
                  Reset Token
                </button>
              </div>

              {/* Assigned Permissions Preview */}
              <div>
                <label className="block font-semibold text-gray-700 mb-1.5">Authorized Platform Permissions</label>
                <div className="space-y-1.5">
                  {(selectedUser.permissions || ['Standard Platform Access', 'Profile Management']).map((p, idx) => (
                    <div key={idx} className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg text-gray-700">
                      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                      <span>{p}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="pt-3 border-t border-gray-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowEditModal(false)}
                  className="px-4 py-2 border border-gray-200 rounded-xl text-gray-600 hover:bg-gray-50 font-semibold cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default UsersManagement;
