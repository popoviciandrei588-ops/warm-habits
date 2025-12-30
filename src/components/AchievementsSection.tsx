import { motion } from 'framer-motion';
import { Achievement } from '@/hooks/useAchievements';
import { Progress } from '@/components/ui/progress';
import { Lock } from 'lucide-react';

interface AchievementsSectionProps {
  achievements: Achievement[];
}

export function AchievementsSection({ achievements }: AchievementsSectionProps) {
  const unlockedCount = achievements.filter(a => a.unlocked).length;
  
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg sm:text-xl font-display font-semibold text-foreground">
          Achievements
        </h2>
        <span className="text-sm text-muted-foreground">
          {unlockedCount}/{achievements.length} unlocked
        </span>
      </div>
      
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
        {achievements.map((achievement, index) => (
          <motion.div
            key={achievement.id}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: index * 0.05, duration: 0.3 }}
            className={`
              relative p-3 sm:p-4 rounded-xl border transition-all duration-300
              ${achievement.unlocked 
                ? 'bg-card border-primary/30 shadow-soft' 
                : 'bg-muted/30 border-border/50 opacity-60'
              }
            `}
          >
            {/* Badge Icon */}
            <div className="flex items-center justify-center mb-2">
              <div className={`
                w-12 h-12 sm:w-14 sm:h-14 rounded-full flex items-center justify-center text-2xl sm:text-3xl
                ${achievement.unlocked 
                  ? 'bg-primary/10' 
                  : 'bg-muted'
                }
              `}>
                {achievement.unlocked ? (
                  <motion.span
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: "spring", stiffness: 500, delay: index * 0.05 + 0.2 }}
                  >
                    {achievement.icon}
                  </motion.span>
                ) : (
                  <Lock className="w-5 h-5 text-muted-foreground" />
                )}
              </div>
            </div>
            
            {/* Achievement Info */}
            <div className="text-center space-y-1">
              <h3 className={`font-medium text-xs sm:text-sm truncate ${
                achievement.unlocked ? 'text-foreground' : 'text-muted-foreground'
              }`}>
                {achievement.name}
              </h3>
              <p className="text-[10px] sm:text-xs text-muted-foreground line-clamp-2">
                {achievement.description}
              </p>
            </div>
            
            {/* Progress Bar */}
            {!achievement.unlocked && (
              <div className="mt-2 space-y-1">
                <Progress 
                  value={(achievement.progress / achievement.maxProgress) * 100} 
                  className="h-1.5"
                />
                <p className="text-[10px] text-muted-foreground text-center">
                  {achievement.progress}/{achievement.maxProgress}
                </p>
              </div>
            )}
            
            {/* Unlocked Glow Effect */}
            {achievement.unlocked && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="absolute inset-0 rounded-xl bg-gradient-to-t from-primary/5 to-transparent pointer-events-none"
              />
            )}
          </motion.div>
        ))}
      </div>
    </div>
  );
}
