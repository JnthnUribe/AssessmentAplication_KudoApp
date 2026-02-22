import React, { useState, useRef, useEffect } from 'react';
import './Search.css';

const Search = ({ placeholder = "Buscar..." }) => {
    const [isExpanded, setIsExpanded] = useState(false);
    const containerRef = useRef(null);
    const inputRef = useRef(null);

    const handleExpand = () => {
        setIsExpanded(true);
        setTimeout(() => {
            if (inputRef.current) inputRef.current.focus();
        }, 100);
    };

    useEffect(() => {
        const handleClickOutside = (event) => {
            if (containerRef.current && !containerRef.current.contains(event.target)) {
                if (!inputRef.current || inputRef.current.value.trim() === '') {
                    setIsExpanded(false);
                }
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, []);

    return (
        <div
            className={`search-container ${isExpanded ? 'expanded' : ''}`}
            ref={containerRef}
            onClick={!isExpanded ? handleExpand : undefined}
        >
            <span className="search-icon" onClick={isExpanded ? undefined : handleExpand}>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </span>
            <input
                ref={inputRef}
                type="text"
                className="search-input"
                placeholder={placeholder}
            />
        </div>
    );
};

export default Search;
