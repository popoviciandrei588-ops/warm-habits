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
    <div className="group fade-in bg-card rounded-lg sm:rounded-xl p-3 sm:p-4 shadow-soft hover:shadow-elevated transition-all duration-300 border border-border/50">
      <div className="flex items-center gap-2 sm:gap-4">
        {/* Check Button */}
        <button
          onClick={handleToggle}
          className={cn(
            "habit-check w-10 h-10 sm:w-12 sm:h-12 rounded-lg sm:rounded-xl flex items-center justify-center text-lg sm:text-xl border-2 transition-all duration-300 shrink-0",
            isCompleted
              ? "bg-success border-success text-success-foreground"
              : "border-border hover:border-primary/50 bg-background hover:bg-primary/5",
            isAnimating && "habit-check-active"
          )}
        >
          {isCompleted ? (
            <Check className="w-5 h-5 sm:w-6 sm:h-6" strokeWidth={3} />
          ) : (
            <span>{habit.emoji}</span>
          )}
        </button>

        {/* Habit Info */}
        <div className="flex-1 min-w-0">
          <h3 className={cn(
            "font-medium text-sm sm:text-base text-foreground transition-all duration-300 truncate",
            isCompleted && "line-through text-muted-foreground"
          )}>
            {habit.name}
          </h3>
          <div className="flex items-center gap-2 sm:gap-3 mt-0.5 sm:mt-1 flex-wrap">
            {streak > 0 && (
              <span className="flex items-center gap-0.5 sm:gap-1 text-xs sm:text-sm text-primary">
                <Flame className="w-3 h-3 sm:w-4 sm:h-4" />
                <span className="hidden sm:inline">{streak} day streak</span>
                <span className="sm:hidden">{streak}d</span>
              </span>
            )}
            <span className="text-xs sm:text-sm text-muted-foreground">
              {completionRate}%
            </span>
          </div>
        </div>

        {/* Progress Ring - hidden on mobile */}
        <div className="relative w-10 h-10 sm:w-12 sm:h-12 hidden sm:block">
          <svg className="w-10 h-10 sm:w-12 sm:h-12 -rotate-90">
            <circle
              cx="20"
              cy="20"
              r="16"
              stroke="currentColor"
              strokeWidth="3"
              fill="none"
              className="text-muted sm:hidden"
            />
            <circle
              cx="20"
              cy="20"
              r="16"
              stroke="currentColor"
              strokeWidth="3"
              fill="none"
              strokeDasharray={`${(completionRate / 100) * 100} 100`}
              strokeLinecap="round"
              className="text-primary transition-all duration-500 sm:hidden"
            />
            <circle
              cx="24"
              cy="24"
              r="20"
              stroke="currentColor"
              strokeWidth="4"
              fill="none"
              className="text-muted hidden sm:block"
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
              className="text-primary transition-all duration-500 hidden sm:block"
            />
          </svg>
          <span className="absolute inset-0 flex items-center justify-center text-[10px] sm:text-xs font-medium text-foreground">
            {completionRate}%
          </span>
        </div>

        {/* Delete Button - always visible on mobile */}
        <Button
          variant="ghost"
          size="icon"
          onClick={onDelete}
          className="opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity text-muted-foreground hover:text-destructive h-8 w-8 sm:h-10 sm:w-10 shrink-0"
        >
          <Trash2 className="w-4 h-4" />
        </Button>
      </div>
    </div>
  );
}
