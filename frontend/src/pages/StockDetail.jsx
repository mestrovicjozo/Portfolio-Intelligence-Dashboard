import { useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import { stocksApi, queryApi, newsApi } from '../services/api';
import PriceChart from '../components/PriceChart';
import './StockDetail.css';

function StockDetail() {
  const { symbol } = useParams();

  const { data: stock, isLoading: stockLoading } = useQuery({
    queryKey: ['stock', symbol],
    queryFn: async () => {
      const response = await stocksApi.getOne(symbol);
      return response.data;
    },
  });

  const { data: sentiment } = useQuery({
    queryKey: ['sentiment', symbol],
    queryFn: async () => {
      const response = await queryApi.getStockSentiment(symbol, 7);
      return response.data;
    },
  });

  const { data: news } = useQuery({
    queryKey: ['stock-news', symbol],
    queryFn: async () => {
      const response = await newsApi.getAll({ stock_symbol: symbol, limit: 10 });
      return response.data;
    },
  });

  if (stockLoading) {
    return <div className="loading"><div className="spinner"></div></div>;
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

            {sentiment && (
              <div className="card" style={{ marginTop: '2rem' }}>
                <h2>Sentiment Analysis (7 days)</h2>
                <p>Articles analyzed: {sentiment.article_count}</p>
                {sentiment.average_sentiment !== null && (
                  <p className={sentiment.average_sentiment > 0 ? 'text-success' : 'text-danger'}>
                    Average Sentiment: {sentiment.average_sentiment.toFixed(3)}
                  </p>
                )}
              </div>
            )}

            {news && news.length > 0 && (
              <div style={{ marginTop: '2rem' }}>
                <h2>Recent News</h2>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', marginTop: '1rem' }}>
                  {news.map((article) => (
                    <div key={article.id} className="card">
                      <h3 style={{ fontSize: '1.125rem', marginBottom: '0.5rem' }}>{article.title}</h3>
                      <p className="text-secondary">{article.source}</p>
                      {article.summary && <p style={{ marginTop: '0.5rem' }}>{article.summary}</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default StockDetail;
