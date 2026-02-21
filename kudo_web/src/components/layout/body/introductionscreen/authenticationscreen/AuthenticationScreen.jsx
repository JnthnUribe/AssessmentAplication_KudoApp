import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import InputForms from './InputForms';
import './AuthenticationScreen.css';

const AuthenticationScreen = ({ onClose }) => {
    const navigate = useNavigate();
    const [isRegistering, setIsRegistering] = useState(false);

    const handleClose = () => {
        if (onClose) {
            onClose();
        } else {
            navigate('/');
        }
    };

    const toggleMode = () => {
        setIsRegistering(!isRegistering);
    };

    return (
        <div className="authentication-screen">
            <button className="back-button" onClick={handleClose}>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M19 12H5"></path>
                    <polyline points="12 19 5 12 12 5"></polyline>
                </svg>
                Volver
            </button>

            <div className="auth-container">
                <div className="auth-left-content">
                    <h1 className="auth-hero-title">
                        {isRegistering ? 'Bienvenido a tu nueva sesión' : 'Iniciar sesión'}
                    </h1>
                    <p className="auth-hero-subtitle">
                        {isRegistering ? 'Una cuenta. Infinitas posibilidades.' : '¿Listo para que el mundo vea lo que construiste?'}
                    </p>
                </div>

                <div className="auth-card">
                    <InputForms isRegistering={isRegistering} toggleMode={toggleMode} />
                </div>
            </div>
        </div>
    );
};

export default AuthenticationScreen;
