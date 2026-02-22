import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../../../../services/authService';
import './InputForms.css';

const InputForms = ({ isRegistering, toggleMode }) => {
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
            localStorage.setItem('user', JSON.stringify(user));
            navigate('/dashboard');
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
            localStorage.setItem('user', JSON.stringify(user));
            alert('Registro exitoso! Por favor inicia sesión.');
            if (toggleMode) toggleMode(); // Switch back to login after successful register
        } catch (err) {
            setError(err.message || 'Error al registrarse');
        }
    };

    const handleToggle = () => {
        setError('');
        setEmail('');
        setPassword('');
        setConfirmPassword('');
        setFirstName('');
        setFirstSurname('');
        if (toggleMode) toggleMode();
    };

    return (
        <>
            {error && <div style={{ color: 'red', marginBottom: '1rem', textAlign: 'center' }}>{error}</div>}

            {!isRegistering ? (
                /* LOGIN FORM */
                <>
                    <form onSubmit={handleLogin} className="auth-form">
                        <div className="form-group">
                            <input
                                type="email"
                                id="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="Correo Electrónico"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Contraseña"
                                required
                            />
                        </div>

                        <button type="submit" className="login-btn">Iniciar Sesión</button>
                    </form>

                    <div className="auth-footer">
                        <p>¿No tienes cuenta? <button type="button" onClick={handleToggle} className="register-link">Regístrate</button></p>
                    </div>
                </>
            ) : (
                /* REGISTER FORM */
                <>
                    <form onSubmit={handleRegister} className="auth-form">
                        <div className="form-group-row" style={{ display: 'flex', gap: '1rem' }}>
                            <div className="form-group" style={{ flex: 1 }}>
                                <input
                                    type="text"
                                    id="firstName"
                                    value={firstName}
                                    onChange={(e) => setFirstName(e.target.value)}
                                    placeholder="Nombre"
                                    required
                                />
                            </div>
                            <div className="form-group" style={{ flex: 1 }}>
                                <input
                                    type="text"
                                    id="firstSurname"
                                    value={firstSurname}
                                    onChange={(e) => setFirstSurname(e.target.value)}
                                    placeholder="Apellido"
                                    required
                                />
                            </div>
                        </div>

                        <div className="form-group">
                            <input
                                type="email"
                                id="register-email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="Correo Electrónico"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="register-password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Contraseña"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="confirm-password"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                placeholder="Confirmar Contraseña"
                                required
                            />
                        </div>

                        <button type="submit" className="login-btn">Crear Cuenta</button>
                    </form>

                    <div className="auth-footer">
                        <p>¿Ya tienes cuenta? <button type="button" onClick={handleToggle} className="register-link">Inicia Sesión</button></p>
                    </div>
                </>
            )}
        </>
    );
};

export default InputForms;
