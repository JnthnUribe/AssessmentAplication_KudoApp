import React, { useState } from 'react';
import './NewProjectView.css';
import ControlPanel from './components/panel/ControlPanel';
import NewProjectInfo from './components/informationcard/newprojectinfo/NewProjectInfo';
import NewProjectInputs from '../../../common/input/NewProjectInputs';
import MenuCard from './components/panel/menucard/MenuCard';
import backgroundVideo from '../../../assets/newprojectImg.mp4';
import creationImg from '../../../assets/creationImg.jpeg';

const NewProjectView = ({ onViewChange }) => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [activeSection, setActiveSection] = useState('identidad');
    const [formData, setFormData] = useState({
        identity: { title: '', category: '' },
        narrative: { problem: '', roleDescription: '' },
        techStack: [],
        outcomes: { results: [], learnings: [] },
        media: { imageUrls: [], videoUrl: '', links: [] }
    });

    const handleViewChange = (newView) => {
        onViewChange(newView);
        setIsMenuOpen(false);
    };

    const handleInputChange = (section, field, value) => {
        setFormData(prev => ({
            ...prev,
            [section]: {
                ...prev[section],
                [field]: value
            }
        }));
    };

    const getSectionStatuses = () => {
        const statuses = {};

        // Identidad validation
        const idFilled = [formData.identity.title, formData.identity.category].filter(v => v.trim() !== '').length;
        statuses.identidad = idFilled === 2 ? 'completed' : idFilled > 0 ? 'partial' : 'empty';

        // Narrativa validation
        const narFilled = [formData.narrative.problem, formData.narrative.roleDescription].filter(v => v.trim() !== '').length;
        statuses.narrativa = narFilled === 2 ? 'completed' : narFilled > 0 ? 'partial' : 'empty';

        // Add more validations as they are implemented
        statuses.tecnologia = 'empty';
        statuses.resultados = 'empty';
        statuses.multimedia = 'empty';
        statuses.revision = 'empty';

        return statuses;
    };

    const sectionStatuses = getSectionStatuses();

    return (
        <div className={`dashboard-container ${isMenuOpen ? 'menu-active' : ''}`}>
            <div
                className="dashboard-bg-image"
                style={{ backgroundImage: `url(${creationImg})` }}
            ></div>
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
                    <aside className="information-card">
                        <NewProjectInfo
                            activeSection={activeSection}
                            onSectionChange={setActiveSection}
                            sectionStatuses={sectionStatuses}
                        />
                    </aside>

                    <div className="dashboard-right-panel">
                        <ControlPanel
                            isMenuOpen={isMenuOpen}
                            setIsMenuOpen={setIsMenuOpen}
                        />

                        <main className="dashboard-main-content">
                            <NewProjectInputs
                                activeSection={activeSection}
                                formData={formData}
                                onInputChange={handleInputChange}
                            />
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

export default NewProjectView;
