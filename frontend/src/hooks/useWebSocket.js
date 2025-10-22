import { useEffect, useRef, useCallback, useState } from 'react';

/**
 * Custom hook for managing WebSocket connections
 * Handles reconnection logic and message broadcasting
 */
export const useWebSocket = (url, options = {}) => {
  const {
    onMessage,
    onOpen,
    onClose,
    onError,
    reconnectInterval = 10000, // Increased to 10 seconds to reduce spam
    reconnectAttempts = 2, // Reduced to 2 attempts to avoid console spam
  } = options;

  const ws = useRef(null);
  const reconnectCount = useRef(0);
  const reconnectTimeout = useRef(null);
  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState(null);

  const connect = useCallback(() => {
    try {
      // Close existing connection if any
      if (ws.current) {
        ws.current.close();
      }

      ws.current = new WebSocket(url);

      ws.current.onopen = (event) => {
        console.log('WebSocket connected');
        setIsConnected(true);
        reconnectCount.current = 0;
        if (onOpen) onOpen(event);
      };

      ws.current.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          setLastMessage(data);
          if (onMessage) onMessage(data);
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };

      ws.current.onerror = (error) => {
        // Only log on first error to reduce console spam
        if (reconnectCount.current === 0) {
          console.warn('WebSocket connection failed (will retry silently)');
        }
        if (onError) onError(error);
      };

      ws.current.onclose = (event) => {
        // Only log disconnect on first attempt
        if (reconnectCount.current === 0) {
          console.log('WebSocket disconnected');
        }
        setIsConnected(false);
        if (onClose) onClose(event);

        // Attempt to reconnect
        if (reconnectCount.current < reconnectAttempts) {
          reconnectCount.current += 1;
          // Only log first reconnection attempt
          if (reconnectCount.current === 1) {
            console.log('WebSocket: Will retry connection...');
          }
          reconnectTimeout.current = setTimeout(connect, reconnectInterval);
        }
      };
    } catch (error) {
      console.error('Error creating WebSocket connection:', error);
    }
  }, [url, onMessage, onOpen, onClose, onError, reconnectInterval, reconnectAttempts]);

  const disconnect = useCallback(() => {
    if (reconnectTimeout.current) {
      clearTimeout(reconnectTimeout.current);
    }
    if (ws.current) {
      ws.current.close();
      ws.current = null;
    }
    setIsConnected(false);
  }, []);

  const sendMessage = useCallback((data) => {
    if (ws.current && ws.current.readyState === WebSocket.OPEN) {
      ws.current.send(typeof data === 'string' ? data : JSON.stringify(data));
    } else {
      console.warn('WebSocket is not connected');
    }
  }, []);

  useEffect(() => {
    connect();

    return () => {
      disconnect();
    };
  }, [connect, disconnect]);

  return {
    isConnected,
    lastMessage,
    sendMessage,
    disconnect,
    reconnect: connect,
  };
};
