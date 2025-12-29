import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Sparkles, Settings } from 'lucide-react';
import { useHabits } from '@/hooks/useHabits';
import { HabitCard } from '@/components/HabitCard';
import { HabitCalendar } from '@/components/HabitCalendar';
import { AddHabitDialog } from '@/components/AddHabitDialog';
import { StatsOverview } from '@/components/StatsOverview';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { OnboardingTour } from '@/components/OnboardingTour';
import { useOnboarding } from '@/hooks/useOnboarding';
// Helper to format date as YYYY-MM-DD in local timezone
const formatDateLocal = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const Index = () => {
  const navigate = useNavigate();
  const { logout } = useAuth();
  const {
    showOnboarding,
    currentStep,
    currentStepData,
    totalSteps,
    nextStep,
    prevStep,
    skipOnboarding,
    isReady,
  } = useOnboarding();
  const {
    habits,
    addHabit,
    toggleHabit,
    deleteHabit,
    isHabitCompleted,
    getCompletionRate,
    getStreak,
  } = useHabits();

  const [selectedDate, setSelectedDate] = useState(() => formatDateLocal(new Date()));

  return (
    <div className="min-h-screen bg-background">
      {/* Onboarding Tour */}
      {showOnboarding && currentStepData && (
        <OnboardingTour
          step={currentStepData}
          currentStep={currentStep}
          totalSteps={totalSteps}
          onNext={nextStep}
          onPrev={prevStep}
          onSkip={skipOnboarding}
          isReady={isReady}
        />
      )}

      {/* Header */}
      <header data-tour="header" className="sticky top-0 z-10 backdrop-blur-lg bg-background/80 border-b border-border/50">
        <div className="container max-w-5xl mx-auto px-3 sm:px-4 py-3 sm:py-4">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2 sm:gap-3 min-w-0">
              <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-glow shrink-0">
                <Sparkles className="w-4 h-4 sm:w-5 sm:h-5 text-primary-foreground" />
              </div>
              <div className="min-w-0">
                <h1 className="font-display text-lg sm:text-xl font-semibold text-foreground truncate">
                  Habit Tracker
                </h1>
                <p className="text-xs sm:text-sm text-muted-foreground hidden sm:block">
                  Build better habits, one day at a time
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <div data-tour="add-habit">
                <AddHabitDialog onAdd={addHabit} />
              </div>
              <Button variant="ghost" size="icon" onClick={() => navigate('/settings')} title="Settings">
                <Settings className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container max-w-5xl mx-auto px-3 sm:px-4 py-4 sm:py-8 space-y-4 sm:space-y-8">
        {/* Stats Overview */}
        <section data-tour="stats">
          <StatsOverview habits={habits} getStreak={getStreak} />
        </section>

        {/* Two Column Layout - Calendar first on mobile */}
        <div className="grid lg:grid-cols-5 gap-4 sm:gap-8">
          {/* Calendar - Shows first on mobile */}
          <section data-tour="calendar" className="lg:col-span-3 order-first lg:order-last">
            <HabitCalendar 
              habits={habits} 
              onToggleHabit={toggleHabit}
              selectedDate={selectedDate}
              onSelectDate={setSelectedDate}
            />
          </section>

          {/* Habits List */}
          <section data-tour="habits-list" className="lg:col-span-2 space-y-3 sm:space-y-4">
            <div className="flex items-center justify-between gap-2">
              <h2 className="font-display text-lg sm:text-xl font-semibold text-foreground">
                {selectedDate === formatDateLocal(new Date()) ? "Today's Habits" : "Habits"}
              </h2>
              <span className="text-xs sm:text-sm text-muted-foreground shrink-0">
                {new Date(selectedDate + 'T12:00:00').toLocaleDateString('en-US', { 
                  weekday: 'short',
                  month: 'short',
                  day: 'numeric'
                })}
              </span>
            </div>

            {habits.length === 0 ? (
              <div className="bg-card rounded-xl p-6 sm:p-8 text-center border border-border/50">
                <div className="w-12 h-12 sm:w-16 sm:h-16 mx-auto mb-3 sm:mb-4 rounded-full bg-secondary flex items-center justify-center">
                  <Sparkles className="w-6 h-6 sm:w-8 sm:h-8 text-muted-foreground" />
                </div>
                <h3 className="font-medium text-foreground mb-2">No habits yet</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Start by adding your first habit to track
                </p>
              </div>
            ) : (
              <div className="space-y-2 sm:space-y-3">
                {habits.map((habit) => (
                  <HabitCard
                    key={habit.id}
                    habit={habit}
                    isCompleted={isHabitCompleted(habit.id, selectedDate)}
                    streak={getStreak(habit.id)}
                    completionRate={getCompletionRate(habit.id)}
                    onToggle={() => toggleHabit(habit.id, selectedDate)}
                    onDelete={() => deleteHabit(habit.id)}
                  />
                ))}
              </div>
            )}
          </section>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-border/50 mt-16">
        <div className="container max-w-5xl mx-auto px-4 py-6 text-center text-sm text-muted-foreground">
          <p>Build positive habits and track your progress every day ✨</p>
        </div>
      </footer>
    </div>
  );
};

export default Index;
