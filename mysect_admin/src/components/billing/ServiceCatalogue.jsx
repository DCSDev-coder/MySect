import React, { useState } from 'react';
import { 
  FileSpreadsheet, Plus, Edit, FileText, Search
} from 'lucide-react';

const ServiceCatalogue = ({ 
  services = [], 
  onSaveService 
}) => {
  const [serviceList, setServiceList] = useState(services);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [showModal, setShowModal] = useState(false);
  const [editingService, setEditingService] = useState(null);

  // Form state
  const [code, setCode] = useState('');
  const [category, setCategory] = useState('Annual Compliance');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [turnaroundDays, setTurnaroundDays] = useState(5);
  const [requiredDocs, setRequiredDocs] = useState('');
  const [baseGovernmentFee, setBaseGovernmentFee] = useState(150);
  const [recommendedFee, setRecommendedFee] = useState(350);
  const [commissionPercent, setCommissionPercent] = useState(8);

  const categories = ['All', 'Annual Compliance', 'Company Changes', 'Share Capital & Members', 'Incorporation & Setup'];

  const filteredServices = serviceList.filter(s => {
    const matchesCat = selectedCategory === 'All' || s.category === selectedCategory;
    const matchesSearch = s.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          s.code.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesCat && matchesSearch;
  });

  const handleOpenCreate = () => {
    setEditingService(null);
    setCode('SRV-' + Math.floor(100 + Math.random() * 900));
    setCategory('Company Changes');
    setTitle('');
    setDescription('');
    setTurnaroundDays(3);
    setRequiredDocs('Director MyKad / Passport copy\nBoard Resolution draft\nConsent letter');
    setBaseGovernmentFee(50);
    setRecommendedFee(250);
    setCommissionPercent(8);
    setShowModal(true);
  };

  const handleOpenEdit = (srv) => {
    setEditingService(srv);
    setCode(srv.code);
    setCategory(srv.category);
    setTitle(srv.title);
    setDescription(srv.description);
    setTurnaroundDays(srv.standardTurnaroundDays);
    setRequiredDocs((srv.requiredDocuments || []).join('\n'));
    setBaseGovernmentFee(srv.baseGovernmentFeeMYR);
    setRecommendedFee(srv.recommendedServiceFeeMYR);
    setCommissionPercent(srv.platformCommissionPercent);
    setShowModal(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    const docArray = requiredDocs.split('\n').filter(d => d.trim().length > 0);
    const updated = {
      id: editingService ? editingService.id : 'srv-' + Math.floor(100 + Math.random() * 900),
      code,
      category,
      title,
      description,
      standardTurnaroundDays: Number(turnaroundDays),
      requiredDocuments: docArray,
      baseGovernmentFeeMYR: Number(baseGovernmentFee),
      recommendedServiceFeeMYR: Number(recommendedFee),
      platformCommissionPercent: Number(commissionPercent),
      status: 'Active',
    };

    if (editingService) {
      setServiceList(serviceList.map(s => s.id === editingService.id ? updated : s));
    } else {
      setServiceList([...serviceList, updated]);
    }

    if (onSaveService) onSaveService(updated);
    setShowModal(false);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <FileSpreadsheet className="w-4 h-4" />
            <span>Service Catalogue & Request Types</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mt-1">Secretarial Service Taxonomy & SLAs</h1>
          <p className="text-sm text-gray-500">
            Define corporate secretarial request categories, intake document requirements for AI processing, standard turnaround SLAs, and benchmark pricing.
          </p>
        </div>

        <button 
          onClick={handleOpenCreate}
          className="px-4 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-lg text-sm font-semibold transition-colors shadow-xs flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Add Request Type
        </button>
      </div>

      {/* Filters Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-xs mt-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            type="text"
            placeholder="Search request type, code, category..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
          />
        </div>

        <div className="flex flex-wrap gap-1.5">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors ${
                selectedCategory === cat 
                  ? 'bg-[#062AAE] text-white' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Services Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
        {filteredServices.map((srv) => (
          <div key={srv.id} className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6 hover:shadow-md transition-shadow flex flex-col justify-between">
            <div>
              <div className="flex items-start justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-mono font-bold text-gray-400 bg-gray-100 px-2 py-0.5 rounded">
                      {srv.code}
                    </span>
                    <span className="text-xs font-medium text-[#062AAE] bg-blue-50 px-2.5 py-0.5 rounded-full border border-blue-100">
                      {srv.category}
                    </span>
                  </div>
                  <h3 className="text-base font-bold text-gray-900 mt-2">{srv.title}</h3>
                </div>

                <span className="px-2 py-1 bg-emerald-50 text-emerald-700 text-xs font-semibold rounded-lg shrink-0">
                  {srv.standardTurnaroundDays} Days SLA
                </span>
              </div>

              <p className="text-xs text-gray-600 mt-2 leading-relaxed">
                {srv.description}
              </p>

              {/* Pricing & Commission */}
              <div className="grid grid-cols-3 gap-3 bg-gray-50 p-3 rounded-xl border border-gray-200 mt-4 text-xs">
                <div>
                  <span className="text-gray-400 block text-[11px]">Govt Filing Fee:</span>
                  <strong className="text-gray-900 font-bold block mt-0.5">MYR {srv.baseGovernmentFeeMYR.toFixed(2)}</strong>
                </div>
                <div>
                  <span className="text-gray-400 block text-[11px]">Recommended Price:</span>
                  <strong className="text-emerald-700 font-bold block mt-0.5">MYR {srv.recommendedServiceFeeMYR.toFixed(2)}</strong>
                </div>
                <div>
                  <span className="text-gray-400 block text-[11px]">Platform Comm:</span>
                  <strong className="text-[#062AAE] font-bold block mt-0.5">{srv.platformCommissionPercent}%</strong>
                </div>
              </div>

              {/* Required Documents Checklist */}
              <div className="mt-4">
                <span className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider block mb-1.5">
                  Mandatory Intake Documents (AI Extraction Checklist)
                </span>
                <div className="space-y-1 text-xs">
                  {(srv.requiredDocuments || []).map((doc, idx) => (
                    <div key={idx} className="flex items-center gap-2 text-gray-600">
                      <FileText className="w-3.5 h-3.5 text-blue-500 shrink-0" />
                      <span className="truncate">{doc}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            <div className="pt-4 mt-5 border-t border-gray-100 flex items-center justify-between">
              <span className="text-[11px] text-gray-400">Available across all member firms</span>
              <button
                onClick={() => handleOpenEdit(srv)}
                className="px-3 py-1.5 bg-gray-50 hover:bg-gray-100 text-gray-700 border border-gray-200 rounded-lg text-xs font-semibold transition-colors flex items-center gap-1"
              >
                <Edit className="w-3 h-3" />
                Configure Service
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Modal: Create/Edit Service */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-gray-200 text-xs max-h-[90vh] overflow-y-auto">
            <h3 className="text-base font-bold text-gray-900">
              {editingService ? `Edit ${editingService.title}` : 'Add New Secretarial Request Type'}
            </h3>
            <p className="text-gray-500 mt-1">
              Configure SLA turnaround, intake document checklists, and commission rates.
            </p>

            <form onSubmit={handleSave} className="mt-4 space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Service Code</label>
                  <input
                    type="text"
                    required
                    value={code}
                    onChange={(e) => setCode(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Service Category</label>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="Annual Compliance">Annual Compliance</option>
                    <option value="Company Changes">Company Changes</option>
                    <option value="Share Capital & Members">Share Capital & Members</option>
                    <option value="Incorporation & Setup">Incorporation & Setup</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Service Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. Appointment / Resignation of Director (Form 58)"
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Description</label>
                <textarea
                  rows={2}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Turnaround (Days)</label>
                  <input
                    type="number"
                    value={turnaroundDays}
                    onChange={(e) => setTurnaroundDays(e.target.value)}
                    className="w-full p-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Govt Fee (MYR)</label>
                  <input
                    type="number"
                    value={baseGovernmentFee}
                    onChange={(e) => setBaseGovernmentFee(e.target.value)}
                    className="w-full p-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Commission (%)</label>
                  <input
                    type="number"
                    value={commissionPercent}
                    onChange={(e) => setCommissionPercent(e.target.value)}
                    className="w-full p-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Required Documents (one per line)</label>
                <textarea
                  rows={3}
                  value={requiredDocs}
                  onChange={(e) => setRequiredDocs(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg font-mono text-xs focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
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
                  Save Service
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default ServiceCatalogue;
