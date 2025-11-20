// src/viewmodels/admin/CourseManagementViewModel.js
import { useState, useEffect } from "react";
import { db, auth } from "../../firebaseConfig";
import {
  collection,
  getDocs,
  addDoc,
  deleteDoc,
  doc,
  updateDoc,
} from "firebase/firestore";

const useCourseManagementViewModel = () => {
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

  // Ajouter un cours
  const addCourse = async (payload) => {
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

  // Modifier un cours
  const updateCourse = async (payload) => {
    if (!editingCourse) return;
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

  // Supprimer un cours
  const deleteCourse = async (id) => {
    if (!window.confirm("Supprimer ce cours ?")) return;
    try {
      await deleteDoc(doc(db, "courses", id));
      fetchCourses();
    } catch (err) {
      console.error(err);
    }
  };

  // Filtrage dynamique
  const filteredCourses = courses.filter((c) =>
    c.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return {
    courses,
    loading,
    showForm,
    editingCourse,
    searchTerm,
    setSearchTerm,
    setShowForm,
    setEditingCourse,
    addCourse,
    updateCourse,
    deleteCourse,
    filteredCourses,
  };
};

export default useCourseManagementViewModel;
