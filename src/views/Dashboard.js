// src/views/Dashboard.js
import React from "react";
import DashboardView from "../components/student/DashboardView";
import { useDashboardViewModel } from "../viewmodels/student/DashboardViewModel";

const Dashboard = () => {
  const viewModel = useDashboardViewModel();
  return <DashboardView {...viewModel} />;
};

export default Dashboard;
