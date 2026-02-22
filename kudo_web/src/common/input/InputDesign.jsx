import React from 'react';
import './InputDesign.css';

const InputDesign = ({ label, type = 'text', placeholder, value, onChange, multiline = false, className = '' }) => {
    return (
        <div className={`input-design-group ${className}`}>
            {label && <label className="input-design-label">{label}</label>}
            {multiline ? (
                <textarea
                    className="input-design-field"
                    placeholder={placeholder}
                    value={value}
                    onChange={onChange}
                />
            ) : (
                <input
                    type={type}
                    className="input-design-field"
                    placeholder={placeholder}
                    value={value}
                    onChange={onChange}
                />
            )}
        </div>
    );
};

export default InputDesign;
