// src/components/admin/CourseManagement.js
import React from "react";
import CourseForm from "./CourseForm";
import useCourseManagementViewModel from "../../viewmodels/admin/CourseManagementViewModel";

const CourseManagement = () => {
  const vm = useCourseManagementViewModel();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap justify-between items-center mb-6 gap-3">
        <input
          type="text"
          placeholder="Rechercher un cours..."
          value={vm.searchTerm}
          onChange={(e) => vm.setSearchTerm(e.target.value)}
          className="border p-2 rounded flex-1 min-w-[250px]"
        />
        <button
          onClick={() => {
            vm.setEditingCourse(null);
            vm.setShowForm(true);
          }}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow"
        >
          + Ajouter un cours
        </button>
      </div>

      {/* Tableau */}
      {vm.loading ? (
        <p>Chargement...</p>
      ) : (
        <div className="bg-white rounded-lg shadow-md p-6 overflow-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b bg-gray-100">
                <th className="p-3">Titre</th>
                <th className="p-3">Catégorie</th>
                <th className="p-3">Prix</th>
                <th className="p-3">Créé le</th>
                <th className="p-3">Actions</th>
              </tr>
            </thead>

            <tbody>
              {vm.filteredCourses.length === 0 ? (
                <tr>
                  <td className="p-3 text-gray-500" colSpan="6">
                    Aucun cours pour le moment.
                  </td>
                </tr>
              ) : (
                vm.filteredCourses.map((c) => (
                  <tr key={c.id} className="border-t hover:bg-gray-50">
                    <td className="p-3 font-medium">{c.title}</td>
                    <td className="p-3">{c.category}</td>
                    <td className="p-3">
                      {c.isFree ? "Gratuit" : `${c.price} TND`}
                    </td>
                    <td className="p-3">
                      {c.createdAt
                        ? new Date(c.createdAt).toLocaleDateString()
                        : "—"}
                    </td>
                    <td className="p-3 flex gap-3">
                      <button
                        onClick={() => {
                          vm.setEditingCourse(c);
                          vm.setShowForm(true);
                        }}
                        className="text-blue-600 hover:underline"
                      >
                        Modifier
                      </button>
                      <button
                        onClick={() => vm.deleteCourse(c.id)}
                        className="text-red-600 hover:underline"
                      >
                        Supprimer
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal formulaire */}
      {vm.showForm && (
        <CourseForm
          initialData={vm.editingCourse}
          onCancel={() => {
            vm.setShowForm(false);
            vm.setEditingCourse(null);
          }}
          onSave={vm.editingCourse ? vm.updateCourse : vm.addCourse}
        />
      )}
    </div>
  );
};

export default CourseManagement;
