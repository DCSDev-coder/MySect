import React, { useState, useRef, useEffect } from 'react';
import { 
  Lock, Mail, Eye, EyeOff, AlertCircle, ArrowLeft
} from 'lucide-react';
import mysectLogo from '../../assets/mysect_logo.png';
import loginIllustration from '../../assets/login.png';
import verifyCodeIllustration from '../../assets/verify_code.png';
import forgotPasswordIllustration from '../../assets/forgot_password.png';

const DEMO_ACCOUNTS = [
  {
    role: 'Super Admin',
    name: 'Ahmad Faizal',
    email: 'Dcs2026@gmail.com',
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
  // 'credentials' | '2fa' | 'forgot_password'
  const [authStep, setAuthStep] = useState('credentials');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // 6-digit OTP code state
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [otpError, setOtpError] = useState('');
  const [resendCountdown, setResendCountdown] = useState(59);
  const otpInputRefs = useRef([]);

  // Forgot Password States
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSubmitted, setForgotSubmitted] = useState(false);
  const [forgotError, setForgotError] = useState('');

  // Countdown timer for 2FA resend
  useEffect(() => {
    let timer;
    if (authStep === '2fa' && resendCountdown > 0) {
      timer = setInterval(() => {
        setResendCountdown((prev) => (prev > 0 ? prev - 1 : 0));
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [authStep, resendCountdown]);

  useEffect(() => {
    if (authStep === '2fa' && otpInputRefs.current[0]) {
      otpInputRefs.current[0].focus();
    }
  }, [authStep]);

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

      const isTestAccount = (cleanEmail === 'dcs2026@gmail.com' || cleanEmail === 'test@gmail.com') && cleanPass === 'Dtct+1234';
      const matchedDemo = DEMO_ACCOUNTS.find(
        acc => acc.email.toLowerCase() === cleanEmail && acc.password === cleanPass
      );

      if (isTestAccount || matchedDemo || (cleanEmail.includes('@') && cleanPass === 'Dtct+1234')) {
        setAuthStep('2fa');
        setError('');
        setOtpError('');
        setOtp(['', '', '', '', '', '']);
        setResendCountdown(59);
      } else {
        setError('Invalid email or password.');
      }
    }, 350);
  };

  const handleOtpChange = (index, value) => {
    const digits = value.replace(/\D/g, '');
    const digit = digits ? digits.slice(-1) : '';

    const newOtp = [...otp];
    newOtp[index] = digit;
    setOtp(newOtp);

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

    const rawCode = otp.join('');
    const fullCode = rawCode.trim();
    const isCodeValid = fullCode === '1122' || 
      fullCode === '112200' || 
      fullCode === '112211' || 
      fullCode === '112233' || 
      fullCode === '112222' || 
      fullCode.startsWith('1122') || 
      fullCode === '000000' || 
      /^\d{6}$/.test(fullCode);

    if (!fullCode || !isCodeValid) {
      setOtpError('Invalid verification code. Please try again.');
      return;
    }

    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);

      if (isCodeValid) {
        const cleanEmail = email.trim();
        const matched = DEMO_ACCOUNTS.find(
          acc => acc.email.toLowerCase() === cleanEmail.toLowerCase()
        );

        onLogin({
          name: matched ? matched.name : 'Ahmad Faizal',
          email: cleanEmail || 'Dcs2026@gmail.com',
          role: matched ? matched.role : 'Super Admin',
          department: matched ? matched.department : 'HQ Platform Operations',
          avatar: matched ? matched.avatar : 'AF',
          token: 'tok_' + Math.random().toString(36).substring(2),
          loginTime: new Date().toISOString()
        }, rememberMe);
      } else {
        setOtpError('Invalid verification code. Please try again.');
      }
    }, 400);
  };

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
    }, 500);
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-[#F1F5FD] p-4 sm:p-6 select-none font-sans">
      
      {/* 1. SIGN IN (CREDENTIALS) DESKTOP SIDE-BY-SIDE LAYOUT */}
      {authStep === 'credentials' && (
        <div className="w-full max-w-[880px] bg-white rounded-[20px] shadow-[0_6px_28px_rgba(0,0,0,0.06)] border border-gray-100 overflow-hidden flex flex-col md:flex-row transition-all animate-in fade-in duration-200">
          
          {/* Left Brand & Illustration Panel */}
          <div className="w-full md:w-5/12 bg-[#F8FAFC] p-8 sm:p-9 flex flex-col items-center justify-center text-center">
            <img 
              src={mysectLogo} 
              alt="MySect - Your Secretary Company" 
              className="w-[130px] object-contain" 
            />
            <img 
              src={loginIllustration} 
              alt="MySect Admin Console" 
              className="h-[145px] object-contain my-5" 
            />
            <h2 className="text-lg font-bold text-[#0F172A]">
              MySect Admin Console
            </h2>
            <p className="text-[11px] text-gray-500 mt-1.5 leading-relaxed max-w-xs">
              Authorized administration & compliance workspace for platform operations and firm management.
            </p>
          </div>

          {/* Vertical Divider */}
          <div className="hidden md:block w-[1px] bg-gray-100" />

          {/* Right Form Panel */}
          <div className="w-full md:w-7/12 bg-white p-8 sm:p-9 flex items-center justify-center">
            <div className="w-full max-w-[360px]">
              
              <h1 className="text-xl font-bold text-gray-900">
                Sign In to Console
              </h1>
              <p className="text-xs text-gray-500 mt-1 mb-5">
                Enter your administrator credentials to continue.
              </p>

              {/* Error Banner */}
              {error && (
                <div className="mb-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-2.5">
                  <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                  <span>{error}</span>
                </div>
              )}

              <form onSubmit={handleCredentialSubmit} className="space-y-3.5">
                {/* Email Address */}
                <div>
                  <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                    Email Address
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#062AAE]" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="name@example.com"
                      required
                      autoFocus
                      className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-300 rounded-[10px] text-xs sm:text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#062AAE] focus:ring-1 focus:ring-[#062AAE] transition-all"
                    />
                  </div>
                </div>

                {/* Password */}
                <div>
                  <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                    Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#062AAE]" />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Enter your password"
                      required
                      className="w-full pl-10 pr-10 py-2.5 bg-white border border-gray-300 rounded-[10px] text-xs sm:text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#062AAE] focus:ring-1 focus:ring-[#062AAE] transition-all"
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

                {/* Forgot Password Link */}
                <div className="flex justify-end pt-0.5">
                  <button
                    type="button"
                    onClick={() => {
                      setForgotEmail(email);
                      setForgotSubmitted(false);
                      setForgotError('');
                      setAuthStep('forgot_password');
                    }}
                    className="text-[11px] font-semibold text-[#062AAE] hover:underline cursor-pointer"
                  >
                    Forgot Password?
                  </button>
                </div>

                {/* Login Button */}
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full mt-4 h-11 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-[10px] text-sm font-bold flex items-center justify-center transition-all cursor-pointer shadow-none disabled:opacity-70"
                >
                  {isLoading ? (
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  ) : (
                    'Login'
                  )}
                </button>

                <p className="text-[10px] text-gray-400 text-center mt-3.5 pt-1">
                  256-Bit SSL Encrypted • Statutory Portal
                </p>
              </form>
            </div>
          </div>

        </div>
      )}

      {/* 2. ENTER CODE / 2FA VERIFICATION LAYOUT */}
      {authStep === '2fa' && (
        <div className="w-full max-w-[480px] bg-white rounded-[20px] shadow-[0_6px_28px_rgba(0,0,0,0.06)] border border-gray-100 p-7 sm:p-9 transition-all animate-in fade-in duration-200">
          
          <div className="flex justify-center mb-3">
            <img 
              src={mysectLogo} 
              alt="MySect - Your Secretary Company" 
              className="h-8 object-contain" 
            />
          </div>

          <div className="flex justify-center my-3">
            <img 
              src={verifyCodeIllustration} 
              alt="Verification Code" 
              className="h-[120px] object-contain" 
            />
          </div>

          <h1 className="text-xl sm:text-2xl font-bold text-gray-900 text-center mt-2">
            Enter verification code
          </h1>
          <p className="text-xs sm:text-[13px] text-gray-600 text-center mt-2 leading-relaxed">
            Enter the 6-digit code we sent to<br />
            your email to verify your account.<br />
            <span className="font-semibold text-gray-900">{email || 'Dcs2026@gmail.com'}</span>
          </p>

          {/* OTP Error Banner */}
          {otpError && (
            <div className="mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-center gap-2">
              <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
              <span>{otpError}</span>
            </div>
          )}

          <form onSubmit={handleVerify2fa} className="mt-6">
            {/* 6 Digit Inputs */}
            <div className="flex items-center justify-center gap-2 sm:gap-2.5">
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
                  className="w-10 sm:w-11 h-12 text-center text-xl font-bold font-mono bg-white border border-gray-300 rounded-xl focus:outline-none focus:border-[#062AAE] focus:ring-1 focus:ring-[#062AAE] transition-all text-gray-900"
                />
              ))}
            </div>

            {/* Resend Code Timer */}
            <p className="text-xs text-gray-500 text-center mt-4">
              Didn't receive the code?{' '}
              {resendCountdown > 0 ? (
                <span className="text-gray-400 font-medium">
                  Resend code in {resendCountdown}s
                </span>
              ) : (
                <button
                  type="button"
                  onClick={() => setResendCountdown(59)}
                  className="text-[#062AAE] font-semibold hover:underline cursor-pointer"
                >
                  Resend code
                </button>
              )}
            </p>

            {/* Verify and continue Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-6 h-11 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-xl text-sm font-bold flex items-center justify-center transition-all shadow-sm cursor-pointer disabled:opacity-70"
            >
              {isLoading ? (
                <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                'Verify and continue'
              )}
            </button>


          </form>
        </div>
      )}

      {/* 3. FORGOT PASSWORD DESKTOP SIDE-BY-SIDE LAYOUT */}
      {authStep === 'forgot_password' && (
        <div className="w-full max-w-[880px] bg-white rounded-[20px] shadow-[0_6px_28px_rgba(0,0,0,0.06)] border border-gray-100 overflow-hidden flex flex-col md:flex-row transition-all animate-in fade-in duration-200">
          
          {/* Left Brand & Illustration Panel */}
          <div className="w-full md:w-5/12 bg-[#F8FAFC] p-8 sm:p-9 flex flex-col items-center justify-center text-center">
            <img 
              src={mysectLogo} 
              alt="MySect - Your Secretary Company" 
              className="w-[130px] object-contain" 
            />
            <img 
              src={forgotPasswordIllustration} 
              alt="Account Recovery" 
              className="h-[145px] object-contain my-5" 
            />
            <h2 className="text-lg font-bold text-[#0F172A]">
              Account Recovery
            </h2>
            <p className="text-[11px] text-gray-500 mt-1.5 leading-relaxed max-w-xs">
              Verify your registered email to reset your admin console access password.
            </p>
          </div>

          {/* Vertical Divider */}
          <div className="hidden md:block w-[1px] bg-gray-100" />

          {/* Right Form Panel */}
          <div className="w-full md:w-7/12 bg-white p-8 sm:p-9 flex items-center justify-center">
            <div className="w-full max-w-[360px]">
              
              <h1 className="text-xl font-bold text-gray-900">
                Forgot Password?
              </h1>
              <p className="text-xs text-gray-500 mt-1 mb-5">
                Enter your registered email address to receive a 6-digit verification code.
              </p>

              {forgotError && (
                <div className="mb-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
                  <span>{forgotError}</span>
                </div>
              )}

              {!forgotSubmitted ? (
                <form onSubmit={handleForgotSubmit} className="space-y-4">
                  <div>
                    <label className="block text-[10px] font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                      Email Address
                    </label>
                    <div className="relative">
                      <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#062AAE]" />
                      <input
                        type="email"
                        value={forgotEmail}
                        onChange={(e) => setForgotEmail(e.target.value)}
                        placeholder="name@example.com"
                        required
                        className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-300 rounded-[10px] text-xs sm:text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#062AAE] focus:ring-1 focus:ring-[#062AAE] transition-all"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={forgotLoading}
                    className="w-full mt-4 h-11 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-[10px] text-sm font-bold flex items-center justify-center transition-all cursor-pointer shadow-none disabled:opacity-70"
                  >
                    {forgotLoading ? (
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                      'Send 6-Digit Code'
                    )}
                  </button>

                  <div className="text-center mt-4">
                    <button
                      type="button"
                      onClick={() => setAuthStep('credentials')}
                      className="text-xs text-gray-600 hover:text-[#062AAE] cursor-pointer"
                    >
                      Remembered your password? <span className="text-[#062AAE] font-bold">Back to Login</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="text-center py-2">
                  <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-3 border border-emerald-100">
                    <span className="text-xl">✓</span>
                  </div>
                  <h3 className="text-base font-bold text-gray-900">
                    Recovery Code Sent
                  </h3>
                  <p className="text-xs text-gray-500 mt-1.5 leading-relaxed">
                    A 6-digit statutory verification code has been dispatched to{' '}
                    <strong className="text-gray-900 font-semibold">{forgotEmail}</strong>.
                  </p>
                  
                  <button
                    type="button"
                    onClick={() => {
                      setEmail(forgotEmail);
                      setAuthStep('2fa');
                      setOtp(['', '', '', '', '', '']);
                      setOtpError('');
                    }}
                    className="mt-5 w-full h-11 bg-[#062AAE] hover:bg-[#05228D] text-white rounded-[10px] text-sm font-bold transition-colors cursor-pointer"
                  >
                    Proceed to Verification
                  </button>

                  <div className="text-center mt-3">
                    <button
                      type="button"
                      onClick={() => setAuthStep('credentials')}
                      className="text-xs text-gray-500 hover:text-[#062AAE] cursor-pointer"
                    >
                      Back to Login
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>

        </div>
      )}

    </div>
  );
};

export default Login;
