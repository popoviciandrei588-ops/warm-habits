import { useEffect, useState, useCallback } from 'react';
import { X, ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { OnboardingStep } from '@/hooks/useOnboarding';
import { cn } from '@/lib/utils';

interface OnboardingTourProps {
  step: OnboardingStep;
  currentStep: number;
  totalSteps: number;
  onNext: () => void;
  onPrev: () => void;
  onSkip: () => void;
  isReady: boolean;
}

interface Position {
  top: number;
  left: number;
  width: number;
  height: number;
}

export const OnboardingTour = ({
  step,
  currentStep,
  totalSteps,
  onNext,
  onPrev,
  onSkip,
  isReady,
}: OnboardingTourProps) => {
  const [targetPosition, setTargetPosition] = useState<Position | null>(null);
  const [tooltipStyle, setTooltipStyle] = useState<React.CSSProperties>({});

  const calculatePosition = useCallback(() => {
    const target = document.querySelector(step.targetSelector);
    if (!target) return;

    const rect = target.getBoundingClientRect();
    const scrollTop = window.scrollY;
    const scrollLeft = window.scrollX;

    setTargetPosition({
      top: rect.top + scrollTop,
      left: rect.left + scrollLeft,
      width: rect.width,
      height: rect.height,
    });

    // Calculate tooltip position
    const padding = 16;
    const tooltipWidth = 320;
    const tooltipHeight = 180;

    let top = 0;
    let left = 0;

    switch (step.position) {
      case 'bottom':
        top = rect.bottom + scrollTop + padding;
        left = rect.left + scrollLeft + rect.width / 2 - tooltipWidth / 2;
        break;
      case 'top':
        top = rect.top + scrollTop - tooltipHeight - padding;
        left = rect.left + scrollLeft + rect.width / 2 - tooltipWidth / 2;
        break;
      case 'left':
        top = rect.top + scrollTop + rect.height / 2 - tooltipHeight / 2;
        left = rect.left + scrollLeft - tooltipWidth - padding;
        break;
      case 'right':
        top = rect.top + scrollTop + rect.height / 2 - tooltipHeight / 2;
        left = rect.right + scrollLeft + padding;
        break;
    }

    // Keep tooltip within viewport
    left = Math.max(padding, Math.min(left, window.innerWidth - tooltipWidth - padding));
    top = Math.max(padding, top);

    setTooltipStyle({ top, left, width: tooltipWidth });
  }, [step]);

  useEffect(() => {
    if (!isReady) return;

    calculatePosition();

    // Scroll target into view
    const target = document.querySelector(step.targetSelector);
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
      // Recalculate after scroll
      setTimeout(calculatePosition, 300);
    }

    window.addEventListener('resize', calculatePosition);
    window.addEventListener('scroll', calculatePosition);

    return () => {
      window.removeEventListener('resize', calculatePosition);
      window.removeEventListener('scroll', calculatePosition);
    };
  }, [step, isReady, calculatePosition]);

  if (!isReady || !targetPosition) return null;

  const isLastStep = currentStep === totalSteps - 1;
  const isFirstStep = currentStep === 0;

  return (
    <div className="fixed inset-0 z-50">
      {/* Overlay with spotlight cutout */}
      <svg className="absolute inset-0 w-full h-full" style={{ pointerEvents: 'none' }}>
        <defs>
          <mask id="spotlight-mask">
            <rect x="0" y="0" width="100%" height="100%" fill="white" />
            <rect
              x={targetPosition.left - 8}
              y={targetPosition.top - 8}
              width={targetPosition.width + 16}
              height={targetPosition.height + 16}
              rx="12"
              fill="black"
            />
          </mask>
        </defs>
        <rect
          x="0"
          y="0"
          width="100%"
          height="100%"
          fill="hsl(var(--foreground) / 0.6)"
          mask="url(#spotlight-mask)"
          style={{ pointerEvents: 'auto' }}
          onClick={onSkip}
        />
      </svg>

      {/* Spotlight ring */}
      <div
        className="absolute rounded-xl ring-4 ring-primary/60 animate-pulse pointer-events-none"
        style={{
          top: targetPosition.top - 8,
          left: targetPosition.left - 8,
          width: targetPosition.width + 16,
          height: targetPosition.height + 16,
        }}
      />

      {/* Tooltip */}
      <div
        className="absolute bg-card border border-border rounded-xl shadow-elevated p-5 z-10 animate-fade-in"
        style={tooltipStyle}
      >
        {/* Close button */}
        <button
          onClick={onSkip}
          className="absolute top-3 right-3 text-muted-foreground hover:text-foreground transition-colors"
          aria-label="Skip tour"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Content */}
        <div className="pr-6">
          <h3 className="font-display text-lg font-semibold text-foreground mb-2">
            {step.title}
          </h3>
          <p className="text-sm text-muted-foreground leading-relaxed">
            {step.description}
          </p>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between mt-5">
          {/* Progress dots */}
          <div className="flex items-center gap-1.5">
            {Array.from({ length: totalSteps }).map((_, i) => (
              <div
                key={i}
                className={cn(
                  'w-2 h-2 rounded-full transition-all duration-200',
                  i === currentStep
                    ? 'bg-primary w-4'
                    : i < currentStep
                    ? 'bg-primary/40'
                    : 'bg-muted-foreground/30'
                )}
              />
            ))}
          </div>

          {/* Navigation buttons */}
          <div className="flex items-center gap-2">
            {!isFirstStep && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onPrev}
                className="gap-1"
              >
                <ChevronLeft className="w-4 h-4" />
                Back
              </Button>
            )}
            <Button
              variant="warm"
              size="sm"
              onClick={onNext}
              className="gap-1"
            >
              {isLastStep ? "Get Started" : "Next"}
              {!isLastStep && <ChevronRight className="w-4 h-4" />}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};
