import React, { useState } from 'react';
import './NewProjectView.css';
import ControlPanel from './components/panel/ControlPanel';
import NewProjectInfo from './components/informationcard/newprojectinfo/NewProjectInfo';
import NewProjectInputs from '../../../common/input/NewProjectInputs';
import MenuCard from './components/panel/menucard/MenuCard';
import backgroundVideo from '../../../assets/newprojectImg.mp4';
import creationImg from '../../../assets/creationImg.jpeg';
import { projectService } from '../../../services/projectService';

const NewProjectView = ({ onViewChange }) => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [activeSection, setActiveSection] = useState('identidad');
    const [formData, setFormData] = useState({
        identity: { title: '', category: '', platform: 'Web' },
        narrative: { problem: '', roleDescription: '' },
        techStack: [],
        outcomes: { results: '', learnings: '' },
        media: { images: [], videoUrl: '', links: [] }
    });

    const handleViewChange = (newView) => {
        onViewChange(newView);
        setIsMenuOpen(false);
    };

    const handleInputChange = (section, field, value) => {
        setFormData(prev => {
            if (field === null) {
                return { ...prev, [section]: value };
            }
            return {
                ...prev,
                [section]: {
                    ...prev[section],
                    [field]: value
                }
            };
        });
    };

    const handleSaveProject = async (status) => {
        try {
            const user = JSON.parse(localStorage.getItem('user'));
            if (!user || !user.id) {
                alert('Sesión no válida. Por favor, inicia sesión de nuevo.');
                return;
            }

            // Transform outcomes from strings to arrays as expected by backend
            const payload = {
                creatorId: user.id,
                status: status,
                identity: {
                    title: formData.identity.title,
                    category: formData.identity.category,
                    platform: formData.identity.platform
                },
                narrative: {
                    problem: formData.narrative.problem,
                    roleDescription: formData.narrative.roleDescription
                },
                techStack: formData.techStack,
                outcomes: {
                    results: formData.outcomes.results.split('\n').filter(r => r.trim() !== ''),
                    learnings: formData.outcomes.learnings.split('\n').filter(l => l.trim() !== '')
                },
                media: {
                    images: formData.media.images,
                    videoUrl: formData.media.videoUrl,
                    links: formData.media.links || []
                }
            };

            const response = await projectService.create(payload);
            console.log('Project saved:', response);
            alert(`Proyecto ${status === 'Publicado' ? 'publicado' : 'guardado como borrador'} con éxito.`);

            if (onViewChange) onViewChange('projects');
        } catch (error) {
            console.error('Error saving project:', error);
            alert('Error al guardar el proyecto: ' + error.message);
        }
    };

    const getSectionStatuses = () => {
        const statuses = {};

        // Identidad validation
        const hasTitle = formData.identity.title.trim() !== '';
        const hasCategory = formData.identity.category.trim() !== '';
        const hasPlatform = formData.identity.platform.trim() !== '';
        statuses.identidad = (hasTitle && hasCategory && hasPlatform) ? 'completed' : (hasTitle || hasCategory) ? 'partial' : 'empty';

        // Narrativa validation
        const narFilled = [formData.narrative.problem, formData.narrative.roleDescription].filter(v => v.trim() !== '').length;
        statuses.narrativa = narFilled === 2 ? 'completed' : narFilled > 0 ? 'partial' : 'empty';

        // Add more validations as they are implemented
        statuses.tecnologia = (formData.techStack && formData.techStack.length > 0) ? 'completed' : 'empty';
        // Outcomes validation
        const outFilled = [formData.outcomes.results, formData.outcomes.learnings].filter(v => v.trim() !== '').length;
        statuses.resultados = outFilled === 2 ? 'completed' : outFilled > 0 ? 'partial' : 'empty';

        // Multimedia validation
        const hasImages = formData.media.images && formData.media.images.length > 0;
        const hasVideo = formData.media.videoUrl && formData.media.videoUrl.trim() !== '';
        statuses.multimedia = (hasImages || hasVideo) ? 'completed' : 'empty';

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
                autoPlay
                muted
                loop
                playsInline
                preload="auto"
            >
                <source src={backgroundVideo} type="video/mp4" />
                Tu navegador no soporta video.
            </video>
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
                                onSave={handleSaveProject}
                                sectionStatuses={sectionStatuses}
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
