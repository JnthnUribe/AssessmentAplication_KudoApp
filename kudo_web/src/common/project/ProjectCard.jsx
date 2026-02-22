import React from 'react';
import './ProjectCard.css';

const ProjectCard = ({ project, onClick }) => {
    const { identity, status, platform, narrative, techStack, media } = project;
    const coverImage = media?.imageUrls?.[0] || 'https://placehold.co/600x400/222/fff?text=Kudo+Project';

    return (
        <div className="project-card-horizontal" onClick={onClick}>
            <div
                className="project-card-image-section"
                style={{ backgroundImage: `url(${coverImage})` }}
            >
                <div className="project-status-badge">
                    {status || 'Borrador'}
                </div>
            </div>

            <div className="project-card-info-section">
                <div className="project-card-header">
                    <span className="project-category-tag">{identity?.category || 'General'}</span>
                    <span className="project-platform-tag">{identity?.platform || 'Web'}</span>
                </div>

                <h3 className="project-card-title">{identity?.title || 'Título del Proyecto'}</h3>

                <p className="project-card-description">
                    {narrative?.problem || 'Sin descripción disponible del problema.'}
                </p>

                <div className="project-card-tech-list">
                    {techStack?.slice(0, 4).map((tech, index) => (
                        <span key={index} className="tech-pill-small">{tech}</span>
                    ))}
                    {techStack?.length > 4 && (
                        <span className="tech-pill-more">+{techStack.length - 4}</span>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ProjectCard;
