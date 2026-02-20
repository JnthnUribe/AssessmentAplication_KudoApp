import React, { useState, useEffect } from 'react';
import './NewProject.css';
import ProjectCard from '../../../../../../common/ProjectCard';
import ProjectDetails from './ProjectDetails';
import { projectService } from '../../../../../../services/projectService';

const NewProject = () => {
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedProject, setSelectedProject] = useState(null);

    useEffect(() => {
        const fetchProjects = async () => {
            try {
                const userStr = localStorage.getItem('user');
                if (userStr) {
                    const user = JSON.parse(userStr);
                    const userId = user.id || user.Id;
                    if (userId) {
                        const data = await projectService.getByCreatorId(userId);
                        setProjects(data);
                    }
                }
            } catch (error) {
                console.error('Error loading projects:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchProjects();
    }, []);

    const handleProjectClick = (project) => {
        setSelectedProject(project);
    };

    const handleCloseDetails = () => {
        setSelectedProject(null);
    };

    return (
        <div className="home-section">
            <div className="home-header">
                <h2 className="section-title">Mis Proyectos</h2>
                <div className="filter-buttons">
                    <button className="filter-btn active">Todos</button>
                    <button className="filter-btn">Publicados</button>
                    <button className="filter-btn">Borradores</button>
                    <button className="filter-btn">Ocultos</button>
                </div>
            </div>

            {loading ? (
                <div style={{ textAlign: 'center', padding: '2rem', color: '#666' }}>Cargando proyectos...</div>
            ) : projects.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '4rem', color: '#999' }}>
                    <p>No tienes proyectos creados aún.</p>
                </div>
            ) : (
                <div className="projects-grid">
                    {projects.map((project) => (
                        <ProjectCard
                            key={project.id || project.Id}
                            project={project}
                            onClick={() => handleProjectClick(project)}
                        />
                    ))}
                </div>
            )}

            {/* Project Details Side Panel */}
            {selectedProject && (
                <ProjectDetails
                    project={selectedProject}
                    onClose={handleCloseDetails}
                />
            )}
        </div>
    );
};

export default NewProject;
