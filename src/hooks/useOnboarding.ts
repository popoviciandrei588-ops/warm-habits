import { useState, useEffect } from 'react';

const ONBOARDING_KEY = 'habit-tracker-onboarding-complete';

export interface OnboardingStep {
  id: string;
  title: string;
  description: string;
  targetSelector: string;
  position: 'top' | 'bottom' | 'left' | 'right';
}

export const onboardingSteps: OnboardingStep[] = [
  {
    id: 'welcome',
    title: 'Welcome to Habit Tracker! 🎉',
    description: 'Let me show you around so you can start building better habits.',
    targetSelector: '[data-tour="header"]',
    position: 'bottom',
  },
  {
    id: 'add-habit',
    title: 'Add Your First Habit',
    description: 'Click here to create a new habit you want to track daily.',
    targetSelector: '[data-tour="add-habit"]',
    position: 'bottom',
  },
  {
    id: 'stats',
    title: 'Track Your Progress',
    description: 'See your overall statistics including total habits, daily completions, and streaks.',
    targetSelector: '[data-tour="stats"]',
    position: 'bottom',
  },
  {
    id: 'calendar',
    title: 'Calendar View',
    description: 'Navigate through dates and see your habit completion history at a glance.',
    targetSelector: '[data-tour="calendar"]',
    position: 'left',
  },
  {
    id: 'habits-list',
    title: 'Your Habits List',
    description: 'Check off habits as you complete them. Build streaks by staying consistent!',
    targetSelector: '[data-tour="habits-list"]',
    position: 'right',
  },
];

export const useOnboarding = () => {
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [currentStep, setCurrentStep] = useState(0);
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    // Check if onboarding was already completed
    const completed = localStorage.getItem(ONBOARDING_KEY);
    if (!completed) {
      // Small delay to ensure DOM is ready
      const timer = setTimeout(() => {
        setShowOnboarding(true);
        setIsReady(true);
      }, 500);
      return () => clearTimeout(timer);
    }
  }, []);

  const nextStep = () => {
    if (currentStep < onboardingSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      completeOnboarding();
    }
  };

  const prevStep = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const skipOnboarding = () => {
    completeOnboarding();
  };

  const completeOnboarding = () => {
    localStorage.setItem(ONBOARDING_KEY, 'true');
    setShowOnboarding(false);
  };

  const resetOnboarding = () => {
    localStorage.removeItem(ONBOARDING_KEY);
    setCurrentStep(0);
    setShowOnboarding(true);
  };

  return {
    showOnboarding,
    currentStep,
    currentStepData: onboardingSteps[currentStep],
    totalSteps: onboardingSteps.length,
    nextStep,
    prevStep,
    skipOnboarding,
    resetOnboarding,
    isReady,
  };
};
