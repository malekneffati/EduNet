import { useState } from "react";

const useUpload = ({
  resourceType,
  maxSize,
  allowedTypes = null,
  cloudName,
  uploadPreset,
}) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState(null);

  const uploadFile = async (file, onComplete) => {
    if (!file) return;

    if (allowedTypes && !allowedTypes.includes(file.type)) {
      setError(`⚠️ Format non supporté`);
      return;
    }

    if (file.size > maxSize) {
      setError(
        `⚠️ Le fichier dépasse la taille maximale (${
          maxSize / (1024 * 1024)
        } MB)`
      );
      return;
    }

    setError(null);
    setUploading(true);
    setProgress(0);

    const formData = new FormData();
    formData.append("file", file);
    formData.append("upload_preset", uploadPreset);
    formData.append("resource_type", resourceType);

    try {
      const xhr = new XMLHttpRequest();
      xhr.open(
        "POST",
        `https://api.cloudinary.com/v1_1/${cloudName}/${resourceType}/upload`
      );

      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable) {
          setProgress(Math.round((event.loaded / event.total) * 100));
        }
      };

      xhr.onload = () => {
        if (xhr.status === 200) {
          const data = JSON.parse(xhr.response);
          onComplete(data.secure_url);
        } else {
          setError(`Erreur lors de l'upload du fichier`);
        }
        setUploading(false);
      };

      xhr.onerror = () => {
        setError("Erreur réseau pendant l'upload");
        setUploading(false);
      };

      xhr.send(formData);
    } catch (err) {
      console.error(err);
      setError("Erreur lors de l'upload");
      setUploading(false);
    }
  };

  return { uploading, progress, error, uploadFile };
};

export default useUpload;
