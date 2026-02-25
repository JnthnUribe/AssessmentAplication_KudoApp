const API_URL = 'http://localhost:5145/api/Users';

export const authService = {
    login: async (email, password) => {
        try {
            const response = await fetch(`${API_URL}/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email, password }),
            });

            if (!response.ok) {
                const error = await response.text();
                throw new Error(error || 'Error en el inicio de sesión');
            }

            return await response.json();
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    },

    register: async (userData) => {
        try {
            // New structure matching RegisterRequest DTO
            const payload = {
                firstName: userData.firstName,
                firstSurname: userData.firstSurname,
                email: userData.email,
                password: userData.password,
                confirmPassword: userData.confirmPassword
            };

            const response = await fetch(`${API_URL}/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const errorMessage = errorData.message || errorData.errors ? Object.values(errorData.errors).flat().join(', ') : 'Error en el registro';
                throw new Error(errorMessage || 'Error en el registro');
            }

            return await response.json();
        } catch (error) {
            console.error('Register error:', error);
            throw error;
        }
    }
};
