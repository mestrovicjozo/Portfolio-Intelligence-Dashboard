import { motion } from 'framer-motion';
import * as animations from '../utils/animations';

/**
 * Reusable animated container component
 * Wraps content with motion.div and applies specified animation variant
 */
const AnimatedContainer = ({
  children,
  animation = 'fadeIn',
  className = '',
  delay = 0,
  ...props
}) => {
  // Get the animation variant or use custom animation props
  const animationProps = typeof animation === 'string'
    ? animations[animation]
    : animation;

  // Add delay if specified
  const finalProps = delay > 0
    ? {
        ...animationProps,
        transition: {
          ...animationProps.transition,
          delay
        }
      }
    : animationProps;

  return (
    <motion.div
      className={className}
      {...finalProps}
      {...props}
    >
      {children}
    </motion.div>
  );
};

export default AnimatedContainer;
