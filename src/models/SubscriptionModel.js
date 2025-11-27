// src/models/subscriptionModel.js
import {
  collection,
  getDocs,
  doc,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { db } from "../firebase";

// Nom de la collection Firestore
const PLANS_COLLECTION = "subscription_plans";

// Plans par défaut si la collection est vide
const defaultPlans = [
  {
    id: "yearly",
    name: "Abonnement annuel",
    price: 300,
    billingPeriod: "year",
    description: "Économie de 60 TND",
    active: true,
  },
];

// Récupérer tous les plans
export async function getSubscriptionPlans() {
  const colRef = collection(db, PLANS_COLLECTION);
  const snap = await getDocs(colRef);

  // Si vide, on initialise avec les plans par défaut
  if (snap.empty) {
    await Promise.all(
      defaultPlans.map((plan) =>
        setDoc(doc(db, PLANS_COLLECTION, plan.id), plan)
      )
    );
    return defaultPlans;
  }

  const plans = [];
  snap.forEach((d) => {
    plans.push({ id: d.id, ...d.data() });
  });
  return plans;
}

// Mettre à jour le prix d'un plan
export async function updateSubscriptionPrice(planId, newPrice) {
  const planRef = doc(db, PLANS_COLLECTION, planId);
  await updateDoc(planRef, {
    price: newPrice,
  });
}
