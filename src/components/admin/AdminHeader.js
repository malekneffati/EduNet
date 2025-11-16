import React from "react";

const AdminHeader = ({ title }) => {
  return (
    <header className="mb-8">
      <h1 className="text-3xl font-bold text-gray-800">{title}</h1>
    </header>
  );
};

export default AdminHeader;
