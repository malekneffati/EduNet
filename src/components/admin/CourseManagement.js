import React, { useEffect, useState } from "react";
import { db, auth } from "../../utils/firebaseConfig";
import {
  collection,
  getDocs,
  addDoc,
  deleteDoc,
  doc,
  updateDoc,
} from "firebase/firestore";
import CourseForm from "./CourseForm";

const CourseManagement = () => {
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingCourse, setEditingCourse] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");

  const fetchCourses = async () => {
    setLoading(true);
    try {
      const snap = await getDocs(collection(db, "courses"));
      const list = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
      setCourses(list);
    } catch (err) {
      console.error("fetchCourses error", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCourses();
  }, []);

  // Ajouter
  const handleAddCourse = async (payload) => {
    try {
      const user = auth.currentUser;
      await addDoc(collection(db, "courses"), {
        ...payload,
        createdBy: user ? user.uid : null,
        createdAt: new Date().toISOString(),
      });
      setShowForm(false);
      fetchCourses();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  // Modifier
  const handleUpdateCourse = async (payload) => {
    try {
      await updateDoc(doc(db, "courses", editingCourse.id), {
        ...payload,
        updatedAt: new Date().toISOString(),
      });
      setEditingCourse(null);
      setShowForm(false);
      fetchCourses();
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  // Supprimer
  const handleDelete = async (id) => {
    if (!window.confirm("Supprimer ce cours ?")) return;
    try {
      await deleteDoc(doc(db, "courses", id));
      fetchCourses();
    } catch (err) {
      console.error(err);
    }
  };

  // Filtrage en temps réel selon le titre
  const filteredCourses = courses.filter((c) =>
    c.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap justify-between items-center mb-6 gap-3">
        <input
          type="text"
          placeholder="Rechercher un cour..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="border p-2 rounded flex-1 min-w-[250px]"
        />

        {/* Bouton Ajouter */}
        <button
          onClick={() => {
            setEditingCourse(null);
            setShowForm(true);
          }}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow"
        >
          + Ajouter un cours
        </button>
      </div>

      {/* Tableau */}
      {loading ? (
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
              {filteredCourses.length === 0 ? (
                <tr>
                  <td className="p-3 text-gray-500" colSpan="6">
                    Aucun cours pour le moment.
                  </td>
                </tr>
              ) : (
                filteredCourses.map((c) => (
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
                          setEditingCourse(c);
                          setShowForm(true);
                        }}
                        className="text-blue-600 hover:underline"
                      >
                        Modifier
                      </button>

                      <button
                        onClick={() => handleDelete(c.id)}
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
      {showForm && (
        <CourseForm
          initialData={editingCourse}
          onCancel={() => {
            setShowForm(false);
            setEditingCourse(null);
          }}
          onSave={editingCourse ? handleUpdateCourse : handleAddCourse}
        />
      )}
    </div>
  );
};

export default CourseManagement;
