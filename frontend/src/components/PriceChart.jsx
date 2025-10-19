import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { TrendingUp, TrendingDown } from 'lucide-react';
import axios from 'axios';
import './PriceChart.css';

const PriceChart = ({ symbol }) => {
  const [timeframe, setTimeframe] = useState('7D');

  const { data: priceData, isLoading } = useQuery({
    queryKey: ['stock-prices', symbol, timeframe],
    queryFn: async () => {
      const days = timeframe === '1D' ? 1 : timeframe === '7D' ? 7 : 30;
      const response = await axios.get(`http://localhost:8000/api/stocks/${symbol}/prices`, {
        params: { days }
      });
      return response.data;
    },
  });

  if (isLoading) {
    return (
      <div className="price-chart-loading">
        <div className="spinner"></div>
        <p>Loading chart...</p>
      </div>
    );
  }

  if (!priceData || priceData.length === 0) {
    return (
      <div className="price-chart-empty">
        <p>No price data available. Please refresh stock prices.</p>
      </div>
    );
  }

  // Calculate price change
  const firstPrice = priceData[0]?.close;
  const lastPrice = priceData[priceData.length - 1]?.close;
  const priceChange = lastPrice - firstPrice;
  const priceChangePercent = ((priceChange / firstPrice) * 100).toFixed(2);
  const isPositive = priceChange >= 0;

  // Format data for chart
  const chartData = priceData.map(item => ({
    date: new Date(item.date).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric'
    }),
    price: item.close,
    fullDate: item.date,
  }));

  return (
    <div className="price-chart">
      <div className="price-chart-header">
        <div className="price-info">
          <h3>Price Chart</h3>
          <div className="price-change">
            <span className="current-price">${lastPrice?.toFixed(2)}</span>
            <span className={`change ${isPositive ? 'positive' : 'negative'}`}>
              {isPositive ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
              {isPositive ? '+' : ''}${Math.abs(priceChange).toFixed(2)} ({isPositive ? '+' : ''}{priceChangePercent}%)
            </span>
          </div>
        </div>
        <div className="timeframe-buttons">
          {['1D', '7D', '30D'].map((tf) => (
            <button
              key={tf}
              className={`timeframe-btn ${timeframe === tf ? 'active' : ''}`}
              onClick={() => setTimeframe(tf)}
            >
              {tf}
            </button>
          ))}
        </div>
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
          <XAxis
            dataKey="date"
            stroke="#6b7280"
            style={{ fontSize: '12px' }}
          />
          <YAxis
            stroke="#6b7280"
            style={{ fontSize: '12px' }}
            domain={['auto', 'auto']}
            tickFormatter={(value) => `$${value.toFixed(2)}`}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: 'white',
              border: '1px solid #e5e7eb',
              borderRadius: '6px',
              padding: '8px 12px'
            }}
            formatter={(value) => [`$${value.toFixed(2)}`, 'Price']}
            labelFormatter={(label, payload) => {
              if (payload && payload[0]) {
                return new Date(payload[0].payload.fullDate).toLocaleDateString('en-US', {
                  weekday: 'short',
                  year: 'numeric',
                  month: 'short',
                  day: 'numeric'
                });
              }
              return label;
            }}
          />
          <Line
            type="monotone"
            dataKey="price"
            stroke={isPositive ? '#10b981' : '#ef4444'}
            strokeWidth={2}
            dot={false}
            activeDot={{ r: 4 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};

export default PriceChart;
