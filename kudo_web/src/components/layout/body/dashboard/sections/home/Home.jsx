import React from 'react';
import './Home.css';

const Home = () => {
    return (
        <div className="home-section">
            <div className="home-header">
                <h2 className="section-title">Proyectos Recientes</h2>
                <div className="filter-buttons">
                    <button className="filter-btn active">Todos</button>
                    <button className="filter-btn">Publicados</button>
                    <button className="filter-btn">Borradores</button>
                    <button className="filter-btn">Ocultos</button>
                </div>
            </div>
            {/* List of projects will go here */}
        </div>
    );
};

export default Home;
