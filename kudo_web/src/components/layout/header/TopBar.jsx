import React from 'react';
import { useNavigate } from 'react-router-dom';
import './TopBar.css';
import reactLogo from '../../../assets/react.svg';

const TopBar = ({ activeSection, onNavigate }) => {
    const navigate = useNavigate();

    return (
        <header className="top-bar">
            <div className="logo-section">
                <img src={reactLogo} alt="EduPortal Logo" className="logo-icon" />
                <span>Kudo</span>
            </div>
            <nav className="nav-links">
                <button
                    className={`nav-button ${activeSection === 'about' ? 'active' : ''}`}
                    onClick={() => onNavigate('about')}
                >
                    Acerca de
                </button>
                <button
                    className={`nav-button ${activeSection === 'opportunities' ? 'active' : ''}`}
                    onClick={() => onNavigate('opportunities')}
                >
                    Oportunidades
                </button>
                <button
                    className={`nav-button ${activeSection === 'objectives' ? 'active' : ''}`}
                    onClick={() => onNavigate('objectives')}
                >
                    Objetivos
                </button>
            </nav>

            <div className="cta-section">
                <button
                    className="profile-button"
                    aria-label="Profile"
                    onClick={() => navigate('/login')}
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </button>
            </div>
        </header>
    );
};

export default TopBar;
