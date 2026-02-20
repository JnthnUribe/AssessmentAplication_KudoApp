import React from 'react';
import './ProjectCard.css';

const ProjectCard = ({ project, onClick }) => {
    const { identity, status, platform, narrative, techStack, media } = project;
    const coverImage = media?.imageUrls?.[0] || 'https://via.placeholder.com/300x150?text=No+Image';

    return (
        <div className="project-card" onClick={onClick}>
            <div className="project-card-image" style={{ backgroundImage: `url(${coverImage})` }}>
                <span className={`project-status status-${status.toLowerCase().replace(/\s+/g, '-')}`}>
                    {status}
                </span>
            </div>
            <div className="project-card-content">
                <div className="project-card-header">
                    <h3 className="project-title">{identity.title}</h3>
                    <span className="project-category">{identity.category}</span>
                </div>

                <p className="project-platform">{platform}</p>

                <p className="project-description">
                    {narrative.problem.length > 100
                        ? `${narrative.problem.substring(0, 100)}...`
                        : narrative.problem}
                </p>

                <div className="project-tech-stack">
                    {techStack.slice(0, 3).map((tech, index) => (
                        <span key={index} className="tech-badge">{tech}</span>
                    ))}
                    {techStack.length > 3 && <span className="tech-badge-more">+{techStack.length - 3}</span>}
                </div>
            </div>
        </div>
    );
};

export default ProjectCard;
