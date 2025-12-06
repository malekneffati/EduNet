import { db } from "../../firebase";
import {
  doc,
  getDoc,
  collection,
  getDocs,
  query,
  where,
} from "firebase/firestore";

class CourseAccessViewModel {
  async userHasAccess(userId, courseId) {
    if (!userId) return false;

    const userSnap = await getDoc(doc(db, "users", userId));
    if (!userSnap.exists()) return false;

    // 2️⃣ Vérifier si le cours est dans la sous-collection myCourses
    const myCoursesRef = collection(db, "users", userId, "myCourses");
    const q = query(myCoursesRef, where("courseId", "==", courseId));
    const querySnap = await getDocs(q);

    return !querySnap.empty;
  }
}

export default new CourseAccessViewModel();
