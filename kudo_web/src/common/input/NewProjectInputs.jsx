import React, { useState } from 'react';
import InputDesign from './InputDesign';
import { uploadFile, deleteFile } from '../../features/fileUploader';
import ProjectCard from '../project/ProjectCard';

const NewProjectInputs = ({ activeSection, formData, onInputChange, onSave, sectionStatuses }) => {
    const [techInputValue, setTechInputValue] = useState('');
    const [isUploading, setIsUploading] = useState(false);

    const cloudName = 'dufvodhuw';
    const uploadPreset = 'kudofiles';

    const handleAddTech = (e) => {
        if (e) e.preventDefault();
        if (techInputValue.trim()) {
            const currentStack = formData.techStack || [];
            if (!currentStack.includes(techInputValue.trim())) {
                const newStack = [...currentStack, techInputValue.trim()];
                onInputChange('techStack', null, newStack);
            }
            setTechInputValue('');
        }
    };

    const handleRemoveTech = (techToRemove) => {
        const newStack = formData.techStack.filter(tech => tech !== techToRemove);
        onInputChange('techStack', null, newStack);
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter') {
            handleAddTech();
        }
    };

    const renderSectionContent = () => {
        switch (activeSection) {
            case 'identidad':
                return (
                    <div className="form-section">
                        <h2>Identidad del Proyecto</h2>
                        <InputDesign
                            label="Título del Proyecto"
                            placeholder="Ej. Sistema de Gestión Universitara"
                            value={formData.identity.title}
                            onChange={(e) => onInputChange('identity', 'title', e.target.value)}
                        />
                        <div className="category-hybrid-container">
                            <InputDesign
                                label="Categoría del Proyecto"
                                placeholder="Selecciona o escribe una categoría"
                                value={formData.identity.category}
                                onChange={(e) => onInputChange('identity', 'category', e.target.value)}
                            />
                            <div className="category-tags-grid small-tags">
                                {['Software', 'Diseño', 'Marketing', 'Hardware', 'Educación'].map(cat => (
                                    <button
                                        key={cat}
                                        type="button"
                                        className={`tag - pill ${formData.identity.category === cat ? 'active' : ''} `}
                                        onClick={() => onInputChange('identity', 'category', cat)}
                                    >
                                        {cat}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div className="category-hybrid-container" style={{ marginTop: '1.5rem' }}>
                            <InputDesign
                                label="Plataforma"
                                placeholder="Selecciona o escribe una plataforma"
                                value={formData.identity.platform}
                                onChange={(e) => onInputChange('identity', 'platform', e.target.value)}
                            />
                            <div className="category-tags-grid small-tags">
                                {['Web', 'Móvil', 'Desktop', 'Multiplataforma', 'Otros'].map(plat => (
                                    <button
                                        key={plat}
                                        type="button"
                                        className={`tag - pill ${formData.identity.platform === plat ? 'active' : ''} `}
                                        onClick={() => onInputChange('identity', 'platform', plat)}
                                    >
                                        {plat}
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>
                );
            case 'narrativa':
                return (
                    <div className="form-section">
                        <h2>Narrativa</h2>
                        <InputDesign
                            label="Problema a resolver"
                            placeholder="Describe el problema que aborda el proyecto..."
                            multiline={true}
                            value={formData.narrative.problem}
                            onChange={(e) => onInputChange('narrative', 'problem', e.target.value)}
                        />
                        <InputDesign
                            label="Descripción de tu rol"
                            placeholder="¿Qué hiciste específicamente en este proyecto?"
                            multiline={true}
                            value={formData.narrative.roleDescription}
                            onChange={(e) => onInputChange('narrative', 'roleDescription', e.target.value)}
                        />
                    </div>
                );
            case 'tecnologia':
                return (
                    <div className="form-section">
                        <h2>Tecnología (Tech Stack)</h2>
                        <div className="tech-input-container">
                            <InputDesign
                                label="Dinos qué herramientas utilizaste."
                                placeholder="Ej. React, Node.js, MongoDB..."
                                value={techInputValue}
                                onChange={(e) => setTechInputValue(e.target.value)}
                                onKeyPress={handleKeyPress}
                                actionIcon="+"
                                onAction={handleAddTech}
                            />
                            <div className="selected-tech-tags">
                                {(formData.techStack || []).map(tech => (
                                    <span key={tech} className="tech-tag">
                                        {tech}
                                        <button
                                            type="button"
                                            className="remove-tech-btn"
                                            onClick={() => handleRemoveTech(tech)}
                                        >
                                            ×
                                        </button>
                                    </span>
                                ))}
                            </div>
                        </div>
                    </div>
                );
            case 'resultados':
                return (
                    <div className="form-section">
                        <h2>Resultados y Aprendizajes</h2>
                        <InputDesign
                            label="Resultados obtenidos"
                            placeholder="¿Qué se logró?"
                            multiline={true}
                            value={formData.outcomes.results}
                            onChange={(e) => onInputChange('outcomes', 'results', e.target.value)}
                        />
                        <InputDesign
                            label="Lecciones aprendidas"
                            placeholder="¿Qué aprendiste?"
                            multiline={true}
                            value={formData.outcomes.learnings}
                            onChange={(e) => onInputChange('outcomes', 'learnings', e.target.value)}
                        />
                    </div>
                );
            case 'multimedia':
                const handleFileChange = async (e) => {
                    const files = Array.from(e.target.files);
                    if (files.length === 0) return;

                    setIsUploading(true);
                    try {
                        const newUrls = [];
                        const newTokens = { ...formData.media.deleteTokens };

                        for (const file of files) {
                            const result = await uploadFile(file, uploadPreset, cloudName);
                            newUrls.push(result.url);
                            newTokens[result.url] = result.deleteToken;
                        }

                        const currentUrls = formData.media.imageUrls || [];
                        onInputChange('media', 'imageUrls', [...currentUrls, ...newUrls]);
                        onInputChange('media', 'deleteTokens', newTokens);
                    } catch (error) {
                        alert('Error al subir imágenes: ' + error.message);
                    } finally {
                        setIsUploading(false);
                    }
                };

                const handleRemoveImage = async (urlToRemove) => {
                    const token = formData.media.deleteTokens?.[urlToRemove];
                    if (token) {
                        await deleteFile(token, cloudName);
                    }

                    const newUrls = formData.media.imageUrls.filter(url => url !== urlToRemove);
                    const newTokens = { ...formData.media.deleteTokens };
                    delete newTokens[urlToRemove];

                    onInputChange('media', 'imageUrls', newUrls);
                    onInputChange('media', 'deleteTokens', newTokens);
                };

                return (
                    <div className="form-section">
                        <h2>Multimedia</h2>

                        <div className="multimedia-container">
                            <div className="upload-wrapper">
                                <label className="input-design-label">Imágenes del Proyecto</label>
                                <div className={`file - upload - area ${isUploading ? 'uploading' : ''} `}>
                                    <input
                                        type="file"
                                        multiple
                                        accept="image/*"
                                        onChange={handleFileChange}
                                        id="file-upload-input"
                                        disabled={isUploading}
                                    />
                                    <label htmlFor="file-upload-input" className="file-upload-label">
                                        {isUploading ? (
                                            <div className="upload-spinner"></div>
                                        ) : (
                                            <>
                                                <span className="upload-icon">↑</span>
                                                <span className="upload-text">Selecciona o arrastra imágenes</span>
                                            </>
                                        )}
                                    </label>
                                </div>
                            </div>

                            <div className="image-preview-grid">
                                {(formData.media.imageUrls || []).map((url, index) => (
                                    <div key={index} className="preview-item">
                                        <img src={url} alt={`Preview ${index} `} />
                                        <button
                                            type="button"
                                            className="remove-preview-btn"
                                            onClick={() => handleRemoveImage(url)}
                                        >
                                            ×
                                        </button>
                                    </div>
                                ))}
                            </div>

                            <InputDesign
                                label="URL de Video (Youtube/Vimeo)"
                                placeholder="https://..."
                                value={formData.media.videoUrl}
                                onChange={(e) => onInputChange('media', 'videoUrl', e.target.value)}
                            />
                        </div>
                    </div>
                );
            case 'revision':
                const isFormComplete =
                    sectionStatuses.identidad === 'completed' &&
                    sectionStatuses.narrativa === 'completed' &&
                    sectionStatuses.tecnologia === 'completed' &&
                    sectionStatuses.resultados === 'completed' &&
                    sectionStatuses.multimedia === 'completed';

                return (
                    <div className="form-section">
                        <h2>Revisión Final</h2>
                        <p className="section-description">Casi hemos terminado. Revisa los detalles y elige cómo quieres guardar tu proyecto.</p>

                        <div className="preview-container">
                            <ProjectCard
                                project={{
                                    ...formData,
                                    status: 'Vista Previa'
                                }}
                            />
                        </div>


                        <div className="revision-actions">
                            <button
                                type="button"
                                className="btn-save-draft"
                                onClick={() => onSave('Borrador')}
                            >
                                Añadir a borrador
                            </button>

                            <button
                                type="button"
                                className={`btn - publish - project ${!isFormComplete ? 'disabled' : ''} `}
                                disabled={!isFormComplete}
                                onClick={() => onSave('Publicado')}
                            >
                                Crear proyecto
                            </button>
                        </div>
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <div className="new-project-inputs">
            {renderSectionContent()}
        </div>
    );
};

export default NewProjectInputs;
