import React, { useState } from 'react';
import InputDesign from './InputDesign';
import { uploadFile, deleteFile } from '../../features/fileUploader';
import ProjectCard from '../project/ProjectCard';
import OptionsForms, { CATEGORY_OPTIONS, PLATFORM_OPTIONS } from './optionsForms.jsx';

const NewProjectInputs = ({ activeSection, onSectionChange, formData, onInputChange, onSave, sectionStatuses }) => {
    const [techInputValue, setTechInputValue] = useState('');
    const [isUploading, setIsUploading] = useState(false);

    const SECTION_SEQUENCE = [
        'identidad',
        'narrativa',
        'tecnologia',
        'resultados',
        'multimedia',
        'revision'
    ];

    const handleNext = () => {
        const currentIndex = SECTION_SEQUENCE.indexOf(activeSection);
        if (currentIndex !== -1 && currentIndex < SECTION_SEQUENCE.length - 1) {
            onSectionChange(SECTION_SEQUENCE[currentIndex + 1]);
            // Scroll to top of main content when changing section
            const mainContent = document.querySelector('.dashboard-main-content');
            if (mainContent) mainContent.scrollTop = 0;
        }
    };

    const handleBack = () => {
        const currentIndex = SECTION_SEQUENCE.indexOf(activeSection);
        if (currentIndex > 0) {
            onSectionChange(SECTION_SEQUENCE[currentIndex - 1]);
            const mainContent = document.querySelector('.dashboard-main-content');
            if (mainContent) mainContent.scrollTop = 0;
        }
    };

    const cloudName = 'dufvodhuw';
    const uploadPreset = 'kudofiles';

    const handleAddTech = (e) => {
        if (e) e.preventDefault();
        if (techInputValue.trim()) {
            // Split by comma and handle multiple entries
            const newEntries = techInputValue
                .split(',')
                .map(item => item.trim())
                .filter(item => item !== '');

            const currentStack = formData.techStack || [];
            let updatedStack = [...currentStack];
            let changed = false;

            newEntries.forEach(entry => {
                if (!updatedStack.includes(entry)) {
                    updatedStack.push(entry);
                    changed = true;
                }
            });

            if (changed) {
                onInputChange('techStack', null, updatedStack);
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

    const handleFileChange = async (e) => {
        const files = Array.from(e.target.files);
        if (files.length === 0) return;

        setIsUploading(true);
        try {
            const newItems = [];

            for (const file of files) {
                const result = await uploadFile(file, uploadPreset, cloudName);
                newItems.push({
                    url: result.url,
                    deleteToken: result.deleteToken
                });
            }

            const currentImages = formData.media.images || [];
            onInputChange('media', null, {
                ...formData.media,
                images: [...currentImages, ...newItems]
            });
        } catch (error) {
            alert('Error al subir imágenes: ' + error.message);
        } finally {
            setIsUploading(false);
        }
    };

    const handleRemoveImage = async (urlToRemove) => {
        const imageObj = formData.media.images?.find(img => img.url === urlToRemove);
        const token = imageObj?.deleteToken;
        if (token) {
            try {
                await deleteFile(token, cloudName);
            } catch (error) {
                console.error("Failed to delete image from Cloudinary:", error);
            }
        }

        const newImages = formData.media.images.filter(img => img.url !== urlToRemove);

        onInputChange('media', null, {
            ...formData.media,
            images: newImages
        });
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
                        <OptionsForms
                            label="Categoría del Proyecto"
                            placeholder="Selecciona o escribe una categoría"
                            value={formData.identity.category}
                            options={CATEGORY_OPTIONS}
                            onChange={(val) => onInputChange('identity', 'category', val)}
                        />

                        <OptionsForms
                            label="Plataforma"
                            placeholder="Selecciona o escribe una plataforma"
                            value={formData.identity.platform}
                            options={PLATFORM_OPTIONS}
                            onChange={(val) => onInputChange('identity', 'platform', val)}
                            style={{ marginTop: '1.5rem' }}
                        />

                        <div className="section-footer">
                            <button type="button" className="btn-next-step" onClick={handleNext}>
                                Siguiente: Narrativa <span className="arrow">→</span>
                            </button>
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

                        <div className="section-footer">
                            <button type="button" className="btn-back-step" onClick={handleBack}>
                                <span className="arrow">←</span> Anterior
                            </button>
                            <button type="button" className="btn-next-step" onClick={handleNext}>
                                Siguiente: Tecnología <span className="arrow">→</span>
                            </button>
                        </div>
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

                        <div className="section-footer">
                            <button type="button" className="btn-back-step" onClick={handleBack}>
                                <span className="arrow">←</span> Anterior
                            </button>
                            <button type="button" className="btn-next-step" onClick={handleNext}>
                                Siguiente: Resultados <span className="arrow">→</span>
                            </button>
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

                        <div className="section-footer">
                            <button type="button" className="btn-back-step" onClick={handleBack}>
                                <span className="arrow">←</span> Anterior
                            </button>
                            <button type="button" className="btn-next-step" onClick={handleNext}>
                                Siguiente: Multimedia <span className="arrow">→</span>
                            </button>
                        </div>
                    </div>
                );
            case 'multimedia':
                return (
                    <div className="form-section">
                        <h2>Multimedia</h2>

                        <div className="multimedia-container">
                            <label className="input-design-label">Imágenes y Multimedia</label>
                            <div className={`file-upload-area ${isUploading ? 'uploading' : ''}`}>
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
                                        <span className="upload-text">Selecciona o arrastra tus mejores imágenes</span>
                                    )}
                                </label>
                            </div>

                            <div className="image-preview-grid">
                                {(formData.media.images || []).map((imgObj, index) => (
                                    <div key={index} className="preview-item">
                                        <img src={imgObj.url} alt={`Preview ${index} `} />
                                        <button
                                            type="button"
                                            className="remove-preview-btn"
                                            onClick={() => handleRemoveImage(imgObj.url)}
                                        >
                                            &times;
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

                        <div className="section-footer">
                            <button type="button" className="btn-back-step" onClick={handleBack}>
                                <span className="arrow">←</span> Anterior
                            </button>
                            <button type="button" className="btn-next-step" onClick={handleNext}>
                                Siguiente: Revisión <span className="arrow">→</span>
                            </button>
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
                                className={`btn-publish-project ${!isFormComplete ? 'disabled' : ''}`}
                                disabled={!isFormComplete}
                                onClick={() => onSave('Publicado')}
                            >
                                Crear proyecto
                            </button>
                        </div>

                        <div className="section-footer" style={{ marginTop: '2rem' }}>
                            <button type="button" className="btn-back-step" onClick={handleBack}>
                                <span className="arrow">←</span> Volver a Multimedia
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
