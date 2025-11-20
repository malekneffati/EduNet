// src/pages/CatalogPage.js
import React from "react";
import Catalog from "../components/catalog/Catalog";
import { useCatalogViewModel } from "../viewmodels/courses/CatalogViewModel";

const CatalogPage = () => {
  const catalogVM = useCatalogViewModel();

  return <Catalog {...catalogVM} />;
};

export default CatalogPage;
