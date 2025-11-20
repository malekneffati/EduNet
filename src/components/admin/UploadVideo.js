import React from "react";
import useUpload from "../../viewmodels/admin/useUpload";

const UploadVideo = ({ onUploadComplete, existingUrl = null }) => {
  const { uploading, progress, error, uploadFile } = useUpload({
    resourceType: "video",
    maxSize: 500 * 1024 * 1024, // 500 MB
    allowedTypes: ["video/mp4", "video/webm", "video/ogg", "video/quicktime"],
    cloudName: "dshxkgodt",
    uploadPreset: "react_upload",
  });

  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) uploadFile(file, onUploadComplete);
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

export default UploadVideo;
