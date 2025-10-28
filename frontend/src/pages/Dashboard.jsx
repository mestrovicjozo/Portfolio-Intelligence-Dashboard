import { useState, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Plus, TrendingUp, TrendingDown, X, MoreVertical, Upload, AlertCircle } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { positionsApi, portfoliosApi, stocksApi } from '../services/api';
import StockActionsModal from '../components/StockActionsModal';
import AnimatedContainer from '../components/AnimatedContainer';
import { DashboardSkeleton, PositionCardSkeleton, StatsCardSkeleton } from '../components/SkeletonLoader';
import { useToast } from '../components/Toast/ToastProvider';
import * as animations from '../utils/animations';
import { formatEUR } from '../utils/currency';
import './Dashboard.css';

function Dashboard() {
  const [showAddPosition, setShowAddPosition] = useState(false);
  const [showImportCSV, setShowImportCSV] = useState(false);
  const [newSymbol, setNewSymbol] = useState('');
  const [newShares, setNewShares] = useState('');
  const [newCost, setNewCost] = useState('');
  const [selectedStock, setSelectedStock] = useState(null);
  const [csvFile, setCsvFile] = useState(null);
  const [expandedPosition, setExpandedPosition] = useState(null);
  const fileInputRef = useRef(null);
  const queryClient = useQueryClient();
  const toast = useToast();

  // Fetch default portfolio
  const { data: portfolio, isLoading: portfolioLoading, isError: portfolioError, error: portfolioErrorData } = useQuery({
    queryKey: ['portfolio'],
    queryFn: async () => {
      const response = await portfoliosApi.getDefault();
      return response.data;
    },
    retry: 2,
    onError: (error) => {
      toast.error(
        'Failed to Load Portfolio',
        error.response?.data?.detail || 'Could not fetch portfolio data. Please try again.',
        6000
      );
    },
  });

  // Fetch positions for active portfolio
  const { data: positions = [], isLoading: positionsLoading, isError: positionsError, error: positionsErrorData } = useQuery({
    queryKey: ['positions'],
    queryFn: async () => {
      const response = await positionsApi.getAll();
      return response.data;
    },
    retry: 2,
    onError: (error) => {
      toast.error(
        'Failed to Load Positions',
        error.response?.data?.detail || 'Could not fetch positions. Please refresh the page.',
        6000
      );
    },
  });

  // Add position mutation
  const addPositionMutation = useMutation({
    mutationFn: (positionData) => positionsApi.create(positionData),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['portfolio']);
      setNewSymbol('');
      setNewShares('');
      setNewCost('');
      setShowAddPosition(false);
      toast.success(
        'Position Added',
        `Successfully added ${response.data.stock.symbol} to your portfolio`,
        4000
      );
    },
    onError: (error) => {
      toast.error(
        'Failed to Add Position',
        error.response?.data?.detail || 'Could not add position. Please check the stock symbol and try again.',
        6000
      );
    },
  });

  // Delete position mutation
  const deletePositionMutation = useMutation({
    mutationFn: (positionId) => positionsApi.delete(positionId),
    onSuccess: () => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['portfolio']);
      toast.success(
        'Position Deleted',
        'Position removed from your portfolio',
        3000
      );
    },
    onError: (error) => {
      toast.error(
        'Failed to Delete Position',
        error.response?.data?.detail || 'Could not delete position. Please try again.',
        5000
      );
    },
  });

  // Import CSV mutation
  const importCSVMutation = useMutation({
    mutationFn: (file) => positionsApi.importCSV(file),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['portfolio']);
      setCsvFile(null);
      setShowImportCSV(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }

      // Show summary with toast
      const data = response.data;
      const summary = `Created: ${data.created}, Updated: ${data.updated}, Skipped: ${data.skipped}`;

      if (data.errors && data.errors.length > 0) {
        toast.warning(
          'CSV Import Completed with Errors',
          `${summary}. Some rows had errors - check console for details.`,
          8000
        );
        console.error('CSV Import Errors:', data.errors);
      } else {
        toast.success(
          'CSV Import Successful',
          summary,
          5000
        );
      }
    },
    onError: (error) => {
      toast.error(
        'CSV Import Failed',
        error.response?.data?.detail || 'Failed to import CSV. Please check the file format and try again.',
        7000
      );
    },
  });

  const handleAddPosition = (e) => {
    e.preventDefault();
    if (newSymbol.trim() && newShares && newCost) {
      addPositionMutation.mutate({
        stock_symbol: newSymbol.toUpperCase(),
        shares: parseFloat(newShares),
        average_cost: parseFloat(newCost),
      });
    }
  };

  const handleFileSelect = (e) => {
    const file = e.target.files[0];
    if (file && file.name.endsWith('.csv')) {
      setCsvFile(file);
    } else {
      toast.error('Invalid File', 'Please select a valid CSV file', 3000);
      e.target.value = '';
    }
  };

  const handleImportCSV = (e) => {
    e.preventDefault();
    if (csvFile) {
      importCSVMutation.mutate(csvFile);
    }
  };

  // Calculate portfolio stats
  const totalGainers = positions.filter(p => p.gain_loss && p.gain_loss > 0).length;
  const totalLosers = positions.filter(p => p.gain_loss && p.gain_loss < 0).length;
  const topGainers = positions
    .filter(p => p.gain_loss_percent)
    .sort((a, b) => b.gain_loss_percent - a.gain_loss_percent)
    .slice(0, 3);
  const topLosers = positions
    .filter(p => p.gain_loss_percent)
    .sort((a, b) => a.gain_loss_percent - b.gain_loss_percent)
    .slice(0, 3);

  // Show skeleton loader while loading
  if (positionsLoading || portfolioLoading) {
    return <DashboardSkeleton />;
  }

  // Show error state if critical data failed to load
  if (positionsError || portfolioError) {
    return (
      <div className="dashboard">
        <div className="container">
          <div className="error-state card" style={{
            textAlign: 'center',
            padding: '3rem',
            marginTop: '2rem'
          }}>
            <AlertCircle size={48} style={{ color: '#ef4444', margin: '0 auto 1rem' }} />
            <h2>Failed to Load Dashboard</h2>
            <p style={{ color: '#6b7280', marginBottom: '1.5rem' }}>
              {positionsErrorData?.response?.data?.detail ||
               portfolioErrorData?.response?.data?.detail ||
               'Could not load your portfolio data. Please check your connection and try again.'}
            </p>
            <button
              className="btn btn-primary"
              onClick={() => {
                queryClient.invalidateQueries(['positions']);
                queryClient.invalidateQueries(['portfolio']);
              }}
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="container">
        <div className="dashboard-header">
          <div>
            <h1>My Portfolio</h1>
            <p className="portfolio-description">Your investment portfolio dashboard</p>
          </div>
          <div className="dashboard-actions">
            <button
              className="btn btn-secondary"
              onClick={() => setShowImportCSV(true)}
            >
              <Upload size={20} />
              Import CSV
            </button>
            <button
              className="btn btn-primary"
              onClick={() => setShowAddPosition(true)}
            >
              <Plus size={20} />
              Add Position
            </button>
          </div>
        </div>

        {portfolio && (
          <motion.div
            className="summary-cards"
            variants={animations.staggerContainer}
            initial="initial"
            animate="animate"
          >
            <AnimatedContainer animation="fadeInUp" delay={0.1} className="card">
              <h3>Total Value</h3>
              <p className="metric">{formatEUR(portfolio.total_value)}</p>
              <p className="text-secondary">Cost: {formatEUR(portfolio.total_cost)}</p>
            </AnimatedContainer>
            <AnimatedContainer animation="fadeInUp" delay={0.2} className="card">
              <h3>Total Gain/Loss</h3>
              <p className={`metric ${portfolio.total_gain_loss >= 0 ? 'text-success' : 'text-danger'}`}>
                {portfolio.total_gain_loss >= 0 ? '+' : ''}
                {formatEUR(Math.abs(portfolio.total_gain_loss))}
              </p>
              <p className={portfolio.total_gain_loss_percent >= 0 ? 'text-success' : 'text-danger'}>
                {portfolio.total_gain_loss_percent >= 0 ? '+' : ''}
                {portfolio.total_gain_loss_percent}%
              </p>
            </AnimatedContainer>
            <AnimatedContainer animation="fadeInUp" delay={0.3} className="card">
              <h3>Positions</h3>
              <p className="metric">{portfolio.position_count}</p>
              <p className="text-secondary">
                {totalGainers} gainers • {totalLosers} losers
              </p>
            </AnimatedContainer>
          </motion.div>
        )}

        <div className="movers-sections">
          {topGainers.length > 0 && (
            <div className="movers-section">
              <h2>Top Gainers</h2>
              <div className="movers-grid">
                {topGainers.map((position) => (
                  <div key={position.id} className="mover-card gain">
                    <div className="mover-header">
                      <h4>{position.stock.symbol}</h4>
                      <TrendingUp size={20} />
                    </div>
                    <p className="mover-price">{position.current_value ? formatEUR(position.current_value) : 'N/A'}</p>
                    <p className="text-success">
                      +{position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares • +{formatEUR(position.gain_loss)}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {topLosers.length > 0 && (
            <div className="movers-section">
              <h2>Top Losers</h2>
              <div className="movers-grid">
                {topLosers.map((position) => (
                  <div key={position.id} className="mover-card loss">
                    <div className="mover-header">
                      <h4>{position.stock.symbol}</h4>
                      <TrendingDown size={20} />
                    </div>
                    <p className="mover-price">{position.current_value ? formatEUR(position.current_value) : 'N/A'}</p>
                    <p className="text-danger">
                      {position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares • {formatEUR(Math.abs(position.gain_loss))}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="positions-section">
          <h2>Your Positions</h2>
          {positions && positions.length > 0 ? (
            <div className="positions-compact-list">
              {positions.map((position) => {
                const isExpanded = expandedPosition === position.id;
                const gainLossClass = position.gain_loss >= 0 ? 'gain' : 'loss';

                return (
                  <div key={position.id} className={`position-compact card ${isExpanded ? 'expanded' : ''}`}>
                    <button
                      className="position-compact-header"
                      onClick={() => setExpandedPosition(isExpanded ? null : position.id)}
                    >
                      <div className="position-compact-left">
                        <div className="stock-logo">
                          <img
                            src={`http://localhost:8000${position.stock.logo_url}`}
                            alt={position.stock.symbol}
                            className="stock-logo-img"
                            onError={(e) => {
                              // If image fails to load, show 2-letter fallback
                              e.target.style.display = 'none';
                              e.target.nextSibling.style.display = 'flex';
                            }}
                          />
                          <span className="stock-logo-text" style={{ display: 'none' }}>
                            {position.stock.symbol.substring(0, 2)}
                          </span>
                        </div>
                        <div className="position-compact-info">
                          <h3 className="position-compact-symbol">{position.stock.symbol}</h3>
                          <p className="position-compact-name">{position.stock.name}</p>
                        </div>
                      </div>
                      <div className="position-compact-right">
                        <div className="position-compact-value">
                          <p className="position-compact-price">{position.current_value ? formatEUR(position.current_value) : 'N/A'}</p>
                          {position.gain_loss !== null && (
                            <p className={`position-compact-change ${gainLossClass}`}>
                              {position.gain_loss >= 0 ? '+' : ''}{formatEUR(Math.abs(position.gain_loss))}
                              <span className="change-percent"> ({position.gain_loss_percent?.toFixed(2)}%)</span>
                            </p>
                          )}
                        </div>
                        <div className="position-expand-icon">
                          {isExpanded ? '−' : '+'}
                        </div>
                      </div>
                    </button>

                    {isExpanded && (
                      <div className="position-expanded-content">
                        <div className="position-details-grid">
                          <div className="detail-item">
                            <span className="detail-label">Shares</span>
                            <span className="detail-value">{position.shares}</span>
                          </div>
                          <div className="detail-item">
                            <span className="detail-label">Avg Cost</span>
                            <span className="detail-value">{formatEUR(position.average_cost)}</span>
                          </div>
                          <div className="detail-item">
                            <span className="detail-label">Current Price</span>
                            <span className="detail-value">{position.current_price ? formatEUR(position.current_price) : 'N/A'}</span>
                          </div>
                          <div className="detail-item">
                            <span className="detail-label">Total Cost</span>
                            <span className="detail-value">{formatEUR(position.total_cost)}</span>
                          </div>
                          {position.current_value && (
                            <div className="detail-item">
                              <span className="detail-label">Total Value</span>
                              <span className="detail-value">{formatEUR(position.current_value)}</span>
                            </div>
                          )}
                          {position.day_change && (
                            <div className="detail-item">
                              <span className="detail-label">Day Change</span>
                              <span className={position.day_change >= 0 ? 'text-success' : 'text-danger'}>
                                {position.day_change >= 0 ? '+' : ''}{formatEUR(Math.abs(position.day_change))} ({position.day_change_percent?.toFixed(2)}%)
                              </span>
                            </div>
                          )}
                        </div>

                        <div className="position-expanded-actions">
                          <Link
                            to={`/stock/${position.stock.symbol}`}
                            className="btn btn-secondary btn-sm"
                          >
                            View Details
                          </Link>
                          <button
                            className="btn btn-secondary btn-sm"
                            onClick={(e) => {
                              e.stopPropagation();
                              setSelectedStock({
                                symbol: position.stock.symbol,
                                name: position.stock.name
                              });
                            }}
                          >
                            <MoreVertical size={16} />
                            Actions
                          </button>
                          <button
                            className="btn btn-danger btn-sm"
                            onClick={(e) => {
                              e.stopPropagation();
                              if (confirm(`Delete ${position.stock.symbol} position?`)) {
                                deletePositionMutation.mutate(position.id);
                              }
                            }}
                            disabled={deletePositionMutation.isPending}
                          >
                            <X size={16} />
                            {deletePositionMutation.isPending ? 'Deleting...' : 'Delete'}
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          ) : (
            <p className="text-secondary">No positions in this portfolio. Add your first position to get started!</p>
          )}
        </div>

        <div className="disclaimer">
          <p>
            <strong>Disclaimer:</strong> This dashboard provides information and insights based on market data and news analysis.
            It is not financial advice and does not guarantee future price movements or investment outcomes.
            Past performance does not indicate future results. Always conduct your own research and consult with a qualified
            financial advisor before making investment decisions.
          </p>
        </div>

        <AnimatePresence>
          {showAddPosition && (
            <motion.div
              className="modal-overlay"
              onClick={() => setShowAddPosition(false)}
              {...animations.modalOverlay}
            >
              <motion.div
                className="modal"
                onClick={(e) => e.stopPropagation()}
                {...animations.modalContent}
              >
                <h2>Add Position to Portfolio</h2>
                <form onSubmit={handleAddPosition}>
                  <div className="form-group">
                    <label htmlFor="symbol">Stock Symbol</label>
                    <input
                      id="symbol"
                      type="text"
                      className="input"
                      placeholder="e.g., AAPL"
                      value={newSymbol}
                      onChange={(e) => setNewSymbol(e.target.value)}
                      autoFocus
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="shares">Number of Shares</label>
                    <input
                      id="shares"
                      type="number"
                      step="0.01"
                      min="0"
                      className="input"
                      placeholder="e.g., 10"
                      value={newShares}
                      onChange={(e) => setNewShares(e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="cost">Average Cost Per Share</label>
                    <input
                      id="cost"
                      type="number"
                      step="0.01"
                      min="0"
                      className="input"
                      placeholder="e.g., 150.00"
                      value={newCost}
                      onChange={(e) => setNewCost(e.target.value)}
                      required
                    />
                  </div>
                  <div className="modal-actions">
                    <button type="button" className="btn btn-secondary" onClick={() => setShowAddPosition(false)}>
                      Cancel
                    </button>
                    <button type="submit" className="btn btn-primary" disabled={addPositionMutation.isPending}>
                      {addPositionMutation.isPending ? 'Adding...' : 'Add Position'}
                    </button>
                  </div>
                </form>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>

        <AnimatePresence>
          {showImportCSV && (
            <motion.div
              className="modal-overlay"
              onClick={() => setShowImportCSV(false)}
              {...animations.modalOverlay}
            >
              <motion.div
                className="modal"
                onClick={(e) => e.stopPropagation()}
                {...animations.modalContent}
              >
                <h2>Import Portfolio from CSV</h2>
                <p className="text-secondary" style={{ marginBottom: '1rem' }}>
                  Upload a CSV file exported from Trading 212 to import all your positions at once.
                </p>
                <div className="alert alert-info" style={{
                  padding: '0.75rem 1rem',
                  marginBottom: '1.5rem',
                  backgroundColor: '#eff6ff',
                  border: '1px solid #bfdbfe',
                  borderRadius: '6px',
                  fontSize: '0.875rem',
                  color: '#1e40af'
                }}>
                  <strong>Note:</strong> Currently, we only support CSV files exported from Trading 212.
                  The format must include columns: Slice (symbol), Name, Invested value, and Owned quantity.
                </div>
                <form onSubmit={handleImportCSV}>
                  <div className="form-group">
                    <label htmlFor="csv-file">Select CSV File</label>
                    <input
                      id="csv-file"
                      type="file"
                      accept=".csv"
                      onChange={handleFileSelect}
                      ref={fileInputRef}
                      className="input"
                      required
                    />
                    {csvFile && (
                      <p className="file-name" style={{ marginTop: '0.5rem', fontSize: '0.875rem', color: '#10b981' }}>
                        Selected: {csvFile.name}
                      </p>
                    )}
                  </div>
                  <div className="modal-actions">
                    <button type="button" className="btn btn-secondary" onClick={() => setShowImportCSV(false)}>
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="btn btn-primary"
                      disabled={!csvFile || importCSVMutation.isPending}
                    >
                      {importCSVMutation.isPending ? 'Importing...' : 'Import Positions'}
                    </button>
                  </div>
                </form>
                {importCSVMutation.isPending && (
                  <div className="import-progress">
                    <div className="progress-header">
                      <p>Importing positions...</p>
                      <p className="progress-subtext">Fetching stock data and price history. This may take a moment.</p>
                    </div>
                    <div className="progress-bar-container">
                      <div className="progress-bar">
                        <div className="progress-bar-fill"></div>
                      </div>
                    </div>
                  </div>
                )}
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>

        {selectedStock && (
          <StockActionsModal
            symbol={selectedStock.symbol}
            stockName={selectedStock.name}
            onClose={() => setSelectedStock(null)}
          />
        )}
      </div>
    </div>
  );
}

export default Dashboard;
