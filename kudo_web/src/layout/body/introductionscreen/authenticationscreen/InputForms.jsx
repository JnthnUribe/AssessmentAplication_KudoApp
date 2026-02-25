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
    const [success, setSuccess] = useState('');
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

        // 1. Sanitization: Trim
        const cleanFirstName = firstName.trim();
        const cleanFirstSurname = firstSurname.trim();
        const cleanEmail = email.trim().toLowerCase(); // Email to lowercase
        const cleanPassword = password;
        const cleanConfirmPassword = confirmPassword;

        // 2. Validation: Campos Obligatorios
        if (!cleanFirstName || !cleanFirstSurname || !cleanEmail || !cleanPassword || !cleanConfirmPassword) {
            setError('Todos los campos son obligatorios');
            return;
        }

        // 3. Validation: Email Formato (Regex)
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(cleanEmail)) {
            setError('Formato de correo electrónico no válido');
            return;
        }

        // 4. Validation: Longitud mínima (8+)
        if (cleanPassword.length < 8) {
            setError('La contraseña debe tener al menos 8 caracteres');
            return;
        }

        // 5. Validation: Requisito de complejidad (Mayúsculas, números, símbolos)
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        if (!passwordRegex.test(cleanPassword)) {
            setError('La contraseña debe contener al menos una mayúscula, una minúscula, un número y un carácter especial');
            return;
        }

        // 6. Validation: Comparación de igualdad
        if (cleanPassword !== cleanConfirmPassword) {
            setError('Las contraseñas no coinciden');
            return;
        }

        try {
            const userData = {
                firstName: cleanFirstName,
                firstSurname: cleanFirstSurname,
                email: cleanEmail,
                password: cleanPassword,
                confirmPassword: cleanConfirmPassword
            };
            const user = await authService.register(userData);
            console.log('Registration successful:', user);
            setSuccess('¡Registro exitoso! Por favor inicia sesión.');

            // Clear only name and confirmation fields, preserve email and password for login
            setConfirmPassword('');
            setFirstName('');
            setFirstSurname('');

            // Transition to login faster (1s)
            setTimeout(() => {
                setSuccess('');
                if (toggleMode) toggleMode();
            }, 1000);

        } catch (err) {
            setError(err.message || 'Error al registrarse');
        }
    };

    const handleToggle = () => {
        setError('');
        setSuccess('');
        setEmail('');
        setPassword('');
        setConfirmPassword('');
        setFirstName('');
        setFirstSurname('');
        if (toggleMode) toggleMode();
    };

    return (
        <>
            {error && <div className="auth-message error">{error}</div>}
            {success && <div className="auth-message success">{success}</div>}

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
                                placeholder="Correo: usuario@correo.com"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Contraseña (mín. 8 caracteres)"
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
                                    placeholder="Nombre: Juan"
                                    required
                                />
                            </div>
                            <div className="form-group" style={{ flex: 1 }}>
                                <input
                                    type="text"
                                    id="firstSurname"
                                    value={firstSurname}
                                    onChange={(e) => setFirstSurname(e.target.value)}
                                    placeholder="Apellido: Pérez"
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
                                placeholder="Email: juan.perez@ejemplo.com"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="register-password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Contraseña: Segura123!"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <input
                                type="password"
                                id="confirm-password"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                placeholder="Repetir Contraseña: Segura123!"
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
