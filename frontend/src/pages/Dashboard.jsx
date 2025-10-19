import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Plus, RefreshCw, TrendingUp, TrendingDown, X } from 'lucide-react';
import { stocksApi, queryApi } from '../services/api';
import './Dashboard.css';

function Dashboard() {
  const [showAddStock, setShowAddStock] = useState(false);
  const [newSymbol, setNewSymbol] = useState('');
  const queryClient = useQueryClient();

  const { data: stocks, isLoading: stocksLoading } = useQuery({
    queryKey: ['stocks'],
    queryFn: async () => {
      const response = await stocksApi.getAll();
      return response.data;
    },
  });

  const { data: summary } = useQuery({
    queryKey: ['portfolio-summary'],
    queryFn: async () => {
      const response = await queryApi.getPortfolioSummary();
      return response.data;
    },
  });

  const addStockMutation = useMutation({
    mutationFn: (symbol) => stocksApi.create({ symbol, name: symbol }),
    onSuccess: () => {
      queryClient.invalidateQueries(['stocks']);
      queryClient.invalidateQueries(['portfolio-summary']);
      setNewSymbol('');
      setShowAddStock(false);
    },
  });

  const deleteStockMutation = useMutation({
    mutationFn: (symbol) => stocksApi.delete(symbol),
    onSuccess: () => {
      queryClient.invalidateQueries(['stocks']);
      queryClient.invalidateQueries(['portfolio-summary']);
    },
  });

  const handleAddStock = (e) => {
    e.preventDefault();
    if (newSymbol.trim()) {
      addStockMutation.mutate(newSymbol.toUpperCase());
    }
  };

  if (stocksLoading) {
    return <div className="loading"><div className="spinner"></div></div>;
  }

  return (
    <div className="dashboard">
      <div className="container">
        <div className="dashboard-header">
          <h1>Portfolio Dashboard</h1>
          <button className="btn btn-primary" onClick={() => setShowAddStock(true)}>
            <Plus size={20} />
            Add Stock
          </button>
        </div>

        {summary && (
          <div className="summary-cards">
            <div className="card">
              <h3>Total Stocks</h3>
              <p className="metric">{summary.total_stocks}</p>
            </div>
            {summary.sentiment_average !== null && (
              <div className="card">
                <h3>Average Sentiment</h3>
                <p className={`metric ${summary.sentiment_average > 0 ? 'text-success' : 'text-danger'}`}>
                  {summary.sentiment_average > 0 ? '+' : ''}{summary.sentiment_average.toFixed(3)}
                </p>
              </div>
            )}
          </div>
        )}

        {summary?.top_gainers && summary.top_gainers.length > 0 && (
          <div className="movers-section">
            <h2>Top Gainers</h2>
            <div className="movers-grid">
              {summary.top_gainers.map((stock) => (
                <div key={stock.symbol} className="mover-card gain">
                  <div className="mover-header">
                    <h4>{stock.symbol}</h4>
                    <TrendingUp size={20} />
                  </div>
                  <p className="mover-price">${stock.price.toFixed(2)}</p>
                  <p className="text-success">
                    +{stock.change_percent.toFixed(2)}%
                  </p>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="stocks-section">
          <h2>Your Stocks</h2>
          {stocks && stocks.length > 0 ? (
            <div className="stocks-grid">
              {stocks.map((stock) => (
                <div key={stock.symbol} className="stock-card card">
                  <div className="stock-header">
                    <div>
                      <Link to={`/stock/${stock.symbol}`} className="stock-symbol">
                        {stock.symbol}
                      </Link>
                      <p className="stock-name text-secondary">{stock.name}</p>
                    </div>
                    <button
                      className="btn-icon"
                      onClick={() => deleteStockMutation.mutate(stock.symbol)}
                    >
                      <X size={18} />
                    </button>
                  </div>
                  {stock.current_price && (
                    <div className="stock-price">
                      <p className="price">${stock.current_price.toFixed(2)}</p>
                      {stock.price_change && (
                        <p className={stock.price_change >= 0 ? 'text-success' : 'text-danger'}>
                          {stock.price_change >= 0 ? '+' : ''}
                          {stock.price_change.toFixed(2)} ({stock.price_change_percent.toFixed(2)}%)
                        </p>
                      )}
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-secondary">No stocks in portfolio. Add your first stock to get started!</p>
          )}
        </div>

        {showAddStock && (
          <div className="modal-overlay" onClick={() => setShowAddStock(false)}>
            <div className="modal" onClick={(e) => e.stopPropagation()}>
              <h2>Add Stock to Portfolio</h2>
              <form onSubmit={handleAddStock}>
                <input
                  type="text"
                  className="input"
                  placeholder="Enter stock symbol (e.g., AAPL)"
                  value={newSymbol}
                  onChange={(e) => setNewSymbol(e.target.value)}
                  autoFocus
                />
                <div className="modal-actions">
                  <button type="button" className="btn btn-secondary" onClick={() => setShowAddStock(false)}>
                    Cancel
                  </button>
                  <button type="submit" className="btn btn-primary" disabled={addStockMutation.isLoading}>
                    {addStockMutation.isLoading ? 'Adding...' : 'Add Stock'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Dashboard;
