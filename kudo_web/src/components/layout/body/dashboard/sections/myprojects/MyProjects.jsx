import React, { useState, useEffect } from 'react';
import './MyProjects.css';
import ProjectCard from '../../../../../../common/project/ProjectCard';
import ProjectDetails from '../../../../../../common/project/ProjectDetails';
import EditProject from './editproject/EditProject';
import { projectService } from '../../../../../../services/projectService';

const MyProjects = () => {
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedProject, setSelectedProject] = useState(null);
    const [isEditing, setIsEditing] = useState(false);
    const [projectToEdit, setProjectToEdit] = useState(null);

    const [filter, setFilter] = useState('Todos');

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

    const handleEditProject = (project) => {
        setProjectToEdit(project);
        setIsEditing(true);
        setSelectedProject(null); // Close details modal
    };

    const handleCancelEdit = () => {
        setIsEditing(false);
        setProjectToEdit(null);
    };

    const handleSaveEdit = () => {
        setIsEditing(false);
        setProjectToEdit(null);
        // Refresh projects list
        window.location.reload(); // Simple reload to fetch updated data, or refetch
    };

    const filteredProjects = projects.filter(project => {
        if (filter === 'Todos') return true;

        // Normalize status for comparison logic if needed, 
        // assuming database stores 'Publicado', 'Borrador', 'Oculto' matching the buttons roughly
        // If the DB stores 'Published', 'Draft', etc., we need a mapping.
        // Based on previous code, status seemed to be 'Publicado', 'En Progreso', etc.

        // Let's implement a safe check:
        const status = project.status || '';

        if (filter === 'Publicados') return status === 'Publicado';
        if (filter === 'Borradores') return status === 'Borrador';
        if (filter === 'Ocultos') return status === 'Oculto';

        return true;
    });

    if (isEditing) {
        return (
            <EditProject
                project={projectToEdit}
                onCancel={handleCancelEdit}
                onSave={handleSaveEdit}
            />
        );
    }

    return (
        <div className="home-section">
            <div className="home-header">
                <h2 className="section-title">Mis Proyectos</h2>
                <div className="filter-buttons">
                    <button
                        className={`filter-btn ${filter === 'Todos' ? 'active' : ''}`}
                        onClick={() => setFilter('Todos')}
                    >
                        Todos
                    </button>
                    <button
                        className={`filter-btn ${filter === 'Publicados' ? 'active' : ''}`}
                        onClick={() => setFilter('Publicados')}
                    >
                        Publicados
                    </button>
                    <button
                        className={`filter-btn ${filter === 'Borradores' ? 'active' : ''}`}
                        onClick={() => setFilter('Borradores')}
                    >
                        Borradores
                    </button>
                    <button
                        className={`filter-btn ${filter === 'Ocultos' ? 'active' : ''}`}
                        onClick={() => setFilter('Ocultos')}
                    >
                        Ocultos
                    </button>
                </div>
            </div>

            {loading ? (
                <div style={{ textAlign: 'center', padding: '2rem', color: '#666' }}>Cargando proyectos...</div>
            ) : filteredProjects.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '4rem', color: '#999' }}>
                    <p>No hay proyectos en esta categoría.</p>
                </div>
            ) : (
                <div className="projects-grid">
                    {filteredProjects.map((project) => (
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
                    onEdit={handleEditProject}
                />
            )}
        </div>
    );
};

export default MyProjects;
