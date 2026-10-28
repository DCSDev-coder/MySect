import os
import subprocess
import json
import base64
from pathlib import Path

ROOT = Path('/Users/marketingdeveloper/DCStack_Development/MySect')
WORK_DIR = ROOT / 'tmp/pitch_video_build'
FRAMES_DIR = WORK_DIR / 'frames'
AUDIO_DIR = WORK_DIR / 'audio'
HTML_DIR = WORK_DIR / 'html'
OUT_DIR = ROOT / 'output/video'

for d in [WORK_DIR, FRAMES_DIR, AUDIO_DIR, HTML_DIR, OUT_DIR]:
    d.mkdir(parents=True, exist_ok=True)

CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
LOGO_PNG = ROOT / 'admin_website/public/mysect_logo.png'
MAIN_LOGO_PNG = ROOT / 'admin_website/public/mysect_main_logo.png'
LOGIN_IMG = ROOT / 'mobile_app/assets/login.png'
COMPANY_IMG = ROOT / 'mobile_app/assets/company.png'
CHAT_IMG = ROOT / 'mobile_app/assets/Chat.png'
PDF_IMG = ROOT / 'mobile_app/assets/PDF.png'

def b64_img(path: Path) -> str:
    if not path.exists():
        return ''
    data = base64.b64encode(path.read_bytes()).decode('ascii')
    return f'data:image/png;base64,{data}'

LOGO_URI = b64_img(LOGO_PNG)
ICON_URI = b64_img(MAIN_LOGO_PNG)
LOGIN_URI = b64_img(LOGIN_IMG)
COMPANY_URI = b64_img(COMPANY_IMG)
CHAT_URI = b64_img(CHAT_IMG)
PDF_URI = b64_img(PDF_IMG)

SCENES = [
    {
        'id': 1,
        'tag': 'SCENE 01  •  THE PROBLEM & THE MYSECT SOLUTION',
        'title': 'Replacing Scattered WhatsApp Chats with One Digital Platform',
        'subtitle': 'MySect Customer Mobile App — Purpose-built for Malaysian company owners & directors',
        'caption': 'For Malaysian business owners and company-secretary firms, statutory compliance is often stuck in scattered WhatsApp chats and lost email attachments. MySect changes that.',
        'vo': 'For Malaysian business owners and company-secretary firms, managing statutory compliance is still stuck in scattered WhatsApp messages, lost email attachments, and manual chasing. MySect changes that.',
    },
    {
        'id': 2,
        'tag': 'SCENE 02  •  MULTI-COMPANY CLARITY IN 5 SECONDS',
        'title': 'One Mobile App for Every Company You Own',
        'subtitle': 'Switch between Sdn Bhd entities, see pending actions, and track upcoming SSM deadlines',
        'caption': 'With the MySect Customer App, directors managing one or multiple Sdn Bhd companies see everything requiring their attention in five seconds—documents needed, replies pending, and SSM deadlines.',
        'vo': 'With the MySect Customer App, directors managing one or multiple Sdn Bhd companies see everything that needs their attention in five seconds—which documents are needed, which replies are pending, and what deadlines are coming up.',
    },
    {
        'id': 3,
        'tag': 'SCENE 03  •  ASK MYSECT GUIDED INTAKE & SSM REQUESTS',
        'title': 'Structured Intake — No More Incomplete Requests',
        'subtitle': 'Digital Assistant confirms company context & collects required documents before handover',
        'caption': 'Every request starts with guided intake. Whether for a Section 58 Director Change or Section 68 Annual Return, MySect confirms the company, prompts for required documents, and creates a structured case.',
        'vo': 'Instead of vague messages, every request starts with guided intake. Whether a client needs a Section 58 Director Change or a Section 68 Annual Return, MySect confirms the company, prompts for the exact required documents, and packages a complete case for their Secretary.',
    },
    {
        'id': 4,
        'tag': 'SCENE 04  •  CENTRALISED DOCUMENT VAULT & FORMAL APPROVALS',
        'title': 'Tracked Document Exchange & Timestamped Sign-Off',
        'subtitle': 'Company-isolated document folders, draft previews, and recorded customer approvals',
        'caption': 'Every corporate document, board resolution, and approval lives in a secure vault. Clients review prepared drafts and approve or reject with a reason—recording an immutable timestamp.',
        'vo': 'Every corporate document, board resolution, and approval lives in a secure, company-isolated vault. Clients can review prepared drafts and approve or reject with a single tap, with every action timestamped for a clean audit trail.',
    },
    {
        'id': 5,
        'tag': 'SCENE 05  •  REAL-TIME HANDOFF TO THE SECRETARY WORKSPACE',
        'title': 'AI Prepares the Case. Licensed Secretaries Stay in Control.',
        'subtitle': 'Seamless sync between the Flutter Customer App and the Partner Secretary Firm Website',
        'caption': 'Partner company-secretary firms receive a pre-organised case in their web workspace. Licensed secretaries accept ownership, open direct human chat when needed, and complete the filing.',
        'vo': 'Behind the scenes, partner company-secretary firms receive a pre-organised case in their dedicated web workspace. Licensed secretaries accept ownership, open direct human conversation when needed, review documents, and complete the work in half the time.',
    },
    {
        'id': 6,
        'tag': 'SCENE 06  •  MYSECT ADMIN GOVERNANCE & 3-MONTH MVP ROADMAP',
        'title': 'One Shared Platform. Three Role-Specific Products.',
        'subtitle': 'Customer Mobile App  •  Secretary Firm Website  •  MySect Admin Portal',
        'caption': 'Backed by MySect Admin for partner firm onboarding, company assignment, and full audit history—MySect delivers a complete end-to-end corporate secretarial platform.',
        'vo': 'Backed by MySect Admin for multi-firm onboarding, company assignment, and full audit governance, MySect connects clients and company secretaries on one trusted platform. Let us build the future of corporate secretarial services together.',
    },
]

def generate_audio():
    metadata = []
    for sc in SCENES:
        sid = sc['id']
        aiff_path = AUDIO_DIR / f'scene_{sid}.aiff'
        m4a_path = AUDIO_DIR / f'scene_{sid}.m4a'
        subprocess.run(['say', '-v', 'Samantha', '-r', '172', '-o', str(aiff_path), sc['vo']], check=True)
        subprocess.run(['afconvert', '-f', 'm4af', '-d', 'aac', str(aiff_path), str(m4a_path)], check=True)
        # Get duration via afinfo
        out = subprocess.check_output(['afinfo', str(m4a_path)], text=True)
        dur = 12.0
        for line in out.splitlines():
            if 'estimated duration:' in line:
                dur = float(line.split('estimated duration:')[1].split('sec')[0].strip())
                break
        sc['audio_path'] = str(m4a_path)
        sc['audio_duration'] = round(dur, 2)
        sc['scene_duration'] = round(dur + 1.0, 2)
        print(f"Scene {sid} audio duration: {sc['audio_duration']}s -> scene duration: {sc['scene_duration']}s")
        metadata.append(sc)
    (WORK_DIR / 'scenes_meta.json').write_text(json.dumps(metadata, indent=2))
    return metadata

def phone_shell(inner_html: str, active_tab: int = 0) -> str:
    tabs = [
        ('Home', '⌂'),
        ('Requests', '⇄'),
        ('Files', '📁'),
        ('Ask MySect', '💬'),
        ('More', '•••'),
    ]
    nav_items = ''
    for idx, (tname, ticon) in enumerate(tabs):
        active_cls = 'nav-item active' if idx == active_tab else 'nav-item'
        nav_items += f'<div class="{active_cls}"><div class="nav-ico">{ticon}</div><span>{tname}</span></div>'

    return f'''
    <div class="iphone-frame">
      <div class="iphone-notch"></div>
      <div class="iphone-statusbar">
        <span>9:41</span>
        <span>5G • 100%</span>
      </div>
      <div class="app-top-header">
        <div class="header-logo-pill">
          <img src="{LOGO_URI}" alt="MySect" />
        </div>
        <div class="header-bell">🔔<span class="bell-dot"></span></div>
      </div>
      <div class="iphone-body">
        {inner_html}
      </div>
      <div class="iphone-bottom-nav">
        {nav_items}
      </div>
    </div>
    '''

def build_step_content(scene_id: int, step: int) -> str:
    # Step is 0, 1, or 2 inside each scene
    if scene_id == 1:
        if step == 0:
            phone = f'''
            <div class="iphone-frame splash-bg">
              <div class="iphone-notch"></div>
              <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;padding:32px;text-align:center;">
                <img src="{LOGO_URI}" style="width:210px;margin-bottom:20px;" />
                <img src="{LOGIN_URI}" style="width:220px;height:180px;object-fit:contain;margin-bottom:20px;" />
                <div style="font-size:20px;font-weight:800;color:#0F2D59;margin-bottom:8px;">Your Digital Company Secretary</div>
                <div style="font-size:12.5px;color:#475569;line-height:1.5;margin-bottom:24px;">Manage your Sdn Bhd compliance, board resolutions, SSM filings, and secretary requests in one secure app.</div>
                <div style="background:#062AAE;color:#fff;padding:12px 36px;border-radius:26px;font-weight:700;font-size:13px;box-shadow:0 8px 20px rgba(6,42,174,0.3);">Get Started →</div>
              </div>
            </div>
            '''
        elif step == 1:
            phone = f'''
            <div class="iphone-frame">
              <div class="iphone-notch"></div>
              <div style="padding:46px 26px 24px 26px;">
                <img src="{LOGO_URI}" style="width:130px;margin-bottom:14px;" />
                <div style="font-size:22px;font-weight:800;color:#0F2D59;">Welcome Back</div>
                <div style="font-size:12px;color:#64748B;margin-bottom:18px;">Sign in to view your authorised companies</div>
                <div class="input-mock"><span class="lbl">Email Address</span><div class="val">ahmad.razak@dcspecialists.com.my</div></div>
                <div class="input-mock"><span class="lbl">Password</span><div class="val">••••••••••••</div></div>
                <div style="display:flex;justify-content:space-between;font-size:11px;color:#062AAE;font-weight:600;margin:8px 0 18px 0;">
                  <span>✓ Verified Company Director</span><span>Forgot Password?</span>
                </div>
                <div class="btn-primary-Tap">Sign In to MySect <span class="tap-ring"></span></div>
                <div style="margin-top:18px;padding:12px;background:#F1F5F9;border-radius:12px;font-size:11px;color:#334155;">
                  🔒 <b>Role & Company Access Control:</b> You only see companies you are explicitly authorised to represent.
                </div>
              </div>
            </div>
            '''
        else:
            inner = f'''
            <div style="padding:14px 18px;">
              <div style="font-size:11px;color:#64748B;font-weight:600;">AUTHORISED COMPANY</div>
              <div class="comp-selector">
                <div>
                  <div style="font-weight:700;font-size:13px;color:#0F2D59;">Data Center Specialists Sdn Bhd</div>
                  <div style="font-size:10.5px;color:#64748B;">SSM No: 202101039281 (1429581-X)</div>
                </div>
                <span style="color:#062AAE;font-weight:800;">▼</span>
              </div>
              <div style="margin-top:12px;font-size:13px;font-weight:700;color:#0F2D59;">Action Required Today</div>
              <div class="action-grid">
                <div class="action-card warn">
                  <div class="ac-num">3</div>
                  <div class="ac-title">Documents Needed</div>
                  <div class="ac-sub">Requested by Secretary</div>
                </div>
                <div class="action-card info">
                  <div class="ac-num">2</div>
                  <div class="ac-title">Approvals Waiting</div>
                  <div class="ac-sub">Board Resolutions</div>
                </div>
              </div>
              <div class="sec-firm-banner">
                <div style="font-size:10px;color:#0A7E8C;font-weight:700;">ASSIGNED SECRETARY FIRM</div>
                <div style="font-size:12.5px;font-weight:700;color:#0F2D59;">Apex Corporate Chambers Sdn Bhd</div>
                <div style="font-size:11px;color:#475569;">Licensed CoSec: Nurul Izzah (LS0010492) • Active</div>
              </div>
            </div>
            '''
            phone = phone_shell(inner, active_tab=0)

        right_cards = [
            ('The Old Way (Before MySect)', '#FEF2F2', '#DC2626', [
                '❌ Scattered WhatsApp messages with no case tracking',
                '❌ Lost NRICs, Form 48A & resolutions in email threads',
                '❌ Clients constantly asking "What is my filing status?"',
                '❌ Secretaries spending 70% of time chasing missing info',
            ]),
            ('The MySect Platform Solution', '#EBF4FA', '#0F2D59', [
                '✓ One mobile app for all authorised Sdn Bhd companies',
                '✓ Guided Ask MySect intake collects missing details upfront',
                '✓ Dedicated Secretary Firm Web Workspace for fast execution',
                '✓ Complete document vault, formal approvals & audit trail',
            ]),
        ]
        r_html = ''
        for idx, (ctitle, cbg, ccol, cbuls) in enumerate(right_cards):
            hi = 'border:2px solid #062AAE;transform:scale(1.01);' if (idx == 1 and step >= 1) else ''
            bul_html = ''.join(f'<div style="font-size:14px;color:#1E293B;margin:7px 0;font-weight:500;">{b}</div>' for b in cbuls)
            r_html += f'''
            <div style="background:{cbg};border-left:6px solid {ccol};border-radius:14px;padding:18px 22px;margin-bottom:16px;box-shadow:0 6px 18px rgba(15,45,89,0.06);{hi}">
              <div style="font-size:17px;font-weight:800;color:{ccol};margin-bottom:8px;">{ctitle}</div>
              {bul_html}
            </div>
            '''
        return f'''
        <div class="split-layout">
          <div class="left-phone-col">{phone}</div>
          <div class="right-info-col">{r_html}</div>
        </div>
        '''

    if scene_id == 2:
        if step == 0:
            inner = '''
            <div style="padding:14px 18px;">
              <div style="font-size:11px;color:#062AAE;font-weight:700;">TAP TO SWITCH COMPANY</div>
              <div class="comp-selector active-ring">
                <div>
                  <div style="font-weight:700;font-size:13px;color:#0F2D59;">Data Center Specialists Sdn Bhd</div>
                  <div style="font-size:10.5px;color:#64748B;">202101039281 (1429581-X)</div>
                </div>
                <span style="color:#062AAE;font-weight:800;">▲</span>
              </div>
              <div class="dropdown-menu">
                <div class="dd-item selected">✓ Data Center Specialists Sdn Bhd <span class="dd-tag">Active</span></div>
                <div class="dd-item">DCStack Cloud Holdings Sdn Bhd <span class="dd-tag">2 Open</span></div>
                <div class="dd-item">Nexus Digital Ventures Sdn Bhd <span class="dd-tag">Compliant</span></div>
              </div>
              <div style="margin-top:12px;padding:12px;background:#F8FAFC;border-radius:12px;border:1px solid #E2E8F0;">
                <div style="font-size:11.5px;font-weight:700;color:#0F2D59;">Company Profile Summary</div>
                <div style="font-size:11px;color:#475569;margin-top:4px;">• Directors: 3 Appointed  • Shareholders: 2<br/>• Paid-Up Capital: RM 500,000<br/>• Registered Office: Cyberjaya, Selangor</div>
              </div>
            </div>
            '''
        elif step == 1:
            inner = '''
            <div style="padding:14px 18px;">
              <div class="comp-selector">
                <div>
                  <div style="font-weight:700;font-size:13px;color:#0F2D59;">Data Center Specialists Sdn Bhd</div>
                  <div style="font-size:10.5px;color:#64748B;">202101039281 (1429581-X)</div>
                </div>
                <span>▼</span>
              </div>
              <div style="margin-top:12px;font-size:13px;font-weight:700;color:#0F2D59;">Items Requiring Your Action</div>
              <div class="action-grid">
                <div class="action-card warn active-ring">
                  <div class="ac-num">3</div>
                  <div class="ac-title">Documents Needed</div>
                  <div class="ac-sub">Tap to upload files →</div>
                </div>
                <div class="action-card info">
                  <div class="ac-num">2</div>
                  <div class="ac-title">Replies / Approvals</div>
                  <div class="ac-sub">Waiting your sign-off</div>
                </div>
              </div>
              <div style="margin-top:12px;font-size:12px;font-weight:700;color:#0F2D59;">Pending Checklists</div>
              <div class="task-row">
                <span class="dot-amber"></span>
                <div style="flex:1;"><div style="font-size:11.5px;font-weight:700;">Director NRIC & Form 48A</div><div style="font-size:10px;color:#64748B;">For Section 58 Director Appointment</div></div>
                <span class="pill-warn">Upload</span>
              </div>
              <div class="task-row">
                <span class="dot-blue"></span>
                <div style="flex:1;"><div style="font-size:11.5px;font-weight:700;">Board Resolution — Registered Address</div><div style="font-size:10px;color:#64748B;">Prepared by Apex Corporate Chambers</div></div>
                <span class="pill-info">Approve</span>
              </div>
            </div>
            '''
        else:
            inner = '''
            <div style="padding:14px 18px;">
              <div style="font-size:13px;font-weight:800;color:#0F2D59;margin-bottom:8px;">SSM Compliance Calendar (2026)</div>
              <div class="cal-box">
                <div style="display:flex;justify-content:space-between;font-weight:700;font-size:12px;color:#062AAE;margin-bottom:6px;">
                  <span>OCTOBER / NOVEMBER 2026</span><span>SSM Statutory</span>
                </div>
                <div class="cal-grid">
                  <span>M</span><span>T</span><span>W</span><span>T</span><span>F</span><span>S</span><span>S</span>
                  <span>26</span><span>27</span><span class="cal-today">28</span><span>29</span><span>30</span><span class="cal-due">31</span><span>1</span>
                </div>
              </div>
              <div style="margin-top:10px;font-size:12px;font-weight:700;color:#0F2D59;">Tracked Statutory Deadlines</div>
              <div class="task-row">
                <div class="date-badge">NOV<br/><b>15</b></div>
                <div style="flex:1;"><div style="font-size:11.5px;font-weight:700;">Section 68 Annual Return (SSM)</div><div style="font-size:10px;color:#64748B;">Lodgement via MBRS by Assigned Secretary</div></div>
                <span class="pill-warn">In 18 days</span>
              </div>
              <div class="task-row">
                <div class="date-badge">NOV<br/><b>30</b></div>
                <div style="flex:1;"><div style="font-size:11.5px;font-weight:700;">Audited Financial Statements</div><div style="font-size:10px;color:#64748B;">Circulation & SSM Lodgement</div></div>
                <span class="pill-ok">In 33 days</span>
              </div>
            </div>
            '''
        phone = phone_shell(inner, active_tab=0)
        steps_ui = [
            ('1. Multi-Company Portfolio Switcher', 'Directors who own multiple Sdn Bhd entities switch between companies in one tap—each strictly isolated by permission.'),
            ('2. Action-First Home Dashboard', '"Documents Needed" and "Approvals Waiting" cards surface exact blockers immediately so nothing stalls.'),
            ('3. SSM Statutory Compliance Calendar', 'Tracks Section 68 Annual Returns, financial statement deadlines, and resolution due dates automatically.'),
        ]
        cards = ''
        for idx, (st, sd) in enumerate(steps_ui):
            act = 'border:2px solid #062AAE;background:#EBF4FA;' if idx == step else 'background:#FFFFFF;'
            cards += f'''
            <div style="{act}border-radius:14px;padding:18px 22px;margin-bottom:14px;box-shadow:0 4px 14px rgba(15,45,89,0.06);">
              <div style="font-size:16px;font-weight:800;color:#0F2D59;margin-bottom:6px;">{st}</div>
              <div style="font-size:13.5px;color:#334155;line-height:1.45;">{sd}</div>
            </div>
            '''
        return f'''
        <div class="split-layout">
          <div class="left-phone-col">{phone}</div>
          <div class="right-info-col">{cards}</div>
        </div>
        '''

    if scene_id == 3:
        if step == 0:
            inner = '''
            <div style="padding:12px 16px;">
              <div style="display:flex;align-items:center;gap:8px;padding-bottom:8px;border-bottom:1px solid #E2E8F0;">
                <div style="width:28px;height:28px;border-radius:14px;background:#062AAE;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:12px;">AI</div>
                <div>
                  <div style="font-size:12.5px;font-weight:800;color:#0F2D59;">Ask MySect Digital Assistant</div>
                  <div style="font-size:9.5px;color:#0A7E8C;font-weight:600;">Guided Case Intake • Data Center Specialists Sdn Bhd</div>
                </div>
              </div>
              <div class="chat-bubble ai">Hi Ahmad! Which company request can I help prepare for your Secretary today?</div>
              <div class="chat-bubble me">We want to appoint a new Director (Lim Wei Ming) effective 1st November.</div>
              <div class="chat-bubble ai">
                Got it — <b>Section 58 Appointment of Director</b> for <b>Data Center Specialists Sdn Bhd</b>.<br/><br/>
                To prepare a complete case for Apex Corporate Chambers, please confirm:<br/>
                1. New Director's NRIC copy<br/>
                2. Residential address & email<br/>
                3. Signed Section 201 Consent to Act
              </div>
              <div class="btn-primary-Tap" style="margin-top:8px;">Continue to Structured Filing Checklist →</div>
            </div>
            '''
            phone = phone_shell(inner, active_tab=3)
        elif step == 1:
            inner = '''
            <div style="padding:12px 16px;">
              <div style="font-size:13px;font-weight:800;color:#0F2D59;">Submit SSM Statutory Request</div>
              <div style="font-size:10.5px;color:#64748B;margin-bottom:8px;">Company: Data Center Specialists Sdn Bhd (1429581-X)</div>
              <div class="input-mock" style="border-color:#062AAE;background:#EBF4FA;">
                <span class="lbl">Selected Statutory Category (Companies Act 2016)</span>
                <div class="val" style="color:#062AAE;font-weight:700;">Section 58 Notice of Director Change ▼</div>
              </div>
              <div style="font-size:11.5px;font-weight:700;color:#0F2D59;margin:8px 0 6px 0;">Required Documents Checklist</div>
              <div class="check-row done">✓ Director NRIC Front & Back (Lim_Wei_Ming_NRIC.pdf)</div>
              <div class="check-row done">✓ Section 201 Consent to Act (Form_S201_Signed.pdf)</div>
              <div class="check-row">○ Board Resolution (To be drafted by Secretary Firm)</div>
              <div class="btn-primary-Tap" style="margin-top:12px;">Review & Submit Case to Secretary</div>
            </div>
            '''
            phone = phone_shell(inner, active_tab=1)
        else:
            inner = '''
            <div style="padding:14px 16px;">
              <div style="background:#DCFCE7;border:1px solid #15803D;border-radius:12px;padding:12px;margin-bottom:10px;">
                <div style="font-size:12px;font-weight:800;color:#15803D;">✓ Case #CASE-2026-089 Created</div>
                <div style="font-size:10.5px;color:#166534;margin-top:2px;">Assigned to: Apex Corporate Chambers Sdn Bhd</div>
              </div>
              <div style="font-size:12px;font-weight:800;color:#0F2D59;margin-bottom:6px;">Prepared Case Summary</div>
              <div style="background:#F8FAFC;border:1px solid #CBD5E1;border-radius:10px;padding:10px;font-size:10.8px;color:#334155;line-height:1.45;">
                <b>Request:</b> Section 58 Appointment of New Director<br/>
                <b>Appointee:</b> Lim Wei Ming (Effective 1 Nov 2026)<br/>
                <b>Attached:</b> NRIC Copy, Signed S201 Consent<br/>
                <b>Action for Secretary:</b> Prepare Board Resolution & S58 lodgement.
              </div>
              <div style="margin-top:10px;padding:10px;background:#FEF3C7;border-radius:10px;font-size:10.5px;color:#92400E;">
                ⏳ <b>Status:</b> Sent to Secretary Queue. Your assigned Secretary will open human conversation once accepted.
              </div>
            </div>
            '''
            phone = phone_shell(inner, active_tab=1)

        right_html = f'''
        <div style="background:#FFFFFF;border-radius:16px;padding:22px;border:1px solid #CBD5E1;box-shadow:0 8px 24px rgba(15,45,89,0.06);">
          <div style="font-size:12px;font-weight:800;color:#B45309;letter-spacing:0.6px;margin-bottom:6px;">HOW THE DIGITAL ASSISTANT PREPARES A CASE</div>
          <div style="font-size:18px;font-weight:800;color:#0F2D59;margin-bottom:14px;">AI Gathers the Facts → Licensed Secretary Takes Control</div>
          <div class="pipeline-step {'active-pipe' if step==0 else ''}"><b>1. Identify & Classify:</b> Confirms company authorisation and matches the request to Malaysian Companies Act 2016 categories (Section 58, Section 68, Section 46, Section 78).</div>
          <div class="pipeline-step {'active-pipe' if step==1 else ''}"><b>2. Collect Missing Info:</b> Prompts the customer with a clear checklist so NRICs, consents, and attachments are uploaded upfront.</div>
          <div class="pipeline-step {'active-pipe' if step==2 else ''}"><b>3. Handover Structured Case:</b> Packages the summary, files, and transcript into Case #CASE-2026-089 and alerts the assigned Secretary Firm.</div>
          <div style="margin-top:14px;padding:12px 16px;background:#EBF4FA;border-left:4px solid #062AAE;border-radius:8px;font-size:13px;color:#0F2D59;font-weight:600;">
            Key Rule: Customers cannot open unstructured human chats at random. The Digital Assistant prepares the case first so Secretaries never start from a blank page.
          </div>
        </div>
        '''
        return f'''
        <div class="split-layout">
          <div class="left-phone-col">{phone}</div>
          <div class="right-info-col">{right_html}</div>
        </div>
        '''

    if scene_id == 4:
        if step == 0:
            inner = '''
            <div style="padding:14px 18px;">
              <div style="font-size:18px;font-weight:800;color:#0F2D59;margin-bottom:10px;">Company Document Vault</div>
              <div class="folder-card attention active-ring">
                <div>
                  <div style="font-size:13px;font-weight:800;color:#B45309;">⚠️ Attention Required</div>
                  <div style="font-size:10.5px;color:#78350F;">1 Board Resolution waiting for your approval</div>
                </div>
                <span class="folder-badge warn">1</span>
              </div>
              <div class="folder-grid">
                <div class="folder-box">📁 <b>Corporate & SSM</b><span>14 Statutory Files</span></div>
                <div class="folder-box">📝 <b>Resolutions</b><span>6 Signed PDFs</span></div>
                <div class="folder-box">📊 <b>Annual Returns</b><span>2024 – 2026</span></div>
                <div class="folder-box">👤 <b>Directors & Shares</b><span>Registers & S58</span></div>
              </div>
            </div>
            '''
        elif step == 1:
            inner = '''
            <div style="padding:12px 16px;">
              <div style="font-size:12px;font-weight:800;color:#0F2D59;margin-bottom:6px;">Review Prepared Document</div>
              <div style="background:#F1F5F9;border:1px solid #CBD5E1;border-radius:10px;padding:12px;margin-bottom:10px;">
                <div style="display:flex;justify-content:space-between;font-size:10px;color:#64748B;margin-bottom:6px;">
                  <span>PDF PREVIEW • VERSION 1.0</span><span>Case #CASE-2026-089</span>
                </div>
                <div style="background:#fff;padding:10px;border-radius:6px;border:1px solid #E2E8F0;font-size:10px;color:#1E293B;line-height:1.4;">
                  <b>DATA CENTER SPECIALISTS SDN BHD</b><br/>
                  <i>(Company No. 202101039281 / 1429581-X)</i><br/>
                  <b>DIRECTORS' CIRCULAR RESOLUTION</b><br/>
                  IT IS HEREBY RESOLVED THAT Lim Wei Ming be appointed as a Director of the Company pursuant to Section 58 of the Companies Act 2016...
                </div>
              </div>
              <div style="display:flex;gap:8px;">
                <div style="flex:1;background:#15803D;color:#fff;text-align:center;padding:10px;border-radius:10px;font-weight:700;font-size:12px;">✓ Approve Resolution</div>
                <div style="flex:1;background:#FEE2E2;color:#DC2626;text-align:center;padding:10px;border-radius:10px;font-weight:700;font-size:12px;">✕ Reject with Reason</div>
              </div>
            </div>
            '''
        else:
            inner = '''
            <div style="padding:14px 16px;">
              <div style="background:#DCFCE7;border:1.5px solid #15803D;border-radius:12px;padding:14px;text-align:center;margin-bottom:12px;">
                <div style="font-size:22px;">✅</div>
                <div style="font-size:13px;font-weight:800;color:#15803D;">Resolution Approved & Recorded</div>
                <div style="font-size:10.5px;color:#166534;margin-top:4px;">Approved by Ahmad Razak • 28 Oct 2026, 10:42 AM</div>
              </div>
              <div style="font-size:11.5px;font-weight:800;color:#0F2D59;margin-bottom:6px;">Immutable Approval Audit History</div>
              <div class="audit-item"><b>10:42 AM</b> — Customer approved <i>Board_Resolution_S58.pdf</i> (v1.0)</div>
              <div class="audit-item"><b>10:15 AM</b> — Secretary Nurul Izzah uploaded prepared resolution for approval</div>
              <div class="audit-item"><b>09:50 AM</b> — Customer uploaded <i>Lim_Wei_Ming_NRIC.pdf</i> & <i>Form_S201.pdf</i></div>
            </div>
            '''
        phone = phone_shell(inner, active_tab=2)
        right_html = f'''
        <div style="background:#FFFFFF;border-radius:16px;padding:24px;border:1px solid #CBD5E1;box-shadow:0 8px 24px rgba(15,45,89,0.06);">
          <div style="font-size:12px;font-weight:800;color:#0A7E8C;letter-spacing:0.6px;margin-bottom:6px;">DOCUMENT & APPROVAL WORKFLOW</div>
          <div style="font-size:19px;font-weight:800;color:#0F2D59;margin-bottom:14px;">Zero Lost Attachments. 100% Timestamped Approvals.</div>
          <div class="pipeline-step {'active-pipe' if step==0 else ''}"><b>1. Structured Company Folders:</b> Every file is linked to its Company ID, Case ID, and version record—protected by role permissions.</div>
          <div class="pipeline-step {'active-pipe' if step==1 else ''}"><b>2. In-App Document Review:</b> Customers preview prepared resolutions and statutory forms right on their phone.</div>
          <div class="pipeline-step {'active-pipe' if step==2 else ''}"><b>3. Recorded Approval or Rejection:</b> Approving (or rejecting with a mandatory reason) logs the user identity, timestamp, and document version permanently.</div>
        </div>
        '''
        return f'''
        <div class="split-layout">
          <div class="left-phone-col">{phone}</div>
          <div class="right-info-col">{right_html}</div>
        </div>
        '''

    if scene_id == 5:
        # Side-by-side: Client Phone on Left + Secretary Web Workspace on Right!
        sec_reply = '<div class="chat-bubble ai" style="background:#E6F5F7;border-left:3px solid #0A7E8C;"><b>Nurul Izzah (Secretary):</b> Hi Ahmad, I have accepted your S58 case and verified Mr. Lim NRIC. Sending the Board Resolution now.</div>' if step >= 1 else ''
        cust_reply = '<div class="chat-bubble me">Thank you Nurul! I have just approved the Board Resolution in the app.</div><div style="background:#DCFCE7;padding:8px;border-radius:8px;font-size:10.5px;color:#15803D;font-weight:700;margin-top:6px;">✓ Case Status Updated: Completed & Lodged</div>' if step == 2 else ''
        inner = f'''
        <div style="padding:12px 16px;">
          <div style="font-size:12px;font-weight:800;color:#0F2D59;">Case #CASE-2026-089</div>
          <div style="font-size:10.5px;color:#0A7E8C;font-weight:700;margin-bottom:8px;">
            {'● Secretary Accepted — Human Chat Open' if step >= 1 else '● Queued with Apex Corporate Chambers'}
          </div>
          <div class="chat-bubble ai" style="font-size:10px;">AI Summary handed over to Licensed Secretary Nurul Izzah (LS0010492).</div>
          {sec_reply}
          {cust_reply}
        </div>
        '''
        phone = phone_shell(inner, active_tab=1)

        web_status = 'Pending Acceptance' if step == 0 else ('In Progress • Human Chat Open' if step == 1 else 'Completed ✓')
        web_badge_col = '#B45309' if step == 0 else ('#062AAE' if step == 1 else '#15803D')
        web_html = f'''
        <div class="browser-window">
          <div class="browser-bar">
            <div class="dots"><span></span><span></span><span></span></div>
            <div class="url-bar">🔒 workspace.mysect.com.my/cases/CASE-2026-089 — Secretary Firm Workspace</div>
          </div>
          <div class="browser-body">
            <div class="web-sidebar">
              <div style="font-weight:800;font-size:13px;color:#fff;margin-bottom:14px;">MySect Secretary</div>
              <div class="ws-item">📊 Dashboard</div>
              <div class="ws-item active">📥 New Requests (3)</div>
              <div class="ws-item">📋 Work Queue</div>
              <div class="ws-item">🏢 Companies (42)</div>
              <div class="ws-item">📅 Deadlines</div>
            </div>
            <div class="web-main">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
                <div>
                  <div style="font-size:15px;font-weight:800;color:#0F2D59;">Case #CASE-2026-089 — Section 58 Director Change</div>
                  <div style="font-size:11.5px;color:#64748B;">Company: Data Center Specialists Sdn Bhd (1429581-X) • Owner: Nurul Izzah</div>
                </div>
                <div style="background:{web_badge_col};color:#fff;padding:6px 12px;border-radius:20px;font-size:11px;font-weight:700;">{web_status}</div>
              </div>
              <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                <div style="background:#F8FAFC;border:1px solid #CBD5E1;border-radius:10px;padding:12px;">
                  <div style="font-size:11px;font-weight:800;color:#B45309;margin-bottom:6px;">🤖 AI-PREPARED INTAKE SUMMARY</div>
                  <div style="font-size:11.5px;color:#1E293B;line-height:1.45;">
                    • <b>Category:</b> S58 Appointment of Director<br/>
                    • <b>Appointee:</b> Lim Wei Ming (Eff. 1 Nov 2026)<br/>
                    • <b>Checklist:</b> NRIC ✓  |  S201 Consent ✓<br/>
                    • <b>Missing Info:</b> None — Ready for Resolution
                  </div>
                </div>
                <div style="background:#F8FAFC;border:1px solid #CBD5E1;border-radius:10px;padding:12px;">
                  <div style="font-size:11px;font-weight:800;color:#0A7E8C;margin-bottom:6px;">⚡ SECRETARY CASE ACTIONS</div>
                  <div class="web-btn {'done' if step>=1 else 'active'}">1. Accept Case Ownership & Open Chat</div>
                  <div class="web-btn {'done' if step>=2 else ('active' if step==1 else '')}">2. Upload Draft Resolution for Approval</div>
                  <div class="web-btn {'active' if step==2 else ''}">3. Record SSM Reference & Complete Case</div>
                </div>
              </div>
              <div style="margin-top:12px;background:#EBF4FA;border-radius:10px;padding:10px 14px;font-size:11.5px;color:#0F2D59;">
                <b>Live Sync with Client Mobile App:</b> {'Customer approved Board_Resolution_S58.pdf at 10:42 AM. Case marked Completed!' if step==2 else 'Every action taken by the Secretary updates the Customer Mobile App in real time.'}
              </div>
            </div>
          </div>
        </div>
        '''
        return f'''
        <div class="split-layout">
          <div class="left-phone-col">{phone}</div>
          <div class="right-info-col">{web_html}</div>
        </div>
        '''

    # Scene 6: Admin Governance + 3-Product Closing
    if step < 2:
        return f'''
        <div style="display:grid;grid-template-columns:1.35fr 1fr;gap:24px;align-items:center;height:100%;">
          <div class="browser-window">
            <div class="browser-bar">
              <div class="dots"><span></span><span></span><span></span></div>
              <div class="url-bar">🔒 admin.mysect.com.my — MySect Internal Platform Operations</div>
            </div>
            <div class="browser-body">
              <div class="web-sidebar" style="background:#091D3A;">
                <div style="font-weight:800;font-size:13px;color:#fff;margin-bottom:14px;">MySect Admin</div>
                <div class="ws-item active">🏛 Platform Overview</div>
                <div class="ws-item">🤝 Secretary Firms</div>
                <div class="ws-item">🏢 Companies & Mapping</div>
                <div class="ws-item">🛡 Audit & Security</div>
              </div>
              <div class="web-main">
                <div style="font-size:15px;font-weight:800;color:#0F2D59;margin-bottom:10px;">Platform Governance & Multi-Firm Oversight</div>
                <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:12px;">
                  <div class="kpi-mini"><b>18</b><span>Partner Secretary Firms</span></div>
                  <div class="kpi-mini"><b>640+</b><span>Managed Companies</span></div>
                  <div class="kpi-mini"><b>100%</b><span>Tenant Data Isolation</span></div>
                </div>
                <div style="background:#F8FAFC;border:1px solid #CBD5E1;border-radius:10px;padding:10px;font-size:11px;color:#1E293B;">
                  <div style="font-weight:800;color:#0F2D59;margin-bottom:6px;">Active Partner Secretary Firm Assignments</div>
                  <div style="display:flex;justify-content:space-between;padding:5px 0;border-bottom:1px solid #E2E8F0;"><span><b>Apex Corporate Chambers Sdn Bhd</b> (LS0010492)</span><span style="color:#15803D;font-weight:700;">42 Companies • Active</span></div>
                  <div style="display:flex;justify-content:space-between;padding:5px 0;border-bottom:1px solid #E2E8F0;"><span><b>Metro Secretarial Services Sdn Bhd</b> (LS0009821)</span><span style="color:#15803D;font-weight:700;">58 Companies • Active</span></div>
                  <div style="display:flex;justify-content:space-between;padding:5px 0;"><span><b>Integrity CoSec Partners PLT</b> (LS0011204)</span><span style="color:#15803D;font-weight:700;">35 Companies • Active</span></div>
                </div>
              </div>
            </div>
          </div>
          <div style="display:flex;flex-direction:column;gap:14px;">
            <div class="pillar-card" style="border-left:5px solid #1D6FA5;">
              <div style="font-size:15px;font-weight:800;color:#0F2D59;">1. Customer Mobile App (Flutter)</div>
              <div style="font-size:12.5px;color:#475569;">Guided Ask MySect intake, document uploads, formal approvals & live tracking.</div>
            </div>
            <div class="pillar-card" style="border-left:5px solid #0A7E8C;">
              <div style="font-size:15px;font-weight:800;color:#0F2D59;">2. Secretary Firm Website</div>
              <div style="font-size:12.5px;color:#475569;">AI-prepared case queue, unified case workspace, human chat & deadline management.</div>
            </div>
            <div class="pillar-card" style="border-left:5px solid #0F2D59;">
              <div style="font-size:15px;font-weight:800;color:#0F2D59;">3. MySect Admin Website</div>
              <div style="font-size:12.5px;color:#475569;">Partner firm onboarding, company assignments, escalation support & audit trail.</div>
            </div>
          </div>
        </div>
        '''
    else:
        return f'''
        <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;text-align:center;background:linear-gradient(135deg,#FFFFFF 0%,#EBF4FA 100%);border-radius:20px;border:1px solid #CBD5E1;padding:36px;">
          <img src="{LOGO_URI}" style="width:240px;margin-bottom:16px;" />
          <div style="font-size:32px;font-weight:900;color:#0F2D59;margin-bottom:8px;">One Shared Platform. Three Connected Products.</div>
          <div style="font-size:16px;color:#475569;max-width:820px;margin-bottom:24px;">
            Proving one complete, secure end-to-end corporate secretarial workflow in 12 weeks—from guided customer intake to licensed Secretary completion and Admin oversight.
          </div>
          <div style="display:flex;gap:20px;">
            <div class="closing-badge">📱 Customer Mobile App</div>
            <div class="closing-badge">💻 Secretary Firm Website</div>
            <div class="closing-badge">🛡 MySect Admin Website</div>
          </div>
        </div>
        '''

def render_all_frames(metadata):
    total_scenes = len(metadata)
    for sc in metadata:
        sid = sc['id']
        for step in range(3):
            body_html = build_step_content(sid, step)
            progress_pct = ((sid - 1 + (step + 1) / 3.0) / total_scenes) * 100.0
            html = f'''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }}
  body {{
    width: 1920px;
    height: 1080px;
    overflow: hidden;
    background: #F1F5F9;
    display: flex;
    flex-direction: column;
  }}
  .top-ribbon {{
    height: 8px;
    width: 100%;
    background: linear-gradient(90deg, #0F2D59 0%, #1D6FA5 65%, #0A7E8C 100%);
  }}
  .stage-header {{
    height: 108px;
    padding: 18px 56px 10px 56px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #FFFFFF;
    border-bottom: 1px solid #E2E8F0;
  }}
  .stage-tag {{
    font-size: 13px;
    font-weight: 800;
    color: #0A7E8C;
    letter-spacing: 1px;
    margin-bottom: 4px;
  }}
  .stage-title {{
    font-size: 28px;
    font-weight: 900;
    color: #0F2D59;
  }}
  .stage-sub {{
    font-size: 15px;
    color: #64748B;
    margin-top: 2px;
  }}
  .stage-main {{
    flex: 1;
    padding: 28px 56px;
    overflow: hidden;
  }}
  .split-layout {{
    display: grid;
    grid-template-columns: 420px 1fr;
    gap: 44px;
    height: 100%;
    align-items: center;
  }}
  .left-phone-col {{
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
  }}
  .right-info-col {{
    display: flex;
    flex-direction: column;
    justify-content: center;
    height: 100%;
  }}
  .iphone-frame {{
    width: 380px;
    height: 760px;
    background: #FFFFFF;
    border-radius: 44px;
    border: 10px solid #0F172A;
    box-shadow: 0 24px 50px rgba(15, 23, 42, 0.22);
    position: relative;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }}
  .splash-bg {{
    background: linear-gradient(180deg, #FFFFFF 0%, #EBF4FA 100%);
  }}
  .iphone-notch {{
    width: 110px;
    height: 20px;
    background: #0F172A;
    border-radius: 0 0 14px 14px;
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    z-index: 10;
  }}
  .iphone-statusbar {{
    height: 28px;
    background: #062AAE;
    color: #FFFFFF;
    font-size: 10.5px;
    font-weight: 700;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 4px 20px 0 20px;
  }}
  .app-top-header {{
    height: 52px;
    background: #062AAE;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 18px;
    border-bottom-left-radius: 16px;
    border-bottom-right-radius: 16px;
  }}
  .header-logo-pill {{
    background: #FFFFFF;
    padding: 4px 12px;
    border-radius: 16px;
    display: flex;
    align-items: center;
  }}
  .header-logo-pill img {{
    height: 22px;
  }}
  .header-bell {{
    color: #FFFFFF;
    font-size: 16px;
    position: relative;
  }}
  .bell-dot {{
    width: 7px;
    height: 7px;
    background: #EF4444;
    border-radius: 50%;
    position: absolute;
    top: 0;
    right: -2px;
  }}
  .iphone-body {{
    flex: 1;
    overflow: hidden;
    background: #FFFFFF;
  }}
  .iphone-bottom-nav {{
    height: 58px;
    background: #062AAE;
    margin: 8px 12px 10px 12px;
    border-radius: 28px;
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 0 8px;
  }}
  .nav-item {{
    color: rgba(255,255,255,0.65);
    font-size: 9.5px;
    font-weight: 600;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
  }}
  .nav-item.active {{
    color: #FFFFFF;
    background: rgba(255,255,255,0.18);
    padding: 5px 11px;
    border-radius: 18px;
  }}
  .nav-ico {{ font-size: 13px; }}
  .input-mock {{
    background: #F8FAFC;
    border: 1.5px solid #CBD5E1;
    border-radius: 10px;
    padding: 9px 12px;
    margin-bottom: 10px;
  }}
  .input-mock .lbl {{ font-size: 9.5px; color: #64748B; font-weight: 700; display: block; margin-bottom: 2px; }}
  .input-mock .val {{ font-size: 12px; color: #0F172A; font-weight: 600; }}
  .btn-primary-Tap {{
    background: #062AAE;
    color: #FFFFFF;
    text-align: center;
    padding: 11px;
    border-radius: 12px;
    font-weight: 700;
    font-size: 12.5px;
    position: relative;
    box-shadow: 0 6px 16px rgba(6,42,174,0.28);
  }}
  .comp-selector {{
    background: #F8FAFC;
    border: 1.5px solid #CBD5E1;
    border-radius: 12px;
    padding: 10px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 4px;
  }}
  .active-ring {{
    border: 2px solid #062AAE !important;
    box-shadow: 0 0 0 4px rgba(6,42,174,0.14);
  }}
  .action-grid {{
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-top: 8px;
  }}
  .action-card {{
    padding: 12px;
    border-radius: 14px;
    border: 1px solid #CBD5E1;
  }}
  .action-card.warn {{ background: #FEF3C7; border-color: #F59E0B; }}
  .action-card.info {{ background: #EBF4FA; border-color: #1D6FA5; }}
  .ac-num {{ font-size: 24px; font-weight: 900; color: #0F2D59; }}
  .ac-title {{ font-size: 11.5px; font-weight: 800; color: #0F2D59; margin-top: 2px; }}
  .ac-sub {{ font-size: 9.8px; color: #475569; margin-top: 2px; }}
  .sec-firm-banner {{
    margin-top: 12px;
    background: #E6F5F7;
    border: 1px solid #0A7E8C;
    border-radius: 12px;
    padding: 10px 12px;
  }}
  .dropdown-menu {{
    background: #FFFFFF;
    border: 1.5px solid #062AAE;
    border-radius: 12px;
    margin-top: 6px;
    overflow: hidden;
  }}
  .dd-item {{
    padding: 9px 12px;
    font-size: 11px;
    font-weight: 600;
    color: #1E293B;
    border-bottom: 1px solid #E2E8F0;
    display: flex;
    justify-content: space-between;
  }}
  .dd-item.selected {{ background: #EBF4FA; color: #062AAE; font-weight: 800; }}
  .dd-tag {{ font-size: 9.5px; background: #F1F5F9; padding: 2px 6px; border-radius: 8px; color: #475569; }}
  .task-row {{
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 9px 10px;
    background: #F8FAFC;
    border: 1px solid #E2E8F0;
    border-radius: 10px;
    margin-top: 7px;
  }}
  .dot-amber {{ width: 9px; height: 9px; border-radius: 50%; background: #F59E0B; }}
  .dot-blue {{ width: 9px; height: 9px; border-radius: 50%; background: #062AAE; }}
  .pill-warn {{ background: #FEF3C7; color: #B45309; font-size: 9.5px; font-weight: 800; padding: 3px 8px; border-radius: 10px; }}
  .pill-info {{ background: #DBEAFE; color: #1E40AF; font-size: 9.5px; font-weight: 800; padding: 3px 8px; border-radius: 10px; }}
  .pill-ok {{ background: #DCFCE7; color: #15803D; font-size: 9.5px; font-weight: 800; padding: 3px 8px; border-radius: 10px; }}
  .cal-box {{ background: #F8FAFC; border: 1px solid #CBD5E1; border-radius: 12px; padding: 10px; }}
  .cal-grid {{ display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; text-align: center; font-size: 10.5px; color: #475569; }}
  .cal-today {{ background: #062AAE; color: #fff; border-radius: 6px; font-weight: 800; padding: 2px 0; }}
  .cal-due {{ background: #FEF3C7; color: #B45309; border-radius: 6px; font-weight: 800; padding: 2px 0; }}
  .date-badge {{ background: #EBF4FA; color: #0F2D59; font-size: 9px; text-align: center; padding: 4px 7px; border-radius: 8px; line-height: 1.1; }}
  .chat-bubble {{ padding: 9px 12px; border-radius: 12px; font-size: 11px; line-height: 1.4; margin-top: 8px; }}
  .chat-bubble.ai {{ background: #F1F5F9; color: #1E293B; border-bottom-left-radius: 3px; }}
  .chat-bubble.me {{ background: #062AAE; color: #FFFFFF; border-bottom-right-radius: 3px; margin-left: 24px; }}
  .check-row {{ padding: 8px 10px; border-radius: 8px; background: #F8FAFC; border: 1px solid #CBD5E1; font-size: 10.5px; margin-bottom: 6px; color: #334155; font-weight: 600; }}
  .check-row.done {{ background: #DCFCE7; border-color: #15803D; color: #166534; }}
  .pipeline-step {{ padding: 13px 16px; border-radius: 10px; background: #F8FAFC; border: 1px solid #E2E8F0; font-size: 13.5px; color: #334155; margin-bottom: 10px; line-height: 1.45; }}
  .pipeline-step.active-pipe {{ background: #FEF3C7; border: 2px solid #B45309; color: #0F2D59; }}
  .folder-card {{ display: flex; justify-content: space-between; align-items: center; padding: 12px; border-radius: 12px; background: #FEF3C7; border: 1.5px solid #F59E0B; margin-bottom: 12px; }}
  .folder-badge.warn {{ background: #B45309; color: #fff; font-weight: 800; font-size: 12px; padding: 4px 10px; border-radius: 12px; }}
  .folder-grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }}
  .folder-box {{ background: #F8FAFC; border: 1px solid #CBD5E1; border-radius: 12px; padding: 12px; display: flex; flex-direction: column; gap: 4px; font-size: 12px; color: #0F2D59; }}
  .folder-box span {{ font-size: 10px; color: #64748B; }}
  .audit-item {{ padding: 8px 10px; border-left: 3px solid #062AAE; background: #F8FAFC; font-size: 10.5px; color: #334155; margin-bottom: 6px; border-radius: 0 8px 8px 0; }}
  .browser-window {{ background: #FFFFFF; border-radius: 16px; border: 1.5px solid #94A3B8; box-shadow: 0 18px 40px rgba(15, 23, 42, 0.14); overflow: hidden; height: 500px; display: flex; flex-direction: column; }}
  .browser-bar {{ height: 36px; background: #1E293B; display: flex; align-items: center; padding: 0 14px; gap: 14px; }}
  .dots {{ display: flex; gap: 6px; }}
  .dots span {{ width: 10px; height: 10px; border-radius: 50%; background: #64748B; }}
  .dots span:nth-child(1) {{ background: #EF4444; }}
  .dots span:nth-child(2) {{ background: #F59E0B; }}
  .dots span:nth-child(3) {{ background: #22C55E; }}
  .url-bar {{ background: #0F172A; color: #CBD5E1; font-size: 11px; padding: 4px 14px; border-radius: 6px; flex: 1; }}
  .browser-body {{ flex: 1; display: grid; grid-template-columns: 175px 1fr; }}
  .web-sidebar {{ background: #0F2D59; padding: 16px 12px; color: #CBD5E1; }}
  .ws-item {{ padding: 8px 10px; border-radius: 8px; font-size: 11.5px; margin-bottom: 4px; font-weight: 600; }}
  .ws-item.active {{ background: #0A7E8C; color: #FFFFFF; }}
  .web-main {{ padding: 18px 20px; background: #FFFFFF; }}
  .web-btn {{ padding: 8px 10px; border-radius: 8px; background: #FFFFFF; border: 1px solid #CBD5E1; font-size: 11px; font-weight: 700; color: #475569; margin-bottom: 6px; }}
  .web-btn.active {{ background: #062AAE; color: #FFFFFF; border-color: #062AAE; }}
  .web-btn.done {{ background: #DCFCE7; color: #15803D; border-color: #15803D; }}
  .kpi-mini {{ background: #EBF4FA; border: 1px solid #BFDBFE; border-radius: 10px; padding: 10px; text-align: center; }}
  .kpi-mini b {{ font-size: 20px; color: #0F2D59; display: block; }}
  .kpi-mini span {{ font-size: 10.5px; color: #475569; font-weight: 600; }}
  .pillar-card {{ background: #FFFFFF; padding: 18px 20px; border-radius: 12px; box-shadow: 0 4px 14px rgba(15,45,89,0.06); border: 1px solid #E2E8F0; }}
  .closing-badge {{ background: #0F2D59; color: #FFFFFF; padding: 14px 26px; border-radius: 30px; font-size: 16px; font-weight: 800; box-shadow: 0 8px 20px rgba(15,45,89,0.18); }}
  .caption-footer {{
    height: 110px;
    background: #091D3A;
    color: #FFFFFF;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 16px 56px 14px 56px;
  }}
  .caption-text {{
    font-size: 18.5px;
    font-weight: 600;
    color: #F8FAFC;
    text-align: center;
    line-height: 1.35;
  }}
  .progress-wrap {{
    display: flex;
    align-items: center;
    gap: 16px;
    font-size: 12px;
    color: #94A3B8;
    font-weight: 700;
  }}
  .progress-track {{
    flex: 1;
    height: 6px;
    background: rgba(255,255,255,0.16);
    border-radius: 3px;
    overflow: hidden;
  }}
  .progress-fill {{
    width: {progress_pct:.1f}%;
    height: 100%;
    background: linear-gradient(90deg, #38BDF8 0%, #2DD4BF 100%);
  }}
</style>
</head>
<body>
  <div class="top-ribbon"></div>
  <div class="stage-header">
    <div>
      <div class="stage-tag">{sc['tag']}</div>
      <div class="stage-title">{sc['title']}</div>
      <div class="stage-sub">{sc['subtitle']}</div>
    </div>
    <img src="{LOGO_URI}" style="height:56px;" />
  </div>
  <div class="stage-main">
    {body_html}
  </div>
  <div class="caption-footer">
    <div class="caption-text">“{sc['caption']}”</div>
    <div class="progress-wrap">
      <span>MYSECT PLATFORM PITCH  •  SCENE {sid} OF {total_scenes}</span>
      <div class="progress-track"><div class="progress-fill"></div></div>
      <span>3-MONTH MVP BLUEPRINT</span>
    </div>
  </div>
</body>
</html>'''
            html_file = HTML_DIR / f'scene_{sid}_step_{step}.html'
            png_file = FRAMES_DIR / f'scene_{sid}_step_{step}.png'
            html_file.write_text(html, encoding='utf-8')
            subprocess.run([
                CHROME,
                '--headless',
                '--disable-gpu',
                '--hide-scrollbars',
                '--window-size=1920,1080',
                f'--screenshot={png_file}',
                f'file://{html_file}'
            ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f'Rendered {png_file.name}')

if __name__ == '__main__':
    meta = generate_audio()
    render_all_frames(meta)
    print('All audio and frames ready!')
