import { useQuery, useMutation, useQueryClient } from '@tantml:invoke>
<invoke name="RefreshCw, ExternalLink } from 'lucide-react';
import { newsApi } from '../services/api';
import { formatDistanceToNow } from 'date-fns';
import './News.css';

function News() {
  const queryClient = useQueryClient();

  const { data: news, isLoading } = useQuery({
    queryKey: ['news'],
    queryFn: async () => {
      const response = await newsApi.getAll({ limit: 100 });
      return response.data;
    },
  });

  const refreshMutation = useMutation({
    mutationFn: () => newsApi.refresh(),
    onSuccess: () => {
      queryClient.invalidateQueries(['news']);
    },
  });

  const getSentimentLabel = (score) => {
    if (score === null || score === undefined) return 'neutral';
    if (score > 0.2) return 'positive';
    if (score < -0.2) return 'negative';
    return 'neutral';
  };

  if (isLoading) {
    return <div className="loading"><div className="spinner"></div></div>;
  }

  return (
    <div className="news-page">
      <div className="container">
        <div className="news-header">
          <h1>Market News</h1>
          <button
            className="btn btn-primary"
            onClick={() => refreshMutation.mutate()}
            disabled={refreshMutation.isLoading}
          >
            <RefreshCw size={20} className={refreshMutation.isLoading ? 'spinning' : ''} />
            {refreshMutation.isLoading ? 'Refreshing...' : 'Refresh News'}
          </button>
        </div>

        {news && news.length > 0 ? (
          <div className="news-list">
            {news.map((article) => {
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
