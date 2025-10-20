import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { RefreshCw, ExternalLink, Filter } from 'lucide-react';
import { newsApi, positionsApi } from '../services/api';
import { formatDistanceToNow } from 'date-fns';
import { useToast } from '../components/Toast/ToastProvider';
import './News.css';

function News() {
  const queryClient = useQueryClient();
  const toast = useToast();
  const [sortBy, setSortBy] = useState('latest'); // latest, oldest, highest-sentiment, lowest-sentiment
  const [filterStock, setFilterStock] = useState('all');
  const [showFilters, setShowFilters] = useState(false);

  const { data: news, isLoading } = useQuery({
    queryKey: ['news'],
    queryFn: async () => {
      const response = await newsApi.getAll({ limit: 100 });
      return response.data;
    },
  });

  // Get all stocks in portfolio for filter dropdown
  const { data: positions = [] } = useQuery({
    queryKey: ['positions'],
    queryFn: async () => {
      const response = await positionsApi.getAll();
      return response.data;
    },
  });

  const refreshMutation = useMutation({
    mutationFn: () => newsApi.refresh(),
    onSuccess: (response) => {
      queryClient.invalidateQueries(['news']);
      const { new_articles = 0, updated_articles = 0 } = response.data || {};
      toast.success(
        'News Refreshed',
        `Found ${new_articles} new articles and updated ${updated_articles} existing articles`,
        5000
      );
    },
    onError: (error) => {
      toast.error(
        'Refresh Failed',
        error.response?.data?.detail || 'Failed to refresh news. Please try again.',
        6000
      );
    },
  });

  const getSentimentLabel = (score) => {
    if (score === null || score === undefined) return 'neutral';
    if (score > 0.2) return 'positive';
    if (score < -0.2) return 'negative';
    return 'neutral';
  };

  // Filter and sort news
  const filteredAndSortedNews = useMemo(() => {
    if (!news) return [];

    let filtered = [...news];

    // Filter by stock
    if (filterStock !== 'all') {
      filtered = filtered.filter(article =>
        article.stock_symbols && article.stock_symbols.includes(filterStock)
      );
    }

    // Sort
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'latest':
          return new Date(b.published_at) - new Date(a.published_at);
        case 'oldest':
          return new Date(a.published_at) - new Date(b.published_at);
        case 'highest-sentiment':
          return (b.sentiment_score || 0) - (a.sentiment_score || 0);
        case 'lowest-sentiment':
          return (a.sentiment_score || 0) - (b.sentiment_score || 0);
        default:
          return 0;
      }
    });

    return filtered;
  }, [news, sortBy, filterStock]);

  // Get unique stocks from positions
  const portfolioStocks = useMemo(() => {
    return positions.map(p => p.stock.symbol).sort();
  }, [positions]);

  if (isLoading) {
    return <div className="loading"><div className="spinner"></div></div>;
  }

  return (
    <div className="news-page">
      <div className="container">
        <div className="news-header">
          <div>
            <h1>Market News</h1>
            <p className="text-secondary">{filteredAndSortedNews.length} articles</p>
          </div>
          <div className="news-actions">
            <button
              className="btn btn-secondary"
              onClick={() => setShowFilters(!showFilters)}
            >
              <Filter size={20} />
              {showFilters ? 'Hide Filters' : 'Show Filters'}
            </button>
            <button
              className="btn btn-primary"
              onClick={() => refreshMutation.mutate()}
              disabled={refreshMutation.isLoading}
            >
              <RefreshCw size={20} className={refreshMutation.isLoading ? 'spinning' : ''} />
              {refreshMutation.isLoading ? 'Refreshing...' : 'Refresh News'}
            </button>
          </div>
        </div>

        {showFilters && (
          <div className="news-filters card">
            <div className="filter-group">
              <label htmlFor="sort-by">Sort By:</label>
              <select
                id="sort-by"
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="filter-select"
              >
                <option value="latest">Latest First</option>
                <option value="oldest">Oldest First</option>
                <option value="highest-sentiment">Highest Sentiment</option>
                <option value="lowest-sentiment">Lowest Sentiment</option>
              </select>
            </div>

            <div className="filter-group">
              <label htmlFor="filter-stock">Filter by Stock:</label>
              <select
                id="filter-stock"
                value={filterStock}
                onChange={(e) => setFilterStock(e.target.value)}
                className="filter-select"
              >
                <option value="all">All Stocks</option>
                {portfolioStocks.map(symbol => (
                  <option key={symbol} value={symbol}>{symbol}</option>
                ))}
              </select>
            </div>

            {(sortBy !== 'latest' || filterStock !== 'all') && (
              <button
                className="btn btn-secondary btn-sm"
                onClick={() => {
                  setSortBy('latest');
                  setFilterStock('all');
                }}
              >
                Clear Filters
              </button>
            )}
          </div>
        )}

        {filteredAndSortedNews && filteredAndSortedNews.length > 0 ? (
          <div className="news-list">
            {filteredAndSortedNews.map((article) => {
              const sentiment = getSentimentLabel(article.sentiment_score);
              return (
                <div key={article.id} className="news-card card">
                  <div className="news-card-header">
                    <h3>{article.title}</h3>
                    {article.sentiment_score !== null && (
                      <span className={`sentiment-badge ${sentiment}`}>
                        {sentiment} ({article.sentiment_score.toFixed(2)})
                      </span>
                    )}
                  </div>
                  <div className="news-meta">
                    <span className="text-secondary">{article.source}</span>
                    {article.published_at && (
                      <span className="text-secondary">
                        {formatDistanceToNow(new Date(article.published_at), { addSuffix: true })}
                      </span>
                    )}
                  </div>
                  {article.summary && (
                    <p className="news-summary">{article.summary}</p>
                  )}
                  {article.stock_symbols && article.stock_symbols.length > 0 && (
                    <div className="stock-tags">
                      {article.stock_symbols.map((symbol) => (
                        <span key={symbol} className="stock-tag">{symbol}</span>
                      ))}
                    </div>
                  )}
                  {article.url && (
                    <a
                      href={article.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="news-link"
                    >
                      Read more <ExternalLink size={16} />
                    </a>
                  )}
                </div>
              );
            })}
          </div>
        ) : (
          <div className="card">
            <p className="text-secondary">
              No news articles found. Click "Refresh News" to fetch the latest articles for your portfolio.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default News;
