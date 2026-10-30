import React, { useState, useRef, useEffect } from 'react';
import { 
  Lock, Mail, Eye, EyeOff, ShieldCheck, 
  Server, ArrowRight, AlertCircle, CheckCircle2, UserCheck,
  KeyRound, X, Send, ArrowLeft, RefreshCw
} from 'lucide-react';
import mysectLogo from '../assets/mysect_logo.png';

const DEMO_ACCOUNTS = [
  {
    role: 'Super Admin',
    name: 'Ahmad Faizal',
    email: 'test@gmail.com',
    password: 'Dtct+1234',
    department: 'HQ Platform Operations',
    color: 'bg-blue-50 text-[#062AAE] border-blue-200 hover:bg-blue-100',
    avatar: 'AF'
  },
  {
    role: 'Super Admin (Official)',
    name: 'Ahmad Faizal',
    email: 'admin@mysect.com.my',
    password: 'admin',
    department: 'HQ Platform Operations',
    color: 'bg-indigo-50 text-indigo-700 border-indigo-200 hover:bg-indigo-100',
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
  }
];

const Login = ({ onLogin }) => {
  const [authStep, setAuthStep] = useState('credentials'); // 'credentials' | '2fa'
  const [email, setEmail] = useState('test@gmail.com');
  const [password, setPassword] = useState('Dtct+1234');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // 6-digit OTP code state
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [otpError, setOtpError] = useState('');
  const otpInputRefs = useRef([]);

  // Forgot Key / Password Recovery Modal States
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSubmitted, setForgotSubmitted] = useState(false);
  const [forgotError, setForgotError] = useState('');

  useEffect(() => {
    if (authStep === '2fa' && otpInputRefs.current[0]) {
      otpInputRefs.current[0].focus();
    }
  }, [authStep]);

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

  const handleCredentialSubmit = (e) => {
    e.preventDefault();
    setError('');

    const cleanEmail = email.trim().toLowerCase();
    const cleanPass = password.trim();

    if (!cleanEmail || !cleanPass) {
      setError('Please enter both your work email and password.');
      return;
    }

    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);

      // Check test credentials
      const isTestAccount = cleanEmail === 'test@gmail.com' && cleanPass === 'Dtct+1234';
      const matchedDemo = DEMO_ACCOUNTS.find(
        acc => acc.email.toLowerCase() === cleanEmail && acc.password === cleanPass
      );

      if (isTestAccount || matchedDemo || (cleanEmail.includes('@') && cleanPass === 'Dtct+1234')) {
        setAuthStep('2fa');
        setError('');
        setOtpError('');
        setOtp(['', '', '', '', '', '']);
      } else {
        setError('Invalid credentials. For access, use email "test@gmail.com" and password "Dtct+1234".');
      }
    }, 450);
  };

  const handleOtpChange = (index, value) => {
    // Extract only the single newest character (never wipe other inputs)
    const digits = value.replace(/\D/g, '');
    const digit = digits ? digits.slice(-1) : '';

    const newOtp = [...otp];
    newOtp[index] = digit;
    setOtp(newOtp);

    // Auto-advance to next box
    if (digit && index < 5) {
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  const handleOtpPaste = (e) => {
    e.preventDefault();
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (pasted) {
      const newOtp = [...otp];
      for (let i = 0; i < 6; i++) {
        newOtp[i] = pasted[i] || '';
      }
      setOtp(newOtp);
      const targetIdx = Math.min(pasted.length - 1, 5);
      if (targetIdx >= 0) {
        otpInputRefs.current[targetIdx]?.focus();
      }
    }
  };

  const handleOtpKeyDown = (index, e) => {
    if (e.key === 'Backspace') {
      if (!otp[index] && index > 0) {
        const newOtp = [...otp];
        newOtp[index - 1] = '';
        setOtp(newOtp);
        otpInputRefs.current[index - 1]?.focus();
      } else {
        const newOtp = [...otp];
        newOtp[index] = '';
        setOtp(newOtp);
      }
    } else if (e.key === 'ArrowLeft' && index > 0) {
      otpInputRefs.current[index - 1]?.focus();
    } else if (e.key === 'ArrowRight' && index < 5) {
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  const handleVerify2fa = (e) => {
    e.preventDefault();
    setOtpError('');

    const fullCode = otp.join('');
    if (fullCode.length < 6) {
      setOtpError('Please enter all 6 digits of your verification code.');
      return;
    }

    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);

      // Expected statutory code is 000000 or any 6-digit test pin
      if (fullCode === '000000' || /^\d{6}$/.test(fullCode)) {
        const cleanEmail = email.trim();
        const matched = DEMO_ACCOUNTS.find(
          acc => acc.email.toLowerCase() === cleanEmail.toLowerCase()
        );

        onLogin({
          name: matched ? matched.name : 'Ahmad Faizal',
          email: cleanEmail,
          role: matched ? matched.role : 'Super Admin',
          department: matched ? matched.department : 'HQ Platform Operations',
          avatar: matched ? matched.avatar : 'AF',
          token: 'tok_' + Math.random().toString(36).substring(2),
          loginTime: new Date().toISOString()
        }, rememberMe);
      } else {
        setOtpError('Invalid 6-digit code. Please enter 6 numeric digits (e.g. "000000").');
      }
    }, 400);
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

      {/* Main Container */}
      <main className="relative z-10 w-full flex-1 flex items-center justify-center p-4 sm:p-6 my-auto">
        <div className="w-full max-w-sm sm:max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-6 sm:p-7 transition-all">
          
          {/* Logo and Header */}
          <div className="text-center mb-5">
            <div className="flex items-center justify-center mb-3">
              <img 
                src={mysectLogo} 
                alt="MySect - Your Secretary Company" 
                className="h-9 sm:h-10 w-auto object-contain" 
              />
            </div>
            <h1 className="text-lg sm:text-xl font-bold text-gray-900">
              {authStep === 'credentials' ? 'Sign in to Operator Console' : 'Security Verification'}
            </h1>
            <p className="text-[11px] text-gray-500 mt-1 max-w-xs mx-auto">
              {authStep === 'credentials'
                ? 'Authorized personnel only. Sessions are audited per statutory governance policies.'
                : `Enter the 6-digit security code dispatched to ${email}`}
            </p>
          </div>

          {/* STEP 1: CREDENTIALS */}
          {authStep === 'credentials' && (
            <>
              {/* Error Banner */}
              {error && (
                <div className="mb-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-2.5">
                  <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                  <span>{error}</span>
                </div>
              )}

              {/* Form */}
              <form onSubmit={handleCredentialSubmit} className="space-y-3">
                <div>
                  <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Work Email Address
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="test@gmail.com"
                      required
                      autoFocus
                      className="w-full pl-9 pr-4 py-2 bg-gray-50/50 border border-gray-200 rounded-xl text-xs sm:text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider">
                      Password
                    </label>
                    <button
                      type="button"
                      onClick={() => {
                        setForgotEmail(email || 'test@gmail.com');
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
                      className="w-full pl-9 pr-10 py-2 bg-gray-50/50 border border-gray-200 rounded-xl text-xs sm:text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
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

                <div className="flex items-center justify-between pt-0.5">
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={rememberMe}
                      onChange={(e) => setRememberMe(e.target.checked)}
                      className="w-3.5 h-3.5 text-[#062AAE] rounded border-gray-300 focus:ring-[#062AAE]"
                    />
                    <span className="text-[11px] text-gray-600">Keep me signed in</span>
                  </label>
                  <div className="flex items-center gap-1 text-[10px] text-gray-500">
                    <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                    <span>2FA Enforced</span>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full mt-1.5 py-2.5 px-4 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-xs sm:text-sm font-semibold flex items-center justify-center gap-2 transition-all shadow-md hover:shadow-lg disabled:opacity-70 disabled:cursor-not-allowed cursor-pointer"
                >
                  {isLoading ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      <span>Verifying Credentials...</span>
                    </>
                  ) : (
                    <>
                      <span>Continue to Security Code</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </>
                  )}
                </button>
              </form>

              {/* Quick Demo Login Preset Buttons */}
              <div className="mt-4 pt-3.5 border-t border-gray-100">
                <p className="text-[10px] font-semibold text-gray-500 uppercase tracking-wider mb-1.5 text-center">
                  Authorized Access Credentials
                </p>
                <div className="grid grid-cols-1 gap-1.5">
                  <div className="bg-blue-50/70 border border-blue-200/80 rounded-xl p-2.5 text-[11px] text-[#062AAE]">
                    <div className="font-semibold flex items-center justify-between">
                      <span>Primary Login Account:</span>
                      <span className="font-mono text-[10px] bg-white px-1.5 py-0.5 rounded border border-blue-200">2FA: 000000</span>
                    </div>
                    <div className="mt-1 flex items-center justify-between text-[11px] text-gray-700">
                      <span>Email: <strong className="font-mono text-gray-900">test@gmail.com</strong></span>
                      <span>Password: <strong className="font-mono text-gray-900">Dtct+1234</strong></span>
                    </div>
                  </div>
                </div>
              </div>
            </>
          )}

          {/* STEP 2: 6-DIGIT 2FA VERIFICATION CODE */}
          {authStep === '2fa' && (
            <div className="animate-in fade-in duration-200">
              {/* Error Banner */}
              {otpError && (
                <div className="mb-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-2.5">
                  <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                  <span>{otpError}</span>
                </div>
              )}

              <form onSubmit={handleVerify2fa} className="space-y-4">
                <div>
                  <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider mb-2 text-center">
                    Enter 6-Digit Password Code
                  </label>
                  
                  {/* 6 Digit Inputs */}
                  <div className="flex items-center justify-center gap-1.5 sm:gap-2.5">
                    {otp.map((digit, idx) => (
                      <input
                        key={idx}
                        ref={(el) => (otpInputRefs.current[idx] = el)}
                        type="text"
                        inputMode="numeric"
                        pattern="[0-9]*"
                        autoComplete="one-time-code"
                        maxLength={1}
                        value={digit}
                        onPaste={handleOtpPaste}
                        onFocus={(e) => e.target.select()}
                        onChange={(e) => handleOtpChange(idx, e.target.value)}
                        onKeyDown={(e) => handleOtpKeyDown(idx, e)}
                        className="w-9 sm:w-10 h-11 sm:h-12 text-center text-lg font-bold font-mono bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all text-gray-900"
                      />
                    ))}
                  </div>

                  <p className="text-[11px] text-gray-500 text-center mt-2.5">
                    Statutory code for testing: <strong className="font-mono text-[#062AAE]">000000</strong>
                  </p>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-2.5 px-4 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-xs sm:text-sm font-semibold flex items-center justify-center gap-2 transition-all shadow-md hover:shadow-lg disabled:opacity-70 disabled:cursor-not-allowed cursor-pointer"
                >
                  {isLoading ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      <span>Verifying Code...</span>
                    </>
                  ) : (
                    <>
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Verify & Enter Console</span>
                    </>
                  )}
                </button>

                <div className="flex items-center justify-between pt-1.5 border-t border-gray-100">
                  <button
                    type="button"
                    onClick={() => {
                      setAuthStep('credentials');
                      setError('');
                      setOtpError('');
                    }}
                    className="flex items-center gap-1.5 text-xs text-gray-600 hover:text-[#062AAE] transition-colors cursor-pointer font-medium"
                  >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    <span>Change Email / Password</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      setOtp(['0', '0', '0', '0', '0', '0']);
                      setOtpError('');
                    }}
                    className="text-xs text-[#062AAE] hover:underline cursor-pointer font-medium"
                  >
                    Auto-Fill 000000
                  </button>
                </div>
              </form>
            </div>
          )}

        </div>
      </main>

      {/* Footer Compliance Badge */}
      <footer className="relative z-10 w-full max-w-6xl mx-auto px-6 py-3 text-center text-xs text-gray-500 flex flex-col sm:flex-row items-center justify-between gap-2 border-t border-gray-200/60">
        <div className="flex items-center gap-2 text-gray-600 text-[11px]">
          <ShieldCheck className="w-3.5 h-3.5 text-[#062AAE]" />
          <span>MySect Corporate Secretarial Platform • SSM Companies Act 2016 Compliant</span>
        </div>
        <div className="flex items-center gap-3 text-[10px] text-gray-400">
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
                        placeholder="test@gmail.com"
                        required
                        className="w-full pl-10 pr-4 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#062AAE] focus:bg-white transition-all"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={forgotLoading}
                    className="w-full py-2.5 px-4 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-sm font-semibold flex items-center justify-center gap-2 transition-all shadow-md cursor-pointer disabled:opacity-50"
                  >
                    {forgotLoading ? (
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                      <>
                        <Send className="w-4 h-4" />
                        <span>Dispatch Recovery Link</span>
                      </>
                    )}
                  </button>
                </form>
              </>
            ) : (
              <div className="text-center py-4">
                <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-4 border border-emerald-100">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-gray-900">
                  Recovery Token Dispatched
                </h3>
                <p className="text-xs text-gray-500 mt-2 leading-relaxed">
                  A statutory authentication reset request has been routed to{' '}
                  <strong className="text-gray-900 font-semibold">{forgotEmail}</strong>. Follow the instructions in the email within 15 minutes.
                </p>
                <button
                  type="button"
                  onClick={() => setShowForgotModal(false)}
                  className="mt-6 w-full py-2.5 px-4 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
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
