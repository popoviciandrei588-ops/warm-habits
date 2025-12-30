import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowLeft, Trophy, Flame, Target, Calendar, Star } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { useHabits } from '@/hooks/useHabits';
import { useAchievements, Achievement } from '@/hooks/useAchievements';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';

const Profile = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { habits, getStreak } = useHabits();
  const achievements = useAchievements({ habits, getStreak });

  const unlockedAchievements = achievements.filter(a => a.unlocked);
  const totalCompletions = habits.reduce((sum, h) => sum + h.completedDates.length, 0);
  const longestStreak = Math.max(...habits.map((h) => getStreak(h.id)), 0);
  
  // Calculate level based on unlocked achievements
  const level = Math.floor(unlockedAchievements.length / 3) + 1;
  const levelProgress = ((unlockedAchievements.length % 3) / 3) * 100;

  const categoryIcons = {
    streak: Flame,
    milestone: Target,
    consistency: Calendar,
  };

  const categoryColors = {
    streak: 'from-orange-500 to-red-500',
    milestone: 'from-primary to-accent',
    consistency: 'from-emerald-500 to-teal-500',
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-10 backdrop-blur-lg bg-background/80 border-b border-border/50">
        <div className="container max-w-3xl mx-auto px-3 sm:px-4 py-3 sm:py-4">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" onClick={() => navigate('/')}>
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <h1 className="font-display text-lg sm:text-xl font-semibold text-foreground">
              Profile
            </h1>
          </div>
        </div>
      </header>

      <main className="container max-w-3xl mx-auto px-3 sm:px-4 py-6 sm:py-8 space-y-6 sm:space-y-8">
        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-card rounded-2xl p-6 sm:p-8 border border-border/50 shadow-soft"
        >
          <div className="flex flex-col sm:flex-row items-center gap-4 sm:gap-6">
            {/* Avatar */}
            <div className="relative">
              <div className="w-24 h-24 sm:w-28 sm:h-28 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center text-4xl sm:text-5xl shadow-glow">
                {user?.photoURL ? (
                  <img 
                    src={user.photoURL} 
                    alt="Profile" 
                    className="w-full h-full rounded-full object-cover"
                  />
                ) : (
                  <span className="text-primary-foreground font-display font-bold">
                    {user?.email?.charAt(0).toUpperCase() || '?'}
                  </span>
                )}
              </div>
              {/* Level Badge */}
              <div className="absolute -bottom-1 -right-1 w-10 h-10 rounded-full bg-accent flex items-center justify-center border-4 border-background">
                <span className="text-accent-foreground font-bold text-sm">{level}</span>
              </div>
            </div>

            {/* User Info */}
            <div className="flex-1 text-center sm:text-left">
              <h2 className="text-xl sm:text-2xl font-display font-semibold text-foreground mb-1">
                {user?.displayName || user?.email?.split('@')[0] || 'Habit Hero'}
              </h2>
              <p className="text-sm text-muted-foreground mb-3">{user?.email}</p>
              
              {/* Level Progress */}
              <div className="space-y-1">
                <div className="flex justify-between text-xs text-muted-foreground">
                  <span>Level {level}</span>
                  <span>Level {level + 1}</span>
                </div>
                <Progress value={levelProgress} className="h-2" />
                <p className="text-xs text-muted-foreground">
                  {3 - (unlockedAchievements.length % 3)} more achievements to level up
                </p>
              </div>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-3 gap-3 mt-6 pt-6 border-t border-border/50">
            <div className="text-center">
              <div className="flex items-center justify-center gap-1 mb-1">
                <Trophy className="w-4 h-4 text-primary" />
                <span className="text-xl sm:text-2xl font-display font-bold text-foreground">
                  {unlockedAchievements.length}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">Badges</p>
            </div>
            <div className="text-center">
              <div className="flex items-center justify-center gap-1 mb-1">
                <Flame className="w-4 h-4 text-accent" />
                <span className="text-xl sm:text-2xl font-display font-bold text-foreground">
                  {longestStreak}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">Best Streak</p>
            </div>
            <div className="text-center">
              <div className="flex items-center justify-center gap-1 mb-1">
                <Star className="w-4 h-4 text-primary" />
                <span className="text-xl sm:text-2xl font-display font-bold text-foreground">
                  {totalCompletions}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">Check-ins</p>
            </div>
          </div>
        </motion.div>

        {/* Badges Section */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-display font-semibold text-foreground flex items-center gap-2">
              <Trophy className="w-5 h-5 text-primary" />
              Your Badges
            </h3>
            <span className="text-sm text-muted-foreground">
              {unlockedAchievements.length}/{achievements.length}
            </span>
          </div>

          {/* Unlocked Badges */}
          {unlockedAchievements.length > 0 && (
            <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
              {unlockedAchievements.map((achievement, index) => (
                <BadgeCard key={achievement.id} achievement={achievement} index={index} />
              ))}
            </div>
          )}

          {/* Locked Badges */}
          {achievements.filter(a => !a.unlocked).length > 0 && (
            <>
              <h4 className="text-sm font-medium text-muted-foreground mt-6 flex items-center gap-2">
                🔒 Locked Badges
              </h4>
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
                {achievements.filter(a => !a.unlocked).map((achievement, index) => (
                  <LockedBadgeCard key={achievement.id} achievement={achievement} index={index} />
                ))}
              </div>
            </>
          )}
        </div>
      </main>
    </div>
  );
};

function BadgeCard({ achievement, index }: { achievement: Achievement; index: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: index * 0.05, type: "spring", stiffness: 300 }}
      className="group relative bg-card rounded-xl p-4 border border-primary/30 shadow-soft hover:shadow-glow transition-all duration-300 cursor-pointer"
    >
      <div className="flex flex-col items-center text-center">
        <motion.div
          whileHover={{ scale: 1.1, rotate: 5 }}
          className="w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center text-3xl sm:text-4xl mb-2"
        >
          {achievement.icon}
        </motion.div>
        <h4 className="font-medium text-xs sm:text-sm text-foreground truncate w-full">
          {achievement.name}
        </h4>
      </div>
      
      {/* Tooltip on hover */}
      <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-popover rounded-lg shadow-lg border border-border opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10 w-40">
        <p className="text-xs text-popover-foreground text-center">{achievement.description}</p>
      </div>

      {/* Shine effect */}
      <div className="absolute inset-0 rounded-xl bg-gradient-to-t from-transparent via-white/5 to-white/10 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none" />
    </motion.div>
  );
}

function LockedBadgeCard({ achievement, index }: { achievement: Achievement; index: number }) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: index * 0.03 }}
      className="relative bg-muted/30 rounded-xl p-4 border border-border/50 opacity-50"
    >
      <div className="flex flex-col items-center text-center">
        <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-muted flex items-center justify-center text-2xl mb-2 grayscale">
          🔒
        </div>
        <h4 className="font-medium text-xs sm:text-sm text-muted-foreground truncate w-full">
          {achievement.name}
        </h4>
        <div className="w-full mt-2">
          <Progress 
            value={(achievement.progress / achievement.maxProgress) * 100} 
            className="h-1"
          />
          <p className="text-[10px] text-muted-foreground mt-1">
            {achievement.progress}/{achievement.maxProgress}
          </p>
        </div>
      </div>
    </motion.div>
  );
}

export default Profile;
