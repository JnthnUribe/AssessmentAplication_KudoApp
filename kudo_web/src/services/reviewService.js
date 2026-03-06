const API_URL = 'https://assessmentaplication-kudoapp.onrender.com/api/Reviews';

export const reviewService = {
    getByProjectId: async (projectId) => {
        try {
            const response = await fetch(`${API_URL}/project/${projectId}`);
            if (!response.ok) throw new Error('Error fetching reviews for project');
            return await response.json();
        } catch (error) {
            console.error('Get reviews by project error:', error);
            throw error;
        }
    }
};
