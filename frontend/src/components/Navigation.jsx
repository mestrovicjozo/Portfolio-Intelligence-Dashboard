import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Newspaper, MessageSquare, TrendingUp, Bot } from 'lucide-react';
import './Navigation.css';

function Navigation() {
  const location = useLocation();

  const navItems = [
    { path: '/', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/news', label: 'News', icon: Newspaper },
    { path: '/roboadvisor', label: 'Roboadvisor', icon: Bot },
    { path: '/chat', label: 'Ask AI', icon: MessageSquare },
  ];

  return (
    <nav className="navigation">
      <div className="nav-container">
        <div className="nav-brand">
          <TrendingUp size={28} />
          <span>Portfolio Intelligence</span>
        </div>
        <ul className="nav-links">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <li key={item.path}>
                <Link
                  to={item.path}
                  className={`nav-link ${isActive ? 'active' : ''}`}
                >
                  <Icon size={20} />
                  <span>{item.label}</span>
                </Link>
              </li>
            );
          })}
        </ul>
      </div>
    </nav>
  );
}

export default Navigation;
