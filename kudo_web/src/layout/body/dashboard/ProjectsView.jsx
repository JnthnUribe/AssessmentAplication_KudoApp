import React, { useState, useEffect } from 'react';
import './ProjectsView.css';
import ControlPanel from './components/panel/ControlPanel';
import InformationCard from './components/informationcard/InformationCard';
import MenuCard from './components/panel/menucard/MenuCard';
import ProjectCard from '../../../common/project/ProjectCard'; // Import ProjectCard
import SpecificProjectView from './SpecificProjectView'; // Import SpecificProjectView
import { projectService } from '../../../services/projectService'; // Import projectService
import backgroundVideo from '../../../assets/newprojectImg.mp4';

const ProjectsView = ({ onViewChange }) => {
    const [activeTab, setActiveTab] = useState('settings');
    const [filter, setFilter] = useState('todos');
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedProject, setSelectedProject] = useState(null);
    const [isPreviewOpen, setIsPreviewOpen] = useState(false);

    useEffect(() => {
        const fetchProjects = async () => {
            try {
                setLoading(true);
                const user = JSON.parse(localStorage.getItem('user'));
                if (!user || !user.id) {
                    console.error('No user found in session');
                    setLoading(false);
                    return;
                }

                const data = await projectService.getByCreatorId(user.id);
                setProjects(data);
            } catch (error) {
                console.error('Error fetching projects:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchProjects();
    }, []);

    const handleViewChange = (newView) => {
        onViewChange(newView);
        setIsMenuOpen(false);
    };

    const handleProjectClick = (project) => {
        setSelectedProject(project);
        setIsPreviewOpen(true);
    };

    const handleProjectUpdate = (updatedProject) => {
        // Update the projects list in-place
        setProjects(prevProjects =>
            prevProjects.map(p => p.id === updatedProject.id ? updatedProject : p)
        );
        // Update the currently selected project for the details view
        setSelectedProject(updatedProject);
    };

    const filteredProjects = projects.filter(project => {
        const currentStatus = project.status || project.Status || 'Borrador';
        if (filter === 'todos') return true;
        if (filter === 'publicados') return currentStatus === 'Publicado';
        if (filter === 'borradores') return currentStatus === 'Borrador' || !currentStatus;
        if (filter === 'ocultos') return currentStatus === 'Oculto';
        return true;
    });

    return (
        <div className={`dashboard-container ${isMenuOpen || isPreviewOpen ? 'menu-active' : ''}`}>
            <div className="dashboard-bg-image"></div>
            <video
                className={`dashboard-bg-video ${isMenuOpen || isPreviewOpen ? 'visible' : ''}`}
                autoPlay
                muted
                loop
                playsInline
                preload="auto"
            >
                <source src={backgroundVideo} type="video/mp4" />
                Tu navegador no soporta video.
            </video>
            {(!isMenuOpen && !isPreviewOpen) && (
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

                            <div className="cards-scroll-container">
                                {loading ? (
                                    <div className="loading-state">Cargando proyectos...</div>
                                ) : filteredProjects.length > 0 ? (
                                    <div className="projects-list">
                                        {filteredProjects.map(project => (
                                            <ProjectCard
                                                key={project.id}
                                                project={project}
                                                onClick={() => handleProjectClick(project)}
                                            />
                                        ))}
                                    </div>
                                ) : (
                                    <div className="no-projects-state">
                                        No se encontraron proyectos en esta categoría.
                                    </div>
                                )}
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

            <SpecificProjectView
                project={selectedProject}
                isOpen={isPreviewOpen}
                onClose={() => setIsPreviewOpen(false)}
                onUpdate={handleProjectUpdate}
            />
        </div>
    );
};

export default ProjectsView;
