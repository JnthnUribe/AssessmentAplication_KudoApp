import React, { useState } from 'react';
import './IntroductionScreen.css';
import introdImg from '../../../assets/introdImg.jpeg';
import TopBar from './topbar/TopBar';
import AuthenticationScreen from './authenticationscreen/AuthenticationScreen';

const IntroductionScreen = () => {
    const [showAuth, setShowAuth] = useState(false);

    return (
        <div
            className="introduction-screen"
            style={{ backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url(${introdImg})` }}
        >
            <div className={`intro-elements ${showAuth ? 'fade-out' : ''}`}>
                <TopBar onProfileClick={() => setShowAuth(true)} />

                <div className="hero-content">
                    <h1 className="hero-title">El mundo necesita ver lo que eres capaz de crear</h1>
                </div>

                <div className="explore-label">
                    <span>Explorar</span>
                </div>
            </div>

            {showAuth && <AuthenticationScreen onClose={() => setShowAuth(false)} />}
        </div>
    );
};

export default IntroductionScreen;
