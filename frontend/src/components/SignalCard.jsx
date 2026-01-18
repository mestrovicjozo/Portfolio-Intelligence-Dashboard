import { useState } from 'react';
import { TrendingUp, TrendingDown, Minus, AlertCircle, CheckCircle, XCircle } from 'lucide-react';
import { RiskBadge } from './RiskGauge';
import './SignalCard.css';

/**
 * Trading signal card component
 * Shows BUY/SELL/HOLD signals with confidence and reasoning
 */
function SignalCard({
  symbol,
  signal,
  confidence,
  reasoning,
  riskScore,
  currentPrice,
  targetPrice,
  onExecuteTrade,
  isExecuting = false
}) {
  const [showDetails, setShowDetails] = useState(false);
  const [quantity, setQuantity] = useState(1);

  const getSignalConfig = (sig) => {
    switch (sig?.toUpperCase()) {
      case 'BUY':
      case 'STRONG_BUY':
        return {
          icon: TrendingUp,
          color: '#10b981',
          bgColor: '#d1fae5',
          label: sig === 'STRONG_BUY' ? 'Strong Buy' : 'Buy',
        };
      case 'SELL':
      case 'STRONG_SELL':
        return {
          icon: TrendingDown,
          color: '#ef4444',
          bgColor: '#fee2e2',
          label: sig === 'STRONG_SELL' ? 'Strong Sell' : 'Sell',
        };
      case 'HOLD':
      default:
        return {
          icon: Minus,
          color: '#f59e0b',
          bgColor: '#fef3c7',
          label: 'Hold',
        };
    }
  };

  const config = getSignalConfig(signal);
  const Icon = config.icon;
  const confidencePercent = (confidence || 0) * 100;

  const priceChange = targetPrice && currentPrice
    ? ((targetPrice - currentPrice) / currentPrice * 100).toFixed(2)
    : null;

  return (
    <div className="signal-card card">
      <div className="signal-card-header">
        <div className="signal-stock-info">
          <h3 className="signal-symbol">{symbol}</h3>
          {currentPrice && (
            <span className="signal-price">${currentPrice.toFixed(2)}</span>
          )}
        </div>
        <div
          className="signal-badge"
          style={{ backgroundColor: config.bgColor, color: config.color }}
        >
          <Icon size={16} />
          <span>{config.label}</span>
        </div>
      </div>

      <div className="signal-metrics">
        <div className="signal-metric">
          <span className="metric-label">Confidence</span>
          <div className="confidence-bar">
            <div
              className="confidence-fill"
              style={{
                width: `${confidencePercent}%`,
                backgroundColor: confidencePercent >= 70 ? '#10b981' : confidencePercent >= 50 ? '#f59e0b' : '#ef4444'
              }}
            />
          </div>
          <span className="metric-value">{confidencePercent.toFixed(0)}%</span>
        </div>

        {riskScore !== undefined && (
          <div className="signal-metric">
            <span className="metric-label">Risk Level</span>
            <RiskBadge score={riskScore} />
          </div>
        )}

        {targetPrice && (
          <div className="signal-metric">
            <span className="metric-label">Target Price</span>
            <span className="metric-value">
              ${targetPrice.toFixed(2)}
              {priceChange && (
                <span className={`price-change ${parseFloat(priceChange) >= 0 ? 'positive' : 'negative'}`}>
                  ({priceChange > 0 ? '+' : ''}{priceChange}%)
                </span>
              )}
            </span>
          </div>
        )}
      </div>

      {reasoning && (
        <button
          className="signal-details-toggle"
          onClick={() => setShowDetails(!showDetails)}
        >
          {showDetails ? 'Hide Analysis' : 'Show Analysis'}
        </button>
      )}

      {showDetails && reasoning && (
        <div className="signal-reasoning">
          <AlertCircle size={16} />
          <p>{reasoning}</p>
        </div>
      )}

      {onExecuteTrade && signal !== 'HOLD' && (
        <div className="signal-actions">
          <div className="trade-quantity">
            <label htmlFor={`qty-${symbol}`}>Quantity:</label>
            <input
              id={`qty-${symbol}`}
              type="number"
              min="1"
              value={quantity}
              onChange={(e) => setQuantity(Math.max(1, parseInt(e.target.value) || 1))}
              className="input quantity-input"
            />
          </div>
          <button
            className={`btn ${signal === 'BUY' || signal === 'STRONG_BUY' ? 'btn-success' : 'btn-danger'}`}
            onClick={() => onExecuteTrade(symbol, signal, quantity)}
            disabled={isExecuting}
          >
            {isExecuting ? 'Processing...' : `Paper ${signal === 'BUY' || signal === 'STRONG_BUY' ? 'Buy' : 'Sell'} ${quantity}`}
          </button>
        </div>
      )}
    </div>
  );
}

/**
 * Compact signal indicator for lists
 */
export function SignalBadge({ signal, confidence }) {
  const getConfig = (sig) => {
    switch (sig?.toUpperCase()) {
      case 'BUY':
      case 'STRONG_BUY':
        return { icon: TrendingUp, color: '#047857', bgColor: '#d1fae5' };
      case 'SELL':
      case 'STRONG_SELL':
        return { icon: TrendingDown, color: '#b91c1c', bgColor: '#fee2e2' };
      default:
        return { icon: Minus, color: '#b45309', bgColor: '#fef3c7' };
    }
  };

  const config = getConfig(signal);
  const Icon = config.icon;

  return (
    <span
      className="signal-badge-compact"
      style={{ backgroundColor: config.bgColor, color: config.color }}
      title={`${signal} (${(confidence * 100).toFixed(0)}% confidence)`}
    >
      <Icon size={14} />
      <span>{signal}</span>
    </span>
  );
}

export default SignalCard;
