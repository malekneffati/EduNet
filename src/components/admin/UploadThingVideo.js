// src/components/admin/UploadThingVideo.js
import React, { useState } from "react";

const UploadThingVideo = ({ onUploadComplete, existingUrl = null }) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState(null);

  const CLOUD_NAME = "dshxkgodt";
  const UPLOAD_PRESET = "react_upload"; 

  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const maxSize = 500 * 1024 * 1024; // 500 MB
    const allowedTypes = [
      "video/mp4",
      "video/webm",
      "video/ogg",
      "video/quicktime",
    ];

    if (!allowedTypes.includes(file.type)) {
      setError("⚠️ Format accepté : MP4, WebM, OGG, MOV");
      return;
    }
    if (file.size > maxSize) {
      setError("⚠️ La vidéo ne doit pas dépasser 500 MB");
      return;
    }

    setError(null);
    setUploading(true);
    setProgress(0);

    const formData = new FormData();
    formData.append("file", file);
    formData.append("upload_preset", UPLOAD_PRESET);
    formData.append("resource_type", "video");

    try {
      const xhr = new XMLHttpRequest();
      xhr.open(
        "POST",
        `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/video/upload`
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
          setError("Erreur lors de l'upload de la vidéo");
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
        className={`relative flex items-center justify-center gap-3 px-6 py-4 border-2 border-dashed rounded-xl cursor-pointer transition-all ${
          uploading
            ? "border-blue-400 bg-blue-50 cursor-not-allowed"
            : "border-gray-300 hover:border-blue-500 hover:bg-blue-50"
        }`}
      >
        {uploading ? (
          <>
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
            <span>Upload en cours... {progress}%</span>
          </>
        ) : existingUrl ? (
          <span>🎬 Changer la vidéo</span>
        ) : (
          <span>📹 Cliquer pour uploader une vidéo</span>
        )}
        <input
          type="file"
          accept="video/mp4,video/webm,video/ogg,video/quicktime"
          onChange={handleFileChange}
          disabled={uploading}
          className="hidden"
        />
      </label>

      {error && <p className="text-red-600">{error}</p>}
      {existingUrl && !uploading && (
        <video
          src={existingUrl}
          controls
          className="w-full rounded-lg shadow-sm"
        />
      )}
    </div>
  );
};

export default UploadThingVideo;
