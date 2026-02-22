import React, { useState, useEffect } from 'react';
import './GeneralInfo.css';
import { projectService } from '../../../../../../services/projectService';
import { reviewService } from '../../../../../../services/reviewService';

const GeneralInfo = () => {
    const [user, setUser] = useState(null);
    const [stats, setStats] = useState({ total: 0, published: 0, drafts: 0, hidden: 0 });
    const [topProjects, setTopProjects] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                // 1. Get user from local storage
                const storedUser = localStorage.getItem('user');
                if (!storedUser) return;

                const parsedUser = JSON.parse(storedUser);
                setUser(parsedUser);

                // 2. Fetch all projects for this user
                const projects = await projectService.getByCreatorId(parsedUser.id);

                // 3. Calculate basic stats based on status
                const published = projects.filter(p => p.status?.toLowerCase() === 'publicado' || p.status?.toLowerCase() === 'published').length;
                const drafts = projects.filter(p => p.status?.toLowerCase() === 'borrador' || p.status?.toLowerCase() === 'draft').length;
                const hidden = projects.filter(p => p.status?.toLowerCase() === 'oculto' || p.status?.toLowerCase() === 'hidden' || p.isDeleted).length;

                setStats({
                    total: projects.length,
                    published,
                    drafts,
                    hidden
                });

                // 4. Fetch reviews for each project and calculate average score to find Top 3
                const projectsWithScores = await Promise.all(projects.map(async (project) => {
                    try {
                        const reviews = await reviewService.getByProjectId(project.id);
                        const avgScore = reviews.length > 0
                            ? reviews.reduce((sum, r) => sum + r.score, 0) / reviews.length
                            : 0;
                        return {
                            title: project.identity?.title || 'Sin Título',
                            score: avgScore.toFixed(1), // format to 1 decimal
                            rawScore: avgScore
                        };
                    } catch (error) {
                        return { title: project.identity?.title || 'Unknown', score: "0.0", rawScore: 0 };
                    }
                }));

                // Sort by highest average score
                const sortedTopProjects = projectsWithScores
                    .filter(p => p.rawScore > 0) // optionally only show projects with score > 0
                    .sort((a, b) => b.rawScore - a.rawScore)
                    .slice(0, 3); // Top 3

                setTopProjects(sortedTopProjects);

            } catch (error) {
                console.error("Error fetching information card data", error);
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, []);

    const displayName = user ? `${user.firstName} ${user.firstSurname}` : 'Usuario';

    return (
        <div className="general-info-content">
            {/* User Profile Section */}
            <div className="info-profile-section">
                <div className="info-profile-picture-container">
                    <div className="info-profile-picture"></div>
                </div>
                <div className="info-profile-details">
                    {loading ? (
                        <h2 className="info-profile-name">Cargando...</h2>
                    ) : (
                        <>
                            <h2 className="info-profile-name">{displayName}</h2>
                            <span className="info-profile-role">Creador</span>
                        </>
                    )}
                </div>
            </div>

            {/* Project Stats Section */}
            <div className="info-stats-section">
                <h3>Resumen de Proyectos</h3>
                <div className="info-stat-row">
                    <span>Total de proyectos:</span>
                    <strong>{loading ? '-' : stats.total}</strong>
                </div>
                <div className="info-stat-row">
                    <span>Publicados:</span>
                    <strong>{loading ? '-' : stats.published}</strong>
                </div>
                <div className="info-stat-row">
                    <span>Borradores:</span>
                    <strong>{loading ? '-' : stats.drafts}</strong>
                </div>
                <div className="info-stat-row">
                    <span>Ocultos:</span>
                    <strong>{loading ? '-' : stats.hidden}</strong>
                </div>
            </div>

            {/* Divider */}
            <div className="info-divider-container">
                <hr className="info-divider" />
            </div>

            {/* Top Projects Ranking */}
            <div className="info-ranking-section">
                <h3>Proyectos Mejor Evaluados</h3>
                {loading ? (
                    <p className="empty-ranking-msg">Cargando ranking...</p>
                ) : topProjects.length > 0 ? (
                    <ul className="info-ranking-list">
                        {topProjects.map((project, index) => (
                            <li key={index} className="info-ranking-item">
                                <span className="rank-number">#{index + 1}</span>
                                <span className="rank-title">{project.title}</span>
                                <span className="rank-score">⭐ {project.score}</span>
                            </li>
                        ))}
                    </ul>
                ) : (
                    <p className="empty-ranking-msg">No hay proyectos aún</p>
                )}
            </div>
        </div>
    );
};

export default GeneralInfo;
