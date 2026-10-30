import React, { useState } from 'react';
import { 
  Lock, Mail, Eye, EyeOff, ShieldCheck, 
  Server, ArrowRight, AlertCircle, CheckCircle2, UserCheck,
  KeyRound, X, Send
} from 'lucide-react';
import mysectLogo from '../assets/mysect_logo.png';

const DEMO_ACCOUNTS = [
  {
    role: 'Super Admin',
    name: 'Ahmad Faizal',
    email: 'admin@mysect.com.my',
    password: 'admin',
    department: 'HQ Platform Operations',
    color: 'bg-blue-50 text-[#062AAE] border-blue-200 hover:bg-blue-100',
    avatar: 'AF'
  },
  {
    role: 'Compliance Lead',
    name: 'Nurul Huda',
    email: 'compliance@mysect.com.my',
    password: 'admin',
    department: 'SSM Regulatory & Audit',
    color: 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100',
    avatar: 'NH'
  },
  {
    role: 'Operations Lead',
    name: 'Kevin Tan',
    email: 'ops@mysect.com.my',
    password: 'admin',
    department: 'Network Services & Support',
    color: 'bg-purple-50 text-purple-700 border-purple-200 hover:bg-purple-100',
    avatar: 'KT'
  }
];

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Forgot Key / Password Recovery Modal States
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSubmitted, setForgotSubmitted] = useState(false);
  const [forgotError, setForgotError] = useState('');

  const handleForgotSubmit = (e) => {
    e.preventDefault();
    setForgotError('');

    if (!forgotEmail.trim() || !forgotEmail.includes('@')) {
      setForgotError('Please enter a valid work email address.');
      return;
    }

    setForgotLoading(true);
    setTimeout(() => {
      setForgotLoading(false);
      setForgotSubmitted(true);
    }, 600);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    if (!email.trim() || !password.trim()) {
      setError('Please enter both your work email and password.');
      return;
    }

    setIsLoading(true);

    // Simulate network authentication
    setTimeout(() => {
      // Find demo account or allow valid admin email
      const matched = DEMO_ACCOUNTS.find(
        acc => acc.email.toLowerCase() === email.trim().toLowerCase()
      );

      if (matched) {
        if (matched.password === password) {
          onLogin({
            name: matched.name,
            email: matched.email,
            role: matched.role,
            department: matched.department,
            avatar: matched.avatar,
            token: 'tok_' + Math.random().toString(36).substring(2),
            loginTime: new Date().toISOString()
          }, rememberMe);
        } else {
          setError('Invalid password. For demo accounts, use "admin".');
          setIsLoading(false);
        }
      } else if (email.includes('@')) {
        // Allow custom email login with default admin privileges
        onLogin({
          name: email.split('@')[0].replace('.', ' ').toUpperCase(),
          email: email.trim(),
          role: 'Platform Operator',
          department: 'Executive Administration',
          avatar: email.substring(0, 2).toUpperCase(),
          token: 'tok_' + Math.random().toString(36).substring(2),
          loginTime: new Date().toISOString()
        }, rememberMe);
      } else {
        setError('Please enter a valid official work email address.');
        setIsLoading(false);
      }
    }, 450);
  };

  const handleQuickLogin = (acc) => {
    setEmail(acc.email);
    setPassword(acc.password);
    setError('');
  };

  return (
    <div className="min-h-screen w-full flex flex-col justify-between bg-[#F4F6F9] text-gray-900 select-none relative overflow-hidden">
      {/* Background Decorative Accents */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[360px] bg-gradient-to-b from-blue-100/60 to-transparent rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -top-32 -left-32 w-96 h-96 bg-blue-600/5 rounded-full blur-2xl pointer-events-none" />
      <div className="absolute -bottom-32 -right-32 w-96 h-96 bg-indigo-600/5 rounded-full blur-2xl pointer-events-none" />

      {/* Top Bar with Status */}
      <header className="relative z-10 w-full max-w-6xl mx-auto px-6 pt-6 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-xs font-semibold text-gray-600 tracking-wide">
            SSM Platform Gateway: <strong className="text-gray-900">Online</strong>
          </span>
        </div>
        <div className="flex items-center gap-2 text-xs text-gray-500 bg-white/80 backdrop-blur-xs px-3 py-1.5 rounded-full border border-gray-200 shadow-2xs">
          <Server className="w-3.5 h-3.5 text-[#062AAE]" />
          <span>Secure Cloud • Hosted in Malaysia</span>
        </div>
      </header>

      {/* Main Login Card */}
      <main className="relative z-10 flex-1 flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-8 sm:p-10 transition-all">
          
          {/* Logo and Header */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center mb-3">
              <img 
                src={mysectLogo} 
                alt="MySect - Your Secretary Company" 
                className="h-10 w-auto object-contain" 
              />
            </div>
            <div className="inline-block px-2.5 py-0.5 rounded-md bg-blue-50 text-[#062AAE] text-[11px] font-bold uppercase tracking-wider mb-2">
              Super-Admin Platform Portal
            </div>
            <h1 className="text-xl font-bold text-gray-900">
              Sign in to Operator Console
            </h1>
            <p className="text-xs text-gray-500 mt-1">
              Authorized personnel only. Sessions are audited per statutory governance policies.
            </p>
          </div>

          {/* Error Banner */}
          {error && (
            <div className="mb-6 p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                Work Email Address
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@mysect.com.my"
                  required
                  autoFocus
                  className="w-full pl-10 pr-4 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider">
                  Password
                </label>
                <button
                  type="button"
                  onClick={() => {
                    setForgotEmail(email || 'admin@mysect.com.my');
                    setForgotSubmitted(false);
                    setForgotError('');
                    setShowForgotModal(true);
                  }}
                  className="text-[11px] text-[#062AAE] hover:underline cursor-pointer font-medium"
                >
                  Forgot key?
                </button>
              </div>
              <div className="relative">
                <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  required
                  className="w-full pl-10 pr-10 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-4 h-4 text-[#062AAE] rounded border-gray-300 focus:ring-[#062AAE]"
                />
                <span className="text-xs text-gray-600">Keep me signed in</span>
              </label>
              <div className="flex items-center gap-1 text-[11px] text-gray-500">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                <span>MFA Enforced</span>
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 py-3 px-4 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-sm font-semibold flex items-center justify-center gap-2 transition-all shadow-md hover:shadow-lg disabled:opacity-70 disabled:cursor-not-allowed cursor-pointer"
            >
              {isLoading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  <span>Authenticating...</span>
                </>
              ) : (
                <>
                  <span>Sign In to Console</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          {/* Quick Demo Login Preset Buttons */}
          <div className="mt-8 pt-6 border-t border-gray-100">
            <p className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider mb-2.5 text-center">
              Quick Authorization Presets
            </p>
            <div className="grid grid-cols-1 gap-2">
              {DEMO_ACCOUNTS.map((acc) => (
                <button
                  key={acc.email}
                  type="button"
                  onClick={() => handleQuickLogin(acc)}
                  className={`flex items-center justify-between px-3.5 py-2 rounded-xl text-xs font-medium border transition-all cursor-pointer ${acc.color}`}
                >
                  <div className="flex items-center gap-2">
                    <UserCheck className="w-3.5 h-3.5" />
                    <span>{acc.name}</span>
                    <span className="text-[10px] opacity-75 font-normal">({acc.role})</span>
                  </div>
                  <span className="text-[10px] uppercase font-bold tracking-wider">Use</span>
                </button>
              ))}
            </div>
          </div>

        </div>
      </main>

      {/* Footer Compliance Badge */}
      <footer className="relative z-10 w-full max-w-6xl mx-auto px-6 py-6 text-center text-xs text-gray-500 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-gray-200/60">
        <div className="flex items-center gap-2 text-gray-600">
          <ShieldCheck className="w-4 h-4 text-[#062AAE]" />
          <span>MySect Corporate Secretarial Platform • SSM Companies Act 2016 Compliant</span>
        </div>
        <div className="flex items-center gap-4 text-[11px] text-gray-400">
          <span>PDPA 2010 Registered</span>
          <span>•</span>
          <span>AES-256 Encryption</span>
          <span>•</span>
          <span>Audit Logged</span>
        </div>
      </footer>
      {/* Forgot Key / Password Recovery Modal */}
      {showForgotModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-2xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-gray-100 relative animate-in fade-in zoom-in-95 duration-150">
            {/* Close Button */}
            <button
              type="button"
              onClick={() => setShowForgotModal(false)}
              className="absolute right-4 top-4 p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>

            {!forgotSubmitted ? (
              <>
                <div className="w-10 h-10 rounded-full bg-blue-50 text-[#062AAE] flex items-center justify-center mb-4">
                  <KeyRound className="w-5 h-5" />
                </div>
                <h3 className="text-lg font-bold text-gray-900">
                  Reset Operator Access Key
                </h3>
                <p className="text-xs text-gray-500 mt-1 leading-relaxed">
                  Enter your registered work email address. We will dispatch an authorized cryptographic reset token and recovery link.
                </p>

                {forgotError && (
                  <div className="mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-center gap-2">
                    <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
                    <span>{forgotError}</span>
                  </div>
                )}

                <form onSubmit={handleForgotSubmit} className="mt-5 space-y-4">
                  <div>
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                      Operator Work Email
                    </label>
                    <div className="relative">
                      <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                      <input
                        type="email"
                        value={forgotEmail}
                        onChange={(e) => setForgotEmail(e.target.value)}
                        placeholder="name@mysect.com.my"
                        required
                        autoFocus
                        className="w-full pl-10 pr-4 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
                      />
                    </div>
                  </div>

                  <div className="p-3 rounded-xl bg-blue-50/60 border border-blue-100 text-[11px] text-gray-600 space-y-1">
                    <p className="font-semibold text-[#062AAE] flex items-center gap-1.5">
                      <ShieldCheck className="w-3.5 h-3.5" />
                      Local Testing & Demo Note
                    </p>
                    <p>
                      All demo accounts use the standard key: <code className="px-1.5 py-0.5 bg-white font-mono text-[#062AAE] font-bold rounded border border-blue-200">admin</code>. You can also click any of the 1-click presets on the sign-in screen.
                    </p>
                  </div>

                  <div className="flex items-center gap-2.5 pt-2">
                    <button
                      type="button"
                      onClick={() => setShowForgotModal(false)}
                      className="flex-1 py-2.5 px-3 border border-gray-200 rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-50 cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      disabled={forgotLoading}
                      className="flex-1 py-2.5 px-3 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-xs font-semibold flex items-center justify-center gap-2 shadow-xs cursor-pointer disabled:opacity-70"
                    >
                      {forgotLoading ? (
                        <>
                          <div className="w-3.5 h-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                          <span>Sending...</span>
                        </>
                      ) : (
                        <>
                          <Send className="w-3.5 h-3.5" />
                          <span>Send Reset Link</span>
                        </>
                      )}
                    </button>
                  </div>
                </form>
              </>
            ) : (
              <div className="text-center py-2">
                <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-4">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-gray-900">
                  Instructions Dispatched
                </h3>
                <p className="text-xs text-gray-600 mt-2 leading-relaxed">
                  We have dispatched security reset instructions to:
                </p>
                <div className="mt-2 py-1.5 px-3 rounded-lg bg-gray-50 border border-gray-200 text-xs font-semibold text-gray-900 inline-block">
                  {forgotEmail}
                </div>
                <p className="text-[11px] text-gray-500 mt-3 leading-relaxed">
                  Please check your inbox. For this testing environment, your access key remains: <strong className="text-gray-900">admin</strong>.
                </p>

                <button
                  type="button"
                  onClick={() => setShowForgotModal(false)}
                  className="w-full mt-6 py-2.5 px-4 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-xs font-semibold transition-all shadow-xs cursor-pointer"
                >
                  Return to Sign In
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default Login;
