import { useMemo, useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Habit } from '@/types/habit';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';

// Helper to format date as YYYY-MM-DD in local timezone
const formatDateLocal = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

interface HabitCalendarProps {
  habits: Habit[];
  onToggleHabit: (habitId: string, date: string) => void;
  selectedDate: string;
  onSelectDate: (date: string) => void;
}

export function HabitCalendar({ habits, onToggleHabit, selectedDate, onSelectDate }: HabitCalendarProps) {
  const [currentMonth, setCurrentMonth] = useState(new Date());

  const { days, monthName, year } = useMemo(() => {
    const firstDay = new Date(currentMonth.getFullYear(), currentMonth.getMonth(), 1);
    const lastDay = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 0);
    const startPadding = firstDay.getDay();
    
    const days: (Date | null)[] = [];
    
    // Add padding for days before the first of the month
    for (let i = 0; i < startPadding; i++) {
      days.push(null);
    }
    
    // Add all days of the month
    for (let i = 1; i <= lastDay.getDate(); i++) {
      days.push(new Date(currentMonth.getFullYear(), currentMonth.getMonth(), i));
    }
    
    return {
      days,
      monthName: currentMonth.toLocaleString('default', { month: 'long' }),
      year: currentMonth.getFullYear(),
    };
  }, [currentMonth]);

  const prevMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1));
  };

  const nextMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1));
  };

  const getCompletionForDate = (date: Date) => {
    const dateStr = formatDateLocal(date);
    const completed = habits.filter((h) => h.completedDates.includes(dateStr)).length;
    return habits.length > 0 ? completed / habits.length : 0;
  };

  const isToday = (date: Date) => {
    const today = new Date();
    return formatDateLocal(date) === formatDateLocal(today);
  };

  const isSelected = (date: Date) => {
    return formatDateLocal(date) === selectedDate;
  };

  const isFuture = (date: Date) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const compareDate = new Date(date);
    compareDate.setHours(0, 0, 0, 0);
    return compareDate > today;
  };

  const handleDateClick = (date: Date) => {
    if (!isFuture(date)) {
      onSelectDate(formatDateLocal(date));
    }
  };

  const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return (
    <div className="bg-card rounded-2xl p-6 shadow-soft border border-border/50">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="font-display text-2xl font-semibold text-foreground">
          {monthName} {year}
        </h2>
        <div className="flex gap-2">
          <Button variant="outline" size="icon" onClick={prevMonth}>
            <ChevronLeft className="w-4 h-4" />
          </Button>
          <Button variant="outline" size="icon" onClick={nextMonth}>
            <ChevronRight className="w-4 h-4" />
          </Button>
        </div>
      </div>

      {/* Week days header */}
      <div className="grid grid-cols-7 gap-2 mb-2">
        {weekDays.map((day) => (
          <div key={day} className="text-center text-sm font-medium text-muted-foreground py-2">
            {day}
          </div>
        ))}
      </div>

      {/* Calendar grid */}
      <div className="grid grid-cols-7 gap-2">
        {days.map((date, index) => {
          if (!date) {
            return <div key={`empty-${index}`} className="aspect-square" />;
          }

          const completion = getCompletionForDate(date);
          const today = isToday(date);
          const future = isFuture(date);
          const selected = isSelected(date);

          return (
            <button
              type="button"
              key={formatDateLocal(date)}
              disabled={future}
              onClick={() => handleDateClick(date)}
              className={cn(
                "calendar-day aspect-square rounded-xl flex flex-col items-center justify-center relative transition-all duration-200 border-2",
                today && "ring-2 ring-primary ring-offset-2 ring-offset-background",
                selected && "border-accent bg-accent/10",
                !selected && "border-transparent",
                future ? "opacity-40 cursor-not-allowed" : "hover:bg-secondary/50 cursor-pointer active:scale-95",
                completion === 1 && "bg-success/20",
                completion > 0 && completion < 1 && !selected && "bg-accent/20"
              )}
            >
              {/* Day status dot */}
              {habits.length > 0 && (
                <div
                  className={cn(
                    "absolute top-2 right-2 h-2 w-2 rounded-full",
                    completion === 1
                      ? "bg-success"
                      : completion > 0
                        ? "bg-accent"
                        : "bg-muted"
                  )}
                  aria-hidden="true"
                />
              )}

              <span className={cn(
                "text-sm font-medium",
                today ? "text-primary" : selected ? "text-accent font-semibold" : "text-foreground"
              )}>
                {date.getDate()}
              </span>
              
              {/* Completion indicator dots - show for all dates with habits */}
              {habits.length > 0 && (
                <div className="flex gap-0.5 mt-1">
                  {habits.map((habit) => {
                    const dateStr = formatDateLocal(date);
                    const isCompleted = habit.completedDates.includes(dateStr);
                    return (
                      <div
                        key={habit.id}
                        className={cn(
                          "w-1.5 h-1.5 rounded-full transition-all duration-300",
                          isCompleted ? "bg-success" : "bg-muted/50"
                        )}
                      />
                    );
                  })}
                </div>
              )}
            </button>
          );
        })}
      </div>

      {/* Legend */}
      <div className="flex items-center justify-center gap-4 mt-6 text-sm text-muted-foreground">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-success" />
          <span>All complete</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-accent" />
          <span>Partial</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-muted" />
          <span>None</span>
        </div>
      </div>
    </div>
  );
}
