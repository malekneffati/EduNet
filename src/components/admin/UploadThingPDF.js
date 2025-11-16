// src/components/admin/UploadThingPDF.js
import React, { useState } from "react";

const UploadThingPDF = ({ onUploadComplete, existingUrl = null }) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState(null);

  const CLOUD_NAME = "dshxkgodt";
  const UPLOAD_PRESET = "react_upload"; 
  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const maxSize = 50 * 1024 * 1024; // 50 MB
    if (file.type !== "application/pdf") {
      setError("⚠️ Seuls les fichiers PDF sont acceptés");
      return;
    }
    if (file.size > maxSize) {
      setError("⚠️ Le PDF ne doit pas dépasser 50 MB");
      return;
    }

    setError(null);
    setUploading(true);
    setProgress(0);

    const formData = new FormData();
    formData.append("file", file);
    formData.append("upload_preset", UPLOAD_PRESET);
    formData.append("resource_type", "raw"); // PDF

    try {
      const xhr = new XMLHttpRequest();
      xhr.open(
        "POST",
        `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/raw/upload`
      );

      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable) {
          setProgress(Math.round((event.loaded / event.total) * 100));
        }
      };

      xhr.onload = () => {
        if (xhr.status === 200) {
          const data = JSON.parse(xhr.response);
          onUploadComplete(data.secure_url);
          setUploading(false);
        } else {
          setError("Erreur lors de l'upload du PDF");
          setUploading(false);
        }
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

  return (
    <div className="space-y-3">
      <label
        className={`flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed rounded-lg cursor-pointer ${
          uploading
            ? "border-blue-300 bg-blue-50 cursor-not-allowed"
            : "border-gray-300 hover:border-blue-500 hover:bg-blue-50"
        }`}
      >
        {uploading ? (
          <span>Upload en cours... {progress}%</span>
        ) : existingUrl ? (
          <span>📄 Changer le PDF</span>
        ) : (
          <span>📄 Cliquer pour uploader un PDF</span>
        )}
        <input
          type="file"
          accept="application/pdf"
          onChange={handleFileChange}
          disabled={uploading}
          className="hidden"
        />
      </label>
      {error && <p className="text-red-600">{error}</p>}
      {existingUrl && !uploading && (
        <a
          href={existingUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-600 underline"
        >
          Voir le PDF
        </a>
      )}
    </div>
  );
};

export default UploadThingPDF;
