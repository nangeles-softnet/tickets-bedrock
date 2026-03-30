import React, { useState } from 'react';
import Login from './components/Login';
import SupportDashboard from './components/SupportDashboard';

// === CONFIGURACIÓN GLOBAL (Reemplazar después de aplicar Terraform) ===
export const CONFIG = {
  region: 'us-east-1',
  UserPoolId: 'us-east-1_XXXXXXXXX',
  ClientId: 'XXXXXXXXXXXXXXXXXXXXX',
  ApiUrl: 'https://xxxxxxxxx.execute-api.us-east-1.amazonaws.com/poc/ticket'
};

function App() {
  const [token, setToken] = useState(null);

  const handleLoginSuccess = (jwtToken) => {
    setToken(jwtToken);
  };

  const handleLogout = () => {
    setToken(null);
  };

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', background: 'white', padding: '30px', borderRadius: '8px', boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}>
      <h1 style={{ textAlign: 'center', color: '#333' }}>Portal de Soporte Técnico (PoC IA)</h1>
      <hr style={{ border: 'none', borderTop: '1px solid #eee', marginBottom: '20px' }} />
      
      {!token ? (
        <Login onLoginSuccess={handleLoginSuccess} config={CONFIG} />
      ) : (
        <SupportDashboard token={token} config={CONFIG} onLogout={handleLogout} />
      )}
    </div>
  );
}

export default App;
