import React from 'react';
import './ControlPanel.css';

import Search from './Search';

const ControlPanel = () => {
    const [user, setUser] = React.useState(null);

    React.useEffect(() => {
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
            setUser(JSON.parse(storedUser));
        }
    }, []);

    const displayName = user ? `${user.firstName} ${user.firstSurname}` : 'Usuario';

    return (
        <header className="control-panel">
            <h2 className="control-panel-title">Panel de Control</h2>
            <Search placeholder="Buscar proyectos, tareas..." />

            <div className="profile-section">
                <span className="profile-name">{displayName}</span>
                <div className="profile-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                </div>
            </div>
        </header>
    );
};

export default ControlPanel;
