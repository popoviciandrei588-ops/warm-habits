import { useState } from 'react';
import { Check, Flame, Trash2 } from 'lucide-react';
import { Habit } from '@/types/habit';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';

interface HabitCardProps {
  habit: Habit;
  isCompleted: boolean;
  streak: number;
  completionRate: number;
  onToggle: () => void;
  onDelete: () => void;
}

export function HabitCard({
  habit,
  isCompleted,
  streak,
  completionRate,
  onToggle,
  onDelete,
}: HabitCardProps) {
  const [isAnimating, setIsAnimating] = useState(false);

  const handleToggle = () => {
    setIsAnimating(true);
    onToggle();
    setTimeout(() => setIsAnimating(false), 400);
  };

  return (
    <div className="group fade-in bg-card rounded-xl p-4 shadow-soft hover:shadow-elevated transition-all duration-300 border border-border/50">
      <div className="flex items-center gap-4">
        {/* Check Button */}
        <button
          onClick={handleToggle}
          className={cn(
            "habit-check w-12 h-12 rounded-xl flex items-center justify-center text-xl border-2 transition-all duration-300",
            isCompleted
              ? "bg-success border-success text-success-foreground"
              : "border-border hover:border-primary/50 bg-background hover:bg-primary/5",
            isAnimating && "habit-check-active"
          )}
        >
          {isCompleted ? (
            <Check className="w-6 h-6" strokeWidth={3} />
          ) : (
            <span>{habit.emoji}</span>
          )}
        </button>

        {/* Habit Info */}
        <div className="flex-1 min-w-0">
          <h3 className={cn(
            "font-medium text-foreground transition-all duration-300",
            isCompleted && "line-through text-muted-foreground"
          )}>
            {habit.name}
          </h3>
          <div className="flex items-center gap-3 mt-1">
            {streak > 0 && (
              <span className="flex items-center gap-1 text-sm text-primary">
                <Flame className="w-4 h-4" />
                {streak} day streak
              </span>
            )}
            <span className="text-sm text-muted-foreground">
              {completionRate}% this week
            </span>
          </div>
        </div>

        {/* Progress Ring */}
        <div className="relative w-12 h-12">
          <svg className="w-12 h-12 -rotate-90">
            <circle
              cx="24"
              cy="24"
              r="20"
              stroke="currentColor"
              strokeWidth="4"
              fill="none"
              className="text-muted"
            />
            <circle
              cx="24"
              cy="24"
              r="20"
              stroke="currentColor"
              strokeWidth="4"
              fill="none"
              strokeDasharray={`${(completionRate / 100) * 126} 126`}
              strokeLinecap="round"
              className="text-primary transition-all duration-500"
            />
          </svg>
          <span className="absolute inset-0 flex items-center justify-center text-xs font-medium text-foreground">
            {completionRate}%
          </span>
        </div>

        {/* Delete Button */}
        <Button
          variant="ghost"
          size="icon"
          onClick={onDelete}
          className="opacity-0 group-hover:opacity-100 transition-opacity text-muted-foreground hover:text-destructive"
        >
          <Trash2 className="w-4 h-4" />
        </Button>
      </div>
    </div>
  );
}
