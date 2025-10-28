import { useState, useEffect } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Send, Bot, User, Sparkles, AlertCircle } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import { queryApi } from '../services/api';
import { useToast } from '../components/Toast/ToastProvider';
import './Chat.css';

function Chat() {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: 'Hello! I\'m your AI portfolio assistant. Ask me anything about your stocks, recent news, or market sentiment.',
    },
  ]);
  const [input, setInput] = useState('');
  const [loadingProgress, setLoadingProgress] = useState(0);
  const [loadingText, setLoadingText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const toast = useToast();

  const askMutation = useMutation({
    mutationFn: (question) => {
      setIsLoading(true);
      return queryApi.ask(question);
    },
    onSuccess: (response, question) => {
      setLoadingProgress(100);
      setIsLoading(false);
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
      setLoadingProgress(0);
      setIsLoading(false);

      const errorMessage = error.response?.data?.detail || error.message || 'An unexpected error occurred';

      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          content: `Sorry, I encountered an error: ${errorMessage}`,
          isError: true,
        },
      ]);

      toast.error(
        'AI Assistant Error',
        errorMessage,
        5000
      );
    },
  });

  // Simulate loading progress for better UX
  useEffect(() => {
    let interval;
    if (isLoading) {
      setLoadingProgress(0);
      const loadingSteps = [
        { progress: 20, text: 'Searching through your portfolio news...' },
        { progress: 40, text: 'Finding relevant information...' },
        { progress: 60, text: 'Analyzing sentiment and context...' },
        { progress: 80, text: 'Generating AI response...' },
        { progress: 95, text: 'Almost done...' },
      ];

      let stepIndex = 0;
      setLoadingText(loadingSteps[0].text);

      interval = setInterval(() => {
        if (stepIndex < loadingSteps.length) {
          setLoadingProgress(loadingSteps[stepIndex].progress);
          setLoadingText(loadingSteps[stepIndex].text);
          stepIndex++;
        }
      }, 800);
    } else {
      setLoadingProgress(0);
      setLoadingText('');
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isLoading]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (input.trim() && !askMutation.isPending) {
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
              <div key={index} className={`message ${message.role} ${message.isError ? 'error' : ''}`}>
                <div className="message-icon">
                  {message.role === 'user' ? (
                    <User size={20} />
                  ) : message.isError ? (
                    <AlertCircle size={20} />
                  ) : (
                    <Bot size={20} />
                  )}
                </div>
                <div className="message-content">
                  {message.role === 'assistant' ? (
                    <ReactMarkdown>{message.content}</ReactMarkdown>
                  ) : (
                    <p>{message.content}</p>
                  )}
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
            {isLoading && (
              <div className="message assistant loading-message">
                <div className="message-icon">
                  <Sparkles size={20} className="sparkle-animate" />
                </div>
                <div className="message-content">
                  <div className="ai-loading-container">
                    <p className="loading-text">{loadingText}</p>
                    <div className="progress-bar-container">
                      <div
                        className="progress-bar"
                        style={{ width: `${loadingProgress}%` }}
                      ></div>
                    </div>
                    <div className="loading-stats">
                      <span>{loadingProgress}% complete</span>
                    </div>
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
              disabled={askMutation.isPending}
            />
            <button
              type="submit"
              className="btn btn-primary"
              disabled={!input.trim() || askMutation.isPending}
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
