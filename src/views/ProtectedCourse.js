//src/views/ProtectedCourse.js
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import CourseAccessViewModel from "../viewmodels/courses/CourseAccessViewModel";

export default function ProtectedCourse({ children }) {
  const { id: courseId } = useParams();
  const [allowed, setAllowed] = useState(null);

  useEffect(() => {
    const checkAccess = async () => {
      // On prend auth.currentUser.uid si l'utilisateur est connecté
      const userId = localStorage.getItem("userId");
      console.log(
        "Checking course access for userId:",
        userId,
        "courseId:",
        courseId
      );
      const canView = await CourseAccessViewModel.userHasAccess(
        userId,
        courseId
      );
      console.log("Access result:", canView);
      setAllowed(canView);
    };

    checkAccess();
  }, [courseId]);

  if (allowed === null) {
    return <p className="text-center mt-20">Vérification d'accès...</p>;
  }

  // Autorisé ou non → laisser CourseContent gérer le rendu
  return children;
}
