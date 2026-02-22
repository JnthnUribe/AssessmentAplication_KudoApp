import React from 'react';
import './ControlPanel.css';

import Search from './Search';
const ControlPanel = ({ isMenuOpen, setIsMenuOpen }) => {
    const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

    return (
        <header className="control-panel">
            <div className="right-section">
                <Search placeholder="Buscar proyectos, tareas..." />
                <button className="control-btn menu-button" onClick={toggleMenu}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <line x1="3" y1="12" x2="21" y2="12"></line>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <line x1="3" y1="18" x2="21" y2="18"></line>
                    </svg>
                </button>
            </div>
        </header>
    );
};

export default ControlPanel;
