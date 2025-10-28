import { useEffect } from 'react';
import { useWebSocket } from '../hooks/useWebSocket';
import { useToast } from './Toast/ToastProvider';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';
const WS_URL = API_BASE_URL.replace('http', 'ws') + '/ws/updates';

/**
 * Component that handles WebSocket notifications
 * Listens for background job updates and displays toast notifications
 */
const NotificationHandler = () => {
  const toast = useToast();

  const handleMessage = (data) => {
    if (data.type === 'job_update') {
      handleJobUpdate(data);
    }
  };

  const handleJobUpdate = (data) => {
    const { status, job_type, stock_symbol, result, error } = data;

    switch (status) {
      case 'completed':
        if (job_type === 'price_news_fetch') {
          const pricesAdded = result?.prices_added || 0;
          const newsAdded = result?.news_added || 0;

          toast.success(
            `${stock_symbol} Data Updated`,
            `Added ${pricesAdded} price records and ${newsAdded} news articles`,
            6000
          );
        }
        break;

      case 'failed':
        if (job_type === 'price_news_fetch') {
          toast.error(
            `${stock_symbol} Update Failed`,
            error || 'Failed to fetch data',
            8000
          );
        }
        break;

      case 'running':
        // Optionally show info toast for long-running jobs
        if (job_type === 'price_news_fetch') {
          toast.info(
            `Fetching ${stock_symbol} Data`,
            'This may take a few moments...',
            3000
          );
        }
        break;

      default:
        break;
    }
  };

  const { isConnected } = useWebSocket(WS_URL, {
    onMessage: handleMessage,
    // Silent - WebSocket reconnects automatically
  });

  // This component doesn't render anything
  return null;
};

export default NotificationHandler;
