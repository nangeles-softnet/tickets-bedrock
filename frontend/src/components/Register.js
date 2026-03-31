import React, { useState } from 'react';
import { CognitoUserPool, CognitoUserAttribute, CognitoUser } from 'amazon-cognito-identity-js';

const Register = ({ onToggleView, config }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [code, setCode] = useState('');
  const [stage, setStage] = useState('signup'); // signup | verify
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');

  const userPool = new CognitoUserPool({
    UserPoolId: config.UserPoolId,
    ClientId: config.ClientId
  });

  const handleSignUp = (e) => {
    e.preventDefault();
    setError('');
    
    if (config.UserPoolId.includes('XXX')) {
      setMessage("MODO MOCK: Registro exitoso simulado. Procediendo a verificación...");
      setStage('verify');
      return;
    }

    const attributeList = [
      new CognitoUserAttribute({ Name: 'email', Value: email })
    ];

    userPool.signUp(email, password, attributeList, null, (err, result) => {
      if (err) {
        setError(err.message || JSON.stringify(err));
        return;
      }
      setStage('verify');
      setMessage("¡Registro exitoso! Por favor revisa tu correo para obtener el código de verificación.");
    });
  };

  const handleVerify = (e) => {
    e.preventDefault();
    setError('');

    if (config.UserPoolId.includes('XXX')) {
        setMessage("MODO MOCK: Verificación exitosa. Ya puedes iniciar sesión.");
        setTimeout(() => onToggleView(), 2000);
        return;
    }

    const userData = { Username: email, Pool: userPool };
    const cognitoUser = new CognitoUser(userData);

    cognitoUser.confirmRegistration(code, true, (err, result) => {
      if (err) {
        setError(err.message || JSON.stringify(err));
        return;
      }
      setMessage("¡Cuenta verificada! Redirigiendo al inicio de sesión...");
      setTimeout(() => onToggleView(), 2000);
    });
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <h2>{stage === 'signup' ? 'Crear Cuenta' : 'Verificar Cuenta'}</h2>
      
      {stage === 'signup' ? (
        <form onSubmit={handleSignUp} style={{ display: 'flex', flexDirection: 'column', gap: '15px', width: '300px' }}>
          <input 
            type="email" 
            placeholder="Correo Electrónico" 
            value={email} onChange={e => setEmail(e.target.value)} 
            style={{ padding: '10px', borderRadius: '4px', border: '1px solid #ccc' }} 
            required
          />
          <input 
            type="password" 
            placeholder="Contraseña" 
            value={password} onChange={e => setPassword(e.target.value)} 
            style={{ padding: '10px', borderRadius: '4px', border: '1px solid #ccc' }} 
            required
          />
          <button type="submit" style={{ padding: '10px', backgroundColor: '#28a745', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
            Registrarse
          </button>
          <button type="button" onClick={onToggleView} style={{ background: 'none', border: 'none', color: '#007BFF', cursor: 'pointer', fontSize: '14px' }}>
            ¿Ya tienes cuenta? Iniciar Sesión
          </button>
        </form>
      ) : (
        <form onSubmit={handleVerify} style={{ display: 'flex', flexDirection: 'column', gap: '15px', width: '300px' }}>
          <p style={{ fontSize: '14px', color: '#666', textAlign: 'center' }}>Ingresa el código enviado a <b>{email}</b></p>
          <input 
            type="text" 
            placeholder="Código de 6 dígitos" 
            value={code} onChange={e => setCode(e.target.value)} 
            style={{ padding: '10px', borderRadius: '4px', border: '1px solid #ccc', textAlign: 'center', fontSize: '18px', letterSpacing: '4px' }} 
            required
          />
          <button type="submit" style={{ padding: '10px', backgroundColor: '#FFC107', color: 'black', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
            Confirmar Registro
          </button>
        </form>
      )}

      {message && <p style={{ color: 'green', marginTop: '15px', textAlign: 'center' }}>{message}</p>}
      {error && <p style={{ color: 'red', marginTop: '15px', textAlign: 'center' }}>{error}</p>}
    </div>
  );
};

export default Register;
