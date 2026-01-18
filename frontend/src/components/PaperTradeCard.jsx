import { TrendingUp, TrendingDown, Clock, CheckCircle, XCircle } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import './PaperTradeCard.css';

/**
 * Paper trade card showing trade details and P&L
 */
function PaperTradeCard({
  trade,
  onCloseTrade,
  isClosing = false
}) {
  const {
    id,
    symbol,
    trade_type,
    quantity,
    entry_price,
    current_price,
    exit_price,
    status,
    profit_loss,
    profit_loss_percent,
    created_at,
    closed_at
  } = trade;

  const isBuy = trade_type?.toUpperCase() === 'BUY';
  const isOpen = status?.toLowerCase() === 'open';
  const displayPrice = isOpen ? current_price : exit_price;
  const pnl = profit_loss || 0;
  const pnlPercent = profit_loss_percent || 0;
  const isProfitable = pnl >= 0;

  return (
    <div className={`paper-trade-card card ${isOpen ? 'open' : 'closed'}`}>
      <div className="paper-trade-header">
        <div className="paper-trade-info">
          <div className="trade-type-badge" data-type={trade_type?.toLowerCase()}>
            {isBuy ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
            <span>{trade_type}</span>
          </div>
          <h4 className="trade-symbol">{symbol}</h4>
          <span className="trade-quantity">{quantity} shares</span>
        </div>
        <div className={`trade-status ${status?.toLowerCase()}`}>
          {isOpen ? (
            <>
              <Clock size={14} />
              <span>Open</span>
            </>
          ) : (
            <>
              <CheckCircle size={14} />
              <span>Closed</span>
            </>
          )}
        </div>
      </div>

      <div className="paper-trade-prices">
        <div className="price-item">
          <span className="price-label">Entry Price</span>
          <span className="price-value">${entry_price?.toFixed(2) || '0.00'}</span>
        </div>
        <div className="price-arrow">
          {isProfitable ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
        </div>
        <div className="price-item">
          <span className="price-label">{isOpen ? 'Current' : 'Exit'} Price</span>
          <span className="price-value">${displayPrice?.toFixed(2) || '0.00'}</span>
        </div>
      </div>

      <div className={`paper-trade-pnl ${isProfitable ? 'profit' : 'loss'}`}>
        <span className="pnl-label">P&L</span>
        <div className="pnl-values">
          <span className="pnl-amount">
            {isProfitable ? '+' : ''}{pnl.toFixed(2)} USD
          </span>
          <span className="pnl-percent">
            ({isProfitable ? '+' : ''}{pnlPercent.toFixed(2)}%)
          </span>
        </div>
      </div>

      <div className="paper-trade-meta">
        <span className="trade-date">
          Opened {created_at ? formatDistanceToNow(new Date(created_at), { addSuffix: true }) : 'recently'}
        </span>
        {closed_at && (
          <span className="trade-date">
            Closed {formatDistanceToNow(new Date(closed_at), { addSuffix: true })}
          </span>
        )}
      </div>

      {isOpen && onCloseTrade && (
        <button
          className="btn btn-secondary btn-sm close-trade-btn"
          onClick={() => onCloseTrade(id)}
          disabled={isClosing}
        >
          {isClosing ? 'Closing...' : 'Close Trade'}
        </button>
      )}
    </div>
  );
}

/**
 * Paper trading performance summary
 */
export function PaperPerformanceSummary({ performance }) {
  if (!performance) return null;

  const {
    total_trades = 0,
    open_trades = 0,
    closed_trades = 0,
    winning_trades = 0,
    losing_trades = 0,
    total_profit_loss = 0,
    win_rate = 0,
    average_profit = 0,
    average_loss = 0
  } = performance;

  const isProfitable = total_profit_loss >= 0;

  return (
    <div className="paper-performance-summary card">
      <h3>Paper Trading Performance</h3>

      <div className="performance-grid">
        <div className="perf-stat">
          <span className="stat-value">{total_trades}</span>
          <span className="stat-label">Total Trades</span>
        </div>
        <div className="perf-stat">
          <span className="stat-value">{open_trades}</span>
          <span className="stat-label">Open</span>
        </div>
        <div className="perf-stat">
          <span className="stat-value">{closed_trades}</span>
          <span className="stat-label">Closed</span>
        </div>
        <div className="perf-stat">
          <span className="stat-value">{(win_rate * 100).toFixed(0)}%</span>
          <span className="stat-label">Win Rate</span>
        </div>
      </div>

      <div className={`total-pnl ${isProfitable ? 'profit' : 'loss'}`}>
        <span className="pnl-label">Total P&L</span>
        <span className="pnl-value">
          {isProfitable ? '+' : ''}{total_profit_loss.toFixed(2)} USD
        </span>
      </div>

      <div className="win-loss-stats">
        <div className="wl-stat winning">
          <CheckCircle size={16} />
          <span>{winning_trades} wins</span>
          <span className="avg">avg: +${average_profit.toFixed(2)}</span>
        </div>
        <div className="wl-stat losing">
          <XCircle size={16} />
          <span>{losing_trades} losses</span>
          <span className="avg">avg: -${Math.abs(average_loss).toFixed(2)}</span>
        </div>
      </div>
    </div>
  );
}

export default PaperTradeCard;
