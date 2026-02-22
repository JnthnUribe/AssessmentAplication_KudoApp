import React from 'react';
import './NewProjectInfo.css';

const NewProjectInfo = ({ activeSection, onSectionChange, sectionStatuses }) => {
    const sections = [
        { id: 'identidad', label: 'Identidad' },
        { id: 'narrativa', label: 'Narrativa' },
        { id: 'tecnologia', label: 'Tecnología' },
        { id: 'resultados', label: 'Resultados' },
        { id: 'multimedia', label: 'Multimedia' },
        { id: 'revision', label: 'Revisión' }
    ];

    const renderStepIcon = (sectionId, index) => {
        const status = sectionStatuses?.[sectionId];
        if (status === 'completed') return '✓';
        if (status === 'partial') return '!';
        return index + 1;
    };

    return (
        <div className="new-project-info-content">
            <div className="info-header">
                <h2>Diseño de Proyecto</h2>
                <p>Configura los detalles iniciales para tu nueva creación.</p>
            </div>

            <div className="info-steps">
                {sections.map((section, index) => {
                    const status = sectionStatuses?.[section.id] || 'empty';
                    return (
                        <div
                            key={section.id}
                            className={`info-step ${activeSection === section.id ? 'active' : ''} status-${status}`}
                            onClick={() => onSectionChange(section.id)}
                            style={{ cursor: 'pointer' }}
                        >
                            <span className="step-number">{renderStepIcon(section.id, index)}</span>
                            <span className="step-text">{section.label}</span>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default NewProjectInfo;
