export interface Habit {
  id: string;
  name: string;
  emoji: string;
  color: string;
  completedDates: string[];
  createdAt: string;
}

export interface HabitCompletion {
  habitId: string;
  date: string;
  completed: boolean;
}
