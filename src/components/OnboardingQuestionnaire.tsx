import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Target, Clock, ChevronRight, ChevronLeft, Check } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { UserPreferences } from '@/hooks/useOnboardingQuestions';

interface OnboardingQuestionnaireProps {
  onComplete: (preferences: UserPreferences) => void;
}

const goalOptions = [
  { id: 'health', label: 'Health & Fitness', icon: '💪' },
  { id: 'productivity', label: 'Productivity', icon: '📈' },
  { id: 'mindfulness', label: 'Mindfulness', icon: '🧘' },
  { id: 'learning', label: 'Learning', icon: '📚' },
  { id: 'creativity', label: 'Creativity', icon: '🎨' },
  { id: 'social', label: 'Social Connections', icon: '🤝' },
];

const experienceOptions = [
  { id: 'beginner', label: 'New to habit tracking', description: "I'm just getting started" },
  { id: 'intermediate', label: 'Some experience', description: "I've tried tracking before" },
  { id: 'advanced', label: 'Experienced', description: 'I regularly track my habits' },
];

const reminderOptions = [
  { id: 'morning', label: 'Morning', time: '8:00 AM', icon: '🌅' },
  { id: 'afternoon', label: 'Afternoon', time: '12:00 PM', icon: '☀️' },
  { id: 'evening', label: 'Evening', time: '6:00 PM', icon: '🌆' },
  { id: 'night', label: 'Night', time: '9:00 PM', icon: '🌙' },
];

export const OnboardingQuestionnaire = ({ onComplete }: OnboardingQuestionnaireProps) => {
  const [step, setStep] = useState(0);
  const [selectedGoals, setSelectedGoals] = useState<string[]>([]);
  const [selectedExperience, setSelectedExperience] = useState('');
  const [selectedReminder, setSelectedReminder] = useState('');

  const toggleGoal = (goalId: string) => {
    setSelectedGoals(prev =>
      prev.includes(goalId)
        ? prev.filter(g => g !== goalId)
        : [...prev, goalId]
    );
  };

  const canProceed = () => {
    switch (step) {
      case 0: return selectedGoals.length > 0;
      case 1: return selectedExperience !== '';
      case 2: return selectedReminder !== '';
      default: return false;
    }
  };

  const handleComplete = () => {
    onComplete({
      goals: selectedGoals,
      experience: selectedExperience,
      reminderTime: selectedReminder,
    });
  };

  const steps = [
    {
      title: 'What are your goals?',
      subtitle: 'Select all areas you want to improve',
      icon: Target,
    },
    {
      title: 'Your experience level',
      subtitle: 'How familiar are you with habit tracking?',
      icon: Sparkles,
    },
    {
      title: 'Best time for reminders',
      subtitle: 'When would you like to check in?',
      icon: Clock,
    },
  ];

  return (
    <div className="fixed inset-0 z-50 bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-lg">
        {/* Progress */}
        <div className="flex gap-2 mb-8">
          {steps.map((_, i) => (
            <div
              key={i}
              className={cn(
                'h-1.5 flex-1 rounded-full transition-colors',
                i <= step ? 'bg-primary' : 'bg-muted'
              )}
            />
          ))}
        </div>

        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            {/* Header */}
            <div className="text-center mb-8">
              <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-glow">
                {(() => {
                  const Icon = steps[step].icon;
                  return <Icon className="w-8 h-8 text-primary-foreground" />;
                })()}
              </div>
              <h1 className="font-display text-2xl font-semibold text-foreground mb-2">
                {steps[step].title}
              </h1>
              <p className="text-muted-foreground">{steps[step].subtitle}</p>
            </div>

            {/* Step Content */}
            {step === 0 && (
              <div className="grid grid-cols-2 gap-3">
                {goalOptions.map(goal => (
                  <button
                    key={goal.id}
                    onClick={() => toggleGoal(goal.id)}
                    className={cn(
                      'p-4 rounded-xl border-2 text-left transition-all',
                      selectedGoals.includes(goal.id)
                        ? 'border-primary bg-primary/10'
                        : 'border-border bg-card hover:border-primary/50'
                    )}
                  >
                    <span className="text-2xl mb-2 block">{goal.icon}</span>
                    <span className="font-medium text-foreground">{goal.label}</span>
                    {selectedGoals.includes(goal.id) && (
                      <Check className="w-4 h-4 text-primary absolute top-2 right-2" />
                    )}
                  </button>
                ))}
              </div>
            )}

            {step === 1 && (
              <div className="space-y-3">
                {experienceOptions.map(option => (
                  <button
                    key={option.id}
                    onClick={() => setSelectedExperience(option.id)}
                    className={cn(
                      'w-full p-4 rounded-xl border-2 text-left transition-all flex items-center justify-between',
                      selectedExperience === option.id
                        ? 'border-primary bg-primary/10'
                        : 'border-border bg-card hover:border-primary/50'
                    )}
                  >
                    <div>
                      <div className="font-medium text-foreground">{option.label}</div>
                      <div className="text-sm text-muted-foreground">{option.description}</div>
                    </div>
                    {selectedExperience === option.id && (
                      <Check className="w-5 h-5 text-primary shrink-0" />
                    )}
                  </button>
                ))}
              </div>
            )}

            {step === 2 && (
              <div className="grid grid-cols-2 gap-3">
                {reminderOptions.map(option => (
                  <button
                    key={option.id}
                    onClick={() => setSelectedReminder(option.id)}
                    className={cn(
                      'p-4 rounded-xl border-2 text-center transition-all',
                      selectedReminder === option.id
                        ? 'border-primary bg-primary/10'
                        : 'border-border bg-card hover:border-primary/50'
                    )}
                  >
                    <span className="text-3xl mb-2 block">{option.icon}</span>
                    <div className="font-medium text-foreground">{option.label}</div>
                    <div className="text-sm text-muted-foreground">{option.time}</div>
                  </button>
                ))}
              </div>
            )}
          </motion.div>
        </AnimatePresence>

        {/* Navigation */}
        <div className="flex gap-3 mt-8">
          {step > 0 && (
            <Button
              variant="outline"
              onClick={() => setStep(step - 1)}
              className="flex-1"
            >
              <ChevronLeft className="w-4 h-4 mr-2" />
              Back
            </Button>
          )}
          <Button
            onClick={() => {
              if (step < steps.length - 1) {
                setStep(step + 1);
              } else {
                handleComplete();
              }
            }}
            disabled={!canProceed()}
            className="flex-1"
          >
            {step < steps.length - 1 ? (
              <>
                Continue
                <ChevronRight className="w-4 h-4 ml-2" />
              </>
            ) : (
              <>
                Get Started
                <Sparkles className="w-4 h-4 ml-2" />
              </>
            )}
          </Button>
        </div>

        {/* Skip */}
        <button
          onClick={handleComplete}
          className="w-full mt-4 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          Skip for now
        </button>
      </div>
    </div>
  );
};
