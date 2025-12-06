// src/viewmodels/courses/CourseAccessViewModel.js
import { db } from "../../firebase";
import { doc, getDoc } from "firebase/firestore";

class CourseAccessViewModel {

  async userHasAccess(userId, courseId) {
    if (!userId) return false;

    const userSnap = await getDoc(doc(db, "users", userId));
    if (!userSnap.exists()) return false;

    const data = userSnap.data();

    // Vérifie si le cours est payé ou rejoint gratuitement
    return (
      data.coursesBought?.includes(courseId) ||
      data.myCourses?.[courseId] != null
    );
  }
}

export default new CourseAccessViewModel();
