import { useState, useMemo, useRef, useEffect, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { RefreshCw, ExternalLink, Filter, Info, Sparkles, ChevronDown, AlertCircle } from 'lucide-react';
import { newsApi, positionsApi } from '../services/api';
import { formatDistanceToNow } from 'date-fns';
import { useToast } from '../components/Toast/ToastProvider';
import { NewsPageSkeleton, NewsCardSkeleton } from '../components/SkeletonLoader';
import './News.css';

function News() {
  const queryClient = useQueryClient();
  const toast = useToast();
  const [sortBy, setSortBy] = useState('latest'); // latest, oldest, highest-sentiment, lowest-sentiment
  const [filterStock, setFilterStock] = useState('all');
  const [showFilters, setShowFilters] = useState(false);
  const [showSentimentDemo, setShowSentimentDemo] = useState(false); // Start collapsed

  // Refresh job state
  const [refreshJobId, setRefreshJobId] = useState(null);
  const [refreshProgress, setRefreshProgress] = useState(0);
  const [refreshMessage, setRefreshMessage] = useState('');
  const pollingIntervalRef = useRef(null);

  const { data: news, isLoading, isError, error } = useQuery({
    queryKey: ['news'],
    queryFn: async () => {
      const response = await newsApi.getAll({ limit: 100 });
      return response.data;
    },
    retry: 2,
    staleTime: 1000 * 60 * 5, // Consider data fresh for 5 minutes
    onError: (error) => {
      toast.error(
        'Failed to Load News',
        error.response?.data?.detail || 'Could not fetch news articles. Please try again.',
        6000
      );
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

  // Clean up polling interval on unmount
  useEffect(() => {
    return () => {
      if (pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
      }
    };
  }, []);

  // Poll for job status
  const pollJobStatus = useCallback(async (jobId) => {
    try {
      const response = await newsApi.refreshStatus(jobId);
      const job = response.data;

      setRefreshProgress(job.progress || 0);
      setRefreshMessage(job.message || 'Processing...');

      if (job.status === 'completed') {
        // Clear polling
        if (pollingIntervalRef.current) {
          clearInterval(pollingIntervalRef.current);
          pollingIntervalRef.current = null;
        }
        setRefreshJobId(null);
        setRefreshProgress(0);
        setRefreshMessage('');

        // Refresh news list
        queryClient.invalidateQueries(['news']);

        const newCount = job.new_articles || 0;
        const existsCount = job.already_exists || 0;
        const message = newCount > 0
          ? `Found ${newCount} new articles`
          : existsCount > 0
            ? `No new articles (${existsCount} already in database)`
            : job.message || 'Refresh completed';

        toast.success('News Refreshed', message, 5000);
      } else if (job.status === 'failed') {
        // Clear polling
        if (pollingIntervalRef.current) {
          clearInterval(pollingIntervalRef.current);
          pollingIntervalRef.current = null;
        }
        setRefreshJobId(null);
        setRefreshProgress(0);
        setRefreshMessage('');

        toast.error(
          'Refresh Failed',
          job.error || 'An error occurred while refreshing news.',
          6000
        );
      }
    } catch (err) {
      console.error('Error polling job status:', err);
      // Stop polling on error
      if (pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
        pollingIntervalRef.current = null;
      }
      setRefreshJobId(null);
      setRefreshProgress(0);
      setRefreshMessage('');

      toast.error(
        'Refresh Failed',
        'Lost connection to refresh job.',
        5000
      );
    }
  }, [queryClient, toast]);

  // Start refresh job
  const refreshMutation = useMutation({
    mutationFn: () => newsApi.refresh(),
    onSuccess: (response) => {
      const { job_id } = response.data;
      if (job_id) {
        setRefreshJobId(job_id);
        setRefreshProgress(0);
        setRefreshMessage('Starting...');

        // Start polling for status
        pollingIntervalRef.current = setInterval(() => {
          pollJobStatus(job_id);
        }, 2000); // Poll every 2 seconds
      } else {
        // Fallback for old API behavior (immediate completion)
        queryClient.invalidateQueries(['news']);
        const { new_articles = 0 } = response.data || {};
        toast.success(
          'News Refreshed',
          `Found ${new_articles} new articles`,
          5000
        );
      }
    },
    onError: (error) => {
      toast.error(
        'Refresh Failed',
        error.response?.data?.detail || 'Failed to start refresh. Please try again.',
        6000
      );
    },
  });

  const isRefreshing = refreshMutation.isPending || refreshJobId !== null;

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

  // Show skeleton while loading
  if (isLoading) {
    return <NewsPageSkeleton />;
  }

  // Show error state
  if (isError) {
    return (
      <div className="news-page">
        <div className="container">
          <div className="error-state card" style={{
            textAlign: 'center',
            padding: '3rem',
            marginTop: '2rem'
          }}>
            <AlertCircle size={48} style={{ color: '#ef4444', margin: '0 auto 1rem' }} />
            <h2>Failed to Load News</h2>
            <p style={{ color: '#6b7280', marginBottom: '1.5rem' }}>
              {error?.response?.data?.detail || 'Could not load news articles. Please check your connection and try again.'}
            </p>
            <button
              className="btn btn-primary"
              onClick={() => queryClient.invalidateQueries(['news'])}
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
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
              onClick={() => {
                if (!isRefreshing) {
                  refreshMutation.mutate();
                }
              }}
              disabled={isRefreshing}
            >
              <RefreshCw size={20} className={isRefreshing ? 'spinning' : ''} />
              {isRefreshing ? 'Refreshing...' : 'Refresh News'}
            </button>
          </div>
        </div>

        {/* Refresh Progress Indicator */}
        {isRefreshing && (
          <div className="refresh-progress card">
            <div className="refresh-progress-header">
              <RefreshCw size={18} className="spinning" />
              <span className="refresh-status">{refreshMessage || 'Processing...'}</span>
            </div>
            <div className="progress-bar-container">
              <div className="progress-bar">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${refreshProgress}%` }}
                />
              </div>
              <span className="progress-percent">{refreshProgress}%</span>
            </div>
          </div>
        )}

        <div className="sentiment-demo card">
          <button
            className="sentiment-demo-toggle"
            onClick={() => setShowSentimentDemo(!showSentimentDemo)}
            aria-expanded={showSentimentDemo}
          >
            <div className="sentiment-demo-title">
              <Sparkles size={20} className="sparkle-icon" />
              <h3>How Our Sentiment Analysis Works</h3>
            </div>
            <ChevronDown
              size={20}
              className={`chevron-icon ${showSentimentDemo ? 'expanded' : ''}`}
            />
          </button>

          {showSentimentDemo && (
            <div className="sentiment-demo-content">
              <p className="sentiment-demo-intro">
                We use Google's Gemini AI to analyze financial news sentiment. Here's how it evaluates different types of news:
              </p>

              <div className="sentiment-examples">
              <div className="sentiment-example">
                <div className="example-header">
                  <Info size={16} />
                  <strong>Very Positive News</strong>
                  <span className="sentiment-badge positive">+0.75</span>
                </div>
                <p className="example-text">"Company reports Q3 revenue up 25% YoY, beating analyst expectations"</p>
                <p className="example-reasoning">
                  <strong>Why:</strong> Revenue growth + earnings beat = strong investor confidence and likely stock price increase
                </p>
              </div>

              <div className="sentiment-example">
                <div className="example-header">
                  <Info size={16} />
                  <strong>Mixed/Neutral News</strong>
                  <span className="sentiment-badge neutral">-0.30</span>
                </div>
                <p className="example-text">"CEO announces restructuring plan, 500 jobs to be cut"</p>
                <p className="example-reasoning">
                  <strong>Why:</strong> Layoffs are concerning, but restructuring can improve efficiency. Market reaction depends on execution.
                </p>
              </div>

              <div className="sentiment-example">
                <div className="example-header">
                  <Info size={16} />
                  <strong>Very Negative News</strong>
                  <span className="sentiment-badge negative">-0.85</span>
                </div>
                <p className="example-text">"SEC opens investigation into accounting practices"</p>
                <p className="example-reasoning">
                  <strong>Why:</strong> Regulatory investigations signal serious concerns, erode investor trust, and often lead to significant price drops.
                </p>
              </div>
            </div>

              <div className="sentiment-factors">
                <h4>Key Factors We Analyze:</h4>
                <ul>
                  <li><strong>Market Impact:</strong> How will this affect the stock price?</li>
                  <li><strong>Investor Confidence:</strong> Will this attract or repel investors?</li>
                  <li><strong>Company Fundamentals:</strong> Does this strengthen or weaken the business?</li>
                  <li><strong>Risk Factors:</strong> Are there hidden concerns or opportunities?</li>
                </ul>
              </div>
            </div>
          )}
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
