// src/viewmodels/courses/CourseAccessViewModel.js
import { db } from "../../firebase";
import { doc, getDoc } from "firebase/firestore";

class CourseAccessViewModel {
  async userHasAccess(userId, courseId) {
    if (!userId || !courseId) return false;

    // Vérifie dans la sous-collection myCourses
    const courseRef = doc(db, "users", userId, "myCourses", courseId);
    const courseSnap = await getDoc(courseRef);

    return courseSnap.exists(); // l’utilisateur possède le cours
  }
}

export default new CourseAccessViewModel();
