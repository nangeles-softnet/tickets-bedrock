import React, { useState } from 'react';

const SupportDashboard = ({ token, config, onLogout }) => {
  const [query, setQuery] = useState('');
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!query.trim()) return;

    const userQuery = query;
    setMessages(prev => [...prev, { role: 'user', text: userQuery }]);
    setQuery('');
    setLoading(true);

    if (config.ApiUrl.includes('xxx')) {
       setTimeout(() => {
          setMessages(prev => [...prev, { role: 'assistant', text: "[MOCK] Recuerda reemplazar config.ApiUrl en App.js con la URL de API Gateway." }]);
          setLoading(false);
       }, 1000);
       return;
    }

    try {
      const response = await fetch(config.ApiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: JSON.stringify({ query: userQuery })
      });

      const data = await response.json();
      
      if (response.ok) {
        setMessages(prev => [...prev, { 
            role: 'assistant', 
            text: data.response,
            ticket_id: data.ticket_id 
        }]);
      } else {
        setMessages(prev => [...prev, { role: 'assistant', text: `Error: ${data.error || 'Fallo desconocido'}` }]);
      }
    } catch (err) {
      setMessages(prev => [...prev, { role: 'assistant', text: `Error de red: ${err.message}` }]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h3>Asistente Resolutivo (Bedrock)</h3>
        <button onClick={onLogout} style={{ padding: '6px 12px', background: '#dc3545', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>Cerrar Sesión</button>
      </div>

      <div style={{ height: '300px', overflowY: 'auto', border: '1px solid #ddd', padding: '15px', borderRadius: '4px', marginBottom: '15px', background: '#fafafa' }}>
        {messages.length === 0 && <p style={{ color: '#888', textAlign: 'center', marginTop: '100px' }}>Describe tu problema para que el Agente IA Bedrock te ayude...</p>}
        {messages.map((msg, idx) => (
          <div key={idx} style={{ marginBottom: '15px', textAlign: msg.role === 'user' ? 'right' : 'left' }}>
            <span style={{ 
              display: 'inline-block', 
              padding: '10px 14px', 
              borderRadius: '18px',
              backgroundColor: msg.role === 'user' ? '#007BFF' : '#E9ECEF',
              color: msg.role === 'user' ? 'white' : 'black',
              maxWidth: '80%'
            }}>
              {msg.text}
            </span>
            {msg.ticket_id && <div style={{ fontSize: '11px', color: '#999', marginTop: '4px' }}>Ticket registrado: {msg.ticket_id}</div>}
          </div>
        ))}
        {loading && <div style={{ textAlign: 'left', color: '#666' }}>El agente está pensando...</div>}
      </div>

      <form onSubmit={handleSubmit} style={{ display: 'flex', gap: '10px' }}>
        <input 
          type="text" 
          value={query} 
          onChange={(e) => setQuery(e.target.value)} 
          placeholder="Ej: Tengo un error 500 al intentar acceder al servicio base..."
          style={{ flex: 1, padding: '12px', borderRadius: '4px', border: '1px solid #ccc' }}
          disabled={loading}
        />
        <button type="submit" disabled={loading} style={{ padding: '12px 20px', background: '#28a745', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
          Enviar
        </button>
      </form>
    </div>
  );
};

export default SupportDashboard;
