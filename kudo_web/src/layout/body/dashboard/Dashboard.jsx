import React, { useState } from 'react';
import './Dashboard.css';
import ProjectsView from './ProjectsView';
import NewProjectView from './NewProjectView';

const Dashboard = () => {
    const [view, setView] = useState('projects');

    return (
        <>
            {view === 'projects' ? (
                <ProjectsView onViewChange={setView} />
            ) : (
                <NewProjectView onViewChange={setView} />
            )}
        </>
    );
};

export default Dashboard;
