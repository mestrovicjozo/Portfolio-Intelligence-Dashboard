import React, { createContext, useContext, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle, XCircle, AlertCircle, Info, X } from 'lucide-react';
import './Toast.css';

const ToastContext = createContext(null);

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
};

const TOAST_TYPES = {
  success: {
    icon: CheckCircle,
    className: 'toast-success',
  },
  error: {
    icon: XCircle,
    className: 'toast-error',
  },
  warning: {
    icon: AlertCircle,
    className: 'toast-warning',
  },
  info: {
    icon: Info,
    className: 'toast-info',
  },
};

const Toast = React.forwardRef(({ id, type, title, message, onClose }, ref) => {
  const { icon: Icon, className } = TOAST_TYPES[type] || TOAST_TYPES.info;

  return (
    <motion.div
      ref={ref}
      layout
      initial={{ opacity: 0, y: -50, scale: 0.3 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, x: 100, scale: 0.5 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
      className={`toast ${className}`}
    >
      <div className="toast-icon">
        <Icon size={24} />
      </div>
      <div className="toast-content">
        {title && <div className="toast-title">{title}</div>}
        {message && <div className="toast-message">{message}</div>}
      </div>
      <button className="toast-close" onClick={() => onClose(id)}>
        <X size={18} />
      </button>
    </motion.div>
  );
});

export const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState([]);

  const addToast = useCallback(({ type = 'info', title, message, duration = 5000 }) => {
    const id = Date.now() + Math.random();

    setToasts((prev) => [...prev, { id, type, title, message }]);

    if (duration > 0) {
      setTimeout(() => {
        removeToast(id);
      }, duration);
    }

    return id;
  }, []);

  const removeToast = useCallback((id) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const success = useCallback(
    (title, message, duration) => addToast({ type: 'success', title, message, duration }),
    [addToast]
  );

  const error = useCallback(
    (title, message, duration) => addToast({ type: 'error', title, message, duration }),
    [addToast]
  );

  const warning = useCallback(
    (title, message, duration) => addToast({ type: 'warning', title, message, duration }),
    [addToast]
  );

  const info = useCallback(
    (title, message, duration) => addToast({ type: 'info', title, message, duration }),
    [addToast]
  );

  return (
    <ToastContext.Provider value={{ success, error, warning, info, addToast, removeToast }}>
      {children}
      <div className="toast-container">
        <AnimatePresence mode="popLayout">
          {toasts.map((toast) => (
            <Toast key={toast.id} {...toast} onClose={removeToast} />
          ))}
        </AnimatePresence>
      </div>
    </ToastContext.Provider>
  );
};
