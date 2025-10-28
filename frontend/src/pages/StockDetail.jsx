import { useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, AlertCircle, Loader } from 'lucide-react';
import { Link } from 'react-router-dom';
import { stocksApi, queryApi, newsApi } from '../services/api';
import PriceChart from '../components/PriceChart';
import { Skeleton, ArticleListSkeleton } from '../components/SkeletonLoader';
import { useToast } from '../components/Toast/ToastProvider';
import './StockDetail.css';

function StockDetail() {
  const { symbol } = useParams();
  const toast = useToast();

  const { data: stock, isLoading: stockLoading, isError: stockError, error: stockErrorData } = useQuery({
    queryKey: ['stock', symbol],
    queryFn: async () => {
      const response = await stocksApi.getOne(symbol);
      return response.data;
    },
    retry: 2,
    onError: (error) => {
      toast.error(
        'Failed to Load Stock Data',
        error.response?.data?.detail || `Could not fetch data for ${symbol}. Please try again.`,
        6000
      );
    },
  });

  const { data: sentiment, isLoading: sentimentLoading } = useQuery({
    queryKey: ['sentiment', symbol],
    queryFn: async () => {
      const response = await queryApi.getStockSentiment(symbol, 7);
      return response.data;
    },
    enabled: !!stock,
    retry: 1,
    onError: (error) => {
      console.error('Failed to load sentiment:', error);
    },
  });

  const { data: news, isLoading: newsLoading } = useQuery({
    queryKey: ['stock-news', symbol],
    queryFn: async () => {
      const response = await newsApi.getAll({ stock_symbol: symbol, limit: 10 });
      return response.data;
    },
    enabled: !!stock,
    retry: 1,
    onError: (error) => {
      console.error('Failed to load news:', error);
    },
  });

  if (stockLoading) {
    return (
      <div className="stock-detail-page">
        <div className="container">
          <Link to="/" className="back-link">
            <ArrowLeft size={20} />
            Back to Dashboard
          </Link>
          <div style={{ marginTop: '2rem' }}>
            <Skeleton width="200px" height="40px" />
            <Skeleton width="300px" height="24px" style={{ marginTop: '0.5rem' }} />
            <div style={{ marginTop: '2rem' }}>
              <Skeleton width="100%" height="400px" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (stockError) {
    return (
      <div className="stock-detail-page">
        <div className="container">
          <Link to="/" className="back-link">
            <ArrowLeft size={20} />
            Back to Dashboard
          </Link>
          <div className="error-state card" style={{
            textAlign: 'center',
            padding: '3rem',
            marginTop: '2rem'
          }}>
            <AlertCircle size={48} style={{ color: '#ef4444', margin: '0 auto 1rem' }} />
            <h2>Failed to Load Stock Details</h2>
            <p style={{ color: '#6b7280', marginBottom: '1.5rem' }}>
              {stockErrorData?.response?.data?.detail || `Could not load details for ${symbol}. The stock may not exist.`}
            </p>
            <Link to="/" className="btn btn-primary">
              Back to Dashboard
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="stock-detail-page">
      <div className="container">
        <Link to="/" className="back-link">
          <ArrowLeft size={20} />
          Back to Dashboard
        </Link>

        {stock && (
          <div>
            <div className="stock-detail-header">
              <div>
                <h1>{stock.symbol}</h1>
                <p className="text-secondary">{stock.name}</p>
                {stock.sector && <p className="text-secondary">{stock.sector}</p>}
              </div>
              {stock.current_price && (
                <div className="stock-detail-price">
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

            <PriceChart symbol={symbol} />

            {/* Sentiment Section with Loading State */}
            <div className="card" style={{ marginTop: '2rem' }}>
              <h2>Sentiment Analysis (7 days)</h2>
              {sentimentLoading ? (
                <div style={{ padding: '1rem 0' }}>
                  <Loader className="spinner" size={24} style={{ margin: '0 auto', display: 'block' }} />
                  <p style={{ textAlign: 'center', marginTop: '0.5rem', color: '#6b7280' }}>
                    Analyzing sentiment...
                  </p>
                </div>
              ) : sentiment ? (
                <>
                  <p>Articles analyzed: {sentiment.article_count}</p>
                  {sentiment.average_sentiment !== null && (
                    <p className={sentiment.average_sentiment > 0 ? 'text-success' : 'text-danger'}>
                      Average Sentiment: {sentiment.average_sentiment.toFixed(3)}
                    </p>
                  )}
                </>
              ) : (
                <p className="text-secondary">No sentiment data available</p>
              )}
            </div>

            {/* News Section with Loading State */}
            <div style={{ marginTop: '2rem' }}>
              <h2>Recent News</h2>
              {newsLoading ? (
                <div style={{ marginTop: '1rem' }}>
                  <ArticleListSkeleton count={3} />
                </div>
              ) : news && news.length > 0 ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', marginTop: '1rem' }}>
                  {news.map((article) => (
                    <div key={article.id} className="card">
                      <h3 style={{ fontSize: '1.125rem', marginBottom: '0.5rem' }}>{article.title}</h3>
                      <p className="text-secondary">{article.source}</p>
                      {article.summary && <p style={{ marginTop: '0.5rem' }}>{article.summary}</p>}
                    </div>
                  ))}
                </div>
              ) : (
                <div className="card" style={{ marginTop: '1rem' }}>
                  <p className="text-secondary">No recent news available for this stock</p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default StockDetail;
