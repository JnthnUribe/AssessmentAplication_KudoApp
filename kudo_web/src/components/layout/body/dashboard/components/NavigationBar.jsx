import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import './NavigationBar.css';

const NavigationBar = ({ activeTab, onTabChange }) => {
    const navigate = useNavigate();
    // const location = useLocation(); // No longer needed for internal nav

    const isActive = (tab) => activeTab === tab;

    const NavItem = ({ tab, label }) => (
        <li className="nav-item">
            <div
                className={`nav-link ${isActive(tab) ? 'active' : ''}`}
                onClick={() => onTabChange(tab)}
            >
                <span className="nav-text">{label}</span>
            </div>
        </li>
    );

    return (
        <nav className="dashboard-sidebar">
            <div className="sidebar-header">
                <div className="logo-container">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="logo-icon"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                    <h1 className="sidebar-logo">Kudo</h1>
                </div>
            </div>

            <ul className="nav-list">
                <NavItem
                    tab="home"
                    label="Home"
                />
                <NavItem
                    tab="projects"
                    label="Mis Proyectos"
                />
                <NavItem
                    tab="settings"
                    label="Configuración"
                />
            </ul>

            <div className="sidebar-footer">
                <button
                    className="new-project-btn"
                    title="Nuevo Proyecto"
                    onClick={() => onTabChange('newproject')}
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <line x1="12" y1="5" x2="12" y2="19"></line>
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                    </svg>
                    <span className="nav-text">Nuevo proyecto</span>
                </button>
            </div>
        </nav>
    );
};

export default NavigationBar;
