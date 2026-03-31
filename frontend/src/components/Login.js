import React, { useState } from 'react';
import { CognitoUserPool, AuthenticationDetails, CognitoUser } from 'amazon-cognito-identity-js';

const Login = ({ onLoginSuccess, onToggleView, config }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = (e) => {
    e.preventDefault();
    setError('');

    if (config.UserPoolId.includes('XXX')) {
      // Modo Mock si no se ha configurado (Para PoC visual antes del despliegue)
      console.warn("ADVERTENCIA: Usando modo MOCK porque la config de Cognito no se ha rellenado.");
      onLoginSuccess("mock_jwt_token_12345");
      return;
    }

    const userPool = new CognitoUserPool({
      UserPoolId: config.UserPoolId,
      ClientId: config.ClientId
    });

    const user = new CognitoUser({ Username: username, Pool: userPool });
    const authDetails = new AuthenticationDetails({ Username: username, Password: password });

    user.authenticateUser(authDetails, {
      onSuccess: (result) => {
        const idToken = result.getIdToken().getJwtToken();
        onLoginSuccess(idToken);
      },
      onFailure: (err) => {
        setError(err.message || JSON.stringify(err));
      }
    });
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <h2>Iniciar Sesión</h2>
      <p style={{ color: '#666', fontSize: '14px' }}>Inicia sesión con tu cuenta de Cognito.</p>
      
      <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '15px', width: '300px' }}>
        <input 
          type="text" 
          placeholder="Correo Electrónico (Usuario)" 
          value={username} onChange={e => setUsername(e.target.value)} 
          style={{ padding: '10px', borderRadius: '4px', border: '1px solid #ccc' }} 
        />
        <input 
          type="password" 
          placeholder="Contraseña" 
          value={password} onChange={e => setPassword(e.target.value)} 
          style={{ padding: '10px', borderRadius: '4px', border: '1px solid #ccc' }} 
        />
        <button type="submit" style={{ padding: '10px', backgroundColor: '#007BFF', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
          Entrar
        </button>
        <button type="button" onClick={onToggleView} style={{ background: 'none', border: 'none', color: '#007BFF', cursor: 'pointer', fontSize: '14px' }}>
          ¿No tienes cuenta? Regístrate aquí
        </button>
      </form>
      {error && <p style={{ color: 'red', marginTop: '15px' }}>{error}</p>}
    </div>
  );
};

export default Login;
