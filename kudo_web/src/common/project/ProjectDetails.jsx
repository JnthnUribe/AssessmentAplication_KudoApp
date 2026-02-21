import React, { useEffect } from 'react';
import './ProjectDetails.css';
import TechStackCarousel from '../TechStackCarousel';

const ProjectDetails = ({ project, onClose, onEdit }) => {

    // Close on escape key
    useEffect(() => {
        const handleEsc = (e) => {
            if (e.key === 'Escape') onClose();
        };
        window.addEventListener('keydown', handleEsc);
        return () => window.removeEventListener('keydown', handleEsc);
    }, [onClose]);

    if (!project) return null;

    const { identity, narrative, techStack, outcomes, media, status, platform } = project;

    return (
        <div className="project-details-overlay" onClick={onClose}>
            <div className="project-details-panel" onClick={(e) => e.stopPropagation()}>
                <button className="btn-close-details" onClick={onClose}>
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M18 6L6 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                        <path d="M6 6L18 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    </svg>
                </button>
                <div className="details-cover-placeholder">
                    <div className="details-cover-content">
                        <h2 className="details-title">{identity.title}</h2>
                        <span className="details-category-pill">{identity.category.toUpperCase()} | {platform.toUpperCase()}</span>
                    </div>
                </div>

                {/* Tech Stack Carousel */}
                <TechStackCarousel techs={techStack} />

                <div className="details-content">

                    {/* Narrative Section */}
                    <div className="details-section">
                        <h3 className="details-section-title">EL PROBLEMA</h3>
                        <p className="text-content">{narrative.problem || "No especificado."}</p>
                    </div>

                    <div className="details-section">
                        <h3 className="details-section-title">MI ROL</h3>
                        <p className="text-content">{narrative.roleDescription || "No especificado."}</p>
                    </div>

                    {/* Old Tech Stack section removed */}

                    {/* Outcomes */}
                    {outcomes && (outcomes.results.length > 0 || outcomes.learnings.length > 0) && (
                        <div className="details-section">
                            <h3 className="details-section-title">RESULTADOS Y APRENDIZAJES</h3>

                            <ul className="outcomes-list">
                                {outcomes.results.map((item, index) => (
                                    <li key={`res-${index}`} className="outcome-item">{item}</li>
                                ))}
                                {outcomes.learnings.map((item, index) => (
                                    <li key={`learn-${index}`} className="outcome-item">{item}</li>
                                ))}
                            </ul>
                        </div>
                    )}

                    {/* Media */}
                    {media && (
                        <div className="details-section">
                            {media.imageUrls && media.imageUrls.length > 0 && (
                                <>
                                    <h3 className="details-section-title">GALERÍA</h3>
                                    <div className="media-gallery">
                                        {media.imageUrls.map((url, index) => (
                                            <img key={index} src={url} alt={`Project media ${index + 1}`} className="media-item" />
                                        ))}
                                    </div>
                                </>
                            )}

                            {media.links && media.links.length > 0 && (
                                <div style={{ marginTop: '1.5rem' }}>
                                    <h3 className="details-section-title">ENLACES</h3>
                                    <div className="links-list">
                                        {media.links.map((link, index) => (
                                            <a key={index} href={link.url} target="_blank" rel="noopener noreferrer" className="link-item">
                                                🔗 {link.label}: {link.url}
                                            </a>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>
                    )}
                </div>

                <div className="details-footer">
                    <button className="btn-footer-share">Compartir</button>
                    <button className="btn-footer-edit" onClick={() => onEdit(project)}>Editar Proyecto</button>
                </div>
            </div>
        </div>
    );
};

export default ProjectDetails;
