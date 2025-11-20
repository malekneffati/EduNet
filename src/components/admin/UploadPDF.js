import React from "react";
import useUpload from "../../viewmodels/admin/useUpload";

const UploadPDF = ({ onUploadComplete, existingUrl = null }) => {
  const { uploading, progress, error, uploadFile } = useUpload({
    resourceType: "raw",
    maxSize: 50 * 1024 * 1024, // 50 MB
    allowedTypes: ["application/pdf"],
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

export default UploadPDF;
