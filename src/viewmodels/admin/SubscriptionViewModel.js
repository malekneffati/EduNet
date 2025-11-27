// src/viewmodels/SubscriptionViewModel.js
import { useState, useEffect } from "react";
import {
  getSubscriptionPlans,
  updateSubscriptionPrice,
} from "../../models/SubscriptionModel";

export function useSubscriptionViewModel() {
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      const data = await getSubscriptionPlans();
      setPlans(data);
      setLoading(false);
    }
    load();
  }, []);

  async function changePrice(planId, newPrice) {
    await updateSubscriptionPrice(planId, newPrice);
    setPlans(
      plans.map((p) => (p.id === planId ? { ...p, price: newPrice } : p))
    );
  }

  return { plans, loading, changePrice };
}
