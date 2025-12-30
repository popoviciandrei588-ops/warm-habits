import { useMemo } from 'react';
import { Habit } from '@/types/habit';

export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  unlocked: boolean;
  progress: number;
  maxProgress: number;
  category: 'streak' | 'consistency' | 'milestone';
}

interface UseAchievementsProps {
  habits: Habit[];
  getStreak: (habitId: string) => number;
}

export function useAchievements({ habits, getStreak }: UseAchievementsProps): Achievement[] {
  return useMemo(() => {
    const totalCompletions = habits.reduce((sum, h) => sum + h.completedDates.length, 0);
    const longestStreak = Math.max(...habits.map((h) => getStreak(h.id)), 0);
    const habitsCount = habits.length;
    
    // Calculate days with at least one completion
    const allDates = new Set(habits.flatMap(h => h.completedDates));
    const activeDays = allDates.size;

    const achievements: Achievement[] = [
      {
        id: 'first-step',
        name: 'First Step',
        description: 'Complete your first habit',
        icon: '🌱',
        unlocked: totalCompletions >= 1,
        progress: Math.min(totalCompletions, 1),
        maxProgress: 1,
        category: 'milestone',
      },
      {
        id: 'getting-started',
        name: 'Getting Started',
        description: 'Complete 10 habits total',
        icon: '🎯',
        unlocked: totalCompletions >= 10,
        progress: Math.min(totalCompletions, 10),
        maxProgress: 10,
        category: 'milestone',
      },
      {
        id: 'habit-hero',
        name: 'Habit Hero',
        description: 'Complete 50 habits total',
        icon: '🏆',
        unlocked: totalCompletions >= 50,
        progress: Math.min(totalCompletions, 50),
        maxProgress: 50,
        category: 'milestone',
      },
      {
        id: 'centurion',
        name: 'Centurion',
        description: 'Complete 100 habits total',
        icon: '💯',
        unlocked: totalCompletions >= 100,
        progress: Math.min(totalCompletions, 100),
        maxProgress: 100,
        category: 'milestone',
      },
      {
        id: 'streak-starter',
        name: 'Streak Starter',
        description: 'Reach a 3-day streak',
        icon: '🔥',
        unlocked: longestStreak >= 3,
        progress: Math.min(longestStreak, 3),
        maxProgress: 3,
        category: 'streak',
      },
      {
        id: 'week-warrior',
        name: 'Week Warrior',
        description: 'Reach a 7-day streak',
        icon: '⚡',
        unlocked: longestStreak >= 7,
        progress: Math.min(longestStreak, 7),
        maxProgress: 7,
        category: 'streak',
      },
      {
        id: 'fortnight-fighter',
        name: 'Fortnight Fighter',
        description: 'Reach a 14-day streak',
        icon: '💪',
        unlocked: longestStreak >= 14,
        progress: Math.min(longestStreak, 14),
        maxProgress: 14,
        category: 'streak',
      },
      {
        id: 'monthly-master',
        name: 'Monthly Master',
        description: 'Reach a 30-day streak',
        icon: '👑',
        unlocked: longestStreak >= 30,
        progress: Math.min(longestStreak, 30),
        maxProgress: 30,
        category: 'streak',
      },
      {
        id: 'habit-collector',
        name: 'Habit Collector',
        description: 'Track 3 different habits',
        icon: '📚',
        unlocked: habitsCount >= 3,
        progress: Math.min(habitsCount, 3),
        maxProgress: 3,
        category: 'consistency',
      },
      {
        id: 'habit-enthusiast',
        name: 'Habit Enthusiast',
        description: 'Track 5 different habits',
        icon: '🌟',
        unlocked: habitsCount >= 5,
        progress: Math.min(habitsCount, 5),
        maxProgress: 5,
        category: 'consistency',
      },
      {
        id: 'dedicated',
        name: 'Dedicated',
        description: 'Be active for 7 different days',
        icon: '📅',
        unlocked: activeDays >= 7,
        progress: Math.min(activeDays, 7),
        maxProgress: 7,
        category: 'consistency',
      },
      {
        id: 'committed',
        name: 'Committed',
        description: 'Be active for 30 different days',
        icon: '🎖️',
        unlocked: activeDays >= 30,
        progress: Math.min(activeDays, 30),
        maxProgress: 30,
        category: 'consistency',
      },
    ];

    return achievements;
  }, [habits, getStreak]);
}
