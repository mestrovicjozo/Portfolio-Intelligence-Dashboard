import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 180000, // 3 minute timeout (news refresh can take 1-2 minutes)
});

// Request interceptor for logging and debugging
api.interceptors.request.use(
  (config) => {
    // Silent in production and development (removed console spam)
    return config;
  },
  (error) => {
    // Only log critical errors
    if (error.code === 'ECONNABORTED' || !error.response) {
      console.error('[API Request Error]', error.message);
    }
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    // Silent success responses (removed console spam)
    return response;
  },
  (error) => {
    // Enhanced error handling
    if (error.response) {
      // Server responded with error status
      const { status, data } = error.response;

      // Only log actual errors (not successful responses)
      if (status >= 400) {
        console.error(`[API Error] ${status}:`, data?.detail || data?.message || 'Request failed');
      }

      // Add user-friendly error messages
      switch (status) {
        case 400:
          error.message = 'Invalid request. Please check your input.';
          break;
        case 401:
          error.message = 'Authentication required. Please log in.';
          break;
        case 403:
          error.message = 'You do not have permission to perform this action.';
          break;
        case 404:
          error.message = 'The requested resource was not found.';
          break;
        case 429:
          error.message = 'Too many requests. Please try again later.';
          break;
        case 500:
          error.message = 'Server error. Please try again later.';
          break;
        case 503:
          error.message = 'Service temporarily unavailable. Please try again later.';
          break;
        default:
          error.message = data?.detail || 'An unexpected error occurred.';
      }
    } else if (error.request) {
      // Request made but no response received
      console.error('[API Error] No response received - check connection');
      error.message = 'Unable to reach the server. Please check your connection.';
    } else {
      // Error in request setup
      console.error('[API Error]', error.message);
      error.message = 'Failed to send request. Please try again.';
    }

    return Promise.reject(error);
  }
);

// Portfolios API
export const portfoliosApi = {
  getDefault: () => api.get('/portfolios/default/'),
};

// Positions API
export const positionsApi = {
  getAll: (portfolioId = null) => api.get('/positions/', { params: { portfolio_id: portfolioId } }),
  getOne: (positionId) => api.get(`/positions/${positionId}/`),
  create: (positionData) => api.post('/positions/', positionData),
  update: (positionId, positionData) => api.put(`/positions/${positionId}/`, positionData),
  addShares: (positionId, sharesData) => api.post(`/positions/${positionId}/add-shares/`, sharesData),
  delete: (positionId) => api.delete(`/positions/${positionId}/`),
  importCSV: (file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post('/positions/import-csv/', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
};

// Stocks API
export const stocksApi = {
  getAll: () => api.get('/stocks/'),
  getOne: (symbol) => api.get(`/stocks/${symbol}/`),
  create: (stockData) => api.post('/stocks/', stockData),
  delete: (symbol) => api.delete(`/stocks/${symbol}/`),
  refresh: (symbol) => api.post(`/stocks/${symbol}/refresh/`),
  search: (keywords) => api.get(`/stocks/${keywords}/search/`),
  // Stock actions
  getActions: (symbol) => api.get(`/stocks/${symbol}/actions/`),
  getArticles: (symbol, limit = 10) => api.get(`/stocks/${symbol}/articles/`, { params: { limit } }),
  getInsights: (symbol) => api.post(`/stocks/${symbol}/insights/`),
  askQuestion: (symbol, question) => api.post(`/stocks/${symbol}/ask/`, null, { params: { question } }),
  // Logo management
  uploadLogo: (symbol, file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/stocks/${symbol}/logo/`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
  getLogo: (symbol) => `${API_BASE_URL}/stocks/${symbol}/logo/`,
  deleteLogo: (symbol) => api.delete(`/stocks/${symbol}/logo/`),
};

// News API
export const newsApi = {
  getAll: (params) => api.get('/news/', { params }),
  getOne: (articleId) => api.get(`/news/${articleId}/`),
  refresh: () => api.post('/news/refresh', {}), // Returns immediately with job_id
  refreshStatus: (jobId) => api.get(`/news/refresh/status/${jobId}`), // Poll for job status
  analyzeSentiment: (articleId) => api.post(`/news/${articleId}/analyze-sentiment/`),
};

// Query API
export const queryApi = {
  ask: (question, contextLimit = 5) =>
    api.post('/query/ask/', { question, context_limit: contextLimit }),
  getPortfolioSummary: () => api.get('/query/portfolio-summary/'),
  getStockSentiment: (symbol, days = 7) =>
    api.get(`/query/sentiment-analysis/${symbol}/`, { params: { days } }),
};

// Research API (Serper)
export const researchApi = {
  searchNews: (symbol, companyName = null, daysBack = 7) =>
    api.get(`/research/search/${symbol}`, { params: { company_name: companyName, days_back: daysBack } }),
  searchFilings: (symbol, companyName = null, filingType = null) =>
    api.get(`/research/filings/${symbol}`, { params: { company_name: companyName, filing_type: filingType } }),
  searchAnalysts: (symbol, companyName = null) =>
    api.get(`/research/analysts/${symbol}`, { params: { company_name: companyName } }),
  comprehensiveResearch: (symbol, companyName = null) =>
    api.get(`/research/comprehensive/${symbol}`, { params: { company_name: companyName } }),
  enhancedNews: (symbols, daysBack = 7, includeSec = false, includeAnalyst = false) =>
    api.post('/research/news/', { symbols, days_back: daysBack, include_sec: includeSec, include_analyst: includeAnalyst }),
  healthCheck: () => api.get('/research/health/'),
};

// Roboadvisor API
export const roboadvisorApi = {
  // Portfolio Analysis
  getPortfolioAnalysis: (portfolioId) =>
    api.get(`/roboadvisor/analysis/${portfolioId}`),

  // Risk Analysis
  getStockRisk: (symbol) =>
    api.get(`/roboadvisor/risk/${symbol}`),
  getPortfolioRisk: (portfolioId) =>
    api.get(`/roboadvisor/risk/portfolio/${portfolioId}`),

  // Trading Signals
  getTradingSignal: (symbol) =>
    api.get(`/roboadvisor/signals/${symbol}`),
  getPortfolioRecommendations: (portfolioId, saveRecommendations = false) =>
    api.get(`/roboadvisor/recommendations/${portfolioId}`, { params: { save_recommendations: saveRecommendations } }),

  // Rebalancing
  getRebalancingRecommendations: (portfolioId) =>
    api.get(`/roboadvisor/rebalance/${portfolioId}`),

  // User Profile
  createOrUpdateProfile: (profileData, portfolioId = null) =>
    api.post('/roboadvisor/profile/', profileData, { params: { portfolio_id: portfolioId } }),
  getProfile: (portfolioId) =>
    api.get(`/roboadvisor/profile/${portfolioId}`),

  // Target Allocations
  setTargetAllocations: (allocations, portfolioId = null) =>
    api.post('/roboadvisor/allocations/', { allocations }, { params: { portfolio_id: portfolioId } }),
  getAllocationSummary: (portfolioId) =>
    api.get(`/roboadvisor/allocations/${portfolioId}`),

  // Paper Trading
  createPaperTrade: (tradeData, portfolioId = null) =>
    api.post('/roboadvisor/paper-trade/', tradeData, { params: { portfolio_id: portfolioId } }),
  createPaperTradeFromSignal: (symbol, quantity, portfolioId = null) =>
    api.post('/roboadvisor/paper-trade/from-signal/', { symbol, quantity }, { params: { portfolio_id: portfolioId } }),
  getPaperTrades: (portfolioId, status = null) =>
    api.get(`/roboadvisor/paper-trades/${portfolioId}`, { params: { status } }),
  closePaperTrade: (tradeId, exitPrice = null) =>
    api.put(`/roboadvisor/paper-trade/${tradeId}/close`, null, { params: { exit_price: exitPrice } }),
  getPaperPerformance: (portfolioId) =>
    api.get(`/roboadvisor/paper-performance/${portfolioId}`),

  // Recommendation Status
  updateRecommendationStatus: (recommendationId, status) =>
    api.put(`/roboadvisor/recommendation/${recommendationId}/status`, null, { params: { status } }),
};

// Batch Price API
export const pricesApi = {
  getBatchPrices: (symbols, forceRefresh = false) =>
    api.get('/stocks/prices/batch/', { params: { symbols: symbols.join(','), force_refresh: forceRefresh } }),
  getCacheStats: () =>
    api.get('/stocks/prices/cache/stats/'),
  clearCache: (symbols = null) =>
    api.post('/stocks/prices/cache/clear/', null, { params: { symbols: symbols ? symbols.join(',') : null } }),
};

export default api;
