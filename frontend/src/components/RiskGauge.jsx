import { useMemo } from 'react';
import './RiskGauge.css';

/**
 * Visual risk gauge component (0-100)
 * Shows risk level with color-coded meter
 */
function RiskGauge({ score, size = 'medium', showLabel = true }) {
  const normalizedScore = Math.max(0, Math.min(100, score || 0));

  const { color, label, bgColor } = useMemo(() => {
    if (normalizedScore <= 30) {
      return { color: '#10b981', label: 'Low Risk', bgColor: '#d1fae5' };
    } else if (normalizedScore <= 50) {
      return { color: '#f59e0b', label: 'Moderate Risk', bgColor: '#fef3c7' };
    } else if (normalizedScore <= 70) {
      return { color: '#f97316', label: 'High Risk', bgColor: '#ffedd5' };
    } else {
      return { color: '#ef4444', label: 'Very High Risk', bgColor: '#fee2e2' };
    }
  }, [normalizedScore]);

  const sizeClass = {
    small: 'risk-gauge-sm',
    medium: 'risk-gauge-md',
    large: 'risk-gauge-lg',
  }[size] || 'risk-gauge-md';

  // SVG arc calculations
  const radius = 45;
  const circumference = Math.PI * radius; // Half circle
  const strokeDashoffset = circumference - (normalizedScore / 100) * circumference;

  return (
    <div className={`risk-gauge ${sizeClass}`}>
      <svg viewBox="0 0 100 60" className="risk-gauge-svg">
        {/* Background arc */}
        <path
          d="M 5 55 A 45 45 0 0 1 95 55"
          fill="none"
          stroke="#e5e7eb"
          strokeWidth="8"
          strokeLinecap="round"
        />
        {/* Foreground arc (filled based on score) */}
        <path
          d="M 5 55 A 45 45 0 0 1 95 55"
          fill="none"
          stroke={color}
          strokeWidth="8"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          className="risk-gauge-fill"
        />
      </svg>
      <div className="risk-gauge-value">
        <span className="risk-gauge-score" style={{ color }}>
          {normalizedScore.toFixed(0)}
        </span>
        {showLabel && (
          <span className="risk-gauge-label" style={{ color }}>
            {label}
          </span>
        )}
      </div>
    </div>
  );
}

/**
 * Mini risk indicator (inline badge style)
 */
export function RiskBadge({ score, showScore = true }) {
  const normalizedScore = Math.max(0, Math.min(100, score || 0));

  const { color, label, bgColor } = useMemo(() => {
    if (normalizedScore <= 30) {
      return { color: '#047857', label: 'Low', bgColor: '#d1fae5' };
    } else if (normalizedScore <= 50) {
      return { color: '#b45309', label: 'Moderate', bgColor: '#fef3c7' };
    } else if (normalizedScore <= 70) {
      return { color: '#c2410c', label: 'High', bgColor: '#ffedd5' };
    } else {
      return { color: '#b91c1c', label: 'Very High', bgColor: '#fee2e2' };
    }
  }, [normalizedScore]);

  return (
    <span
      className="risk-badge"
      style={{ backgroundColor: bgColor, color }}
    >
      {label}
      {showScore && <span className="risk-badge-score">({normalizedScore.toFixed(0)})</span>}
    </span>
  );
}

export default RiskGauge;
