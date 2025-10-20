/**
 * Currency formatting utilities
 */

/**
 * Format a number as EUR currency
 * @param {number} value - The value to format
 * @param {object} options - Formatting options
 * @returns {string} Formatted currency string
 */
export const formatEUR = (value, options = {}) => {
  const {
    minimumFractionDigits = 2,
    maximumFractionDigits = 2,
    showSymbol = true
  } = options;

  if (value === null || value === undefined || isNaN(value)) {
    return showSymbol ? '€0.00' : '0.00';
  }

  const formatted = new Intl.NumberFormat('de-DE', {
    style: showSymbol ? 'currency' : 'decimal',
    currency: 'EUR',
    minimumFractionDigits,
    maximumFractionDigits,
  }).format(value);

  return formatted;
};

/**
 * Format a number as USD currency (for backwards compatibility)
 * @param {number} value - The value to format
 * @param {object} options - Formatting options
 * @returns {string} Formatted currency string
 */
export const formatUSD = (value, options = {}) => {
  const {
    minimumFractionDigits = 2,
    maximumFractionDigits = 2,
  } = options;

  if (value === null || value === undefined || isNaN(value)) {
    return '$0.00';
  }

  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits,
    maximumFractionDigits,
  }).format(value);
};

/**
 * Format currency based on user preference or default
 * @param {number} value - The value to format
 * @param {string} currency - Currency code (EUR, USD)
 * @param {object} options - Formatting options
 * @returns {string} Formatted currency string
 */
export const formatCurrency = (value, currency = 'EUR', options = {}) => {
  if (currency === 'USD') {
    return formatUSD(value, options);
  }
  return formatEUR(value, options);
};

/**
 * Format a percentage value
 * @param {number} value - The percentage value
 * @param {object} options - Formatting options
 * @returns {string} Formatted percentage string
 */
export const formatPercent = (value, options = {}) => {
  const {
    minimumFractionDigits = 2,
    maximumFractionDigits = 2,
    includeSign = false
  } = options;

  if (value === null || value === undefined || isNaN(value)) {
    return '0.00%';
  }

  const sign = includeSign && value >= 0 ? '+' : '';
  return `${sign}${value.toFixed(maximumFractionDigits)}%`;
};

/**
 * Format a compact number (e.g., 1.5K, 2.3M)
 * @param {number} value - The value to format
 * @param {string} currency - Currency code (EUR, USD)
 * @returns {string} Formatted compact string
 */
export const formatCompact = (value, currency = 'EUR') => {
  if (value === null || value === undefined || isNaN(value)) {
    return currency === 'EUR' ? '€0' : '$0';
  }

  const symbol = currency === 'EUR' ? '€' : '$';

  if (Math.abs(value) >= 1000000) {
    return `${symbol}${(value / 1000000).toFixed(1)}M`;
  }
  if (Math.abs(value) >= 1000) {
    return `${symbol}${(value / 1000).toFixed(1)}K`;
  }
  return `${symbol}${value.toFixed(0)}`;
};
