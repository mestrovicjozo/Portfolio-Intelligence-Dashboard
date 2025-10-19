import { useState } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { stocksApi } from '../services/api';
import {
  Newspaper,
  Brain,
  TrendingUp,
  MessageCircle,
  X,
  Loader,
  ExternalLink,
  BarChart3,
} from 'lucide-react';
import PriceChart from './PriceChart';
import './StockActionsModal.css';

const StockActionsModal = ({ symbol, stockName, onClose }) => {
  const [selectedAction, setSelectedAction] = useState(null);
  const [question, setQuestion] = useState('');

  // Fetch available actions
  const { data: actions = [] } = useQuery({
    queryKey: ['stock-actions', symbol],
    queryFn: async () => {
      const response = await stocksApi.getActions(symbol);
      return response.data;
    },
  });

  // Fetch articles
  const { data: articles = [], isLoading: loadingArticles } = useQuery({
    queryKey: ['stock-articles', symbol],
    queryFn: async () => {
      const response = await stocksApi.getArticles(symbol, 5);
      return response.data;
    },
    enabled: selectedAction === 'view_articles',
  });

  // Get insights mutation
  const insightsMutation = useMutation({
    mutationFn: () => stocksApi.getInsights(symbol),
  });

  // Ask question mutation
  const askMutation = useMutation({
    mutationFn: (q) => stocksApi.askQuestion(symbol, q),
    onSuccess: () => {
      // Clear the question input after successful submission
      setQuestion('');
    },
  });

  const handleActionClick = (action) => {
    setSelectedAction(action);

    if (action === 'get_insights') {
      insightsMutation.mutate();
    }

    // Reset ask mutation when switching to ask_question action
    if (action === 'ask_question') {
      askMutation.reset();
      setQuestion('');
    }
  };

  const handleAskQuestion = (e) => {
    e.preventDefault();
    if (question.trim()) {
      // Reset the mutation to clear previous answer before asking new question
      askMutation.reset();
      askMutation.mutate(question);
    }
  };

  const getIcon = (iconName) => {
    const icons = {
      'bar-chart-3': BarChart3,
      newspaper: Newspaper,
      brain: Brain,
      'trending-up': TrendingUp,
      'message-circle': MessageCircle,
    };
    const Icon = icons[iconName] || MessageCircle;
    return <Icon size={20} />;
  };

  const getSentimentBadge = (score) => {
    if (score > 0.2) return <span className="sentiment-badge positive">Positive</span>;
    if (score < -0.2) return <span className="sentiment-badge negative">Negative</span>;
    return <span className="sentiment-badge neutral">Neutral</span>;
  };

  return (
    <>
      <div className="modal-overlay" onClick={onClose} />
      <div className="stock-actions-modal">
        <div className="modal-header">
          <div>
            <h2>{stockName}</h2>
            <p className="stock-symbol">{symbol}</p>
          </div>
          <button className="modal-close" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="modal-content">
          {!selectedAction ? (
            <div className="actions-grid">
              {actions.map((action) => (
                <button
                  key={action.action}
                  className="action-card"
                  onClick={() => handleActionClick(action.action)}
                >
                  <div className="action-icon">{getIcon(action.icon)}</div>
                  <h3>{action.label}</h3>
                  <p>{action.description}</p>
                </button>
              ))}
            </div>
          ) : (
            <div className="action-content">
              <button className="btn-back" onClick={() => setSelectedAction(null)}>
                ← Back
              </button>

              {selectedAction === 'view_articles' && (
                <div className="articles-view">
                  <h3>Recent Articles</h3>
                  {loadingArticles ? (
                    <div className="loading-state">
                      <Loader className="spinner" />
                      <p>Loading articles...</p>
                    </div>
                  ) : articles.length === 0 ? (
                    <div className="empty-state">
                      <p>No articles found. Try refreshing the news feed.</p>
                    </div>
                  ) : (
                    <div className="articles-list">
                      {articles.map((article) => (
                        <div key={article.id} className="article-card">
                          <div className="article-header">
                            <h4>{article.title}</h4>
                            {getSentimentBadge(article.sentiment_score)}
                          </div>
                          <p className="article-summary">{article.summary}</p>
                          <div className="article-meta">
                            <span className="article-source">{article.source}</span>
                            <span className="article-date">
                              {new Date(article.published_at).toLocaleDateString()}
                            </span>
                            <a
                              href={article.url}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="article-link"
                            >
                              Read more <ExternalLink size={14} />
                            </a>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {selectedAction === 'get_insights' && (
                <div className="insights-view">
                  <h3>AI-Generated Insights</h3>
                  {insightsMutation.isLoading ? (
                    <div className="loading-state">
                      <Loader className="spinner" />
                      <p>Generating insights...</p>
                    </div>
                  ) : insightsMutation.isError ? (
                    <div className="error-state">
                      <p>Error: {insightsMutation.error.response?.data?.detail || 'Failed to generate insights'}</p>
                    </div>
                  ) : insightsMutation.data ? (
                    <div className="insights-content">
                      <div className="insight-section">
                        <h4>Summary</h4>
                        <p>{insightsMutation.data.data.summary}</p>
                      </div>
                      <div className="insight-section">
                        <h4>Key Points</h4>
                        <ul>
                          {insightsMutation.data.data.key_points.map((point, index) => (
                            <li key={index}>{point}</li>
                          ))}
                        </ul>
                      </div>
                      <div className="insight-section">
                        <h4>Sentiment</h4>
                        <p className={`sentiment-${insightsMutation.data.data.sentiment}`}>
                          {insightsMutation.data.data.sentiment.toUpperCase()}
                        </p>
                      </div>
                      <div className="insight-section">
                        <h4>Outlook</h4>
                        <p>{insightsMutation.data.data.recommendation}</p>
                      </div>
                    </div>
                  ) : null}
                </div>
              )}

              {selectedAction === 'ask_question' && (
                <div className="ask-view">
                  <h3>Ask AI About {symbol}</h3>
                  <form onSubmit={handleAskQuestion}>
                    <div className="form-group">
                      <textarea
                        value={question}
                        onChange={(e) => setQuestion(e.target.value)}
                        placeholder={`Ask anything about ${symbol}...`}
                        rows={4}
                        autoFocus
                      />
                    </div>
                    <button
                      type="submit"
                      className="btn-primary"
                      disabled={!question.trim() || askMutation.isLoading}
                    >
                      {askMutation.isLoading ? 'Asking...' : 'Ask Question'}
                    </button>
                  </form>

                  {askMutation.isLoading && (
                    <div className="loading-state">
                      <Loader className="spinner" />
                      <p>Thinking...</p>
                    </div>
                  )}

                  {askMutation.data && (
                    <div className="answer-content">
                      <h4>Answer</h4>
                      <p>{askMutation.data.data.answer}</p>
                      {askMutation.data.data.sources && askMutation.data.data.sources.length > 0 && (
                        <div className="sources">
                          <h5>Sources</h5>
                          {askMutation.data.data.sources.map((source, index) => (
                            <a
                              key={index}
                              href={source.url}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="source-link"
                            >
                              {source.title}
                            </a>
                          ))}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}

              {selectedAction === 'view_chart' && (
                <div className="chart-view">
                  <h3>Price Chart</h3>
                  <PriceChart symbol={symbol} />
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default StockActionsModal;
