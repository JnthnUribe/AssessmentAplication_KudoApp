import React from 'react';
import InputDesign from './InputDesign';

const NewProjectInputs = ({ activeSection, formData, onInputChange }) => {
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
                                label="Categoría"
                                placeholder="Selecciona o escribe una categoría"
                                className="main-category-input-wrapper"
                                value={formData.identity.category}
                                onChange={(e) => onInputChange('identity', 'category', e.target.value)}
                            />
                            <div className="category-tags-bottom">
                                {['Web', 'Móvil', 'Escritorio', 'IA', 'Ciberseguridad', 'Videojuegos'].map(cat => (
                                    <button
                                        key={cat}
                                        type="button"
                                        className={`suggestion-tag ${formData.identity.category === cat ? 'active' : ''}`}
                                        onClick={() => onInputChange('identity', 'category', cat)}
                                    >
                                        {cat}
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
                        <div className="form-group inline-group">
                            <InputDesign
                                label="Dinos qué herramientas utilizaste."
                                placeholder="Ej. React, Node.js, MongoDB..."
                                className="flex-grow"
                            />
                            <button className="add-btn">Agregar</button>
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
                        />
                        <InputDesign
                            label="Lecciones aprendidas"
                            placeholder="¿Qué aprendiste?"
                            multiline={true}
                        />
                    </div>
                );
            case 'multimedia':
                return (
                    <div className="form-section">
                        <h2>Multimedia</h2>
                        <InputDesign
                            label="URL de Imágenes (separadas por coma)"
                            placeholder="https://..."
                        />
                        <InputDesign
                            label="URL de Video (Youtube/Vimeo)"
                            placeholder="https://..."
                        />
                    </div>
                );
            case 'revision':
                return (
                    <div className="form-section revision-section">
                        <h2>Revisión Final</h2>
                        <p>Verifica que toda la información sea correcta.</p>
                        <div className="summary-box">
                            <p><strong>Título:</strong> {formData.identity.title || 'Pendiente'}</p>
                            <p><strong>Categoría:</strong> {formData.identity.category || 'Pendiente'}</p>
                        </div>
                        <button className="submit-project-btn">Crear Proyecto</button>
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
