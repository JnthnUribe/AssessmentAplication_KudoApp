import React from 'react';
import { useNavigate } from 'react-router-dom';
import './MenuCard.css';

const MenuCard = ({ isOpen, onClose, onViewChange }) => {
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            // Notify server about logout
            await authService.logout();
            // Clear tokens/session
            localStorage.removeItem('user');
            navigate('/');
            onClose();
        } catch (error) {
            console.error('Error during logout:', error);
        }
    };

    return (
        <div className={`menu-card-overlay ${isOpen ? 'open' : ''}`} onClick={onClose}>
            <div
                className={`menu-card ${isOpen ? 'open' : ''}`}
                onClick={(e) => e.stopPropagation()}
            >
                <div className="menu-card-header">
                    <button className="close-menu-btn" onClick={onClose}>
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                        </svg>
                    </button>
                </div>
                <div className="menu-card-content">
                    <ul className="menu-options-list">
                        <li className="menu-option" onClick={() => { onViewChange('projects'); onClose(); }}>Ver mi perfil</li>
                        <li className="menu-option" onClick={() => { onViewChange('projects'); onClose(); }}>Ver mis proyectos</li>
                        <li className="menu-option" onClick={() => { onViewChange('new-project'); onClose(); }}>Crear nuevo proyecto</li>
                        <li className="menu-option">Revisar notificaciones</li>
                    </ul>

                    <div className="menu-footer">
                        <button className="logout-btn" onClick={handleLogout}>
                            Cerrar sesión
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MenuCard;
