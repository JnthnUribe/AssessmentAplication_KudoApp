import React from 'react';
import './TopBar.css';

const TopBar = ({ onProfileClick }) => {
    return (
        <div className="topbar">
            <div className="topbar-left">
                <div className="topbar-logo">
                    Kudo
                </div>
                <nav className="topbar-nav">
                    <a href="#home" className="nav-item">Home</a>
                    <a href="#demuestra" className="nav-item">Comienza aquí</a>
                </nav>
            </div>
            <div className="topbar-right">
                <a href="#profile" className="profile-btn" aria-label="Profile" onClick={(e) => { e.preventDefault(); onProfileClick?.(); }}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </a>
            </div>
        </div>
    );
};

export default TopBar;
