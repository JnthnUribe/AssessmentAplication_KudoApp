import React, { useState } from 'react';
import './ProjectsView.css';
import ControlPanel from './components/panel/ControlPanel';
import InformationCard from './components/informationcard/InformationCard';
import MenuCard from './components/panel/menucard/MenuCard';
import backgroundVideo from '../../../assets/newprojectImg.mp4';

const ProjectsView = ({ onViewChange }) => {
    const [activeTab, setActiveTab] = useState('settings');
    const [filter, setFilter] = useState('todos');
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    const handleViewChange = (newView) => {
        onViewChange(newView);
        setIsMenuOpen(false);
    };

    return (
        <div className={`dashboard-container ${isMenuOpen ? 'menu-active' : ''}`}>
            <div className="dashboard-bg-image"></div>
            <video
                className={`dashboard-bg-video ${isMenuOpen ? 'visible' : ''}`}
                src={backgroundVideo}
                autoPlay
                muted
                loop
                playsInline
            />
            {!isMenuOpen && (
                <>
                    <InformationCard />

                    <div className="dashboard-right-panel">
                        {activeTab !== 'newproject' && (
                            <ControlPanel
                                isMenuOpen={isMenuOpen}
                                setIsMenuOpen={setIsMenuOpen}
                            />
                        )}

                        <main className="dashboard-main-content">
                            <h1 className="dashboard-title">Mis creaciones</h1>

                            <div className="filter-bar">
                                <button
                                    className={`filter-btn ${filter === 'todos' ? 'active' : ''}`}
                                    onClick={() => setFilter('todos')}
                                >
                                    Todos
                                </button>
                                <button
                                    className={`filter-btn ${filter === 'publicados' ? 'active' : ''}`}
                                    onClick={() => setFilter('publicados')}
                                >
                                    Publicados
                                </button>
                                <button
                                    className={`filter-btn ${filter === 'borradores' ? 'active' : ''}`}
                                    onClick={() => setFilter('borradores')}
                                >
                                    Borradores
                                </button>
                                <button
                                    className={`filter-btn ${filter === 'ocultos' ? 'active' : ''}`}
                                    onClick={() => setFilter('ocultos')}
                                >
                                    Ocultos
                                </button>
                            </div>

                            <div className="dashboard-content-area">
                                {/* Projects will be listed here later */}
                            </div>
                        </main>
                    </div>
                </>
            )}

            <MenuCard
                isOpen={isMenuOpen}
                onClose={() => setIsMenuOpen(false)}
                onViewChange={handleViewChange}
            />
        </div>
    );
};

export default ProjectsView;
