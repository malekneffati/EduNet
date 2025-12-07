// src/components/admin/MonthlySalesDualChart.jsx
import React, { useEffect, useState } from "react";
import { Bar } from "react-chartjs-2";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../firebaseConfig";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const MonthlySalesDualChart = () => {
  const [chartData, setChartData] = useState({
    labels: [],
    datasets: [],
  });

  useEffect(() => {
    const fetchSales = async () => {
      const paiementsRef = collection(db, "paiements");
      const snap = await getDocs(paiementsRef);

      const salesPerMonth = {}; // { "YYYY-MM": { revenue: X, count: Y } }

      snap.forEach((doc) => {
        const data = doc.data();
        const date = data.date?.toDate
          ? data.date.toDate()
          : new Date(data.date);
        const month = `${date.getFullYear()}-${String(
          date.getMonth() + 1
        ).padStart(2, "0")}`;

        if (!salesPerMonth[month])
          salesPerMonth[month] = { revenue: 0, count: 0 };

        salesPerMonth[month].revenue += data.montant || 0;
        salesPerMonth[month].count += 1;
      });

      const labels = Object.keys(salesPerMonth).sort();
      const revenueData = labels.map((month) => salesPerMonth[month].revenue);
      const countData = labels.map((month) => salesPerMonth[month].count);

      setChartData({
        labels,
        datasets: [
          {
            label: "Revenu (TND)",
            data: revenueData,
            backgroundColor: "rgba(99, 102, 241, 0.7)", // violet
            yAxisID: "y1",
          },
          {
            label: "Nombre de ventes",
            data: countData,
            backgroundColor: "rgba(16, 185, 129, 0.7)", // vert
            yAxisID: "y2",
          },
        ],
      });
    };

    fetchSales();
  }, []);

  const options = {
    responsive: true,
    interaction: {
      mode: "index",
      intersect: false,
    },
    scales: {
      y1: {
        type: "linear",
        position: "left",
        title: { display: true, text: "Revenu (TND)" },
      },
      y2: {
        type: "linear",
        position: "right",
        title: { display: true, text: "Nombre de ventes" },
        grid: { drawOnChartArea: false },
      },
    },
  };

  return <Bar data={chartData} options={options} />;
};

export default MonthlySalesDualChart;
