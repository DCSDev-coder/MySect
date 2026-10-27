import React, { useState } from 'react';
import {
  FileText, CheckCircle2, XCircle, AlertCircle, HelpCircle,
  Search, ShieldCheck, User, Calendar, ExternalLink,
  Clock, Hash, FileCheck, ArrowRight, Eye, RefreshCw,
  FolderOpen
} from 'lucide-react';

const SecretaryWorkspace = ({
  documents = [],
  firms = [],
  companies = [],
  currentUser = null,
  onReviewDocument = () => {},
  logAudit = () => {},
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('All');
  const [selectedCompany, setSelectedCompany] = useState('All');
  const [selectedCategory, setSelectedCategory] = useState('All');

  // Selected document for modal / drawer review
  const [activeDoc, setActiveDoc] = useState(null);

  // Review action modal state ('approve' | 'reject' | 'details' | null)
  const [reviewAction, setReviewAction] = useState(null);
  const [approvalRemarks, setApprovalRemarks] = useState('');
  const [rejectionReasonPreset, setRejectionReasonPreset] = useState('Signature disparity with statutory records');
  const [rejectionCustomReason, setRejectionCustomReason] = useState('');
  const [requestedDetailsText, setRequestedDetailsText] = useState('');
  const [internalSecretaryNotes, setInternalSecretaryNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [actionSuccessMsg, setActionSuccessMsg] = useState('');

  // Calculations for KPIs
  const totalDocs = documents.length;
  const pendingDocs = documents.filter(d => d.status === 'Pending Review');
  const approvedDocs = documents.filter(d => d.status === 'Approved');
  const rejectedDocs = documents.filter(d => d.status === 'Rejected');
  const moreDetailsDocs = documents.filter(d => d.status === 'More Details Needed');

  // Filtered documents
  const filteredDocs = documents.filter(doc => {
    const matchesSearch =
      doc.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doc.companyName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doc.uploadedBy.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (doc.category && doc.category.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesStatus =
      selectedStatus === 'All' || doc.status === selectedStatus;

    const matchesCompany =
      selectedCompany === 'All' || doc.companyId === selectedCompany;

    const matchesCategory =
      selectedCategory === 'All' || doc.category === selectedCategory;

    return matchesSearch && matchesStatus && matchesCompany && matchesCategory;
  });

  const categories = Array.from(new Set(documents.map(d => d.category))).filter(Boolean);

  const handleOpenReview = (doc, action = null) => {
    setActiveDoc(doc);
    setReviewAction(action);
    setApprovalRemarks('');
    setRejectionCustomReason('');
    setRequestedDetailsText('');
    setInternalSecretaryNotes('');
    setActionSuccessMsg('');
  };

  const handleExecuteReview = async (decision) => {
    if (!activeDoc) return;
    setIsSubmitting(true);

    const reviewerName = currentUser?.name
      ? `${currentUser.name} (${currentUser.role || 'Licensed Secretary'})`
      : 'Lim Mei Ling (MIA CA 48192)';

    let rejectionReason = '';
    if (decision === 'Rejected') {
      rejectionReason = rejectionCustomReason.trim()
        ? rejectionCustomReason.trim()
        : rejectionReasonPreset;
    }

    const payload = {
      decision, // 'Approved' | 'Rejected' | 'More Details Needed'
      reviewedBy: reviewerName,
      remarks: decision === 'Approved' ? (approvalRemarks || 'Complies with Companies Act 2016 statutory requirements.') : undefined,
      rejectionReason: decision === 'Rejected' ? rejectionReason : undefined,
      requestedDetails: decision === 'More Details Needed' ? requestedDetailsText : undefined,
      internalNotes: internalSecretaryNotes
    };

    try {
      await onReviewDocument(activeDoc.id, payload);

      // Local success feedback
      setActionSuccessMsg(`Document successfully marked as "${decision}". Updated in Secretary Queue and Mobile App.`);
      logAudit(
        `SECRETARY_${decision.toUpperCase().replace(/\s+/g, '_')}`,
        `${activeDoc.title} (${activeDoc.companyName})`,
        `Secretary ${reviewerName} reviewed document with outcome: ${decision}.`
      );

      // Update the activeDoc locally so modal shows latest review
      const nowStr = new Date().toISOString().replace('T', ' ').substring(0, 16);
      setActiveDoc(prev => ({
        ...prev,
        status: decision,
        reviewDetails: {
          reviewedBy: reviewerName,
          reviewedAt: nowStr,
          decision,
          internalNotes: internalSecretaryNotes,
          remarks: payload.remarks,
          rejectionReason: payload.rejectionReason,
          requestedDetails: payload.requestedDetails
        },
        auditTrail: [
          ...(prev.auditTrail || []),
          {
            timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
            action: `FILE_${decision.toUpperCase().replace(/\s+/g, '_')}`,
            actor: reviewerName,
            details: decision === 'Approved'
              ? `Approved: ${payload.remarks}`
              : decision === 'Rejected'
                ? `Rejected: ${payload.rejectionReason}`
                : `Requested details: ${payload.requestedDetails}`
          }
        ]
      }));

      setTimeout(() => {
        setIsSubmitting(false);
        setReviewAction(null);
      }, 500);
    } catch (e) {
      console.error(e);
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Pending Review':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
            Pending Review
          </span>
        );
      case 'Approved':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
            Approved
          </span>
        );
      case 'Rejected':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-50 text-rose-700 border border-rose-200">
            <XCircle className="w-3.5 h-3.5 text-rose-600" />
            Rejected
          </span>
        );
      case 'More Details Needed':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-blue-50 text-blue-700 border border-blue-200">
            <HelpCircle className="w-3.5 h-3.5 text-blue-600" />
            More Details Needed
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-700">
            {status}
          </span>
        );
    }
  };

  return (
    <div className="flex-1 flex flex-col h-screen overflow-hidden bg-[#F8F9FA]">
      {/* Top Header */}
      <div className="bg-white border-b border-gray-200 px-8 py-5 shrink-0">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2.5">
              <span className="px-2.5 py-0.5 rounded-md bg-[#062AAE]/10 text-[#062AAE] font-bold text-xs tracking-wider uppercase">
                Company Secretary Workspace
              </span>
              <span className="flex items-center gap-1 text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                Mobile Sync Active
              </span>
            </div>
            <h1 className="text-2xl font-bold text-gray-900 mt-1">
              Document Intake & Review Queue
            </h1>
            <p className="text-sm text-gray-500 mt-0.5">
              Verify client files submitted from the MySect mobile app. Approve, reject, or request more details in accordance with Malaysian Companies Act 2016.
            </p>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2.5 px-3.5 py-2 rounded-xl bg-gray-50 border border-gray-200 text-xs">
              <ShieldCheck className="w-4 h-4 text-[#062AAE]" />
              <div>
                <p className="font-semibold text-gray-900 leading-none">Lim Mei Ling (MIA)</p>
                <p className="text-gray-500 text-[11px] mt-0.5">SectPro Corporate Services</p>
              </div>
            </div>
          </div>
        </div>

        {/* 4 KPI Metric Cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
          <div
            onClick={() => setSelectedStatus('All')}
            className={`p-4 rounded-xl border transition-all cursor-pointer ${
              selectedStatus === 'All'
                ? 'bg-blue-50/50 border-[#062AAE] ring-1 ring-[#062AAE]'
                : 'bg-white border-gray-200 hover:border-gray-300'
            }`}
          >
            <div className="flex items-center justify-between text-xs font-medium text-gray-500">
              <span>Total Client Uploads</span>
              <FolderOpen className="w-4 h-4 text-gray-400" />
            </div>
            <div className="text-2xl font-bold text-gray-900 mt-2">{totalDocs}</div>
            <div className="text-[11px] text-gray-500 mt-1">Across all managed companies</div>
          </div>

          <div
            onClick={() => setSelectedStatus('Pending Review')}
            className={`p-4 rounded-xl border transition-all cursor-pointer ${
              selectedStatus === 'Pending Review'
                ? 'bg-amber-50/60 border-amber-500 ring-1 ring-amber-500'
                : 'bg-white border-gray-200 hover:border-amber-300'
            }`}
          >
            <div className="flex items-center justify-between text-xs font-medium text-amber-700">
              <span className="flex items-center gap-1.5 font-semibold">
                <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse"></span>
                Action Required
              </span>
              <Clock className="w-4 h-4 text-amber-500" />
            </div>
            <div className="text-2xl font-bold text-amber-800 mt-2">{pendingDocs.length}</div>
            <div className="text-[11px] text-amber-700/80 mt-1">Pending secretary decision</div>
          </div>

          <div
            onClick={() => setSelectedStatus('Approved')}
            className={`p-4 rounded-xl border transition-all cursor-pointer ${
              selectedStatus === 'Approved'
                ? 'bg-emerald-50/60 border-emerald-500 ring-1 ring-emerald-500'
                : 'bg-white border-gray-200 hover:border-emerald-300'
            }`}
          >
            <div className="flex items-center justify-between text-xs font-medium text-emerald-700">
              <span className="font-semibold">Approved Files</span>
              <CheckCircle2 className="w-4 h-4 text-emerald-500" />
            </div>
            <div className="text-2xl font-bold text-emerald-800 mt-2">{approvedDocs.length}</div>
            <div className="text-[11px] text-emerald-700/80 mt-1">Verified for SSM lodgement</div>
          </div>

          <div
            onClick={() => setSelectedStatus('More Details Needed')}
            className={`p-4 rounded-xl border transition-all cursor-pointer ${
              selectedStatus === 'More Details Needed'
                ? 'bg-blue-50/60 border-blue-500 ring-1 ring-blue-500'
                : 'bg-white border-gray-200 hover:border-blue-300'
            }`}
          >
            <div className="flex items-center justify-between text-xs font-medium text-blue-700">
              <span className="font-semibold">Clarifications Sent</span>
              <HelpCircle className="w-4 h-4 text-blue-500" />
            </div>
            <div className="text-2xl font-bold text-blue-800 mt-2">{moreDetailsDocs.length}</div>
            <div className="text-[11px] text-blue-700/80 mt-1">Waiting for client response</div>
          </div>
        </div>
      </div>

      {/* Main Content & Controls */}
      <div className="flex-1 overflow-y-auto p-8 space-y-6">
        {/* Filter and Search Bar */}
        <div className="bg-white p-4 rounded-2xl border border-gray-200 shadow-xs flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="relative w-full md:w-80">
            <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search file, company, or uploader..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 rounded-xl text-sm border border-gray-200 focus:outline-none focus:border-[#062AAE] bg-gray-50/50"
            />
          </div>

          <div className="flex flex-wrap items-center gap-3 w-full md:w-auto">
            {/* Status Filter */}
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="px-3 py-2 rounded-xl text-xs font-medium border border-gray-200 bg-white text-gray-700 focus:outline-none focus:border-[#062AAE]"
            >
              <option value="All">All Statuses</option>
              <option value="Pending Review">Pending Review</option>
              <option value="Approved">Approved</option>
              <option value="More Details Needed">More Details Needed</option>
              <option value="Rejected">Rejected</option>
            </select>

            {/* Company Filter */}
            <select
              value={selectedCompany}
              onChange={(e) => setSelectedCompany(e.target.value)}
              className="px-3 py-2 rounded-xl text-xs font-medium border border-gray-200 bg-white text-gray-700 focus:outline-none focus:border-[#062AAE] max-w-[200px]"
            >
              <option value="All">All Companies</option>
              {companies.map(c => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>

            {/* Category Filter */}
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="px-3 py-2 rounded-xl text-xs font-medium border border-gray-200 bg-white text-gray-700 focus:outline-none focus:border-[#062AAE] max-w-[180px]"
            >
              <option value="All">All Categories</option>
              {categories.map(cat => (
                <option key={cat} value={cat}>{cat}</option>
              ))}
            </select>

            {(selectedStatus !== 'All' || selectedCompany !== 'All' || selectedCategory !== 'All' || searchQuery) && (
              <button
                onClick={() => {
                  setSelectedStatus('All');
                  setSelectedCompany('All');
                  setSelectedCategory('All');
                  setSearchQuery('');
                }}
                className="text-xs text-gray-500 hover:text-gray-900 underline ml-1 cursor-pointer"
              >
                Reset
              </button>
            )}
          </div>
        </div>

        {/* Documents Table View */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
            <div className="flex items-center gap-2">
              <FileText className="w-4 h-4 text-[#062AAE]" />
              <h2 className="text-sm font-bold text-gray-900">
                End-User Submitted Files ({filteredDocs.length})
              </h2>
            </div>
            <span className="text-xs text-gray-500">
              Click any file row to view preview and review controls
            </span>
          </div>

          {filteredDocs.length === 0 ? (
            <div className="py-16 text-center">
              <div className="w-12 h-12 rounded-full bg-gray-100 text-gray-400 flex items-center justify-center mx-auto mb-3">
                <FileText className="w-6 h-6" />
              </div>
              <p className="text-sm font-semibold text-gray-700">No matching documents found</p>
              <p className="text-xs text-gray-400 mt-1">Try adjusting your filters or search keywords.</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {filteredDocs.map((doc) => {
                const isPending = doc.status === 'Pending Review';

                return (
                  <div
                    key={doc.id}
                    className="p-5 hover:bg-gray-50/80 transition-all flex flex-col lg:flex-row lg:items-center justify-between gap-4 cursor-pointer"
                    onClick={() => handleOpenReview(doc)}
                  >
                    {/* Left: File icon & details */}
                    <div className="flex items-start gap-4 flex-1">
                      <div className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 border ${
                        isPending
                          ? 'bg-amber-50 text-amber-600 border-amber-200'
                          : doc.status === 'Approved'
                            ? 'bg-emerald-50 text-emerald-600 border-emerald-200'
                            : doc.status === 'Rejected'
                              ? 'bg-rose-50 text-rose-600 border-rose-200'
                              : 'bg-blue-50 text-blue-600 border-blue-200'
                      }`}>
                        <FileText className="w-5 h-5" />
                      </div>

                      <div className="space-y-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <h3 className="text-sm font-bold text-gray-900 hover:text-[#062AAE] transition-colors">
                            {doc.title}
                          </h3>
                          <span className="text-xs text-gray-400 font-mono">({doc.fileSize})</span>
                          {getStatusBadge(doc.status)}
                        </div>

                        <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500">
                          <span className="font-medium text-gray-800">
                            🏢 {doc.companyName}
                          </span>
                          <span>•</span>
                          <span>Reg: <strong className="font-mono text-gray-700">{doc.companySsmNo}</strong></span>
                          <span>•</span>
                          <span>Category: <strong className="text-gray-700">{doc.category}</strong></span>
                        </div>

                        <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-[11px] text-gray-400 pt-0.5">
                          <span className="flex items-center gap-1">
                            <User className="w-3 h-3" />
                            Uploaded by: <span className="text-gray-600 font-medium">{doc.uploadedBy} ({doc.uploadedByRole})</span>
                          </span>
                          <span>•</span>
                          <span className="flex items-center gap-1">
                            <Calendar className="w-3 h-3" />
                            {doc.uploadedAt}
                          </span>
                          <span>•</span>
                          <span className="text-[#062AAE] font-medium flex items-center gap-1">
                            <ShieldCheck className="w-3 h-3" />
                            TM Cloud Alpha Verified
                          </span>
                        </div>

                        {/* If review notes exist, show summary snippet */}
                        {doc.reviewDetails && (
                          <div className="mt-2 text-xs p-2 rounded-lg bg-gray-50 border border-gray-100 flex items-start gap-2">
                            <span className="font-semibold text-gray-700 shrink-0">Secretary Remark:</span>
                            <span className="text-gray-600 italic">
                              {doc.reviewDetails.remarks || doc.reviewDetails.rejectionReason || doc.reviewDetails.requestedDetails}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Right: Quick Review Action Buttons */}
                    <div
                      className="flex items-center gap-2 self-end lg:self-center shrink-0"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <button
                        onClick={() => handleOpenReview(doc, 'approve')}
                        title="Approve Document"
                        className={`px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                          doc.status === 'Approved'
                            ? 'bg-emerald-100 text-emerald-800 opacity-60'
                            : 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs'
                        }`}
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>Approve</span>
                      </button>

                      <button
                        onClick={() => handleOpenReview(doc, 'reject')}
                        title="Reject Document"
                        className={`px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                          doc.status === 'Rejected'
                            ? 'bg-rose-100 text-rose-800 opacity-60'
                            : 'bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200'
                        }`}
                      >
                        <XCircle className="w-3.5 h-3.5" />
                        <span>Reject</span>
                      </button>

                      <button
                        onClick={() => handleOpenReview(doc, 'details')}
                        title="Ask for More Details / Replacement"
                        className={`px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                          doc.status === 'More Details Needed'
                            ? 'bg-blue-100 text-blue-800 opacity-60'
                            : 'bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200'
                        }`}
                      >
                        <HelpCircle className="w-3.5 h-3.5" />
                        <span>Ask Details</span>
                      </button>

                      <button
                        onClick={() => handleOpenReview(doc)}
                        className="p-2 text-gray-400 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors cursor-pointer"
                        title="Inspect Document & Audit Trail"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* ============================================================== */}
      {/* Interactive Document Review & Preview Modal                   */}
      {/* ============================================================== */}
      {activeDoc && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[92vh] flex flex-col shadow-2xl border border-gray-100 overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/70">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#062AAE]/10 text-[#062AAE] flex items-center justify-center">
                  <FileText className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-bold text-gray-900">{activeDoc.title}</h3>
                  <p className="text-xs text-gray-500">
                    Uploaded by {activeDoc.uploadedBy} ({activeDoc.uploadedByRole}) • {activeDoc.companyName}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                {getStatusBadge(activeDoc.status)}
                <button
                  onClick={() => {
                    setActiveDoc(null);
                    setReviewAction(null);
                  }}
                  className="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-200/50 rounded-lg transition-colors cursor-pointer"
                >
                  <XCircle className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Modal Body: Split into Preview & Details/Actions */}
            <div className="flex-1 overflow-y-auto p-6 grid grid-cols-1 md:grid-cols-12 gap-6">
              {/* Left Column (7 cols): Document Preview Card */}
              <div className="md:col-span-7 space-y-4">
                <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-xs">
                  <div className="flex items-center justify-between pb-3 border-b border-gray-100 text-xs text-gray-500">
                    <span className="font-semibold text-gray-700">DOCUMENT PREVIEW</span>
                    <span className="font-mono text-gray-400">Page 1 of 4 • {activeDoc.fileSize}</span>
                  </div>

                  {/* Simulated High-Res Document Preview Box */}
                  <div className="mt-4 p-6 rounded-xl bg-gray-50 border border-gray-200/80 font-sans relative overflow-hidden">
                    {/* Watermark seal */}
                    <div className="absolute right-4 top-4 opacity-15 pointer-events-none">
                      <ShieldCheck className="w-32 h-32 text-[#062AAE]" />
                    </div>

                    <div className="border-b border-gray-300 pb-3 mb-4 flex items-center justify-between">
                      <div>
                        <p className="text-xs font-bold text-gray-900 tracking-wider uppercase">
                          COMPANIES ACT 2016 (MALAYSIA)
                        </p>
                        <p className="text-[11px] text-gray-500">
                          Statutory Document Intake: {activeDoc.category}
                        </p>
                      </div>
                      <span className="text-[10px] font-mono bg-white px-2 py-0.5 rounded border border-gray-200 text-gray-600">
                        SSM Verified
                      </span>
                    </div>

                    <div className="space-y-3 text-xs text-gray-700 leading-relaxed">
                      <div className="p-2.5 rounded-lg bg-white border border-gray-200">
                        <p className="font-bold text-gray-900">{activeDoc.companyName}</p>
                        <p className="text-[11px] text-gray-500">SSM Registration: {activeDoc.companySsmNo}</p>
                      </div>

                      <div className="text-[11px] space-y-1 text-gray-600">
                        <p><strong>Title:</strong> {activeDoc.title}</p>
                        <p><strong>Filing Reference:</strong> {activeDoc.linkedFilingRef || 'SSM/S68/2026/04812'}</p>
                        <p><strong>Submission Notes:</strong> {activeDoc.submissionNotes || 'Client uploaded for Annual statutory lodgement'}</p>
                      </div>

                      <div className="pt-3 border-t border-gray-200/60 flex items-center justify-between text-[10px] text-gray-400">
                        <span>Encrypted TM Cloud Storage Vault</span>
                        <span>Hash: {activeDoc.sha256Hash?.substring(0, 16)}...</span>
                      </div>
                    </div>
                  </div>

                  {/* External download / view link */}
                  <div className="mt-3 flex items-center justify-between text-xs text-gray-500 px-1">
                    <span className="flex items-center gap-1.5">
                      <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                      Stored in TM One Cloud Alpha (Cyberjaya DC1)
                    </span>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault();
                        alert(`Opening verified secure link in TM Cloud storage: ${activeDoc.title}`);
                      }}
                      className="text-[#062AAE] hover:underline flex items-center gap-1 font-semibold"
                    >
                      <ExternalLink className="w-3.5 h-3.5" />
                      Download Raw PDF
                    </a>
                  </div>
                </div>

                {/* Audit Trail Timeline */}
                <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-xs">
                  <h4 className="text-xs font-bold text-gray-700 tracking-wider uppercase mb-3 flex items-center gap-2">
                    <Clock className="w-3.5 h-3.5 text-[#062AAE]" />
                    Document Audit History
                  </h4>
                  <div className="space-y-3 text-xs">
                    {(activeDoc.auditTrail || []).map((log, i) => (
                      <div key={i} className="flex items-start gap-3 pl-1 border-l-2 border-gray-200 ml-1.5 pb-2">
                        <span className="w-2 h-2 rounded-full bg-[#062AAE] -ml-[5px] mt-1 shrink-0"></span>
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-semibold text-gray-900">{log.action}</span>
                            <span className="text-[11px] text-gray-400 font-mono">{log.timestamp}</span>
                          </div>
                          <p className="text-[11px] text-gray-600 mt-0.5">{log.details}</p>
                          <p className="text-[10px] text-gray-400">Actor: {log.actor}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Right Column (5 cols): Review Decisions & Action Forms */}
              <div className="md:col-span-5 space-y-4">
                {/* Success alert if just updated */}
                {actionSuccessMsg && (
                  <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 flex items-start gap-2.5 animate-in fade-in">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                    <span>{actionSuccessMsg}</span>
                  </div>
                )}

                {/* Status Box */}
                <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-xs">
                  <h4 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">
                    Secretary Decision Status
                  </h4>
                  <div className="flex items-center gap-2 mt-1">
                    {getStatusBadge(activeDoc.status)}
                  </div>

                  {activeDoc.reviewDetails && (
                    <div className="mt-4 pt-3 border-t border-gray-100 text-xs space-y-2">
                      <p className="text-gray-500">
                        Reviewed by: <strong className="text-gray-800">{activeDoc.reviewDetails.reviewedBy}</strong>
                      </p>
                      <p className="text-gray-500">
                        Date: <span className="font-mono text-gray-700">{activeDoc.reviewDetails.reviewedAt}</span>
                      </p>
                      {activeDoc.reviewDetails.remarks && (
                        <div className="p-2.5 rounded-xl bg-emerald-50 text-emerald-900 border border-emerald-100">
                          <strong>Endorsement Remark:</strong> {activeDoc.reviewDetails.remarks}
                        </div>
                      )}
                      {activeDoc.reviewDetails.rejectionReason && (
                        <div className="p-2.5 rounded-xl bg-rose-50 text-rose-900 border border-rose-100">
                          <strong>Rejection Justification:</strong> {activeDoc.reviewDetails.rejectionReason}
                        </div>
                      )}
                      {activeDoc.reviewDetails.requestedDetails && (
                        <div className="p-2.5 rounded-xl bg-blue-50 text-blue-900 border border-blue-100">
                          <strong>Client Action Needed:</strong> {activeDoc.reviewDetails.requestedDetails}
                        </div>
                      )}
                    </div>
                  )}
                </div>

                {/* Interactive Action Control Section */}
                <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-xs">
                  <h4 className="text-xs font-bold text-gray-900 uppercase tracking-wider mb-3">
                    Choose Secretary Action
                  </h4>

                  {/* 3 Action Selector Tabs */}
                  <div className="grid grid-cols-3 gap-2 p-1 rounded-xl bg-gray-100 mb-4">
                    <button
                      type="button"
                      onClick={() => setReviewAction('approve')}
                      className={`py-2 px-2 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                        reviewAction === 'approve'
                          ? 'bg-emerald-600 text-white shadow-xs'
                          : 'text-gray-600 hover:text-gray-900'
                      }`}
                    >
                      ✓ Approve
                    </button>
                    <button
                      type="button"
                      onClick={() => setReviewAction('reject')}
                      className={`py-2 px-2 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                        reviewAction === 'reject'
                          ? 'bg-rose-600 text-white shadow-xs'
                          : 'text-gray-600 hover:text-gray-900'
                      }`}
                    >
                      ✕ Reject
                    </button>
                    <button
                      type="button"
                      onClick={() => setReviewAction('details')}
                      className={`py-2 px-2 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                        reviewAction === 'details'
                          ? 'bg-[#062AAE] text-white shadow-xs'
                          : 'text-gray-600 hover:text-gray-900'
                      }`}
                    >
                      ? More Details
                    </button>
                  </div>

                  {/* 1. APPROVE FORM */}
                  {reviewAction === 'approve' && (
                    <div className="space-y-3 animate-in fade-in">
                      <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-100 text-xs text-emerald-800 leading-relaxed">
                        Marking this file as <strong>Approved</strong> confirms that all statutory criteria, signatures, and company details meet Companies Act 2016 lodgement rules.
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-gray-700 mb-1">
                          Secretary Endorsement Remarks (Optional)
                        </label>
                        <textarea
                          rows={3}
                          value={approvalRemarks}
                          onChange={(e) => setApprovalRemarks(e.target.value)}
                          placeholder="e.g. Verified against company statutory registers. Ready for Section 68 lodgement."
                          className="w-full p-2.5 rounded-xl border border-gray-200 text-xs focus:outline-none focus:border-emerald-500"
                        />
                      </div>

                      <button
                        type="button"
                        disabled={isSubmitting}
                        onClick={() => handleExecuteReview('Approved')}
                        className="w-full py-2.5 px-4 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs transition-all flex items-center justify-center gap-2 cursor-pointer"
                      >
                        {isSubmitting ? (
                          <RefreshCw className="w-4 h-4 animate-spin" />
                        ) : (
                          <CheckCircle2 className="w-4 h-4" />
                        )}
                        <span>Confirm Approval</span>
                      </button>
                    </div>
                  )}

                  {/* 2. REJECT FORM */}
                  {reviewAction === 'reject' && (
                    <div className="space-y-3 animate-in fade-in">
                      <div className="p-3 rounded-xl bg-rose-50 border border-rose-100 text-xs text-rose-800 leading-relaxed">
                        Rejecting this document will notify the client on their mobile app and explain why the document cannot be lodged to SSM.
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-gray-700 mb-1">
                          Reason Preset
                        </label>
                        <select
                          value={rejectionReasonPreset}
                          onChange={(e) => setRejectionReasonPreset(e.target.value)}
                          className="w-full p-2 rounded-xl border border-gray-200 text-xs bg-white text-gray-800 focus:outline-none focus:border-rose-500"
                        >
                          <option value="Signature disparity with statutory records">Signature disparity with statutory records</option>
                          <option value="Document expired or insufficient validity period">Document expired or insufficient validity period</option>
                          <option value="Scan is blurry, unreadable or missing required stamp">Scan is blurry, unreadable or missing required stamp</option>
                          <option value="Incomplete pages or missing attached statutory schedule">Incomplete pages or missing attached statutory schedule</option>
                          <option value="Wrong document type uploaded for this filing category">Wrong document type uploaded for this filing category</option>
                          <option value="Custom">Custom Justification</option>
                        </select>
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-gray-700 mb-1">
                          Specific Rejection Feedback for Client
                        </label>
                        <textarea
                          rows={3}
                          value={rejectionCustomReason}
                          onChange={(e) => setRejectionCustomReason(e.target.value)}
                          placeholder="Provide clear instructions to the client on what was wrong and how to fix it..."
                          className="w-full p-2.5 rounded-xl border border-gray-200 text-xs focus:outline-none focus:border-rose-500"
                        />
                      </div>

                      <button
                        type="button"
                        disabled={isSubmitting}
                        onClick={() => handleExecuteReview('Rejected')}
                        className="w-full py-2.5 px-4 rounded-xl text-xs font-bold bg-rose-600 hover:bg-rose-700 text-white shadow-xs transition-all flex items-center justify-center gap-2 cursor-pointer"
                      >
                        {isSubmitting ? (
                          <RefreshCw className="w-4 h-4 animate-spin" />
                        ) : (
                          <XCircle className="w-4 h-4" />
                        )}
                        <span>Issue Formal Rejection</span>
                      </button>
                    </div>
                  )}

                  {/* 3. ASK FOR MORE DETAILS FORM */}
                  {reviewAction === 'details' && (
                    <div className="space-y-3 animate-in fade-in">
                      <div className="p-3 rounded-xl bg-blue-50 border border-blue-100 text-xs text-blue-800 leading-relaxed">
                        Requesting more details prompts the end-user via mobile notification to provide clarifications, Form 48A declarations, or replacement documents.
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-gray-700 mb-1">
                          Clarification / Additional Documents Needed <span className="text-rose-500">*</span>
                        </label>
                        <textarea
                          rows={4}
                          value={requestedDetailsText}
                          onChange={(e) => setRequestedDetailsText(e.target.value)}
                          placeholder="e.g. Under Section 201 Companies Act 2016, please provide signed Form 48A Consent to Act and clear NRIC copy front and back."
                          className="w-full p-2.5 rounded-xl border border-gray-200 text-xs focus:outline-none focus:border-[#062AAE]"
                        />
                      </div>

                      <button
                        type="button"
                        disabled={isSubmitting || !requestedDetailsText.trim()}
                        onClick={() => handleExecuteReview('More Details Needed')}
                        className="w-full py-2.5 px-4 rounded-xl text-xs font-bold bg-[#062AAE] hover:bg-blue-800 text-white shadow-xs transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
                      >
                        {isSubmitting ? (
                          <RefreshCw className="w-4 h-4 animate-spin" />
                        ) : (
                          <HelpCircle className="w-4 h-4" />
                        )}
                        <span>Send Query to Client</span>
                      </button>
                    </div>
                  )}

                  {!reviewAction && (
                    <p className="text-xs text-gray-400 text-center py-4">
                      Select one of the actions above (Approve, Reject, or Ask Details) to update this document's statutory review status.
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="px-6 py-3.5 border-t border-gray-100 bg-gray-50 flex items-center justify-between text-xs text-gray-500">
              <span className="font-mono">Document ID: {activeDoc.id}</span>
              <button
                type="button"
                onClick={() => {
                  setActiveDoc(null);
                  setReviewAction(null);
                }}
                className="px-4 py-2 rounded-xl border border-gray-200 text-gray-700 font-semibold hover:bg-gray-100 cursor-pointer"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default SecretaryWorkspace;
