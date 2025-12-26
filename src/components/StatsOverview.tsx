import { Flame, Target, TrendingUp, Calendar } from 'lucide-react';
import { Habit } from '@/types/habit';

interface StatsOverviewProps {
  habits: Habit[];
  getStreak: (habitId: string) => number;
}

export function StatsOverview({ habits, getStreak }: StatsOverviewProps) {
  const today = new Date().toISOString().split('T')[0];
  
  const completedToday = habits.filter((h) => 
    h.completedDates.includes(today)
  ).length;

  const longestStreak = Math.max(...habits.map((h) => getStreak(h.id)), 0);

  const totalCompletions = habits.reduce(
    (sum, h) => sum + h.completedDates.length,
    0
  );

  const stats = [
    {
      label: 'Today\'s Progress',
      value: `${completedToday}/${habits.length}`,
      icon: Target,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
    {
      label: 'Best Streak',
      value: `${longestStreak} days`,
      icon: Flame,
      color: 'text-accent',
      bgColor: 'bg-accent/10',
    },
    {
      label: 'Total Check-ins',
      value: totalCompletions.toString(),
      icon: TrendingUp,
      color: 'text-success',
      bgColor: 'bg-success/10',
    },
    {
      label: 'Active Habits',
      value: habits.length.toString(),
      icon: Calendar,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat) => (
        <div
          key={stat.label}
          className="bg-card rounded-xl p-4 shadow-soft border border-border/50 fade-in"
        >
          <div className="flex items-center gap-3 mb-2">
            <div className={`w-10 h-10 rounded-lg ${stat.bgColor} flex items-center justify-center`}>
              <stat.icon className={`w-5 h-5 ${stat.color}`} />
            </div>
          </div>
          <p className="text-2xl font-display font-semibold text-foreground">
            {stat.value}
          </p>
          <p className="text-sm text-muted-foreground">{stat.label}</p>
        </div>
      ))}
    </div>
  );
}
