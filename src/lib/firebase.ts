import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBEaM9xsFeYkSVxKYSQPhL_A9iXGNRCvXQ",
  authDomain: "warmhabits-6eb64.firebaseapp.com",
  projectId: "warmhabits-6eb64",
  storageBucket: "warmhabits-6eb64.firebasestorage.app",
  messagingSenderId: "113019280668",
  appId: "1:113019280668:web:601ba41850a149dc3d6ed9"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export default app;
