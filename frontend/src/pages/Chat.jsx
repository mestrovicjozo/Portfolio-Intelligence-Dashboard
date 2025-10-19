import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Send, Bot, User } from 'lucide-react';
import { queryApi } from '../services/api';
import './Chat.css';

function Chat() {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: 'Hello! I\'m your AI portfolio assistant. Ask me anything about your stocks, recent news, or market sentiment.',
    },
  ]);
  const [input, setInput] = useState('');

  const askMutation = useMutation({
    mutationFn: (question) => queryApi.ask(question),
    onSuccess: (response, question) => {
      setMessages((prev) => [
        ...prev,
        { role: 'user', content: question },
        {
          role: 'assistant',
          content: response.data.answer,
          sources: response.data.sources,
        },
      ]);
      setInput('');
    },
    onError: (error) => {
      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          content: `Sorry, I encountered an error: ${error.message}`,
        },
      ]);
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    if (input.trim() && !askMutation.isLoading) {
      askMutation.mutate(input);
    }
  };

  const exampleQuestions = [
    'Why are my stocks moving today?',
    'What\'s the sentiment around my tech stocks?',
    'Summarize the latest news for my portfolio',
    'Which stocks have positive sentiment?',
  ];

  const handleExampleClick = (question) => {
    setInput(question);
  };

  return (
    <div className="chat-page">
      <div className="container">
        <div className="chat-header">
          <h1>Ask AI Assistant</h1>
        </div>

        <div className="chat-container card">
          <div className="messages">
            {messages.map((message, index) => (
              <div key={index} className={`message ${message.role}`}>
                <div className="message-icon">
                  {message.role === 'user' ? <User size={20} /> : <Bot size={20} />}
                </div>
                <div className="message-content">
                  <p>{message.content}</p>
                  {message.sources && message.sources.length > 0 && (
                    <div className="sources">
                      <p className="sources-label">Sources:</p>
                      <ul>
                        {message.sources.map((source, idx) => (
                          <li key={idx}>
                            <a href={source.url} target="_blank" rel="noopener noreferrer">
                              {source.title}
                            </a>
                            {source.stocks && source.stocks.length > 0 && (
                              <span className="source-stocks">
                                {source.stocks.join(', ')}
                              </span>
                            )}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              </div>
            ))}
            {askMutation.isLoading && (
              <div className="message assistant">
                <div className="message-icon">
                  <Bot size={20} />
                </div>
                <div className="message-content">
                  <div className="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                </div>
              </div>
            )}
          </div>

          {messages.length === 1 && (
            <div className="example-questions">
              <p className="text-secondary">Try asking:</p>
              <div className="example-grid">
                {exampleQuestions.map((question, index) => (
                  <button
                    key={index}
                    className="example-btn"
                    onClick={() => handleExampleClick(question)}
                  >
                    {question}
                  </button>
                ))}
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="chat-input-form">
            <input
              type="text"
              className="input chat-input"
              placeholder="Ask a question about your portfolio..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={askMutation.isLoading}
            />
            <button
              type="submit"
              className="btn btn-primary"
              disabled={!input.trim() || askMutation.isLoading}
            >
              <Send size={20} />
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default Chat;
