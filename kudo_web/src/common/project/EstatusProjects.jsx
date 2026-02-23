import React, { useState } from 'react';
import './EstatusProjects.css';

const EstatusProjects = ({ currentStatus, onStatusChange }) => {
    const [isOpen, setIsOpen] = useState(false);
    const statuses = ['Publicado', 'Borrador', 'Oculto'];

    const icons = {
        'Publicado': (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="status-svg">
                <path d="M20 6L9 17l-5-5" />
            </svg>
        ),
        'Borrador': (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="status-svg">
                <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" />
                <path d="M18.5 2.5a2.121 2.121 0 113 3L12 15l-4 1 1-4 9.5-9.5z" />
            </svg>
        ),
        'Oculto': (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="status-svg">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                <path d="M7 11V7a5 5 0 0110 0v4" />
            </svg>
        )
    };

    const handleToggle = (e) => {
        e.stopPropagation();
        setIsOpen(!isOpen);
    };

    const handleSelect = (status, e) => {
        e.stopPropagation();
        onStatusChange(status);
        setIsOpen(false);
    };

    const displayStatus = currentStatus || 'Borrador';
    const otherStatuses = statuses.filter(s => s !== displayStatus);

    return (
        <div className={`estatus-projects-container ${isOpen ? 'open' : ''}`}>
            <div className={`status-badge ${displayStatus.toLowerCase()}`} onClick={handleToggle}>
                <span className="status-icon">{icons[displayStatus]}</span>
                {displayStatus}
            </div>
            {isOpen && (
                <div className="status-dropdown">
                    {otherStatuses.map(status => (
                        <div
                            key={status}
                            className={`status-option ${status.toLowerCase()}`}
                            onClick={(e) => handleSelect(status, e)}
                        >
                            <span className="status-icon">{icons[status]}</span>
                            {status}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default EstatusProjects;
