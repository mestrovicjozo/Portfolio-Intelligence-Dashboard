import { motion } from 'framer-motion';
import './SkeletonLoader.css';

/**
 * Skeleton loader components for various content types
 * Provides visual feedback while content is loading
 */

// Basic skeleton element
export const Skeleton = ({ width = '100%', height = '20px', className = '' }) => (
  <motion.div
    className={`skeleton ${className}`}
    style={{ width, height }}
    animate={{
      opacity: [0.5, 0.8, 0.5],
    }}
    transition={{
      duration: 1.5,
      repeat: Infinity,
      ease: 'easeInOut',
    }}
  />
);

// Skeleton for news card
export const NewsCardSkeleton = () => (
  <div className="news-card-skeleton card">
    <div className="skeleton-header">
      <Skeleton width="80%" height="24px" />
      <Skeleton width="60px" height="24px" className="skeleton-badge" />
    </div>
    <div className="skeleton-meta">
      <Skeleton width="120px" height="14px" />
      <Skeleton width="100px" height="14px" />
    </div>
    <Skeleton width="100%" height="60px" className="skeleton-summary" />
    <div className="skeleton-tags">
      <Skeleton width="60px" height="24px" />
      <Skeleton width="60px" height="24px" />
      <Skeleton width="60px" height="24px" />
    </div>
  </div>
);

// Skeleton for position card
export const PositionCardSkeleton = () => (
  <div className="position-compact card skeleton-position">
    <div className="position-compact-header">
      <div className="position-compact-left">
        <Skeleton width="48px" height="48px" className="skeleton-logo" />
        <div className="skeleton-info">
          <Skeleton width="80px" height="20px" />
          <Skeleton width="140px" height="16px" />
        </div>
      </div>
      <div className="position-compact-right">
        <Skeleton width="100px" height="24px" />
        <Skeleton width="120px" height="20px" />
      </div>
    </div>
  </div>
);

// Skeleton for dashboard stats cards
export const StatsCardSkeleton = () => (
  <div className="card skeleton-stats">
    <Skeleton width="120px" height="20px" />
    <Skeleton width="140px" height="36px" className="skeleton-metric" />
    <Skeleton width="100px" height="16px" />
  </div>
);

// Skeleton for chat message
export const ChatMessageSkeleton = () => (
  <div className="message assistant skeleton-message">
    <div className="message-icon">
      <Skeleton width="40px" height="40px" className="skeleton-circle" />
    </div>
    <div className="message-content skeleton-chat-content">
      <Skeleton width="100%" height="16px" />
      <Skeleton width="95%" height="16px" />
      <Skeleton width="90%" height="16px" />
    </div>
  </div>
);

// Skeleton for article list
export const ArticleListSkeleton = ({ count = 3 }) => (
  <div className="articles-list">
    {Array.from({ length: count }).map((_, index) => (
      <div key={index} className="article-card skeleton-article">
        <Skeleton width="90%" height="20px" />
        <Skeleton width="100%" height="40px" className="skeleton-summary" />
        <div className="skeleton-meta">
          <Skeleton width="80px" height="14px" />
          <Skeleton width="100px" height="14px" />
        </div>
      </div>
    ))}
  </div>
);

// Full page skeleton for dashboard
export const DashboardSkeleton = () => (
  <div className="dashboard">
    <div className="container">
      <div className="dashboard-header">
        <div>
          <Skeleton width="200px" height="32px" />
          <Skeleton width="250px" height="20px" />
        </div>
      </div>

      <div className="summary-cards">
        <StatsCardSkeleton />
        <StatsCardSkeleton />
        <StatsCardSkeleton />
      </div>

      <div className="positions-section">
        <Skeleton width="180px" height="28px" />
        <div className="positions-compact-list">
          <PositionCardSkeleton />
          <PositionCardSkeleton />
          <PositionCardSkeleton />
        </div>
      </div>
    </div>
  </div>
);

// Full page skeleton for news
export const NewsPageSkeleton = () => (
  <div className="news-page">
    <div className="container">
      <div className="news-header">
        <div>
          <Skeleton width="180px" height="32px" />
          <Skeleton width="100px" height="20px" />
        </div>
      </div>

      <div className="news-list">
        <NewsCardSkeleton />
        <NewsCardSkeleton />
        <NewsCardSkeleton />
        <NewsCardSkeleton />
      </div>
    </div>
  </div>
);

// Skeleton for signal card
export const SignalCardSkeleton = () => (
  <div className="card skeleton-signal">
    <div className="skeleton-signal-header">
      <div className="skeleton-info">
        <Skeleton width="80px" height="24px" />
        <Skeleton width="60px" height="16px" />
      </div>
      <Skeleton width="70px" height="28px" className="skeleton-badge" />
    </div>
    <div className="skeleton-metrics">
      <Skeleton width="100%" height="12px" />
      <Skeleton width="80px" height="24px" />
    </div>
    <Skeleton width="100px" height="16px" />
  </div>
);

// Full page skeleton for roboadvisor
export const RoboadvisorSkeleton = () => (
  <div className="roboadvisor-page">
    <div className="container">
      <div className="roboadvisor-header" style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
            <Skeleton width="28px" height="28px" className="skeleton-circle" />
            <Skeleton width="160px" height="32px" />
          </div>
          <Skeleton width="280px" height="20px" />
        </div>
        <Skeleton width="140px" height="40px" />
      </div>

      {/* Tabs skeleton */}
      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.5rem', paddingBottom: '1rem', borderBottom: '1px solid #e5e7eb' }}>
        <Skeleton width="100px" height="40px" />
        <Skeleton width="140px" height="40px" />
        <Skeleton width="120px" height="40px" />
      </div>

      {/* Risk card skeleton */}
      <div className="card" style={{ marginBottom: '1.5rem' }}>
        <Skeleton width="200px" height="24px" style={{ marginBottom: '1rem' }} />
        <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '2rem', alignItems: 'center' }}>
          <Skeleton width="160px" height="100px" />
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '1rem' }}>
            <div>
              <Skeleton width="80px" height="14px" />
              <Skeleton width="60px" height="24px" />
            </div>
            <div>
              <Skeleton width="80px" height="14px" />
              <Skeleton width="60px" height="24px" />
            </div>
            <div>
              <Skeleton width="80px" height="14px" />
              <Skeleton width="60px" height="24px" />
            </div>
            <div>
              <Skeleton width="80px" height="14px" />
              <Skeleton width="60px" height="24px" />
            </div>
          </div>
        </div>
      </div>

      {/* Stock risks skeleton */}
      <div className="card">
        <Skeleton width="180px" height="24px" style={{ marginBottom: '1rem' }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {[1, 2, 3].map((i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.75rem', background: '#f9fafb', borderRadius: '6px' }}>
              <div style={{ display: 'flex', gap: '0.75rem' }}>
                <Skeleton width="60px" height="20px" />
                <Skeleton width="120px" height="20px" />
              </div>
              <div style={{ display: 'flex', gap: '1rem' }}>
                <Skeleton width="80px" height="24px" />
                <Skeleton width="60px" height="20px" />
                <Skeleton width="60px" height="20px" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  </div>
);

export default Skeleton;
