import React, { useState } from 'react';
import './ProjectCard.css';
import EstatusProjects from './EstatusProjects';
import { projectService } from '../../services/projectService';

const ProjectCard = ({ project, onClick }) => {
    // Normalize project properties to handle potential PascalCase/camelCase discrepancies
    const normalizedMedia = project.media || project.Media || {};
    const normalizedIdentity = project.identity || project.Identity || {};
    const normalizedNarrative = project.narrative || project.Narrative || {};
    const normalizedTechStack = project.techStack || project.TechStack || [];

    // Check both casings for status
    const initialStatus = project.status || project.Status || 'Borrador';
    const [status, setStatus] = useState(initialStatus);

    // Get images from the new structure or legacy imageUrls, checking both casings for sub-properties
    const images = normalizedMedia.images || normalizedMedia.Images || [];
    const imageUrls = normalizedMedia.imageUrls || normalizedMedia.ImageUrls || [];

    // Be EXTREMELY defensive with the cover image URL
    const firstImage = images[0] || {};
    const firstImageUrl = firstImage.url || firstImage.Url || imageUrls[0] || '';
    const coverImage = firstImageUrl || 'https://placehold.co/600x400/222/fff?text=Kudo+Project';

    const handleStatusChange = async (newStatus) => {
        try {
            // Update local state first for responsiveness
            const prevStatus = status;
            setStatus(newStatus);

            // Prepare update payload (full object as required by backend)
            const updatedProject = { ...project, status: newStatus };

            await projectService.update(project.id, updatedProject);
            console.log(`Status successfully updated to: ${newStatus} for project: ${project.id}`);
        } catch (error) {
            console.error('Failed to update status in database:', error);
            // Optional: revert state on failure
            // setStatus(prevStatus);
            alert('Error al actualizar el estado en el servidor. Inténtalo de nuevo.');
        }
    };

    return (
        <div className="project-card-horizontal" onClick={onClick}>
            <div className="project-status-container" onClick={(e) => e.stopPropagation()}>
                <EstatusProjects
                    currentStatus={status}
                    onStatusChange={handleStatusChange}
                />
            </div>
            <div className="project-card-image-section">
                <div
                    className="project-image-wrapper"
                    style={{ backgroundImage: `url(${coverImage})` }}
                >
                </div>
            </div>

            <div className="project-card-info-section">
                <h3 className="project-card-title">
                    {normalizedIdentity.title || normalizedIdentity.Title || 'Título del Proyecto'}
                </h3>

                <p className="project-card-description">
                    {normalizedNarrative.problem || normalizedNarrative.Problem || 'Sin descripción disponible del problema.'}
                </p>

                <div className="project-card-tech-list">
                    {normalizedTechStack.slice(0, 4).map((tech, index) => (
                        <span key={index} className="tech-pill-small">{tech}</span>
                    ))}
                    {normalizedTechStack.length > 4 && (
                        <span className="tech-pill-more">+{normalizedTechStack.length - 4}</span>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ProjectCard;
