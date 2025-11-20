// src/models/CourseModel.js
import { collection, getDocs } from "firebase/firestore";
import { db } from "../firebase";

export const fetchCoursesFromDB = async () => {
  const querySnapshot = await getDocs(collection(db, "courses"));
  console.log("Docs trouvés:", querySnapshot.docs.length);
  const coursesData = await Promise.all(
    querySnapshot.docs.map(async (docSnap) => {
      const course = { id: docSnap.id, ...docSnap.data() };
      console.log("Course récupérée:", course.title);
      const reviewsSnapshot = await getDocs(
        collection(db, "courses", course.id, "reviews")
      );
      const reviews = reviewsSnapshot.docs.map((r) => r.data());

      const average =
        reviews.length > 0
          ? (
              reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
            ).toFixed(1)
          : 0;

      return { ...course, averageRating: average };
    })
  );

  return coursesData;
};
