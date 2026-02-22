import React from 'react';
import './InputDesign.css';

const InputDesign = ({
    label,
    type = 'text',
    value,
    onChange,
    placeholder,
    multiline = false,
    className = "",
    onKeyPress,
    actionIcon,
    onAction
}) => {
    return (
        <div className={`input-design-group ${className}`}>
            {label && <label className="input-design-label">{label}</label>}
            <div className="input-with-action">
                {multiline ? (
                    <textarea
                        className="input-design-field textarea"
                        value={value}
                        onChange={onChange}
                        placeholder={placeholder}
                        onKeyPress={onKeyPress}
                    />
                ) : (
                    <input
                        className="input-design-field"
                        type={type}
                        value={value}
                        onChange={onChange}
                        placeholder={placeholder}
                        onKeyPress={onKeyPress}
                    />
                )}
                {actionIcon && (
                    <button
                        type="button"
                        className="input-action-btn"
                        onClick={onAction}
                    >
                        {actionIcon}
                    </button>
                )}
            </div>
        </div>
    );
};

export default InputDesign;
