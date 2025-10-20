import { motion } from 'framer-motion';
import './LoadingSpinner.css';

/**
 * Animated loading spinner component
 */
const LoadingSpinner = ({ size = 'medium', text = '' }) => {
  const sizeClasses = {
    small: 'spinner-small',
    medium: 'spinner-medium',
    large: 'spinner-large'
  };

  return (
    <div className="loading-container">
      <motion.div
        className={`spinner ${sizeClasses[size]}`}
        animate={{ rotate: 360 }}
        transition={{
          duration: 1,
          ease: 'linear',
          repeat: Infinity
        }}
      >
        <div className="spinner-inner"></div>
      </motion.div>
      {text && <p className="loading-text">{text}</p>}
    </div>
  );
};

export default LoadingSpinner;
