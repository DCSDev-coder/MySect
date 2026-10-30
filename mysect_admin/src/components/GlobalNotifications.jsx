import React, { useState } from 'react';
import {
  Bell, Plus, Send
} from 'lucide-react';

const GlobalNotifications = ({
  notifications = [],
  onPublishNotification
}) => {
  const [notifList, setNotifList] = useState(notifications);
  const [showModal, setShowModal] = useState(false);

  // Form states
  const [title, setTitle] = useState('');
  const [targetAudience, setTargetAudience] = useState('All Secretary Firms');
  const [priority, setPriority] = useState('High');
  const [content, setContent] = useState('');
  const [channelBanner, setChannelBanner] = useState(true);
  const [channelEmail, setChannelEmail] = useState(true);

  const handleOpenCreate = () => {
    setTitle('');
    setTargetAudience('All Secretary Firms');
    setPriority('High');
    setContent('');
    setChannelBanner(true);
    setChannelEmail(false);
    setShowModal(true);
  };

  const handlePublish = (e) => {
    e.preventDefault();
    const channels = [];
    if (channelBanner) channels.push('In-App Banner');
    if (channelEmail) channels.push('Email Notification');

    const newNotif = {
      id: 'notif-' + Math.floor(100 + Math.random() * 900),
      title,
      targetAudience,
      priority,
      channels,
      status: 'Published',
      publishDate: new Date().toISOString().replace('T', ' ').substring(0, 16),
      content,
      readCount: 0,
    };

    setNotifList([newNotif, ...notifList]);
    if (onPublishNotification) onPublishNotification(newNotif);
    setShowModal(false);
  };

  return (
    <div className="flex-1 overflow-y-auto bg-[#F8F9FA] p-4 sm:p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-gray-200 gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-[#062AAE]">
            <Bell className="w-4 h-4" />
            <span>Platform Broadcast & Regulatory Communications</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold text-gray-900 mt-1">Global Notifications & Announcements</h1>
          <p className="text-xs sm:text-sm text-gray-500">
            Publish network-wide regulatory notices, SSM MBRS scheduled maintenance advisories, and system alerts to secretary firms and mobile clients.
          </p>
        </div>

        <button
          onClick={handleOpenCreate}
          className="px-3.5 py-2 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-lg text-xs sm:text-sm font-semibold transition-colors shadow-xs flex items-center gap-2 self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Broadcast Announcement</span>
        </button>
      </div>

      {/* Notifications List */}
      <div className="mt-6 space-y-4 w-full">
        {notifList.map((notif) => (
          <div key={notif.id} className="bg-white rounded-2xl border border-gray-200 shadow-xs p-4 sm:p-6 hover:shadow-md transition-shadow">
            <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
              <div>
                <div className="flex items-center gap-2">
                  <span className={`px-2 py-0.5 text-xs font-semibold rounded-full ${notif.priority === 'High'
                      ? 'bg-rose-50 text-rose-700 border border-rose-200'
                      : 'bg-blue-50 text-[#062AAE] border border-blue-200'
                    }`}>
                    {notif.priority} Priority
                  </span>
                  <span className="text-xs font-medium text-gray-700 bg-gray-100 px-2.5 py-0.5 rounded-full">
                    Audience: {notif.targetAudience}
                  </span>
                  <span className={`px-2 py-0.5 text-xs font-medium rounded-full ${notif.status === 'Published' ? 'bg-emerald-50 text-emerald-700' : 'bg-gray-100 text-gray-600'
                    }`}>
                    {notif.status}
                  </span>
                </div>
                <h3 className="text-base font-bold text-gray-900 mt-2">{notif.title}</h3>
              </div>

              <div className="text-xs text-gray-400 sm:text-right shrink-0">
                <span>{notif.publishDate}</span>
                <div className="text-gray-500 font-medium mt-0.5">{notif.readCount} recipients viewed</div>
              </div>
            </div>

            <p className="text-xs text-gray-600 mt-3 leading-relaxed bg-gray-50 p-4 rounded-xl border border-gray-100">
              {notif.content}
            </p>

            <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-400">
              <div className="flex items-center gap-2">
                <span>Channels:</span>
                {(notif.channels || []).map((ch, idx) => (
                  <span key={idx} className="font-semibold text-gray-700 bg-gray-100 px-2 py-0.5 rounded">
                    {ch}
                  </span>
                ))}
              </div>
              <span className="text-emerald-600 font-medium">Delivered to network</span>
            </div>
          </div>
        ))}
      </div>

      {/* Modal: Create Broadcast */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-gray-200 text-xs">
            <h3 className="text-base font-bold text-gray-900">Broadcast Global Announcement</h3>
            <p className="text-gray-500 mt-1">
              Notify firms and client users about important regulatory or operational matters.
            </p>

            <form onSubmit={handlePublish} className="mt-4 space-y-4">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Announcement Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. SSM MBRS Scheduled Downtime on 25 Oct"
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Target Audience</label>
                  <select
                    value={targetAudience}
                    onChange={(e) => setTargetAudience(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="All Secretary Firms">All Secretary Firms</option>
                    <option value="All Secretary Firms & Clients">All Secretary Firms & Clients</option>
                    <option value="Firm Administrators Only">Firm Administrators Only</option>
                    <option value="Platform Operations Staff">Platform Operations Staff</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Broadcast Urgency</label>
                  <select
                    value={priority}
                    onChange={(e) => setPriority(e.target.value)}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                  >
                    <option value="High">High (Banner Pop-up)</option>
                    <option value="Normal">Normal (Standard Bulletin)</option>
                    <option value="Critical">Critical (Immediate Alert)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Notification Content</label>
                <textarea
                  rows={4}
                  required
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="Provide complete guidance, statutory reference, or downtime timetable..."
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#062AAE]"
                />
              </div>

              <div className="bg-gray-50 p-3 rounded-xl border border-gray-200 space-y-2">
                <span className="font-semibold text-gray-700 block">Dispatch Channels</span>
                <label className="flex items-center gap-2 cursor-pointer text-gray-700">
                  <input
                    type="checkbox"
                    checked={channelBanner}
                    onChange={(e) => setChannelBanner(e.target.checked)}
                    className="rounded text-[#062AAE]"
                  />
                  <span>Display In-App Banner on Web Workspaces & Mobile App</span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer text-gray-700">
                  <input
                    type="checkbox"
                    checked={channelEmail}
                    onChange={(e) => setChannelEmail(e.target.checked)}
                    className="rounded text-[#062AAE]"
                  />
                  <span>Send Direct Email to Principal / Registered Email</span>
                </label>
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
                  className="px-4 py-2 font-semibold text-white bg-[#062AAE] hover:bg-[#05228D] rounded-lg shadow-sm flex items-center gap-1.5"
                >
                  <Send className="w-3.5 h-3.5" />
                  Broadcast Immediately
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default GlobalNotifications;
