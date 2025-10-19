import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Portfolios API
export const portfoliosApi = {
  getAll: () => api.get('/portfolios'),
  getActive: () => api.get('/portfolios/active'),
  getOne: (portfolioId) => api.get(`/portfolios/${portfolioId}`),
  create: (portfolioData) => api.post('/portfolios', portfolioData),
  update: (portfolioId, portfolioData) => api.put(`/portfolios/${portfolioId}`, portfolioData),
  activate: (portfolioId) => api.post(`/portfolios/${portfolioId}/activate`),
  delete: (portfolioId) => api.delete(`/portfolios/${portfolioId}`),
};

// Positions API
export const positionsApi = {
  getAll: (portfolioId = null) => api.get('/positions', { params: { portfolio_id: portfolioId } }),
  getOne: (positionId) => api.get(`/positions/${positionId}`),
  create: (positionData) => api.post('/positions', positionData),
  update: (positionId, positionData) => api.put(`/positions/${positionId}`, positionData),
  addShares: (positionId, sharesData) => api.post(`/positions/${positionId}/add-shares`, sharesData),
  delete: (positionId) => api.delete(`/positions/${positionId}`),
};

// Stocks API
export const stocksApi = {
  getAll: () => api.get('/stocks'),
  getOne: (symbol) => api.get(`/stocks/${symbol}`),
  create: (stockData) => api.post('/stocks', stockData),
  delete: (symbol) => api.delete(`/stocks/${symbol}`),
  refresh: (symbol) => api.post(`/stocks/${symbol}/refresh`),
  search: (keywords) => api.get(`/stocks/${keywords}/search`),
  // Stock actions
  getActions: (symbol) => api.get(`/stocks/${symbol}/actions`),
  getArticles: (symbol, limit = 10) => api.get(`/stocks/${symbol}/articles`, { params: { limit } }),
  getInsights: (symbol) => api.post(`/stocks/${symbol}/insights`),
  askQuestion: (symbol, question) => api.post(`/stocks/${symbol}/ask`, null, { params: { question } }),
};

// News API
export const newsApi = {
  getAll: (params) => api.get('/news', { params }),
  getOne: (articleId) => api.get(`/news/${articleId}`),
  refresh: () => api.post('/news/refresh'),
  analyzeSentiment: (articleId) => api.post(`/news/${articleId}/analyze-sentiment`),
};

// Query API
export const queryApi = {
  ask: (question, contextLimit = 5) =>
    api.post('/query/ask', { question, context_limit: contextLimit }),
  getPortfolioSummary: () => api.get('/query/portfolio-summary'),
  getStockSentiment: (symbol, days = 7) =>
    api.get(`/query/sentiment-analysis/${symbol}`, { params: { days } }),
};

export default api;
