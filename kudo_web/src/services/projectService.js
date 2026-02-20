const API_URL = 'http://localhost:5145/api/Projects';

export const projectService = {
    getAll: async () => {
        try {
            const response = await fetch(API_URL);
            if (!response.ok) throw new Error('Error fetching projects');
            return await response.json();
        } catch (error) {
            console.error('Get projects error:', error);
            throw error;
        }
    },

    getById: async (id) => {
        try {
            const response = await fetch(`${API_URL}/${id}`);
            if (!response.ok) throw new Error('Error fetching project');
            return await response.json();
        } catch (error) {
            console.error('Get project error:', error);
            throw error;
        }
    },

    getByCreatorId: async (creatorId) => {
        try {
            const response = await fetch(`${API_URL}/creator/${creatorId}`);
            if (!response.ok) throw new Error('Error fetching projects by creator');
            return await response.json();
        } catch (error) {
            console.error('Get projects by creator error:', error);
            throw error;
        }
    },

    create: async (projectData) => {
        try {
            // Ensure data structure matches Project.cs entity
            const payload = {
                ...projectData,
                // Default values if not provided
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
                throw new Error(error || 'Error creating project');
            }

            return await response.json();
        } catch (error) {
            console.error('Create project error:', error);
            throw error;
        }
    },

    update: async (id, projectData) => {
        try {
            const response = await fetch(`${API_URL}/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(projectData),
            });

            if (!response.ok) throw new Error('Error updating project');
            return true; // No content returned
        } catch (error) {
            console.error('Update project error:', error);
            throw error;
        }
    },

    delete: async (id) => {
        try {
            const response = await fetch(`${API_URL}/${id}`, {
                method: 'DELETE',
            });

            if (!response.ok) throw new Error('Error deleting project');
            return true;
        } catch (error) {
            console.error('Delete project error:', error);
            throw error;
        }
    }
};
