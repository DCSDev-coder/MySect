import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import Companies from './components/Companies';
import Tasks from './components/Tasks';
import Deadlines from './components/Deadlines';

function App() {
  const [activePage, setActivePage] = useState('Dashboard');

  const renderPage = () => {
    switch (activePage) {
      case 'Dashboard':
        return <Dashboard setActivePage={setActivePage} />;
      case 'Companies':
        return <Companies />;
      case 'Tasks':
        return <Tasks />;
      case 'Deadlines':
        return <Deadlines />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="flex h-screen overflow-hidden bg-[#F8F9FA]">
      <Sidebar activePage={activePage} setActivePage={setActivePage} />
      {renderPage()}
    </div>
  );
}

export default App;
