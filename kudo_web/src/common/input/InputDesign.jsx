import React, { useRef, useEffect } from 'react';
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
    const textareaRef = useRef(null);

    useEffect(() => {
        if (multiline && textareaRef.current) {
            textareaRef.current.style.height = 'auto';
            textareaRef.current.style.height = `${textareaRef.current.scrollHeight}px`;
        }
    }, [value, multiline]);

    return (
        <div className={`input-design-group ${className}`}>
            {label && <label className="input-design-label">{label}</label>}
            <div className="input-with-action">
                {multiline ? (
                    <textarea
                        ref={textareaRef}
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
