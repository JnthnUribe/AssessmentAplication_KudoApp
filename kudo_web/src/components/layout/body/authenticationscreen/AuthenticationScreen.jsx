import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../../../../services/authService';
import './AuthenticationScreen.css';

const AuthenticationScreen = () => {
    const [isRegistering, setIsRegistering] = useState(false);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [firstName, setFirstName] = useState('');
    const [firstSurname, setFirstSurname] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setError('');
        try {
            const user = await authService.login(email, password);
            console.log('Login successful:', user);
            // Save user to localStorage or context here if needed
            localStorage.setItem('user', JSON.stringify(user));
            // alert(`Bienvenido, ${user.firstName}!`);
            navigate('/dashboard'); // Navigate to dashboard
        } catch (err) {
            setError(err.message || 'Error al iniciar sesión');
        }
    };

    const handleRegister = async (e) => {
        e.preventDefault();
        setError('');
        if (password !== confirmPassword) {
            setError('Las contraseñas no coinciden');
            return;
        }

        try {
            const userData = {
                firstName,
                firstSurname,
                email,
                password
            };
            const user = await authService.register(userData);
            console.log('Registration successful:', user);
            localStorage.setItem('user', JSON.stringify(user)); // Save user
            alert('Registro exitoso! Por favor inicia sesión.');
            setIsRegistering(false); // Switch to login view
        } catch (err) {
            setError(err.message || 'Error al registrarse');
        }
    };

    const toggleMode = () => {
        setIsRegistering(!isRegistering);
        setError('');
        setEmail('');
        setPassword('');
        setConfirmPassword('');
        setFirstName('');
        setFirstSurname('');
    };

    return (
        <div className="authentication-screen">
            <button className="back-button" onClick={() => navigate('/')}>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M19 12H5"></path>
                    <polyline points="12 19 5 12 12 5"></polyline>
                </svg>
                Volver
            </button>

            <div className="auth-container">
                <div className="auth-card">
                    <h2 className="auth-title">
                        {isRegistering ? 'Únete a ' : 'Bienvenido a '}
                        <span className="highlight-blue">KUDO</span>
                    </h2>
                    <p className="auth-subtitle">
                        {isRegistering
                            ? 'Crea tu cuenta para empezar a conectar'
                            : 'Ingresa a tu cuenta para gestionar tu perfil profesional'}
                    </p>

                    {error && <div style={{ color: 'red', marginBottom: '1rem', textAlign: 'center' }}>{error}</div>}

                    {!isRegistering ? (
                        /* LOGIN FORM */
                        <>
                            <form onSubmit={handleLogin} className="auth-form">
                                <div className="form-group">
                                    <label htmlFor="email">Correo Electrónico</label>
                                    <input
                                        type="email"
                                        id="email"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        placeholder="tu@email.com"
                                        required
                                    />
                                </div>

                                <div className="form-group">
                                    <label htmlFor="password">Contraseña</label>
                                    <input
                                        type="password"
                                        id="password"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder="••••••••"
                                        required
                                    />
                                </div>

                                <div className="form-actions">
                                    <a href="#" className="forgot-password">¿Olvidaste tu contraseña?</a>
                                </div>

                                <button type="submit" className="login-btn">Iniciar Sesión</button>
                            </form>

                            <div className="auth-footer">
                                <p>¿No tienes cuenta? <button type="button" onClick={toggleMode} className="register-link">Regístrate</button></p>
                            </div>
                        </>
                    ) : (
                        /* REGISTER FORM */
                        <>
                            <form onSubmit={handleRegister} className="auth-form">
                                <div className="form-group-row" style={{ display: 'flex', gap: '1rem' }}>
                                    <div className="form-group" style={{ flex: 1 }}>
                                        <label htmlFor="firstName">Nombre</label>
                                        <input
                                            type="text"
                                            id="firstName"
                                            value={firstName}
                                            onChange={(e) => setFirstName(e.target.value)}
                                            placeholder="Juan"
                                            required
                                        />
                                    </div>
                                    <div className="form-group" style={{ flex: 1 }}>
                                        <label htmlFor="firstSurname">Apellido</label>
                                        <input
                                            type="text"
                                            id="firstSurname"
                                            value={firstSurname}
                                            onChange={(e) => setFirstSurname(e.target.value)}
                                            placeholder="Pérez"
                                            required
                                        />
                                    </div>
                                </div>

                                <div className="form-group">
                                    <label htmlFor="register-email">Correo Electrónico</label>
                                    <input
                                        type="email"
                                        id="register-email"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        placeholder="tu@email.com"
                                        required
                                    />
                                </div>

                                <div className="form-group">
                                    <label htmlFor="register-password">Contraseña</label>
                                    <input
                                        type="password"
                                        id="register-password"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder="••••••••"
                                        required
                                    />
                                </div>

                                <div className="form-group">
                                    <label htmlFor="confirm-password">Confirmar Contraseña</label>
                                    <input
                                        type="password"
                                        id="confirm-password"
                                        value={confirmPassword}
                                        onChange={(e) => setConfirmPassword(e.target.value)}
                                        placeholder="••••••••"
                                        required
                                    />
                                </div>

                                <button type="submit" className="login-btn">Crear Cuenta</button>
                            </form>

                            <div className="auth-footer">
                                <p>¿Ya tienes cuenta? <button type="button" onClick={toggleMode} className="register-link">Inicia Sesión</button></p>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </div>
    );
};

export default AuthenticationScreen;
