import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { portfoliosApi } from '../services/api';
import { ChevronDown, Plus, Check, Trash2, Edit2 } from 'lucide-react';
import './PortfolioSelector.css';

const PortfolioSelector = () => {
  const queryClient = useQueryClient();
  const [showDropdown, setShowDropdown] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingPortfolio, setEditingPortfolio] = useState(null);
  const [newPortfolioName, setNewPortfolioName] = useState('');
  const [newPortfolioDesc, setNewPortfolioDesc] = useState('');
  const [editPortfolioName, setEditPortfolioName] = useState('');
  const [editPortfolioDesc, setEditPortfolioDesc] = useState('');

  // Fetch all portfolios
  const { data: portfolios = [], isLoading } = useQuery({
    queryKey: ['portfolios'],
    queryFn: async () => {
      const response = await portfoliosApi.getAll();
      return response.data;
    },
  });

  // Fetch active portfolio
  const { data: activePortfolio } = useQuery({
    queryKey: ['active-portfolio'],
    queryFn: async () => {
      const response = await portfoliosApi.getActive();
      return response.data;
    },
  });

  // Activate portfolio mutation
  const activateMutation = useMutation({
    mutationFn: (portfolioId) => portfoliosApi.activate(portfolioId),
    onSuccess: () => {
      queryClient.invalidateQueries(['portfolios']);
      queryClient.invalidateQueries(['active-portfolio']);
      queryClient.invalidateQueries(['positions']);
      setShowDropdown(false);
    },
  });

  // Create portfolio mutation
  const createMutation = useMutation({
    mutationFn: (portfolioData) => portfoliosApi.create(portfolioData),
    onSuccess: () => {
      queryClient.invalidateQueries(['portfolios']);
      setShowCreateModal(false);
      setNewPortfolioName('');
      setNewPortfolioDesc('');
    },
  });

  // Update portfolio mutation
  const updateMutation = useMutation({
    mutationFn: ({ portfolioId, data }) => portfoliosApi.update(portfolioId, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['portfolios']);
      queryClient.invalidateQueries(['active-portfolio']);
      setShowEditModal(false);
      setEditingPortfolio(null);
      setEditPortfolioName('');
      setEditPortfolioDesc('');
    },
  });

  // Delete portfolio mutation
  const deleteMutation = useMutation({
    mutationFn: (portfolioId) => portfoliosApi.delete(portfolioId),
    onSuccess: () => {
      queryClient.invalidateQueries(['portfolios']);
      queryClient.invalidateQueries(['active-portfolio']);
    },
  });

  const handleCreatePortfolio = (e) => {
    e.preventDefault();
    if (newPortfolioName.trim()) {
      createMutation.mutate({
        name: newPortfolioName.trim(),
        description: newPortfolioDesc.trim() || null,
      });
    }
  };

  const handleEditPortfolio = (e) => {
    e.preventDefault();
    if (editingPortfolio && editPortfolioName.trim()) {
      updateMutation.mutate({
        portfolioId: editingPortfolio.id,
        data: {
          name: editPortfolioName.trim(),
          description: editPortfolioDesc.trim() || null,
        },
      });
    }
  };

  const openEditModal = (portfolio) => {
    setEditingPortfolio(portfolio);
    setEditPortfolioName(portfolio.name);
    setEditPortfolioDesc(portfolio.description || '');
    setShowEditModal(true);
    setShowDropdown(false);
  };

  if (isLoading) {
    return <div className="portfolio-selector-loading">Loading portfolios...</div>;
  }

  return (
    <div className="portfolio-selector">
      <button
        className="portfolio-selector-trigger"
        onClick={() => setShowDropdown(!showDropdown)}
      >
        <div className="portfolio-info">
          <span className="portfolio-label">Portfolio:</span>
          <span className="portfolio-name">{activePortfolio?.name || 'Select Portfolio'}</span>
          {activePortfolio && (
            <span className="portfolio-stats">
              {activePortfolio.position_count} positions • ${activePortfolio.total_value.toLocaleString()}
            </span>
          )}
        </div>
        <ChevronDown size={20} />
      </button>

      {showDropdown && (
        <>
          <div className="dropdown-overlay" onClick={() => setShowDropdown(false)} />
          <div className="portfolio-dropdown">
            <div className="portfolio-dropdown-header">
              <h3>Your Portfolios</h3>
              <button
                className="btn-create-portfolio"
                onClick={() => {
                  setShowCreateModal(true);
                  setShowDropdown(false);
                }}
              >
                <Plus size={16} />
                New Portfolio
              </button>
            </div>

            <div className="portfolio-list">
              {portfolios.map((portfolio) => (
                <div
                  key={portfolio.id}
                  className={`portfolio-item ${portfolio.is_active ? 'active' : ''}`}
                >
                  <button
                    className="portfolio-item-content"
                    onClick={() => !portfolio.is_active && activateMutation.mutate(portfolio.id)}
                  >
                    <div className="portfolio-item-info">
                      <div className="portfolio-item-name">
                        {portfolio.name}
                        {portfolio.is_active && <Check size={16} className="check-icon" />}
                      </div>
                      {portfolio.description && (
                        <div className="portfolio-item-desc">{portfolio.description}</div>
                      )}
                    </div>
                  </button>
                  <div className="portfolio-item-actions">
                    <button
                      className="btn-edit-portfolio"
                      onClick={() => openEditModal(portfolio)}
                      title="Rename portfolio"
                    >
                      <Edit2 size={16} />
                    </button>
                    {portfolios.length > 1 && (
                      <button
                        className="btn-delete-portfolio"
                        onClick={() => {
                          if (confirm(`Delete portfolio "${portfolio.name}"?`)) {
                            deleteMutation.mutate(portfolio.id);
                          }
                        }}
                        title="Delete portfolio"
                      >
                        <Trash2 size={16} />
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </>
      )}

      {showCreateModal && (
        <>
          <div className="modal-overlay" onClick={() => setShowCreateModal(false)} />
          <div className="modal">
            <div className="modal-header">
              <h2>Create New Portfolio</h2>
              <button className="modal-close" onClick={() => setShowCreateModal(false)}>
                ×
              </button>
            </div>
            <form onSubmit={handleCreatePortfolio}>
              <div className="form-group">
                <label htmlFor="portfolio-name">Portfolio Name *</label>
                <input
                  id="portfolio-name"
                  type="text"
                  value={newPortfolioName}
                  onChange={(e) => setNewPortfolioName(e.target.value)}
                  placeholder="e.g., Tech Stocks, Dividend Portfolio"
                  required
                  autoFocus
                />
              </div>
              <div className="form-group">
                <label htmlFor="portfolio-desc">Description</label>
                <textarea
                  id="portfolio-desc"
                  value={newPortfolioDesc}
                  onChange={(e) => setNewPortfolioDesc(e.target.value)}
                  placeholder="Optional description"
                  rows={3}
                />
              </div>
              <div className="modal-actions">
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => setShowCreateModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={createMutation.isLoading}>
                  {createMutation.isLoading ? 'Creating...' : 'Create Portfolio'}
                </button>
              </div>
            </form>
          </div>
        </>
      )}

      {showEditModal && (
        <>
          <div className="modal-overlay" onClick={() => setShowEditModal(false)} />
          <div className="modal">
            <div className="modal-header">
              <h2>Rename Portfolio</h2>
              <button className="modal-close" onClick={() => setShowEditModal(false)}>
                ×
              </button>
            </div>
            <form onSubmit={handleEditPortfolio}>
              <div className="form-group">
                <label htmlFor="edit-portfolio-name">Portfolio Name *</label>
                <input
                  id="edit-portfolio-name"
                  type="text"
                  value={editPortfolioName}
                  onChange={(e) => setEditPortfolioName(e.target.value)}
                  placeholder="e.g., Tech Stocks, Dividend Portfolio"
                  required
                  autoFocus
                />
              </div>
              <div className="form-group">
                <label htmlFor="edit-portfolio-desc">Description</label>
                <textarea
                  id="edit-portfolio-desc"
                  value={editPortfolioDesc}
                  onChange={(e) => setEditPortfolioDesc(e.target.value)}
                  placeholder="Optional description"
                  rows={3}
                />
              </div>
              <div className="modal-actions">
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => setShowEditModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={updateMutation.isLoading}>
                  {updateMutation.isLoading ? 'Saving...' : 'Save Changes'}
                </button>
              </div>
            </form>
          </div>
        </>
      )}
    </div>
  );
};

export default PortfolioSelector;
