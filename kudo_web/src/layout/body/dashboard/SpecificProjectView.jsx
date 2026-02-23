import React from 'react';
import './SpecificProjectView.css';
import backgroundImage from '../../../assets/newprojectImg.jpeg';
import { projectService } from '../../../services/projectService';
import { uploadFile, deleteFile } from '../../../features/fileUploader';

const cloudName = 'dufvodhuw';
const uploadPreset = 'kudofiles';

const SpecificProjectView = ({ project, isOpen, onClose, onUpdate }) => {
    const [selectedMedia, setSelectedMedia] = React.useState(null);
    const [isEditing, setIsEditing] = React.useState(false);
    const [editFormData, setEditFormData] = React.useState(null);
    const [isSaving, setIsSaving] = React.useState(false);
    const [isUploading, setIsUploading] = React.useState(false);
    const [newTech, setNewTech] = React.useState('');
    const fileInputRef = React.useRef(null);

    React.useEffect(() => {
        if (project) {
            setEditFormData({
                title: project.identity?.title || '',
                problem: project.narrative?.problem || '',
                roleDescription: project.narrative?.roleDescription || '',
                techStack: project.techStack || [],
                results: project.outcomes?.results?.join('\n') || '',
                learnings: project.outcomes?.learnings?.join('\n') || '',
                category: Array.isArray(project.identity?.category) ? project.identity.category[0] || '' : project.identity?.category || '',
                platform: Array.isArray(project.identity?.platform) ? project.identity.platform[0] || '' : project.identity?.platform || '',
                status: project.status || 'Borrador',
                images: project.media?.images || (project.media?.imageUrls || []).map(url => ({
                    url,
                    deleteToken: (project.media?.deleteTokens || []).find(t => (t.url || t.Url) === url)?.token || ''
                })),
                videoUrl: project.media?.videoUrl || '',
            });
        }
    }, [project]);

    const displayImages = React.useMemo(() => {
        const sourceMedia = project?.media || project?.Media || {};
        const sourceImages = sourceMedia.images || sourceMedia.Images || [];
        const sourceImageUrls = sourceMedia.imageUrls || sourceMedia.ImageUrls || [];

        return isEditing
            ? (editFormData?.images || [])
            : (sourceImages.length > 0
                ? sourceImages.map(img => ({
                    url: img.url || img.Url || '',
                    deleteToken: img.deleteToken || img.DeleteToken || ''
                }))
                : sourceImageUrls.map(url => ({ url })));
    }, [isEditing, editFormData?.images, project?.media, project?.Media]);

    const displayVideo = React.useMemo(() => {
        const sourceMedia = project?.media || project?.Media || {};
        return isEditing ? editFormData?.videoUrl : (sourceMedia.videoUrl || sourceMedia.VideoUrl);
    }, [isEditing, editFormData?.videoUrl, project?.media, project?.Media]);

    const allMediaUrls = React.useMemo(() => {
        return [
            ...displayImages.map(img => img.url),
            ...(displayVideo ? [displayVideo] : [])
        ];
    }, [displayImages, displayVideo]);

    React.useEffect(() => {
        if (displayImages.length > 0) {
            setSelectedMedia(displayImages[0].url);
        } else if (displayVideo) {
            setSelectedMedia(displayVideo);
        }
    }, [project, isEditing, displayImages.length, displayVideo]);

    if (!project) return null;

    const { identity, status, narrative, techStack, media, outcomes } = project;

    // Normalize properties for robust viewing/rendering (handle PascalCase/camelCase)
    const normalizedIdentity = identity || project.Identity || {};
    const normalizedNarrative = narrative || project.Narrative || {};
    const normalizedTechStack = techStack || project.TechStack || [];
    const normalizedMedia = media || project.Media || {};
    const normalizedOutcomes = outcomes || project.Outcomes || {};
    const normalizedStatus = status || project.Status || 'Borrador';

    const isVideo = (url) => url?.includes('video') || url?.includes('.mp4');

    const handleEditToggle = () => {
        setIsEditing(!isEditing);
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setEditFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleAddTech = (e) => {
        if (e.key === 'Enter' || e.type === 'blur') {
            e.preventDefault();
            const value = newTech.trim();
            if (value && !editFormData.techStack.includes(value)) {
                setEditFormData(prev => ({
                    ...prev,
                    techStack: [...prev.techStack, value]
                }));
                setNewTech('');
            }
        }
    };

    const handleRemoveTech = (techToRemove) => {
        setEditFormData(prev => ({
            ...prev,
            techStack: prev.techStack.filter(tech => tech !== techToRemove)
        }));
    };

    const handleDeleteMedia = async (url) => {
        // 1. Get token before state update
        const imageObj = editFormData.images.find(img => img.url === url);
        const token = imageObj?.deleteToken;
        console.log("Attempting to delete image. URL:", url, "Token found:", token ? "Yes" : "No");

        // 2. Update state using functional update
        setEditFormData(prev => {
            const isVideoUrl = url === prev.videoUrl;
            const updatedVideoUrl = isVideoUrl ? '' : prev.videoUrl;
            const updatedImages = isVideoUrl ? prev.images : prev.images.filter(img => img.url !== url);

            // Update selection if the deleted one was selected
            if (selectedMedia === url) {
                if (updatedImages.length > 0) {
                    setSelectedMedia(updatedImages[0].url);
                } else if (updatedVideoUrl) {
                    setSelectedMedia(updatedVideoUrl);
                } else {
                    setSelectedMedia(null);
                }
            }

            return {
                ...prev,
                images: updatedImages,
                videoUrl: updatedVideoUrl
            };
        });

        // 3. Perform Cloudinary deletion in background if token exists
        if (token) {
            try {
                await deleteFile(token, cloudName);
            } catch (error) {
                console.error("Failed to delete image from Cloudinary (likely expired token):", error);
                // We don't alert the user here because the visual deletion already happened
            }
        }
    };

    const handleAddMediaClick = () => {
        if (fileInputRef.current) {
            fileInputRef.current.click();
        }
    };

    const handleFileChange = async (e) => {
        const files = Array.from(e.target.files);
        if (files.length === 0) return;

        setIsUploading(true);
        try {
            const uploadPromises = files.map(file => uploadFile(file, uploadPreset, cloudName));
            const results = await Promise.all(uploadPromises);

            setEditFormData(prev => {
                const newItems = results.map(r => ({
                    url: r.url,
                    deleteToken: r.deleteToken
                }));

                const updatedImages = [...prev.images, ...newItems];

                // Set first new image as selected
                if (newItems.length > 0) {
                    setSelectedMedia(newItems[0].url);
                }

                return {
                    ...prev,
                    images: updatedImages
                };
            });
        } catch (error) {
            alert('Error al subir imágenes: ' + error.message);
        } finally {
            setIsUploading(false);
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    const handleAddVideoUrl = () => {
        const url = prompt('Introduce la URL del video (Youtube/Vimeo):');
        if (url) {
            setEditFormData(prev => ({
                ...prev,
                videoUrl: url
            }));
            setSelectedMedia(url);
        }
    };

    const handleSave = async () => {
        setIsSaving(true);
        try {
            const updatedProject = {
                ...project,
                status: editFormData.status,
                identity: {
                    ...project.identity,
                    title: editFormData.title,
                    category: editFormData.category,
                    platform: editFormData.platform
                },
                narrative: {
                    ...project.narrative,
                    problem: editFormData.problem,
                    roleDescription: editFormData.roleDescription
                },
                techStack: editFormData.techStack,
                media: {
                    ...project.media,
                    images: editFormData.images,
                    videoUrl: editFormData.videoUrl,
                },
                outcomes: {
                    ...project.outcomes,
                    results: editFormData.results.split('\n').map(item => item.trim()).filter(item => item !== ''),
                    learnings: editFormData.learnings.split('\n').map(item => item.trim()).filter(item => item !== '')
                }
            };

            console.log('Saving project with media details:', updatedProject.media);
            await projectService.update(project.id, updatedProject);

            console.log('Project updated successfully on server');

            // Notify parent to refresh state without page reload
            if (onUpdate) {
                onUpdate(updatedProject);
            }

            setIsEditing(false);

            // Instead of reload, we could trigger a local update if the parent provides a refresh function
            // For now, let's keep it clean and maybe just alert success
            // If the user really wants the reload behavior but fluid, we'd need to lift state.
            // But let's try WITHOUT reload first.
            alert('Cambios guardados con éxito');
        } catch (error) {
            alert('Error al guardar los cambios: ' + error.message);
        } finally {
            setIsSaving(false);
        }
    };

    return (
        <div
            className={`specific-project-overlay ${isOpen ? 'open' : ''}`}
            onClick={onClose}
            style={{ backgroundImage: `url(${backgroundImage})` }}
        >
            <div className={`specific-project-container ${isOpen ? 'open' : ''}`}>
                <div className="specific-project-media-gallery" onClick={(e) => e.stopPropagation()}>
                    {selectedMedia && (
                        <div className="media-main-preview">
                            {isVideo(selectedMedia) ? (
                                <iframe
                                    src={selectedMedia.includes('youtube.com') ? `https://www.youtube.com/embed/${selectedMedia.split('v=')[1]?.split('&')[0]}` : selectedMedia.includes('vimeo.com') ? `https://player.vimeo.com/video/${selectedMedia.split('/').pop()}` : selectedMedia}
                                    frameBorder="0"
                                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                    allowFullScreen
                                    title="Project Video"
                                    className="main-media-content"
                                ></iframe>
                            ) : (
                                <img src={selectedMedia} alt="Preview" className="main-media-content" />
                            )}
                        </div>
                    )}

                    <div className="media-thumbnails-strip">
                        {displayImages.map((imgObj, index) => (
                            <div
                                key={index}
                                className={`media-thumbnail ${selectedMedia === imgObj.url ? 'active' : ''}`}
                                onClick={() => setSelectedMedia(imgObj.url)}
                            >
                                {isEditing && (
                                    <button
                                        className="delete-media-btn"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            handleDeleteMedia(imgObj.url);
                                        }}
                                        title="Eliminar"
                                    >
                                        &times;
                                    </button>
                                )}
                                <img src={imgObj.url} alt={`Thumbnail ${index}`} />
                            </div>
                        ))}

                        {isEditing && (
                            <div
                                className={`media-thumbnail add-media-placeholder ${isUploading ? 'uploading' : ''}`}
                                onClick={handleAddMediaClick}
                                title="Subir Imagen"
                            >
                                {isUploading ? (
                                    <div className="upload-spinner-small"></div>
                                ) : (
                                    <div className="add-media-icon">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <line x1="12" y1="5" x2="12" y2="19"></line>
                                            <line x1="5" y1="12" x2="19" y2="12"></line>
                                        </svg>
                                    </div>
                                )}
                            </div>
                        )}

                        {isEditing && !displayVideo && (
                            <div
                                className="media-thumbnail add-media-placeholder"
                                onClick={handleAddVideoUrl}
                                title="Agregar URL de Video"
                            >
                                <div className="add-media-icon">
                                    <svg viewBox="0 0 24 24" width="24" height="24">
                                        <path fill="currentColor" d="M8 5v14l11-7z" />
                                    </svg>
                                </div>
                            </div>
                        )}

                        {/* If video exists, show it in the strip */}
                        {displayVideo && (
                            <div
                                className={`media-thumbnail ${selectedMedia === displayVideo ? 'active' : ''}`}
                                onClick={() => setSelectedMedia(displayVideo)}
                            >
                                {isEditing && (
                                    <button
                                        className="delete-media-btn"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            handleDeleteMedia(displayVideo);
                                        }}
                                        title="Eliminar"
                                    >
                                        &times;
                                    </button>
                                )}
                                <div className="video-thumbnail-placeholder">
                                    <svg viewBox="0 0 24 24" width="24" height="24">
                                        <path fill="currentColor" d="M8 5v14l11-7z" />
                                    </svg>
                                </div>
                            </div>
                        )}
                    </div>
                    <input
                        type="file"
                        ref={fileInputRef}
                        onChange={handleFileChange}
                        multiple
                        accept="image/*"
                        style={{ display: 'none' }}
                    />
                </div>

                <div
                    className={`specific-project-card ${isOpen ? 'open' : ''}`}
                    onClick={(e) => e.stopPropagation()}
                >
                    <div className="specific-project-header">
                        <button className="close-panel-btn" onClick={onClose}>
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <line x1="18" y1="6" x2="6" y2="18"></line>
                                <line x1="6" y1="6" x2="18" y2="18"></line>
                            </svg>
                        </button>
                    </div>

                    <div className="specific-project-content">
                        <div className="specific-project-info">
                            <div className={`specific-project-status-inline ${(normalizedStatus || 'borrador').toLowerCase()}`}>
                                {isEditing ? (
                                    <select
                                        name="status"
                                        value={editFormData.status}
                                        onChange={handleInputChange}
                                        className="edit-select-status"
                                    >
                                        <option value="Publicado">Publicado</option>
                                        <option value="Borrador">Borrador</option>
                                        <option value="Oculto">Oculto</option>
                                    </select>
                                ) : (
                                    normalizedStatus
                                )}
                            </div>

                            {isEditing ? (
                                <input
                                    name="title"
                                    value={editFormData.title}
                                    onChange={handleInputChange}
                                    className="edit-input-title"
                                    placeholder="Título del Proyecto"
                                />
                            ) : (
                                <h2 className="specific-project-title">{normalizedIdentity.title || normalizedIdentity.Title || 'Título del Proyecto'}</h2>
                            )}

                            <div className="specific-project-body-grid">
                                <div className="grid-row">

                                    <div className="specific-project-section">
                                        <h3>Problema a resolver</h3>
                                        {isEditing ? (
                                            <textarea
                                                name="problem"
                                                value={editFormData.problem}
                                                onChange={handleInputChange}
                                                className="edit-textarea"
                                            />
                                        ) : (
                                            <p>{normalizedNarrative.problem || normalizedNarrative.Problem || 'No hay descripción disponible para este proyecto.'}</p>
                                        )}
                                    </div>

                                    <div className="specific-project-section">
                                        <h3>Descripción de tu rol</h3>
                                        {isEditing ? (
                                            <textarea
                                                name="roleDescription"
                                                value={editFormData.roleDescription}
                                                onChange={handleInputChange}
                                                className="edit-textarea"
                                            />
                                        ) : (
                                            <p>{normalizedNarrative.roleDescription || 'No se ha especificado un rol para este proyecto.'}</p>
                                        )}
                                    </div>
                                </div>

                                <div className="grid-row">
                                    <div className="specific-project-section">
                                        <h3>Resultados obtenidos</h3>
                                        {isEditing ? (
                                            <textarea
                                                name="results"
                                                value={editFormData.results}
                                                onChange={handleInputChange}
                                                className="edit-textarea"
                                                placeholder="Un resultado por línea"
                                            />
                                        ) : normalizedOutcomes.results && normalizedOutcomes.results.length > 0 ? (
                                            <ul className="specific-list">
                                                {normalizedOutcomes.results.map((result, index) => (
                                                    <li key={index}>{result}</li>
                                                ))}
                                            </ul>
                                        ) : <p className="empty-val">Sin resultados registrados.</p>}
                                    </div>

                                    <div className="specific-project-section">
                                        <h3>Lecciones aprendidas</h3>
                                        {isEditing ? (
                                            <textarea
                                                name="learnings"
                                                value={editFormData.learnings}
                                                onChange={handleInputChange}
                                                className="edit-textarea"
                                                placeholder="Una lección por línea"
                                            />
                                        ) : normalizedOutcomes.learnings && normalizedOutcomes.learnings.length > 0 ? (
                                            <ul className="specific-list">
                                                {normalizedOutcomes.learnings.map((learning, index) => (
                                                    <li key={index}>{learning}</li>
                                                ))}
                                            </ul>
                                        ) : <p className="empty-val">Sin lecciones registradas.</p>}
                                    </div>
                                </div>
                            </div>

                            <div className="specific-project-section">
                                <h3>Stack Tecnológico</h3>
                                {isEditing ? (
                                    <div className="edit-tech-container">
                                        <div className="specific-tech-list">
                                            {editFormData.techStack.map((tech, index) => (
                                                <span key={index} className="tech-pill-edit">
                                                    {tech}
                                                    <button
                                                        type="button"
                                                        className="remove-tech-btn"
                                                        onClick={() => handleRemoveTech(tech)}
                                                    >
                                                        &times;
                                                    </button>
                                                </span>
                                            ))}
                                        </div>
                                        <div className="add-tech-input-group">
                                            <input
                                                type="text"
                                                value={newTech}
                                                onChange={(e) => setNewTech(e.target.value)}
                                                onKeyDown={handleAddTech}
                                                onBlur={handleAddTech}
                                                className="edit-input-add-tech"
                                                placeholder="Agregar tecnología..."
                                            />
                                        </div>
                                    </div>
                                ) : normalizedTechStack && normalizedTechStack.length > 0 ? (
                                    <div className="specific-tech-list">
                                        {normalizedTechStack.map((tech, index) => (
                                            <span key={index} className="tech-pill-large">{tech}</span>
                                        ))}
                                    </div>
                                ) : <p className="empty-val">Sin tecnologías registradas.</p>}
                            </div>

                            <div className="specific-project-section">
                                <h3>Detalles</h3>
                                <div className="details-grid">
                                    <div className="detail-item">
                                        <span className="detail-label">Categoría</span>
                                        {isEditing ? (
                                            <input
                                                name="category"
                                                value={editFormData.category}
                                                onChange={handleInputChange}
                                                className="edit-input-small"
                                            />
                                        ) : (
                                            <span className="detail-value">{normalizedIdentity.category || 'General'}</span>
                                        )}
                                    </div>
                                    <div className="detail-item">
                                        <span className="detail-label">Plataforma</span>
                                        {isEditing ? (
                                            <input
                                                name="platform"
                                                value={editFormData.platform}
                                                onChange={handleInputChange}
                                                className="edit-input-small"
                                            />
                                        ) : (
                                            <span className="detail-value">{normalizedIdentity.platform || 'Web'}</span>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="specific-project-footer">
                        {isEditing ? (
                            <div className="edit-actions">
                                <button className="cancel-edit-btn" onClick={handleEditToggle} disabled={isSaving}>
                                    Cancelar
                                </button>
                                <button className="save-project-btn" onClick={handleSave} disabled={isSaving}>
                                    {isSaving ? 'Guardando...' : 'Guardar Cambios'}
                                </button>
                            </div>
                        ) : (
                            <button className="edit-project-btn" onClick={handleEditToggle}>
                                Editar Proyecto
                            </button>
                        )}
                    </div>
                </div>
            </div >
        </div >
    );
};

export default SpecificProjectView;
