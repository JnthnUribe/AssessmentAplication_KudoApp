export const uploadFile = async (file, uploadPreset, cloudName) => {
    if (!file) {
        throw new Error('Por favor selecciona una imagen primero.');
    }

    const uploadData = new FormData();
    uploadData.append("file", file);
    uploadData.append("upload_preset", uploadPreset);

    try {
        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
            method: 'POST',
            body: uploadData,
        });

        const data = await response.json();
        console.log("Cloudinary Upload Response:", data);

        if (data.secure_url) {
            // Insertamos los parámetros de optimización en la URL
            const urlFinal = data.secure_url.replace("/upload/", "/upload/f_auto,q_auto,w_800/");
            console.log("Delete Token received:", data.delete_token);
            return {
                url: urlFinal,
                deleteToken: data.delete_token
            };
        } else {
            throw new Error('No se pudo obtener la URL de la imagen. Verifica tu Cloud Name y Preset.');
        }
    } catch (error) {
        console.error("Error subiendo la imagen:", error);
        throw error;
    }
};

export const deleteFile = async (deleteToken, cloudName) => {
    console.log("Attempting to delete from Cloudinary with token:", deleteToken);
    if (!deleteToken) {
        console.warn("No delete token provided. Deletion aborted.");
        return;
    }

    try {
        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/delete_by_token`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ token: deleteToken })
        });

        const result = await response.json();
        console.log("Cloudinary Deletion Result:", result);

        if (!response.ok) {
            console.warn("No se pudo eliminar de Cloudinary:", result);
        }
        return result;
    } catch (error) {
        console.error("Error eliminando la imagen de Cloudinary:", error);
    }
};
