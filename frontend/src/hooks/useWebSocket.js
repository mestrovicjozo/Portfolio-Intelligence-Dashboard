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

      // Add a small delay before attempting connection to give backend time to start
      setTimeout(() => {
        try {
          ws.current = new WebSocket(url);

          ws.current.onopen = (event) => {
            // Silently connect - no console spam
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
            // Silently handle errors - no console spam
            if (onError) onError(error);
          };

          ws.current.onclose = (event) => {
            // Silently handle disconnect - no console spam
            setIsConnected(false);
            if (onClose) onClose(event);

            // Attempt to reconnect silently
            if (reconnectCount.current < reconnectAttempts) {
              reconnectCount.current += 1;
              reconnectTimeout.current = setTimeout(connect, reconnectInterval);
            }
          };
        } catch (error) {
          // Silently fail - WebSocket is optional
        }
      }, 1000);
    } catch (error) {
      // Silently fail - WebSocket is optional
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
