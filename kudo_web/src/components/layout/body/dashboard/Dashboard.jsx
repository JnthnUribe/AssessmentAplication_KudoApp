import React, { useState } from 'react';
import './Dashboard.css';
import NavigationBar from './components/NavigationBar';
import ControlPanel from './components/ControlPanel';
import Home from './sections/home/Home';

import MyProjects from './sections/myprojects/MyProjects';
import NewProject from './sections/myprojects/newproject/NewProject';

const Dashboard = () => {
    const [activeTab, setActiveTab] = useState('home');

    return (
        <div className="dashboard-container">
            <NavigationBar activeTab={activeTab} onTabChange={setActiveTab} />
            {activeTab !== 'newproject' && <ControlPanel />}

            {/* Main Content */}
            <main className="dashboard-main-content">
                {activeTab === 'home' && <Home />}
                {activeTab === 'projects' && <MyProjects />}
                {activeTab === 'settings' && <div>Configuración Content</div>}
                {activeTab === 'newproject' && <NewProject onCancel={() => setActiveTab('home')} />}
            </main>
        </div>
    );
};

export default Dashboard;
