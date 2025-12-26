import { Sparkles } from 'lucide-react';
import { useHabits } from '@/hooks/useHabits';
import { HabitCard } from '@/components/HabitCard';
import { HabitCalendar } from '@/components/HabitCalendar';
import { AddHabitDialog } from '@/components/AddHabitDialog';
import { StatsOverview } from '@/components/StatsOverview';

const Index = () => {
  const {
    habits,
    addHabit,
    toggleHabit,
    deleteHabit,
    isHabitCompleted,
    getCompletionRate,
    getStreak,
  } = useHabits();

  const today = new Date().toISOString().split('T')[0];

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-10 backdrop-blur-lg bg-background/80 border-b border-border/50">
        <div className="container max-w-5xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-glow">
                <Sparkles className="w-5 h-5 text-primary-foreground" />
              </div>
              <div>
                <h1 className="font-display text-xl font-semibold text-foreground">
                  Habit Tracker
                </h1>
                <p className="text-sm text-muted-foreground">
                  Build better habits, one day at a time
                </p>
              </div>
            </div>
            <AddHabitDialog onAdd={addHabit} />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container max-w-5xl mx-auto px-4 py-8 space-y-8">
        {/* Stats Overview */}
        <section>
          <StatsOverview habits={habits} getStreak={getStreak} />
        </section>

        {/* Two Column Layout */}
        <div className="grid lg:grid-cols-5 gap-8">
          {/* Habits List */}
          <section className="lg:col-span-2 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="font-display text-xl font-semibold text-foreground">
                Today's Habits
              </h2>
              <span className="text-sm text-muted-foreground">
                {new Date().toLocaleDateString('en-US', { 
                  weekday: 'long',
                  month: 'short',
                  day: 'numeric'
                })}
              </span>
            </div>

            {habits.length === 0 ? (
              <div className="bg-card rounded-xl p-8 text-center border border-border/50">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-secondary flex items-center justify-center">
                  <Sparkles className="w-8 h-8 text-muted-foreground" />
                </div>
                <h3 className="font-medium text-foreground mb-2">No habits yet</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Start by adding your first habit to track
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {habits.map((habit) => (
                  <HabitCard
                    key={habit.id}
                    habit={habit}
                    isCompleted={isHabitCompleted(habit.id, today)}
                    streak={getStreak(habit.id)}
                    completionRate={getCompletionRate(habit.id)}
                    onToggle={() => toggleHabit(habit.id, today)}
                    onDelete={() => deleteHabit(habit.id)}
                  />
                ))}
              </div>
            )}
          </section>

          {/* Calendar */}
          <section className="lg:col-span-3">
            <HabitCalendar 
              habits={habits} 
              onToggleHabit={toggleHabit}
            />
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
