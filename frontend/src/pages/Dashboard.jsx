import { useState, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Plus, TrendingUp, TrendingDown, X, MoreVertical, Upload } from 'lucide-react';
import { positionsApi, portfoliosApi, stocksApi } from '../services/api';
import StockActionsModal from '../components/StockActionsModal';
import './Dashboard.css';

function Dashboard() {
  const [showAddPosition, setShowAddPosition] = useState(false);
  const [showImportCSV, setShowImportCSV] = useState(false);
  const [newSymbol, setNewSymbol] = useState('');
  const [newShares, setNewShares] = useState('');
  const [newCost, setNewCost] = useState('');
  const [selectedStock, setSelectedStock] = useState(null);
  const [csvFile, setCsvFile] = useState(null);
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
          <div className="summary-cards">
            <div className="card">
              <h3>Total Value</h3>
              <p className="metric">${activePortfolio.total_value.toLocaleString()}</p>
              <p className="text-secondary">Cost: ${activePortfolio.total_cost.toLocaleString()}</p>
            </div>
            <div className="card">
              <h3>Total Gain/Loss</h3>
              <p className={`metric ${activePortfolio.total_gain_loss >= 0 ? 'text-success' : 'text-danger'}`}>
                {activePortfolio.total_gain_loss >= 0 ? '+' : ''}
                ${Math.abs(activePortfolio.total_gain_loss).toLocaleString()}
              </p>
              <p className={activePortfolio.total_gain_loss_percent >= 0 ? 'text-success' : 'text-danger'}>
                {activePortfolio.total_gain_loss_percent >= 0 ? '+' : ''}
                {activePortfolio.total_gain_loss_percent}%
              </p>
            </div>
            <div className="card">
              <h3>Positions</h3>
              <p className="metric">{activePortfolio.position_count}</p>
              <p className="text-secondary">
                {totalGainers} gainers • {totalLosers} losers
              </p>
            </div>
          </div>
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
                    <p className="mover-price">${position.current_price?.toFixed(2)}</p>
                    <p className="text-success">
                      +{position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares • +${position.gain_loss.toFixed(2)}
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
                    <p className="mover-price">${position.current_price?.toFixed(2)}</p>
                    <p className="text-danger">
                      {position.gain_loss_percent.toFixed(2)}%
                    </p>
                    <p className="mover-shares">
                      {position.shares} shares • ${position.gain_loss.toFixed(2)}
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
            <div className="positions-grid">
              {positions.map((position) => (
                <div key={position.id} className="position-card card">
                  <div className="position-header">
                    <div className="position-info">
                      <Link
                        to={`/stock/${position.stock.symbol}`}
                        className="stock-symbol"
                      >
                        {position.stock.symbol}
                      </Link>
                      <p className="stock-name text-secondary">{position.stock.name}</p>
                    </div>
                    <div className="position-actions">
                      <button
                        className="btn-icon"
                        onClick={() => setSelectedStock({
                          symbol: position.stock.symbol,
                          name: position.stock.name
                        })}
                        title="Stock actions"
                      >
                        <MoreVertical size={18} />
                      </button>
                      <button
                        className="btn-icon"
                        onClick={() => {
                          if (confirm(`Delete ${position.stock.symbol} position?`)) {
                            deletePositionMutation.mutate(position.id);
                          }
                        }}
                        title="Delete position"
                      >
                        <X size={18} />
                      </button>
                    </div>
                  </div>

                  <div className="position-details">
                    <div className="detail-row">
                      <span className="detail-label">Shares:</span>
                      <span className="detail-value">{position.shares}</span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">Avg Cost:</span>
                      <span className="detail-value">${position.average_cost.toFixed(2)}</span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">Current:</span>
                      <span className="detail-value">
                        ${position.current_price?.toFixed(2) || 'N/A'}
                      </span>
                    </div>
                  </div>

                  {position.current_value && (
                    <div className="position-summary">
                      <div className="summary-row">
                        <span>Total Value:</span>
                        <span className="value-amount">
                          ${position.current_value.toLocaleString()}
                        </span>
                      </div>
                      <div className="summary-row">
                        <span>Gain/Loss:</span>
                        <span className={position.gain_loss >= 0 ? 'text-success value-amount' : 'text-danger value-amount'}>
                          {position.gain_loss >= 0 ? '+' : ''}
                          ${Math.abs(position.gain_loss).toLocaleString()} ({position.gain_loss_percent.toFixed(2)}%)
                        </span>
                      </div>
                      {position.day_change && (
                        <div className="summary-row">
                          <span>Today:</span>
                          <span className={position.day_change >= 0 ? 'text-success' : 'text-danger'}>
                            {position.day_change >= 0 ? '+' : ''}
                            ${Math.abs(position.day_change).toFixed(2)} ({position.day_change_percent.toFixed(2)}%)
                          </span>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              ))}
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

        {showAddPosition && (
          <div className="modal-overlay" onClick={() => setShowAddPosition(false)}>
            <div className="modal" onClick={(e) => e.stopPropagation()}>
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
            </div>
          </div>
        )}

        {showImportCSV && (
          <div className="modal-overlay" onClick={() => setShowImportCSV(false)}>
            <div className="modal" onClick={(e) => e.stopPropagation()}>
              <h2>Import Portfolio from CSV</h2>
              <p className="text-secondary" style={{ marginBottom: '1.5rem' }}>
                Upload a CSV file exported from Trading 212 to import all your positions at once.
              </p>
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
                <div style={{ marginTop: '1rem', textAlign: 'center', color: '#6b7280' }}>
                  <p>Importing positions... This may take a moment as we fetch stock data.</p>
                </div>
              )}
            </div>
          </div>
        )}

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
