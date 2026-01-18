import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Bot, AlertCircle, TrendingUp, TrendingDown, RefreshCw, ChevronDown } from 'lucide-react';
import { roboadvisorApi, portfoliosApi } from '../services/api';
import RiskGauge, { RiskBadge } from '../components/RiskGauge';
import SignalCard from '../components/SignalCard';
import PaperTradeCard, { PaperPerformanceSummary } from '../components/PaperTradeCard';
import { RoboadvisorSkeleton } from '../components/SkeletonLoader';
import { useToast } from '../components/Toast/ToastProvider';
import { formatEUR } from '../utils/currency';
import './Roboadvisor.css';

function Roboadvisor() {
  const queryClient = useQueryClient();
  const toast = useToast();
  const [activeTab, setActiveTab] = useState('overview'); // overview, signals, trades
  const [showRebalancing, setShowRebalancing] = useState(false);

  // Fetch default portfolio
  const { data: portfolio, isLoading: portfolioLoading } = useQuery({
    queryKey: ['portfolio'],
    queryFn: async () => {
      const response = await portfoliosApi.getDefault();
      return response.data;
    },
  });

  const portfolioId = portfolio?.id;

  // Fetch portfolio risk analysis
  const { data: portfolioRisk, isLoading: riskLoading, isError: riskError, refetch: refetchRisk } = useQuery({
    queryKey: ['portfolioRisk', portfolioId],
    queryFn: async () => {
      const response = await roboadvisorApi.getPortfolioRisk(portfolioId);
      return response.data;
    },
    enabled: !!portfolioId,
    retry: 1,
    staleTime: 1000 * 60 * 5, // 5 minutes
  });

  // Fetch trading recommendations
  const { data: recommendations, isLoading: recommendationsLoading, refetch: refetchRecommendations } = useQuery({
    queryKey: ['recommendations', portfolioId],
    queryFn: async () => {
      const response = await roboadvisorApi.getPortfolioRecommendations(portfolioId);
      return response.data;
    },
    enabled: !!portfolioId,
    retry: 1,
    staleTime: 1000 * 60 * 5,
  });

  // Fetch rebalancing recommendations
  const { data: rebalancing, isLoading: rebalancingLoading } = useQuery({
    queryKey: ['rebalancing', portfolioId],
    queryFn: async () => {
      const response = await roboadvisorApi.getRebalancingRecommendations(portfolioId);
      return response.data;
    },
    enabled: !!portfolioId && showRebalancing,
    retry: 1,
  });

  // Fetch paper trades
  const { data: paperTrades, isLoading: tradesLoading } = useQuery({
    queryKey: ['paperTrades', portfolioId],
    queryFn: async () => {
      const response = await roboadvisorApi.getPaperTrades(portfolioId);
      return response.data;
    },
    enabled: !!portfolioId,
  });

  // Fetch paper trading performance
  const { data: paperPerformance } = useQuery({
    queryKey: ['paperPerformance', portfolioId],
    queryFn: async () => {
      const response = await roboadvisorApi.getPaperPerformance(portfolioId);
      return response.data;
    },
    enabled: !!portfolioId,
  });

  // Create paper trade from signal
  const createTradeMutation = useMutation({
    mutationFn: ({ symbol, quantity }) =>
      roboadvisorApi.createPaperTradeFromSignal(symbol, quantity, portfolioId),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['paperTrades', portfolioId]);
      queryClient.invalidateQueries(['paperPerformance', portfolioId]);
      toast.success(
        'Paper Trade Created',
        `Successfully opened ${response.data.trade_type} position for ${response.data.symbol}`,
        4000
      );
    },
    onError: (error) => {
      toast.error(
        'Failed to Create Trade',
        error.response?.data?.detail || 'Could not create paper trade',
        5000
      );
    },
  });

  // Close paper trade
  const closeTradeMutation = useMutation({
    mutationFn: (tradeId) => roboadvisorApi.closePaperTrade(tradeId),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['paperTrades', portfolioId]);
      queryClient.invalidateQueries(['paperPerformance', portfolioId]);
      const pnl = response.data.profit_loss || 0;
      toast.success(
        'Trade Closed',
        `Closed position with ${pnl >= 0 ? 'profit' : 'loss'} of $${Math.abs(pnl).toFixed(2)}`,
        4000
      );
    },
    onError: (error) => {
      toast.error(
        'Failed to Close Trade',
        error.response?.data?.detail || 'Could not close trade',
        5000
      );
    },
  });

  const handleExecuteTrade = (symbol, signal, quantity) => {
    createTradeMutation.mutate({ symbol, quantity });
  };

  const handleCloseTrade = (tradeId) => {
    closeTradeMutation.mutate(tradeId);
  };

  const handleRefreshData = () => {
    refetchRisk();
    refetchRecommendations();
    queryClient.invalidateQueries(['paperTrades', portfolioId]);
  };

  // Loading state
  if (portfolioLoading || (riskLoading && !portfolioRisk)) {
    return <RoboadvisorSkeleton />;
  }

  // Error state
  if (riskError) {
    return (
      <div className="roboadvisor-page">
        <div className="container">
          <div className="error-state card" style={{ textAlign: 'center', padding: '3rem', marginTop: '2rem' }}>
            <AlertCircle size={48} style={{ color: '#ef4444', margin: '0 auto 1rem' }} />
            <h2>Failed to Load Roboadvisor</h2>
            <p style={{ color: '#6b7280', marginBottom: '1.5rem' }}>
              Could not load risk analysis data. Please check your connection and try again.
            </p>
            <button className="btn btn-primary" onClick={() => refetchRisk()}>
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  const openTrades = paperTrades?.filter(t => t.status?.toLowerCase() === 'open') || [];
  const closedTrades = paperTrades?.filter(t => t.status?.toLowerCase() === 'closed') || [];

  return (
    <div className="roboadvisor-page">
      <div className="container">
        <div className="roboadvisor-header">
          <div className="header-info">
            <div className="header-title">
              <Bot size={28} className="header-icon" />
              <h1>Roboadvisor</h1>
            </div>
            <p className="text-secondary">AI-powered trading signals and portfolio analysis</p>
          </div>
          <button
            className="btn btn-secondary"
            onClick={handleRefreshData}
            disabled={riskLoading || recommendationsLoading}
          >
            <RefreshCw size={20} className={(riskLoading || recommendationsLoading) ? 'spinning' : ''} />
            Refresh Analysis
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="roboadvisor-tabs">
          <button
            className={`tab-btn ${activeTab === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveTab('overview')}
          >
            Overview
          </button>
          <button
            className={`tab-btn ${activeTab === 'signals' ? 'active' : ''}`}
            onClick={() => setActiveTab('signals')}
          >
            Trading Signals
            {recommendations?.signals?.length > 0 && (
              <span className="tab-badge">{recommendations.signals.length}</span>
            )}
          </button>
          <button
            className={`tab-btn ${activeTab === 'trades' ? 'active' : ''}`}
            onClick={() => setActiveTab('trades')}
          >
            Paper Trades
            {openTrades.length > 0 && (
              <span className="tab-badge">{openTrades.length}</span>
            )}
          </button>
        </div>

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="roboadvisor-overview">
            {/* Portfolio Risk Card */}
            <div className="risk-overview-card card">
              <h2>Portfolio Risk Analysis</h2>
              {portfolioRisk ? (
                <div className="risk-content">
                  <div className="risk-gauge-container">
                    <RiskGauge score={portfolioRisk.overall_risk} size="large" />
                  </div>
                  <div className="risk-details">
                    <div className="risk-detail-item">
                      <span className="detail-label">Weighted Risk</span>
                      <span className="detail-value">{portfolioRisk.weighted_risk?.toFixed(1) || 'N/A'}</span>
                    </div>
                    <div className="risk-detail-item">
                      <span className="detail-label">Concentration Risk</span>
                      <span className="detail-value">{portfolioRisk.concentration_risk?.toFixed(1) || 'N/A'}</span>
                    </div>
                    <div className="risk-detail-item">
                      <span className="detail-label">Total Value</span>
                      <span className="detail-value">{formatEUR(portfolioRisk.total_value)}</span>
                    </div>
                    <div className="risk-detail-item">
                      <span className="detail-label">Positions</span>
                      <span className="detail-value">{portfolioRisk.position_count || 0}</span>
                    </div>
                  </div>
                </div>
              ) : (
                <p className="text-secondary">Loading risk analysis...</p>
              )}
            </div>

            {/* Stock Risk Breakdown */}
            {portfolioRisk?.position_risks && portfolioRisk.position_risks.length > 0 && (
              <div className="stock-risks-card card">
                <h2>Stock Risk Breakdown</h2>
                <div className="stock-risks-list">
                  {portfolioRisk.position_risks.map((stock) => (
                    <div key={stock.symbol} className="stock-risk-item">
                      <div className="stock-risk-info">
                        <span className="stock-symbol">{stock.symbol}</span>
                        <span className="stock-weight">{stock.weight?.toFixed(1)}% of portfolio</span>
                      </div>
                      <div className="stock-risk-metrics">
                        <RiskBadge score={stock.overall_risk} />
                        <span className="metric-item">
                          <span className="metric-label">Vol:</span>
                          <span className="metric-value">{stock.volatility_score?.toFixed(1) || 'N/A'}</span>
                        </span>
                        <span className="metric-item">
                          <span className="metric-label">Beta:</span>
                          <span className="metric-value">{stock.beta?.toFixed(2) || 'N/A'}</span>
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Rebalancing Recommendations */}
            <div className="rebalancing-card card">
              <button
                className="rebalancing-toggle"
                onClick={() => setShowRebalancing(!showRebalancing)}
              >
                <h2>Rebalancing Recommendations</h2>
                <ChevronDown
                  size={20}
                  className={`chevron ${showRebalancing ? 'expanded' : ''}`}
                />
              </button>

              {showRebalancing && (
                <div className="rebalancing-content">
                  {rebalancingLoading ? (
                    <p className="text-secondary">Loading recommendations...</p>
                  ) : rebalancing?.recommendations?.length > 0 ? (
                    <div className="rebalancing-list">
                      {rebalancing.recommendations.map((rec, index) => (
                        <div key={index} className="rebalancing-item">
                          <div className="rebalance-action" data-action={rec.action?.toLowerCase()}>
                            {rec.action === 'BUY' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                            <span>{rec.action}</span>
                          </div>
                          <span className="rebalance-symbol">{rec.symbol}</span>
                          <span className="rebalance-amount">${rec.amount?.toFixed(2) || '0.00'}</span>
                          <span className="rebalance-reason">{rec.reason}</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-secondary">
                      No rebalancing needed. Your portfolio is well-balanced.
                    </p>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Signals Tab */}
        {activeTab === 'signals' && (
          <div className="roboadvisor-signals">
            {recommendationsLoading ? (
              <div className="signals-loading">
                <p className="text-secondary">Analyzing stocks and generating signals...</p>
              </div>
            ) : recommendations?.signals?.length > 0 ? (
              <div className="signals-grid">
                {recommendations.signals.map((signal, index) => (
                  <SignalCard
                    key={`${signal.symbol}-${index}`}
                    symbol={signal.symbol}
                    signal={signal.action}
                    confidence={signal.confidence}
                    reasoning={signal.reasoning}
                    riskScore={signal.risk_data?.overall_risk}
                    currentPrice={signal.price_trend?.current_price}
                    targetPrice={null}
                    onExecuteTrade={handleExecuteTrade}
                    isExecuting={createTradeMutation.isPending}
                  />
                ))}
              </div>
            ) : (
              <div className="card empty-state">
                <AlertCircle size={32} className="empty-icon" />
                <p>No trading signals available at this time.</p>
                <p className="text-secondary">Add stocks to your portfolio to receive personalized signals.</p>
              </div>
            )}

            <div className="signals-disclaimer card">
              <AlertCircle size={16} />
              <p>
                <strong>Disclaimer:</strong> Trading signals are generated by AI analysis and should not be considered
                financial advice. Always conduct your own research before making investment decisions. Past performance
                does not guarantee future results.
              </p>
            </div>
          </div>
        )}

        {/* Paper Trades Tab */}
        {activeTab === 'trades' && (
          <div className="roboadvisor-trades">
            {/* Performance Summary */}
            {paperPerformance && (
              <PaperPerformanceSummary performance={paperPerformance} />
            )}

            {/* Open Trades */}
            <div className="trades-section">
              <h2>Open Trades ({openTrades.length})</h2>
              {tradesLoading ? (
                <p className="text-secondary">Loading trades...</p>
              ) : openTrades.length > 0 ? (
                <div className="trades-grid">
                  {openTrades.map((trade) => (
                    <PaperTradeCard
                      key={trade.id}
                      trade={trade}
                      onCloseTrade={handleCloseTrade}
                      isClosing={closeTradeMutation.isPending}
                    />
                  ))}
                </div>
              ) : (
                <p className="text-secondary">
                  No open paper trades. Execute a signal to start paper trading.
                </p>
              )}
            </div>

            {/* Closed Trades */}
            {closedTrades.length > 0 && (
              <div className="trades-section">
                <h2>Trade History ({closedTrades.length})</h2>
                <div className="trades-grid">
                  {closedTrades.slice(0, 10).map((trade) => (
                    <PaperTradeCard key={trade.id} trade={trade} />
                  ))}
                </div>
                {closedTrades.length > 10 && (
                  <p className="text-secondary" style={{ marginTop: '1rem' }}>
                    Showing 10 of {closedTrades.length} closed trades
                  </p>
                )}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default Roboadvisor;
