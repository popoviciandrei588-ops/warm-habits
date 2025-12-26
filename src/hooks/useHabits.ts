import { useState, useEffect } from 'react';
import { Habit } from '@/types/habit';

const STORAGE_KEY = 'habit-tracker-habits';

const defaultHabits: Habit[] = [
  {
    id: '1',
    name: 'Morning Exercise',
    emoji: '🏃',
    color: 'primary',
    completedDates: [],
    createdAt: new Date().toISOString(),
  },
  {
    id: '2',
    name: 'Read 30 minutes',
    emoji: '📚',
    color: 'accent',
    completedDates: [],
    createdAt: new Date().toISOString(),
  },
  {
    id: '3',
    name: 'Drink 8 glasses of water',
    emoji: '💧',
    color: 'success',
    completedDates: [],
    createdAt: new Date().toISOString(),
  },
];

export function useHabits() {
  const [habits, setHabits] = useState<Habit[]>(() => {
    if (typeof window === 'undefined') return defaultHabits;
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : defaultHabits;
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(habits));
  }, [habits]);

  const addHabit = (name: string, emoji: string) => {
    const newHabit: Habit = {
      id: Date.now().toString(),
      name,
      emoji,
      color: ['primary', 'accent', 'success'][Math.floor(Math.random() * 3)],
      completedDates: [],
      createdAt: new Date().toISOString(),
    };
    setHabits((prev) => [...prev, newHabit]);
  };

  const toggleHabit = (habitId: string, date: string) => {
    setHabits((prev) =>
      prev.map((habit) => {
        if (habit.id !== habitId) return habit;
        const isCompleted = habit.completedDates.includes(date);
        return {
          ...habit,
          completedDates: isCompleted
            ? habit.completedDates.filter((d) => d !== date)
            : [...habit.completedDates, date],
        };
      })
    );
  };

  const deleteHabit = (habitId: string) => {
    setHabits((prev) => prev.filter((habit) => habit.id !== habitId));
  };

  const isHabitCompleted = (habitId: string, date: string) => {
    const habit = habits.find((h) => h.id === habitId);
    return habit?.completedDates.includes(date) ?? false;
  };

  const getCompletionRate = (habitId: string, days: number = 7) => {
    const habit = habits.find((h) => h.id === habitId);
    if (!habit) return 0;
    
    const today = new Date();
    let completed = 0;
    
    for (let i = 0; i < days; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      if (habit.completedDates.includes(dateStr)) completed++;
    }
    
    return Math.round((completed / days) * 100);
  };

  const getStreak = (habitId: string) => {
    const habit = habits.find((h) => h.id === habitId);
    if (!habit) return 0;
    
    let streak = 0;
    const today = new Date();
    
    for (let i = 0; i < 365; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      if (habit.completedDates.includes(dateStr)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  };

  return {
    habits,
    addHabit,
    toggleHabit,
    deleteHabit,
    isHabitCompleted,
    getCompletionRate,
    getStreak,
  };
}
