import React, { useState } from 'react';
import { 
  CreditCard, Plus, Check, Edit, HardDrive, 
  Users, Building2, Zap
} from 'lucide-react';

const SubscriptionPlans = ({ 
  plans = [], 
  firms = [], 
  onCreatePlan, 
  onUpdatePlan 
}) => {
  const [showModal, setShowModal] = useState(false);
  const [editingPlan, setEditingPlan] = useState(null);

  // Form states
  const [name, setName] = useState('');
  const [tierCode, setTierCode] = useState('');
  const [targetAudience, setTargetAudience] = useState('');
  const [monthlyPrice, setMonthlyPrice] = useState(499);
  const [annualPrice, setAnnualPrice] = useState(4990);
  const [companyLimit, setCompanyLimit] = useState(100);
  const [staffSeats, setStaffSeats] = useState(5);
  const [tmCloudStorageGB, setTmCloudStorageGB] = useState(200);
  const [aiIntakeTokenLimit, setAiIntakeTokenLimit] = useState('2,500,000 tokens/mo');
  const [features, setFeatures] = useState('');

  const handleOpenCreate = () => {
    setEditingPlan(null);
    setName('');
    setTierCode('PLAN-NEW-' + Math.floor(10 + Math.random() * 90));
    setTargetAudience('');
    setMonthlyPrice(399);
    setAnnualPrice(3990);
    setCompanyLimit(50);
    setStaffSeats(4);
    setTmCloudStorageGB(100);
    setAiIntakeTokenLimit('1,000,000 tokens/mo');
    setFeatures('Manage up to 50 companies\n4 staff user accounts\nAI intake & drafting assistance\n100 GB TM Cloud vault');
    setShowModal(true);
  };

  const handleOpenEdit = (plan) => {
    setEditingPlan(plan);
    setName(plan.name);
    setTierCode(plan.tierCode);
    setTargetAudience(plan.targetAudience);
    setMonthlyPrice(plan.monthlyPrice);
    setAnnualPrice(plan.annualPrice);
    setCompanyLimit(plan.companyLimit);
    setStaffSeats(plan.staffSeats);
    setTmCloudStorageGB(plan.tmCloudStorageGB);
    setAiIntakeTokenLimit(plan.aiIntakeTokenLimit);
    setFeatures((plan.features || []).join('\n'));
    setShowModal(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    const featArray = features.split('\n').filter(f => f.trim().length > 0);
    const planData = {
      name,
      tierCode,
      targetAudience,
      monthlyPrice: Number(monthlyPrice),
      annualPrice: Number(annualPrice),
      companyLimit: Number(companyLimit),
      staffSeats: Number(staffSeats),
      tmCloudStorageGB: Number(tmCloudStorageGB),
      aiIntakeTokenLimit,
      features: featArray,
      status: 'Active',
    };

    if (editingPlan) {
      if (onUpdatePlan) onUpdatePlan(editingPlan.id, planData);
    } else {
      if (onCreatePlan) onCreatePlan({ ...planData, id: name.toLowerCase().replace(/\s+/g, '-'), activeFirmsCount: 0 });
    }

    setShowModal(false);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <CreditCard className="w-4 h-4" />
            <span>Commercial Monetization & Plan Engine</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Subscription Plans & Company Limits</h1>
          <p className="text-sm text-gray-500">
            Define secretary firm subscription tiers, enforce company capacity limits, allocate TM Cloud storage quotas, and manage recurring software pricing.
          </p>
        </div>

        <button 
          onClick={handleOpenCreate}
          className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-lg text-sm font-semibold transition-colors shadow-xs flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Create New Plan
        </button>
      </div>

      {/* Plans Tier Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
        {plans.map((plan) => {
          const firmsOnPlan = firms.filter(f => f.planId === plan.id);
          return (
            <div 
              key={plan.id}
              className="bg-white rounded-2xl border border-gray-200 shadow-xs hover:shadow-md transition-all flex flex-col justify-between overflow-hidden relative"
            >
              {plan.id === 'growth' && (
                <div className="bg-[#062AAE] text-white text-[10px] font-bold uppercase tracking-wider py-1 text-center">
                  Most Popular for Mid-Sized Firms
                </div>
              )}

              <div className="p-6">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono font-bold text-gray-400">{plan.tierCode}</span>
                  <span className="px-2 py-0.5 text-xs font-medium bg-blue-50 text-[#062AAE] rounded-full">
                    {firmsOnPlan.length} firm(s) subscribed
                  </span>
                </div>

                <h3 className="text-lg font-bold text-gray-900 mt-2">{plan.name}</h3>
                <p className="text-xs text-gray-500 mt-1 min-h-[32px]">{plan.targetAudience}</p>

                {/* Price Display */}
                <div className="mt-4 pt-4 border-t border-gray-100 flex items-baseline gap-1">
                  <span className="text-xs font-semibold text-gray-500">MYR</span>
                  <span className="text-3xl font-extrabold text-gray-900">{plan.monthlyPrice}</span>
                  <span className="text-xs text-gray-500 font-medium">/ month</span>
                </div>
                <div className="text-[11px] text-gray-400 mt-0.5">
                  Billed annually at MYR {plan.annualPrice}/yr
                </div>

                {/* Limits & Quotas Box */}
                <div className="bg-gray-50 rounded-xl p-3.5 border border-gray-200 mt-5 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 flex items-center gap-1.5">
                      <Building2 className="w-3.5 h-3.5 text-[#062AAE]" /> Company Limit:
                    </span>
                    <strong className="text-gray-900 font-bold">{plan.companyLimit} Companies</strong>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 flex items-center gap-1.5">
                      <Users className="w-3.5 h-3.5 text-emerald-600" /> Staff Seats:
                    </span>
                    <strong className="text-gray-900 font-bold">{plan.staffSeats} Users</strong>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 flex items-center gap-1.5">
                      <HardDrive className="w-3.5 h-3.5 text-blue-500" /> TM Cloud Storage:
                    </span>
                    <strong className="text-gray-900 font-bold">{plan.tmCloudStorageGB} GB</strong>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 flex items-center gap-1.5">
                      <Zap className="w-3.5 h-3.5 text-amber-500" /> AI Intake Token Limit:
                    </span>
                    <strong className="text-gray-800 text-[11px] truncate max-w-[120px]">{plan.aiIntakeTokenLimit}</strong>
                  </div>
                </div>

                {/* Features List */}
                <div className="mt-5 space-y-2 text-xs">
                  <span className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider block mb-2">
                    Included Capabilities
                  </span>
                  {(plan.features || []).map((feat, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-gray-600">
                      <Check className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
                      <span>{feat}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Edit Button */}
              <div className="p-4 bg-gray-50 border-t border-gray-100 flex items-center justify-between">
                <span className="text-xs text-gray-500">
                  Status: <strong className="text-emerald-700">Active</strong>
                </span>
                <button
                  onClick={() => handleOpenEdit(plan)}
                  className="px-3 py-1.5 bg-white border border-gray-200 hover:bg-gray-100 text-gray-700 rounded-lg text-xs font-semibold flex items-center gap-1 transition-colors"
                >
                  <Edit className="w-3 h-3" />
                  Edit Plan Limits
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Firm Subscriptions Ledger Overview */}
      <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden mt-8">
        <div className="p-5 border-b border-gray-200 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Secretary Firm Subscription Billing Status</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Recurring SaaS billing relationships between MySect HQ and member secretary firms.
            </p>
          </div>
          <span className="text-xs text-gray-500">
            Total Projected MRR: <strong className="text-gray-900">MYR 32,840.00</strong>
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3 text-left font-semibold text-gray-600">Secretary Firm</th>
                <th className="px-5 py-3 text-left font-semibold text-gray-600">Subscribed Tier</th>
                <th className="px-5 py-3 text-left font-semibold text-gray-600">Company Quota Usage</th>
                <th className="px-5 py-3 text-left font-semibold text-gray-600">Monthly Bill</th>
                <th className="px-5 py-3 text-left font-semibold text-gray-600">Payment Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {firms.map((firm) => (
                <tr key={firm.id} className="hover:bg-gray-50">
                  <td className="px-5 py-3 font-semibold text-gray-900">{firm.name}</td>
                  <td className="px-5 py-3 text-gray-700">{firm.planName}</td>
                  <td className="px-5 py-3">
                    <span className="font-medium text-gray-800">{firm.companiesCount} / {firm.companyLimit}</span>
                    <span className="text-gray-400 text-[11px] ml-1">
                      ({Math.round((firm.companiesCount / firm.companyLimit) * 100)}%)
                    </span>
                  </td>
                  <td className="px-5 py-3 font-bold text-gray-900">
                    MYR {firm.monthlyPlatformFee?.toFixed(2)}
                  </td>
                  <td className="px-5 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold ${
                      firm.billingStatus === 'Paid' 
                        ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                        : firm.billingStatus?.includes('Past Due')
                        ? 'bg-rose-50 text-rose-700 border border-rose-200'
                        : 'bg-amber-50 text-amber-700 border border-amber-200'
                    }`}>
                      {firm.billingStatus}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: Create or Edit Subscription Plan */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl border border-gray-200 max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-bold text-gray-900">
              {editingPlan ? `Edit ${editingPlan.name} Limits` : 'Create New Subscription Plan'}
            </h3>
            <p className="text-xs text-gray-500 mt-1">
              Configure company quotas, staff limits, storage buffers, and software pricing.
            </p>

            <form onSubmit={handleSave} className="mt-4 space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Plan Display Name</label>
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. Growth Plus Plan"
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Tier Internal Code</label>
                  <input
                    type="text"
                    required
                    value={tierCode}
                    onChange={(e) => setTierCode(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Target Firm Audience</label>
                <input
                  type="text"
                  value={targetAudience}
                  onChange={(e) => setTargetAudience(e.target.value)}
                  placeholder="e.g. Mid-sized secretarial practices..."
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Monthly Software Fee (MYR)</label>
                  <input
                    type="number"
                    required
                    value={monthlyPrice}
                    onChange={(e) => setMonthlyPrice(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Annual Upfront Price (MYR)</label>
                  <input
                    type="number"
                    required
                    value={annualPrice}
                    onChange={(e) => setAnnualPrice(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3 bg-gray-50 p-3 rounded-xl border border-gray-200">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Company Limit</label>
                  <input
                    type="number"
                    required
                    value={companyLimit}
                    onChange={(e) => setCompanyLimit(e.target.value)}
                    className="w-full p-2 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Staff Seats</label>
                  <input
                    type="number"
                    required
                    value={staffSeats}
                    onChange={(e) => setStaffSeats(e.target.value)}
                    className="w-full p-2 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">TM Storage (GB)</label>
                  <input
                    type="number"
                    required
                    value={tmCloudStorageGB}
                    onChange={(e) => setTmCloudStorageGB(e.target.value)}
                    className="w-full p-2 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Included Features (one per line)</label>
                <textarea
                  rows={4}
                  value={features}
                  onChange={(e) => setFeatures(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg font-mono text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded-lg shadow-sm"
                >
                  Save Plan Configuration
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default SubscriptionPlans;
