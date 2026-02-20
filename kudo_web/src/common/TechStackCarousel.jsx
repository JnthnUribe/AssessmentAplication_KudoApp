import React from 'react';
import './TechStackCarousel.css';

const TechStackCarousel = ({ techs }) => {
    if (!techs || techs.length === 0) return null;

    // Duplicamos los items para lograr el efecto infinito sin cortes
    // Si hay poquitos items, los duplicamos más veces para llenar el ancho
    const items = [...techs, ...techs, ...techs, ...techs];

    return (
        <div className="tech-carousel-container">
            <div className="tech-carousel-track">
                {items.map((tech, index) => (
                    <div key={index} className="tech-carousel-item">
                        <span className="tech-text">{tech}</span>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default TechStackCarousel;
