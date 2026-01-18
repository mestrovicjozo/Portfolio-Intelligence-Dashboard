import { Routes, Route, useLocation } from 'react-router-dom';
import { AnimatePresence } from 'framer-motion';
import Dashboard from './pages/Dashboard';
import StockDetail from './pages/StockDetail';
import News from './pages/News';
import Chat from './pages/Chat';
import Roboadvisor from './pages/Roboadvisor';
import Navigation from './components/Navigation';
import AnimatedContainer from './components/AnimatedContainer';

function App() {
  const location = useLocation();

  return (
    <div className="app">
      <Navigation />
      <main className="main-content">
        <AnimatePresence mode="wait">
          <Routes location={location} key={location.pathname}>
            <Route
              path="/"
              element={
                <AnimatedContainer animation="pageTransition">
                  <Dashboard />
                </AnimatedContainer>
              }
            />
            <Route
              path="/stock/:symbol"
              element={
                <AnimatedContainer animation="pageTransition">
                  <StockDetail />
                </AnimatedContainer>
              }
            />
            <Route
              path="/news"
              element={
                <AnimatedContainer animation="pageTransition">
                  <News />
                </AnimatedContainer>
              }
            />
            <Route
              path="/chat"
              element={
                <AnimatedContainer animation="pageTransition">
                  <Chat />
                </AnimatedContainer>
              }
            />
            <Route
              path="/roboadvisor"
              element={
                <AnimatedContainer animation="pageTransition">
                  <Roboadvisor />
                </AnimatedContainer>
              }
            />
          </Routes>
        </AnimatePresence>
      </main>
    </div>
  );
}

export default App;
