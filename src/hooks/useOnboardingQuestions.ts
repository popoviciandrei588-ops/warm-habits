import { useState, useEffect } from 'react';

const ONBOARDING_QUESTIONS_KEY = 'habit-tracker-onboarding-questions-complete';

export interface UserPreferences {
  goals: string[];
  experience: string;
  reminderTime: string;
}

export const useOnboardingQuestions = () => {
  const [showQuestionnaire, setShowQuestionnaire] = useState(false);
  const [preferences, setPreferences] = useState<UserPreferences | null>(null);

  useEffect(() => {
    const completed = localStorage.getItem(ONBOARDING_QUESTIONS_KEY);
    if (!completed) {
      setShowQuestionnaire(true);
    } else {
      try {
        setPreferences(JSON.parse(completed));
      } catch {
        setPreferences(null);
      }
    }
  }, []);

  const completeQuestionnaire = (prefs: UserPreferences) => {
    localStorage.setItem(ONBOARDING_QUESTIONS_KEY, JSON.stringify(prefs));
    setPreferences(prefs);
    setShowQuestionnaire(false);
  };

  const resetQuestionnaire = () => {
    localStorage.removeItem(ONBOARDING_QUESTIONS_KEY);
    setPreferences(null);
    setShowQuestionnaire(true);
  };

  return {
    showQuestionnaire,
    preferences,
    completeQuestionnaire,
    resetQuestionnaire,
  };
};
