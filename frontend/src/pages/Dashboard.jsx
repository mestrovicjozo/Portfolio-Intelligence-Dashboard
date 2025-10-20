import { useState, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Plus, TrendingUp, TrendingDown, X, MoreVertical, Upload } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { positionsApi, portfoliosApi, stocksApi } from '../services/api';
import StockActionsModal from '../components/StockActionsModal';
import AnimatedContainer from '../components/AnimatedContainer';
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

  // Fetch active portfolio
  const { data: activePortfolio } = useQuery({
    queryKey: ['active-portfolio'],
    queryFn: async () => {
      const response = await portfoliosApi.getActive();
      return response.data;
    },
  });

  // Fetch positions for active portfolio
  const { data: positions = [], isLoading: positionsLoading } = useQuery({
    queryKey: ['positions'],
    queryFn: async () => {
      const response = await positionsApi.getAll();
      return response.data;
    },
  });

  // Add position mutation
  const addPositionMutation = useMutation({
    mutationFn: (positionData) => positionsApi.create(positionData),
    onSuccess: () => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['active-portfolio']);
      setNewSymbol('');
      setNewShares('');
      setNewCost('');
      setShowAddPosition(false);
    },
  });

  // Delete position mutation
  const deletePositionMutation = useMutation({
    mutationFn: (positionId) => positionsApi.delete(positionId),
    onSuccess: () => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['active-portfolio']);
    },
  });

  // Import CSV mutation
  const importCSVMutation = useMutation({
    mutationFn: (file) => positionsApi.importCSV(file),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['positions']);
      queryClient.invalidateQueries(['active-portfolio']);
      setCsvFile(null);
      setShowImportCSV(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }

      // Show summary
      const data = response.data;
      alert(
        `CSV Import Complete!\n\n` +
        `Created: ${data.created} positions\n` +
        `Updated: ${data.updated} positions\n` +
        `Skipped: ${data.skipped} rows\n` +
        (data.errors && data.errors.length > 0 ? `\nErrors:\n${data.errors.join('\n')}` : '')
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
      alert('Please select a valid CSV file');
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

  if (positionsLoading) {
    return <div className="loading"><div className="spinner"></div></div>;
  }

  return (
    <div className="dashboard">
      <div className="container">
        <div className="dashboard-header">
          <div>
            <h1>{activePortfolio?.name || 'Portfolio Dashboard'}</h1>
            {activePortfolio?.description && (
              <p className="portfolio-description">{activePortfolio.description}</p>
            )}
          </div>
          <div className="dashboard-actions">
            <button className="btn btn-secondary" onClick={() => setShowImportCSV(true)}>
              <Upload size={20} />
              Import CSV
            </button>
            <button className="btn btn-primary" onClick={() => setShowAddPosition(true)}>
              <Plus size={20} />
              Add Position
            </button>
          </div>
        </div>

        {activePortfolio && (
          <motion.div
            className="summary-cards"
            variants={animations.staggerContainer}
            initial="initial"
            animate="animate"
          >
            <AnimatedContainer animation="fadeInUp" delay={0.1} className="card">
              <h3>Total Value</h3>
              <p className="metric">{formatEUR(activePortfolio.total_value)}</p>
              <p className="text-secondary">Cost: {formatEUR(activePortfolio.total_cost)}</p>
            </AnimatedContainer>
            <AnimatedContainer animation="fadeInUp" delay={0.2} className="card">
              <h3>Total Gain/Loss</h3>
              <p className={`metric ${activePortfolio.total_gain_loss >= 0 ? 'text-success' : 'text-danger'}`}>
                {activePortfolio.total_gain_loss >= 0 ? '+' : ''}
                {formatEUR(Math.abs(activePortfolio.total_gain_loss))}
              </p>
              <p className={activePortfolio.total_gain_loss_percent >= 0 ? 'text-success' : 'text-danger'}>
                {activePortfolio.total_gain_loss_percent >= 0 ? '+' : ''}
                {activePortfolio.total_gain_loss_percent}%
              </p>
            </AnimatedContainer>
            <AnimatedContainer animation="fadeInUp" delay={0.3} className="card">
              <h3>Positions</h3>
              <p className="metric">{activePortfolio.position_count}</p>
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
                    <p className="mover-price">{formatEUR(position.current_price)}</p>
                    <p className="text-success">
                      +{position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares @ {formatEUR(position.current_price)} • +{formatEUR(position.gain_loss)}
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
                    <p className="mover-price">{formatEUR(position.current_price)}</p>
                    <p className="text-danger">
                      {position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares @ {formatEUR(position.current_price)} • {formatEUR(Math.abs(position.gain_loss))}
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
                          <span className="stock-logo-text">{position.stock.symbol.substring(0, 2)}</span>
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
                          >
                            <X size={16} />
                            Delete
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
                    <button type="submit" className="btn btn-primary" disabled={addPositionMutation.isLoading}>
                      {addPositionMutation.isLoading ? 'Adding...' : 'Add Position'}
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
                      disabled={!csvFile || importCSVMutation.isLoading}
                    >
                      {importCSVMutation.isLoading ? 'Importing...' : 'Import Positions'}
                    </button>
                  </div>
                </form>
                {importCSVMutation.isLoading && (
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
