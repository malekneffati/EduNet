import { auth, db } from "./firebaseConfig";
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithPopup,
  onAuthStateChanged,
} from "firebase/auth";
import { doc, setDoc, getDoc } from "firebase/firestore";

export const handleRegister = async (email, password, name) => {
  const userCredential = await createUserWithEmailAndPassword(
    auth,
    email,
    password
  );
  const user = userCredential.user;

  await new Promise((resolve) => {
    const unsubscribe = onAuthStateChanged(auth, (u) => {
      if (u) {
        unsubscribe();
        resolve();
      }
    });
  });

  await setDoc(doc(db, "users", user.uid), {
    name,
    email,
    role: "student", 
    createdAt: new Date().toISOString(),
  });

  return { user, role: "student" };
};


export const handleLogin = async (email, password) => {
  const userCredential = await signInWithEmailAndPassword(
    auth,
    email,
    password
  );
  const user = userCredential.user;

  const docSnap = await getDoc(doc(db, "users", user.uid));
  if (!docSnap.exists()) throw new Error("Utilisateur non trouvé");
  const role = docSnap.data().role.toLowerCase();

  return { user, role };
};

export const handleGoogleAuth = async () => {
  const provider = new GoogleAuthProvider();
  const result = await signInWithPopup(auth, provider);
  const user = result.user;

  const userRef = doc(db, "users", user.uid);
  const userSnap = await getDoc(userRef);

  if (!userSnap.exists()) {
    await setDoc(userRef, {
      name: user.displayName,
      email: user.email,
      role: "student",
      createdAt: new Date().toISOString(),
    });
  }

  const userDoc = await getDoc(doc(db, "users", user.uid));
  const role = userDoc.exists() ? userDoc.data().role.toLowerCase() : "student";
  return { user, role };
};
