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
            // Mapping frontend userData to backend User entity structure
            const payload = {
                firstName: userData.firstName,
                firstSurname: userData.firstSurname,
                email: userData.email,
                passwordHash: userData.password, // Backend expects passwordHash, sending plain password as requested
                role: 'creator', // Default role
                isDeleted: false,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            const response = await fetch(API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                const error = await response.text();
                throw new Error(error || 'Error en el registro');
            }

            return await response.json();
        } catch (error) {
            console.error('Register error:', error);
            throw error;
        }
    }
};
