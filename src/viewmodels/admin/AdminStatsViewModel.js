import { db } from "../../firebase/config";
import { collection, getDocs } from "firebase/firestore";

export default class AdminStatsViewModel {
  static async getStats() {
    try {
      const snap = await getDocs(collection(db, "paiements"));

      let monthlyRevenue = {};
      let courseSales = {};

      snap.forEach((doc) => {
        const data = doc.data();
        if (data.status !== "success") return;

        const date = new Date(data.createdAt);
        const monthKey = `${date.getFullYear()}-${date.getMonth() + 1}`;

        // Revenus par mois
        monthlyRevenue[monthKey] =
          (monthlyRevenue[monthKey] || 0) + data.amount;

        // Top cours vendus
        courseSales[data.courseTitle] =
          (courseSales[data.courseTitle] || 0) + 1;
      });

      return { monthlyRevenue, courseSales };
    } catch (err) {
      console.error("Erreur récupération stats:", err);
      return { monthlyRevenue: {}, courseSales: {} };
    }
  }
}
