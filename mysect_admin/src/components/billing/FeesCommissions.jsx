import React, { useState } from 'react';
import { 
  DollarSign, Plus, Edit, Shield
} from 'lucide-react';

const FeesCommissions = ({ 
  feeRules = [], 
  onSaveRule
}) => {
  const [rules, setRules] = useState(feeRules);
  const [showModal, setShowModal] = useState(false);
  const [editingRule, setEditingRule] = useState(null);

  // Form states
  const [ruleName, setRuleName] = useState('');
  const [chargeType, setChargeType] = useState('Recurring Monthly Fee');
  const [rateAmount, setRateAmount] = useState(20);
  const [currency, setCurrency] = useState('MYR');
  const [description, setDescription] = useState('');
  const [appliesTo, setAppliesTo] = useState('All Standard Secretary Firms');

  const handleOpenCreate = () => {
    setEditingRule(null);
    setRuleName('');
    setChargeType('Recurring Monthly Fee');
    setRateAmount(25);
    setCurrency('MYR');
    setDescription('');
    setAppliesTo('All Standard Secretary Firms');
    setShowModal(true);
  };

  const handleOpenEdit = (rule) => {
    setEditingRule(rule);
    setRuleName(rule.ruleName);
    setChargeType(rule.chargeType);
    setRateAmount(rule.rateAmount);
    setCurrency(rule.currency);
    setDescription(rule.description);
    setAppliesTo(rule.appliesTo);
    setShowModal(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    const updated = {
      id: editingRule ? editingRule.id : 'rule-' + Math.floor(100 + Math.random() * 900),
      ruleName,
      chargeType,
      rateAmount: Number(rateAmount),
      currency,
      description,
      appliesTo,
      status: 'Active',
      effectiveSince: editingRule ? editingRule.effectiveSince : '2026-10-21',
    };

    if (editingRule) {
      setRules(rules.map(r => r.id === editingRule.id ? updated : r));
    } else {
      setRules([...rules, updated]);
    }

    if (onSaveRule) onSaveRule(updated);
    setShowModal(false);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <DollarSign className="w-4 h-4" />
            <span>Commercial Finance & Marketplace Governance</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Platform Fees & Commission Rules</h1>
          <p className="text-sm text-gray-500">
            Configure monthly per-company platform rates, service marketplace commission rules, and review the two-tier platform revenue ledger.
          </p>
        </div>

        <button 
          onClick={handleOpenCreate}
          className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-lg text-sm font-semibold transition-colors shadow-xs flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Add Platform Fee Rule
        </button>
      </div>

      {/* Revenue High-level Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5 mt-6">
        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-xs">
          <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Per-Company Fee Revenue</span>
          <div className="mt-2 text-2xl font-bold text-gray-900">MYR 24,800.00</div>
          <p className="text-xs text-gray-500 mt-1">1,240 active Sdn Bhd × RM 20/mo</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-xs">
          <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Marketplace Commission (8%)</span>
          <div className="mt-2 text-2xl font-bold text-emerald-600">MYR 6,420.00</div>
          <p className="text-xs text-gray-500 mt-1">From ad-hoc services (AR, Form 58, Incorp)</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-xs">
          <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Firm Software Subscriptions</span>
          <div className="mt-2 text-2xl font-bold text-[#062AAE]">MYR 9,280.00</div>
          <p className="text-xs text-gray-500 mt-1">Starter, Growth & Pro recurring tiers</p>
        </div>
      </div>

      {/* Fee Rules Table */}
      <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden mt-8">
        <div className="p-5 border-b border-gray-200 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Active Platform Pricing & Commission Rules</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Governs fees levied by MySect platform on member firms and marketplace transactions.
            </p>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Rule Name & Type</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Platform Rate</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Description</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Applies To</th>
                <th className="px-5 py-3.5 text-left font-semibold text-gray-600">Effective Since</th>
                <th className="px-5 py-3.5 text-center font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 bg-white">
              {rules.map((rule) => (
                <tr key={rule.id} className="hover:bg-gray-50">
                  <td className="px-5 py-4">
                    <div className="font-semibold text-sm text-gray-900">{rule.ruleName}</div>
                    <span className="inline-block px-2 py-0.5 bg-blue-50 text-[#062AAE] font-medium rounded text-[10px] mt-1">
                      {rule.chargeType}
                    </span>
                  </td>

                  <td className="px-5 py-4">
                    <span className="text-base font-bold text-gray-900">
                      {rule.currency.includes('%') ? `${rule.rateAmount}%` : `MYR ${rule.rateAmount.toFixed(2)}`}
                    </span>
                    <span className="text-gray-400 text-[11px] block">{rule.currency}</span>
                  </td>

                  <td className="px-5 py-4 text-gray-600 max-w-xs leading-relaxed">
                    {rule.description}
                  </td>

                  <td className="px-5 py-4 text-gray-700 font-medium">
                    {rule.appliesTo}
                  </td>

                  <td className="px-5 py-4 text-gray-500 font-mono text-[11px]">
                    {rule.effectiveSince}
                  </td>

                  <td className="px-5 py-4 text-center">
                    <button
                      onClick={() => handleOpenEdit(rule)}
                      className="px-3 py-1.5 bg-white border border-gray-200 hover:bg-gray-100 text-gray-700 rounded-lg text-xs font-semibold inline-flex items-center justify-center gap-1 transition-colors"
                    >
                      <Edit className="w-3 h-3" />
                      Configure
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Blueprint Commercial Policy Reference Note */}
      <div className="bg-blue-50/60 p-5 rounded-2xl border border-blue-200 mt-6 text-xs text-gray-700 leading-relaxed">
        <h4 className="font-bold text-[#062AAE] flex items-center gap-1.5 text-sm mb-1">
          <Shield className="w-4 h-4" />
          Blueprint Multi-Tenant Commercial Architecture Notice
        </h4>
        <p>
          As documented in Section 12.2 of the Platform Blueprint, MySect enforces two separate commercial relationships:
        </p>
        <ul className="list-disc pl-5 mt-2 space-y-1 text-gray-600">
          <li>
            <strong>Relationship A (Platform Subscription):</strong> MySect bills the Secretary Firm for platform SaaS usage, per-company fees, and seat allowances.
          </li>
          <li>
            <strong>Relationship B (Professional Service):</strong> The Secretary Firm defines and bills its own professional fees to the end-client. MySect acts as software orchestrator and commission collector where facilitated.
          </li>
        </ul>
      </div>

      {/* Modal: Create/Edit Rule */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-gray-200 text-xs">
            <h3 className="text-base font-bold text-gray-900">
              {editingRule ? 'Configure Fee Rule' : 'Create Platform Fee Rule'}
            </h3>
            <p className="text-gray-500 mt-1">
              Adjust commission rates or per-company platform fee calculations.
            </p>

            <form onSubmit={handleSave} className="mt-4 space-y-4">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Rule Name</label>
                <input
                  type="text"
                  required
                  value={ruleName}
                  onChange={(e) => setRuleName(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  placeholder="e.g. Per-Company Platform Fee"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Charge Type</label>
                  <select
                    value={chargeType}
                    onChange={(e) => setChargeType(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="Recurring Monthly Fee">Recurring Monthly Fee</option>
                    <option value="Transaction Commission (%)">Transaction Commission (%)</option>
                    <option value="Per-Check Cost">Per-Check Cost</option>
                    <option value="One-time Setup Fee">One-time Setup Fee</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Rate Value</label>
                  <input
                    type="number"
                    step="0.1"
                    required
                    value={rateAmount}
                    onChange={(e) => setRateAmount(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Currency / Unit Label</label>
                <input
                  type="text"
                  value={currency}
                  onChange={(e) => setCurrency(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  placeholder="e.g. MYR or % of Gross Service Fee"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Description & Applicability</label>
                <textarea
                  rows={2}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  placeholder="Explain when and how this fee is levied..."
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-gray-100">
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
                  Save Fee Rule
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default FeesCommissions;
