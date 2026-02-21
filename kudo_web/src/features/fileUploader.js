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

        if (data.secure_url) {
            // Insertamos los parámetros de optimización en la URL ("f_auto" = formato automático, "q_auto" = calidad automática, "w_800" = ancho 800px)
            const urlFinal = data.secure_url.replace("/upload/", "/upload/f_auto,q_auto,w_800/");
            return urlFinal;
        } else {
            throw new Error('No se pudo obtener la URL de la imagen. Verifica tu Cloud Name y Preset.');
        }
    } catch (error) {
        console.error("Error subiendo la imagen:", error);
        throw error;
    }
};
