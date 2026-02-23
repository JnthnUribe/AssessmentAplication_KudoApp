import React from 'react';
import InputDesign from './InputDesign';
import './optionsForms.css';

export const CATEGORY_OPTIONS = ['Software', 'Diseño', 'Marketing', 'Hardware', 'Educación'];
export const PLATFORM_OPTIONS = ['Web', 'Móvil', 'Desktop', 'Multiplataforma', 'Otros'];

const OptionsForms = ({ label, value, options, onChange, placeholder, style }) => {
    return (
        <div className="options-form-hybrid" style={style}>
            <InputDesign
                label={label}
                placeholder={placeholder}
                value={value}
                onChange={(e) => onChange(e.target.value)}
            />
            <div className="options-tags-grid">
                {options.map(opt => (
                    <button
                        key={opt}
                        type="button"
                        className={`option-tag-pill ${value === opt ? 'active' : ''}`}
                        onClick={() => onChange(opt)}
                    >
                        {opt}
                    </button>
                ))}
            </div>
        </div>
    );
};

export default OptionsForms;
