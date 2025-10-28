// src/utils/firebaseConfig.js
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAVwXVdXXMaHAmEJMxe_mZCQLTWQCzvD1s",
  authDomain: "edunet-1574d.firebaseapp.com",
  projectId: "edunet-1574d",
  storageBucket: "edunet-1574d.firebasestorage.app",
  messagingSenderId: "382115033753",
  appId: "1:382115033753:web:05913ab72ff36e680ffe08",
  measurementId: "G-7KWEXSRWNC",
};
// Initialise Firebase
const app = initializeApp(firebaseConfig);

// Export des services
export const auth = getAuth(app);
export const db = getFirestore(app);
