import React from 'react';
import { Building2, ClipboardList, AlertTriangle, CalendarDays, Activity, CheckCircle2, UserPlus, FileUp, AlertCircle, TrendingUp, ArrowRight } from 'lucide-react';

const StatCard = ({ title, value, icon: Icon, trendIcon: Trend, isAlert }) => (
  <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex flex-col justify-between h-full">
    <div className="flex justify-between items-start mb-4">
      <div className={`p-2.5 rounded-lg ${isAlert ? 'bg-red-50 text-red-600' : 'bg-gray-900 text-white'}`}>
        <Icon className="w-5 h-5" />
      </div>
      {Trend && <Trend className={`w-4 h-4 ${isAlert ? 'text-red-500' : 'text-emerald-500'}`} />}
    </div>
    <div>
      <h3 className={`text-3xl font-bold mb-1 ${isAlert ? 'text-red-600' : 'text-gray-900'}`}>{value}</h3>
      <p className="text-sm font-medium text-gray-500">{title}</p>
    </div>
  </div>
);

const CompanyHealthCard = ({ name, id, status, overdue }) => {
  const getStatusStyles = () => {
    switch(status) {
      case 'Active': return 'bg-[#E8F5E9] text-[#2E7D32]';
      case 'Needs Attention': return 'bg-red-50 text-red-600';
      case 'Fair': return 'bg-[#FFF7A3] text-[#FF8A00]';
      case 'Dormant': return 'bg-gray-100 text-gray-600';
      default: return 'bg-gray-100 text-gray-600';
    }
  };

  return (
    <div className="p-4 border border-gray-100 rounded-xl mb-3 flex items-center justify-between hover:border-gray-200 transition-colors bg-white">
      <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-lg bg-red-50 flex items-center justify-center text-red-600">
          <Building2 className="w-5 h-5" />
        </div>
        <div>
          <h4 className="font-semibold text-gray-900">{name}</h4>
          <div className="flex items-center text-xs text-gray-500 mt-1 gap-2">
            <span>{id}</span>
            {overdue && (
              <>
                <span>•</span>
                <span className="text-red-600 font-medium">{overdue} overdue</span>
              </>
            )}
          </div>
        </div>
      </div>
      <div className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusStyles()}`}>
        {status}
      </div>
    </div>
  );
};

const ActivityItem = ({ title, subtitle, icon: Icon, iconBg }) => (
  <div className="flex gap-4 mb-6 relative">
    <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 z-10 ${iconBg}`}>
      <Icon className="w-4 h-4" />
    </div>
    <div className="flex-1 pb-1">
      <p className="text-sm font-medium text-gray-900">{title}</p>
      <p className="text-xs text-gray-500 mt-0.5">{subtitle}</p>
    </div>
  </div>
);

const Dashboard = ({ setActivePage }) => {
  return (
    <div className="flex-1 bg-[#F8F9FA] overflow-y-auto">
      <div className="max-w-6xl mx-auto p-8">
        
        {/* Header */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-2 tracking-tight">Good morning, Sarah</h2>
          <p className="text-gray-500">
            Data Center Specialists Sdn Bhd (M) — Monday, 28 September 2026
          </p>
        </div>

        {/* Alert Banner */}
        <div className="bg-red-50 border border-red-100 rounded-xl p-4 flex items-center justify-between mb-8">
          <div className="flex items-center gap-3 text-red-600">
            <AlertTriangle className="w-5 h-5" />
            <span className="font-semibold">4 overdue items require attention</span>
          </div>
          <button onClick={() => setActivePage('Deadlines')} className="bg-[#D71920] hover:bg-red-700 text-white px-5 py-2 rounded-lg text-sm font-medium transition-colors">
            Review
          </button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard title="Companies" value="4" icon={Building2} trendIcon={TrendingUp} />
          <StatCard title="Pending Tasks" value="5" icon={ClipboardList} trendIcon={TrendingUp} />
          <StatCard title="Overdue Items" value="4" icon={AlertTriangle} trendIcon={AlertTriangle} isAlert />
          <StatCard title="Upcoming Deadlines" value="0" icon={CalendarDays} trendIcon={TrendingUp} />
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          {/* Company Health */}
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <div className="flex justify-between items-center mb-6">
              <h3 className="font-bold text-gray-900 text-lg">Company Health</h3>
              <a href="#" onClick={(e) => { e.preventDefault(); setActivePage('Companies'); }} className="text-sm text-gray-500 font-medium hover:text-gray-900 flex items-center gap-1">
                View all <ArrowRight className="w-4 h-4" />
              </a>
            </div>
            
            <CompanyHealthCard 
              name="Data Center Specialists Sdn Bhd (M)" 
              id="202301001234" 
              status="Needs Attention" 
              overdue="1" 
            />
            <CompanyHealthCard 
              name="C2 Coffee + Candle" 
              id="202201005678" 
              status="Fair" 
            />
            <CompanyHealthCard 
              name="5Luxe Scents Co." 
              id="202001009012" 
              status="Active" 
            />
            <CompanyHealthCard 
              name="Test Enterprise" 
              id="202401003456" 
              status="Dormant" 
            />
          </div>

          {/* Recent Activity */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 relative overflow-hidden">
            <h3 className="font-bold text-gray-900 text-lg mb-6">Recent Activity</h3>
            
            <div className="absolute left-[38px] top-[80px] bottom-10 w-0.5 bg-gray-100"></div>

            <div className="relative">
              <ActivityItem 
                title="Share Transfer marked as completed"
                subtitle="Sarah Ahmad · 25 Apr 2026, 5:30 PM"
                icon={CheckCircle2}
                iconBg="bg-orange-50 text-orange-500"
              />
              <ActivityItem 
                title="New director added for Data Center Specialists"
                subtitle="Sarah Ahmad · 24 Apr 2026, 10:15 PM"
                icon={UserPlus}
                iconBg="bg-blue-50 text-[#062AAE]"
              />
              <ActivityItem 
                title="Board Resolution uploaded — C2 Coffee"
                subtitle="Farah Izzati · 23 Apr 2026, 7:00 PM"
                icon={Activity}
                iconBg="bg-gray-100 text-gray-600"
              />
              <ActivityItem 
                title="AGM Preparation started for 5Luxe Scents"
                subtitle="David Wong · 23 Apr 2026, 12:45 AM"
                icon={FileUp}
                iconBg="bg-orange-50 text-orange-500"
              />
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default Dashboard;
