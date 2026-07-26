import { useEffect, useState } from 'react';

export function LoginStatus() {
  const [user, setUser] = useState<{ email?: string } | null>(null);

  useEffect(() => {
    fetch('/auth/me')
      .then(res => res.json())
      .then(data => {
        if (data.ready && data.user) {
          setUser({ email: data.user });
        }
      })
      .catch(console.error);
  }, []);

  if (user) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', background: 'var(--surface-color, #f3f4f6)', padding: '6px 12px', borderRadius: '16px' }}>
        <span>{user.email}</span>
        <a href="/auth/logout" style={{ textDecoration: 'none', color: 'var(--primary-color, #2563eb)', fontWeight: '600' }}>Logout</a>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', background: 'var(--surface-color, #f3f4f6)', padding: '6px 12px', borderRadius: '16px' }}>
      <a href="/auth/google" style={{ textDecoration: 'none', color: 'var(--primary-color, #2563eb)', fontWeight: '600' }}>
        Login with Google
      </a>
    </div>
  );
}
