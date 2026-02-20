import React, { useState } from 'react';
import './NewProject.css';
import { projectService } from '../../../../../../../services/projectService';

const NewProject = ({ onCancel }) => {
    const [formData, setFormData] = useState({
        status: '',
        platform: '',
        identity: {
            title: '',
            category: ''
        },
        narrative: {
            problem: '',
            roleDescription: ''
        },
        techStack: [],
        outcomes: {
            results: [],
            learnings: []
        },
        media: {
            imageUrls: [],
            videoUrl: '',
            links: []
        }
    });

    const [tempData, setTempData] = useState({
        techStack: '',
        outcomes: {
            results: '',
            learnings: ''
        },
        media: {
            imageUrls: '',
            links: { label: '', url: '' }
        }
    });

    const handleIdentityChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            identity: { ...prev.identity, [name]: value }
        }));
    };

    const handleNarrativeChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            narrative: { ...prev.narrative, [name]: value }
        }));
    };

    const handleMediaChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            media: { ...prev.media, [name]: value }
        }));
    };

    // Generic handler for simple array additions (Tech Stack)
    const addSimpleItem = (category, valueKey) => {
        const value = valueKey ? tempData[category][valueKey] : tempData[category];
        if (!value || value.trim() === '') return;

        setFormData(prev => {
            if (valueKey) {
                return {
                    ...prev,
                    [category]: {
                        ...prev[category],
                        [valueKey]: [...prev[category][valueKey], value]
                    }
                };
            } else {
                return { ...prev, [category]: [...prev[category], value] };
            }
        });

        // Clear temp input
        setTempData(prev => {
            if (valueKey) {
                return {
                    ...prev,
                    [category]: { ...prev[category], [valueKey]: '' }
                };
            } else {
                return { ...prev, [category]: '' };
            }
        });
    };

    // Handler for removing items
    const removeArrayItem = (category, index, subCategory = null) => {
        setFormData(prev => {
            if (subCategory) {
                const newArray = prev[category][subCategory].filter((_, i) => i !== index);
                return {
                    ...prev,
                    [category]: { ...prev[category], [subCategory]: newArray }
                };
            } else {
                const newArray = prev[category].filter((_, i) => i !== index);
                return { ...prev, [category]: newArray };
            }
        });
    };

    // Specific handler for Links
    const addLink = () => {
        const { label, url } = tempData.media.links;
        if (!label.trim() || !url.trim()) return;

        setFormData(prev => ({
            ...prev,
            media: {
                ...prev.media,
                links: [...prev.media.links, { label, url }]
            }
        }));

        setTempData(prev => ({
            ...prev,
            media: { ...prev.media, links: { label: '', url: '' } }
        }));
    };

    const removeLink = (index) => {
        setFormData(prev => ({
            ...prev,
            media: {
                ...prev.media,
                links: prev.media.links.filter((_, i) => i !== index)
            }
        }));
    };

    const handleProjectSubmit = async (status) => {
        try {
            // Basic validation: Title is always required for identification
            if (!formData.identity.title.trim()) {
                alert('El título del proyecto es obligatorio.');
                return;
            }

            // Get user from localStorage
            const userStr = localStorage.getItem('user');
            if (!userStr) {
                alert('No hay usuario autenticado. Por favor inicie sesión nuevamente.');
                return;
            }

            const user = JSON.parse(userStr);
            const creatorId = user.id || user.Id;

            if (!creatorId) {
                alert('Error: No se pudo obtener el ID del usuario.');
                return;
            }

            // Prepare payload
            const projectData = {
                ...formData,
                status: status,
                creatorId: creatorId,
                createdAt: new Date(),
                updatedAt: new Date()
            };

            await projectService.create(projectData);
            alert(status === 'Publicado' ? 'Proyecto publicado exitosamente!' : 'Borrador guardado exitosamente!');

            // Optional: Redirect to Home after success
            if (onCancel) onCancel();

        } catch (error) {
            console.error('Error creating project:', error);
            alert('Error al guardar el proyecto. Por favor intente de nuevo.');
        }
    };

    return (
        <div className="new-project-container">
            <h2 className="new-project-title">Crear Nuevo Proyecto</h2>
            <form className="new-project-form" onSubmit={(e) => e.preventDefault()}>

                {/* Identity Section */}
                <div className="form-section">
                    <h3 className="section-subtitle">Identidad del Proyecto</h3>
                    <div className="form-row">
                        <div className="form-group">
                            <label>Título</label>
                            <input
                                type="text"
                                name="title"
                                value={formData.identity.title}
                                onChange={handleIdentityChange}
                                placeholder="Nombre del proyecto"
                            />
                        </div>
                        <div className="form-group">
                            <label>Categoría</label>
                            <input
                                type="text"
                                name="category"
                                value={formData.identity.category}
                                onChange={handleIdentityChange}
                                placeholder="Ej. E-commerce, Videojuego, Punto de venta..."
                            />
                        </div>
                    </div>
                    <div className="form-row">
                        <div className="form-group">
                            <label>Plataforma</label>
                            <input
                                type="text"
                                value={formData.platform}
                                onChange={(e) => setFormData({ ...formData, platform: e.target.value })}
                                placeholder="Ej. Mobile Android, Web, Multiplataforma..."
                            />
                        </div>
                    </div>
                </div>

                {/* Narrative Section */}
                <div className="form-section">
                    <h3 className="section-subtitle">Narrativa</h3>
                    <div className="form-group">
                        <label>El Problema</label>
                        <textarea
                            name="problem"
                            value={formData.narrative.problem}
                            onChange={handleNarrativeChange}
                            rows="3"
                            placeholder="Describe el problema que el proyecto resuelve. Ej. Los usuarios tenían dificultades para rastrear sus gastos diarios..."
                        />
                    </div>
                    <div className="form-group">
                        <label>Descripción del Rol</label>
                        <textarea
                            name="roleDescription"
                            value={formData.narrative.roleDescription}
                            onChange={handleNarrativeChange}
                            rows="3"
                            placeholder="Explica tu rol y responsabilidades. Ej. Fui el desarrollador principal encargado del backend..."
                        />
                    </div>
                </div>

                {/* Tech Stack Section */}
                <div className="form-section">
                    <h3 className="section-subtitle">Tech Stack</h3>
                    <div className="input-group-add">
                        <input
                            type="text"
                            value={tempData.techStack}
                            onChange={(e) => setTempData({ ...tempData, techStack: e.target.value })}
                            placeholder="Tecnología (ej. React)"
                        />
                        <button type="button" className="btn-add-item" onClick={() => addSimpleItem('techStack')}>Agregar</button>
                    </div>
                    <div className="items-list">
                        {formData.techStack.map((tech, index) => (
                            <div key={index} className="list-item">
                                <span>{tech}</span>
                                <button type="button" className="btn-remove-small" onClick={() => removeArrayItem('techStack', index)}>×</button>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Outcomes Section */}
                <div className="form-section">
                    <h3 className="section-subtitle">Resultados y Aprendizajes</h3>

                    <label className="sub-label">Resultados</label>
                    <div className="input-group-add">
                        <input
                            type="text"
                            value={tempData.outcomes.results}
                            onChange={(e) => setTempData({
                                ...tempData,
                                outcomes: { ...tempData.outcomes, results: e.target.value }
                            })}
                            placeholder="Resultado obtenido"
                        />
                        <button type="button" className="btn-add-item" onClick={() => addSimpleItem('outcomes', 'results')}>Agregar</button>
                    </div>
                    <div className="items-list">
                        {formData.outcomes.results.map((result, index) => (
                            <div key={index} className="list-item">
                                <span>{result}</span>
                                <button type="button" className="btn-remove-small" onClick={() => removeArrayItem('outcomes', index, 'results')}>×</button>
                            </div>
                        ))}
                    </div>

                    <label className="sub-label" style={{ marginTop: '1rem', display: 'block' }}>Aprendizajes</label>
                    <div className="input-group-add">
                        <input
                            type="text"
                            value={tempData.outcomes.learnings}
                            onChange={(e) => setTempData({
                                ...tempData,
                                outcomes: { ...tempData.outcomes, learnings: e.target.value }
                            })}
                            placeholder="Aprendizaje clave"
                        />
                        <button type="button" className="btn-add-item" onClick={() => addSimpleItem('outcomes', 'learnings')}>Agregar</button>
                    </div>
                    <div className="items-list">
                        {formData.outcomes.learnings.map((learning, index) => (
                            <div key={index} className="list-item">
                                <span>{learning}</span>
                                <button type="button" className="btn-remove-small" onClick={() => removeArrayItem('outcomes', index, 'learnings')}>×</button>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Media Section */}
                <div className="form-section">
                    <h3 className="section-subtitle">Media y Enlaces (Deshabilitado)</h3>

                    <div className="form-group">
                        <label>URL del Video</label>
                        <input
                            type="text"
                            name="videoUrl"
                            value={formData.media.videoUrl}
                            onChange={handleMediaChange}
                            placeholder="https://..."
                            disabled
                        />
                    </div>

                    <label className="sub-label">Imágenes (URLs)</label>
                    <div className="input-group-add">
                        <input
                            type="text"
                            value={tempData.media.imageUrls}
                            onChange={(e) => setTempData({
                                ...tempData,
                                media: { ...tempData.media, imageUrls: e.target.value }
                            })}
                            placeholder="https://..."
                            disabled
                        />
                        <button type="button" className="btn-add-item" onClick={() => addSimpleItem('media', 'imageUrls')} disabled>Agregar</button>
                    </div>
                    <div className="items-list">
                        {formData.media.imageUrls.map((url, index) => (
                            <div key={index} className="list-item">
                                <span className="text-truncate">{url}</span>
                                <button type="button" className="btn-remove-small" onClick={() => removeArrayItem('media', index, 'imageUrls')} disabled>×</button>
                            </div>
                        ))}
                    </div>

                    <label className="sub-label" style={{ marginTop: '1rem', display: 'block' }}>Enlaces Externos</label>
                    <div className="input-group-add">
                        <input
                            type="text"
                            value={tempData.media.links.label}
                            onChange={(e) => setTempData({
                                ...tempData,
                                media: { ...tempData.media, links: { ...tempData.media.links, label: e.target.value } }
                            })}
                            placeholder="Etiqueta"
                            style={{ width: '30%' }}
                            disabled
                        />
                        <input
                            type="text"
                            value={tempData.media.links.url}
                            onChange={(e) => setTempData({
                                ...tempData,
                                media: { ...tempData.media, links: { ...tempData.media.links, url: e.target.value } }
                            })}
                            placeholder="URL"
                            style={{ width: '60%' }}
                            disabled
                        />
                        <button type="button" className="btn-add-item" onClick={addLink} style={{ width: '10%' }} disabled>+</button>
                    </div>
                    <div className="items-list">
                        {formData.media.links.map((link, index) => (
                            <div key={index} className="list-item">
                                <span>{link.label}: <a href={link.url} target="_blank" rel="noopener noreferrer">{link.url}</a></span>
                                <button type="button" className="btn-remove-small" onClick={() => removeLink(index)} disabled>×</button>
                            </div>
                        ))}
                    </div>
                </div>

                <div className="form-actions">
                    <button type="button" className="btn-cancel" onClick={onCancel}>Cancelar</button>
                    <button type="button" className="btn-draft" onClick={() => handleProjectSubmit('Borrador')}>Guardar Borrador</button>
                    <button type="button" className="btn-submit" onClick={() => handleProjectSubmit('Publicado')}>Publicar Proyecto</button>
                </div>
            </form>
        </div>
    );
};

export default NewProject;
