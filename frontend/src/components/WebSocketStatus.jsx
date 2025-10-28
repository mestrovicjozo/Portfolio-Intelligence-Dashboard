import { motion, AnimatePresence } from 'framer-motion';
import { Wifi, WifiOff, AlertCircle } from 'lucide-react';
import './WebSocketStatus.css';

/**
 * WebSocket connection status indicator
 * Shows a subtle indicator when WebSocket is disconnected
 */
const WebSocketStatus = ({ isConnected, showAlways = false }) => {
  // Only show when disconnected, or if showAlways is true
  const shouldShow = showAlways || !isConnected;

  if (!shouldShow) return null;

  return (
    <AnimatePresence>
      <motion.div
        className={`websocket-status ${isConnected ? 'connected' : 'disconnected'}`}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 20 }}
        transition={{ duration: 0.3 }}
      >
        <div className="websocket-status-content">
          {isConnected ? (
            <>
              <Wifi size={16} />
              <span>Live updates active</span>
            </>
          ) : (
            <>
              <WifiOff size={16} />
              <span>Live updates unavailable</span>
              <AlertCircle size={14} className="websocket-warning-icon" />
            </>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  );
};

export default WebSocketStatus;
