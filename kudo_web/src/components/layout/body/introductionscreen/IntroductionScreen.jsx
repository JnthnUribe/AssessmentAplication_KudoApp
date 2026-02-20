import React from 'react';
import './IntroductionScreen.css';

import TopBar from '../../header/TopBar.jsx';

const IntroductionScreen = () => {
    const [scrollY, setScrollY] = React.useState(0);
    const [activeSection, setActiveSection] = React.useState('home');

    React.useEffect(() => {
        const handleScroll = () => {
            setScrollY(window.scrollY);
            // Determine active section based on scroll position
            if (window.scrollY > 1800) {
                setActiveSection('objectives');
            } else if (window.scrollY > 1100) {
                setActiveSection('opportunities');
            } else if (window.scrollY > 400) {
                setActiveSection('about');
            } else {
                setActiveSection('home');
            }
        };

        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const scrollToSection = (section) => {
        if (section === 'home') {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else if (section === 'about') {
            window.scrollTo({ top: 800, behavior: 'smooth' });
        } else if (section === 'opportunities') {
            window.scrollTo({ top: 1600, behavior: 'smooth' });
        } else if (section === 'objectives') {
            window.scrollTo({ top: 2400, behavior: 'smooth' });
        }
    };

    // Calculate opacity based on scroll position
    // Hero fades out as you scroll down (0 to 400px)
    const heroOpacity = Math.max(0, 1 - scrollY / 400);
    const heroScale = Math.max(0.8, 1 - scrollY / 2000);

    // About section: fades in (300-800), then fades out (1100-1400)
    const aboutOpacityIn = Math.min(1, Math.max(0, (scrollY - 300) / 400));
    const aboutOpacityOut = Math.max(0, 1 - (scrollY - 1100) / 300);
    const aboutOpacity = Math.min(aboutOpacityIn, aboutOpacityOut);

    const aboutTranslateY = Math.max(0, 100 - (scrollY - 300) / 5);

    // Opportunities section: fades in (1300-1600), fades out (1900-2200)
    const opportunitiesOpacityIn = Math.min(1, Math.max(0, (scrollY - 1300) / 300));
    const opportunitiesOpacityOut = Math.max(0, 1 - (scrollY - 1900) / 300);
    const opportunitiesOpacity = Math.min(opportunitiesOpacityIn, opportunitiesOpacityOut);
    const opportunitiesTranslateY = Math.max(0, 100 - (scrollY - 1300) / 5);

    // Objectives section: fades in (2100-2400)
    const objectivesOpacity = Math.min(1, Math.max(0, (scrollY - 2100) / 300));
    const objectivesTranslateY = Math.max(0, 100 - (scrollY - 2100) / 5);

    return (
        <div className="introduction-screen">
            <TopBar activeSection={activeSection} onNavigate={scrollToSection} />

            <div className="blur-overlay"></div>

            <div
                className="content hero-section"
                style={{
                    opacity: heroOpacity,
                    transform: `scale(${heroScale})`,
                    pointerEvents: heroOpacity <= 0 ? 'none' : 'auto'
                }}
            >
                <h1>Transforma tu <span className="highlight-blue">Visión</span> Académica <br /> en <span className="highlight-blue">Impacto</span> Profesional</h1>
                <p>Gestiona, valida y proyecta tus competencias. <br /> El centro estratégico para Creadores que definen su futuro.</p>
                <div className="cta-container">
                    <button className="primary-btn">Comienza tu viaje</button>
                    <button className="secondary-btn">Animate</button>
                </div>
            </div>

            <div
                className="content about-section"
                style={{
                    opacity: aboutOpacity,
                    transform: `translateY(${aboutTranslateY}px)`,
                    pointerEvents: aboutOpacity <= 0 ? 'none' : 'auto'
                }}
            >
                <div className="about-container">
                    <h2>¿Qué es <span className="highlight-blue">KUDO</span>?</h2>
                    <p className="about-text">
                        La plataforma web de <strong>KUDO</strong> está diseñada como el centro de gestión estratégica para los <strong>Creadores</strong>.
                        Su objetivo primordial es facilitar la transición de un proyecto puramente académico hacia una narrativa de competencias profesionales.
                    </p>

                    <div className="features-grid">
                        <div className="feature-card">
                            <h3>Gestión de Identidad</h3>
                            <p>Vincula tu perfil a una identidad única y construye tu portafolio profesional.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Proceso Estructurado</h3>
                            <p>Un flujo de 5 etapas diseñado para transformar tareas en soluciones profesionales.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Validación Real</h3>
                            <p>Recibe feedback cualitativo de jueces expertos para mejorar tu perfil.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div
                className="content opportunities-section"
                style={{
                    opacity: opportunitiesOpacity,
                    transform: `translateY(${opportunitiesTranslateY}px)`,
                    pointerEvents: opportunitiesOpacity <= 0 ? 'none' : 'auto'
                }}
            >
                <div className="about-container">
                    <h2>Tus <span className="highlight-blue">Oportunidades</span></h2>
                    <p className="about-text">
                        KUDO no solo almacena tus proyectos, los potencia. Convierte el esfuerzo académico en una herramienta de empleabilidad y visibilidad.
                    </p>

                    <div className="features-grid">
                        <div className="feature-card">
                            <h3>Narrativa Profesional</h3>
                            <p>Transforma la "tarea" escolar en una "solución profesional" describiendo problemas reales y tu rol específico.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Token QR Único</h3>
                            <p>Genera automáticamente un acceso directo a tu portafolio validado para compartir en CVs y redes.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Dashboard de Impacto</h3>
                            <p>Visualiza el estado de tus proyectos y monitorea las evaluaciones recibidas en tiempo real.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div
                className="content objectives-section"
                style={{
                    opacity: objectivesOpacity,
                    transform: `translateY(${objectivesTranslateY}px)`,
                    pointerEvents: objectivesOpacity <= 0 ? 'none' : 'auto'
                }}
            >
                <div className="about-container">
                    <h2>Nuestros <span className="highlight-blue">Objetivos</span></h2>
                    <p className="about-text">
                        Aspiramos a ser el estándar para la documentación de competencias técnicas en el ámbito académico y profesional.
                    </p>

                    <div className="features-grid">
                        <div className="feature-card">
                            <h3>Rigor Técnico</h3>
                            <p>Fomentar la documentación precisa de arquitecturas tecnológicas y decisiones de diseño.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Claridad Visual</h3>
                            <p>Presentar la información de manera estructurada y atractiva para reclutadores y pares.</p>
                        </div>
                        <div className="feature-card">
                            <h3>Transición Profesional</h3>
                            <p>Facilitar el paso de estudiante a profesional mediante la creación de un historial de trabajo validado.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default IntroductionScreen;
