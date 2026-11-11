#!/usr/bin/env python3
"""
Generate executive-tier PDF for MYSECT_PROJECT_REQUIREMENTS.pdf
Using ReportLab with custom page templates, corporate branding, and polished styling.
"""

from pathlib import Path
import os
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, Image, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

ROOT = Path('/Users/marketingdeveloper/DCStack_Development/MySect')
PDF_OUTPUT = ROOT / 'Documentation/MYSECT_PROJECT_REQUIREMENTS.pdf'
LOGO_PATH = ROOT / 'mysect_admin/public/mysect_main_logo.png'
ICON_PATH = ROOT / 'mysect_admin/public/mysect_logo.png'

# Color Palette (MySect Corporate Theme)
NAVY_PRIMARY = colors.HexColor('#0F2D59')
NAVY_DARK = colors.HexColor('#091D3A')
NAVY_LIGHT = colors.HexColor('#EBF3FA')
BLUE_ACCENT = colors.HexColor('#1D6FA5')
BLUE_LIGHT = colors.HexColor('#EBF4FA')
TEAL_ACCENT = colors.HexColor('#0A7E8C')
TEAL_LIGHT = colors.HexColor('#E6F5F7')
AMBER_ACCENT = colors.HexColor('#D97706')
AMBER_LIGHT = colors.HexColor('#FEF3C7')
GREEN_ACCENT = colors.HexColor('#15803D')
GREEN_LIGHT = colors.HexColor('#DCFCE7')
RED_ACCENT = colors.HexColor('#B91C1C')
RED_LIGHT = colors.HexColor('#FEE2E2')
SLATE_BG = colors.HexColor('#F8FAFC')
SLATE_ALT = colors.HexColor('#F1F5F9')
BORDER_COLOR = colors.HexColor('#CBD5E1')
BORDER_LIGHT = colors.HexColor('#E2E8F0')
TEXT_PRIMARY = colors.HexColor('#1E293B')
TEXT_MUTED = colors.HexColor('#64748B')
WHITE = colors.white

PAGE_W, PAGE_H = A4
MARGIN_X = 14 * mm
MARGIN_Y = 15 * mm
CONTENT_W = PAGE_W - (2 * MARGIN_X)  # ~515 pt


class NumberedCanvas(canvas.Canvas):
    """
    Two-pass canvas to dynamically compute and draw 'Page X of Y',
    along with running headers and running footers.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            # Suppress running headers and footers on cover page
            return

        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(NAVY_PRIMARY)

        # Running Header
        self.drawString(MARGIN_X, PAGE_H - 11.5 * mm, "MYSECT ENTERPRISE PLATFORM")
        self.setFont("Helvetica", 8)
        self.setFillColor(TEXT_MUTED)
        self.drawRightString(PAGE_W - MARGIN_X, PAGE_H - 11.5 * mm, "Requirements & Architectural Blueprint (v2.0)")

        # Thin header rule
        self.setStrokeColor(BORDER_LIGHT)
        self.setLineWidth(0.75)
        self.line(MARGIN_X, PAGE_H - 13 * mm, PAGE_W - MARGIN_X, PAGE_H - 13 * mm)

        # Running Footer
        self.setStrokeColor(BORDER_LIGHT)
        self.setLineWidth(0.75)
        self.line(MARGIN_X, 12 * mm, PAGE_W - MARGIN_X, 12 * mm)

        self.setFont("Helvetica", 8)
        self.setFillColor(TEXT_MUTED)
        self.drawString(MARGIN_X, 8 * mm, "CONFIDENTIAL — STRICTLY FOR INTERNAL & STAKEHOLDER REVIEW")

        page_str = f"Page {self._pageNumber} of {page_count}"
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(NAVY_PRIMARY)
        self.drawRightString(PAGE_W - MARGIN_X, 8 * mm, page_str)

        self.restoreState()


def build_pdf():
    doc = SimpleDocTemplate(
        str(PDF_OUTPUT),
        pagesize=A4,
        leftMargin=MARGIN_X,
        rightMargin=MARGIN_X,
        topMargin=MARGIN_Y,
        bottomMargin=MARGIN_Y,
    )

    base_styles = getSampleStyleSheet()

    style_cover_title = ParagraphStyle(
        'CoverTitle',
        parent=base_styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=25,
        leading=30,
        textColor=NAVY_DARK,
        spaceAfter=5,
    )

    style_cover_subtitle = ParagraphStyle(
        'CoverSubtitle',
        parent=base_styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=BLUE_ACCENT,
        spaceAfter=12,
    )

    style_h1 = ParagraphStyle(
        'Header1',
        parent=base_styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13.5,
        leading=17,
        textColor=NAVY_PRIMARY,
        spaceBefore=11,
        spaceAfter=4,
        keepWithNext=True,
    )

    style_h2 = ParagraphStyle(
        'Header2',
        parent=base_styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=BLUE_ACCENT,
        spaceBefore=8,
        spaceAfter=3,
        keepWithNext=True,
    )

    style_body = ParagraphStyle(
        'BodyDark',
        parent=base_styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12.2,
        textColor=TEXT_PRIMARY,
        spaceAfter=5,
    )

    style_body_bold = ParagraphStyle(
        'BodyBold',
        parent=style_body,
        fontName='Helvetica-Bold',
    )

    style_body_muted = ParagraphStyle(
        'BodyMuted',
        parent=style_body,
        fontSize=8,
        leading=11,
        textColor=TEXT_MUTED,
    )

    style_bullet = ParagraphStyle(
        'CustomBullet',
        parent=style_body,
        leftIndent=10,
        bulletIndent=2,
        spaceAfter=3,
    )

    style_callout_text = ParagraphStyle(
        'CalloutText',
        parent=base_styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=NAVY_DARK,
    )

    style_table_cell = ParagraphStyle(
        'TableCell',
        parent=base_styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10.2,
        textColor=TEXT_PRIMARY,
    )

    style_table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=style_table_cell,
        fontName='Helvetica-Bold',
        textColor=NAVY_DARK,
    )

    style_table_header = ParagraphStyle(
        'TableHeader',
        parent=base_styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=11,
        textColor=WHITE,
    )

    story = []

    # =========================================================================
    # COVER PAGE
    # =========================================================================
    story.append(Spacer(1, 6 * mm))

    if LOGO_PATH.exists():
        img = Image(str(LOGO_PATH), width=56 * mm, height=36 * mm)
        img.hAlign = 'LEFT'
        story.append(img)
    else:
        story.append(Paragraph("<b>MySect</b>", style_cover_title))

    story.append(Spacer(1, 6 * mm))

    story.append(Paragraph("MYSECT ENTERPRISE PLATFORM", style_cover_title))
    story.append(Paragraph("Comprehensive Project Requirements & Architectural Blueprint", style_cover_subtitle))

    story.append(HRFlowable(width="100%", thickness=2.5, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=10))

    exec_summary_html = """
    <b>Executive Mission:</b> MySect is a regulatory-compliant digital platform engineered to modernize and automate 
    the Malaysian corporate secretarial (CoSec) industry under the <b>Companies Act 2016</b> and <b>Suruhanjaya Syarikat Malaysia (SSM)</b> guidelines. 
    This blueprint establishes production technical specifications, role-separated client applications, dedicated backend security gatekeeper, 
    on-premise/hybrid AI reasoning gateway, and a phased 12-week implementation schedule.
    """
    exec_table = Table(
        [[Paragraph(exec_summary_html, style_callout_text)]],
        colWidths=[CONTENT_W]
    )
    exec_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), NAVY_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BLUE_ACCENT),
        ('LINEBEFORE', (0, 0), (0, -1), 4, NAVY_PRIMARY),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(exec_table)
    story.append(Spacer(1, 6 * mm))

    meta_data = [
        [
            Paragraph("<b>Document Reference:</b>", style_table_cell_bold),
            Paragraph("SEC-REQ-2026-V2", style_table_cell),
            Paragraph("<b>Target Delivery:</b>", style_table_cell_bold),
            Paragraph("Q1 2027 (12-Week MVP)", style_table_cell),
        ],
        [
            Paragraph("<b>Effective Date:</b>", style_table_cell_bold),
            Paragraph("9 November 2026", style_table_cell),
            Paragraph("<b>Platform Scope:</b>", style_table_cell_bold),
            Paragraph("Client Mobile, Secretary Web/Desktop, Admin Web", style_table_cell),
        ],
        [
            Paragraph("<b>Classification:</b>", style_table_cell_bold),
            Paragraph("<font color='#B91C1C'><b>STRICTLY CONFIDENTIAL</b></font>", style_table_cell),
            Paragraph("<b>Infrastructure Host:</b>", style_table_cell_bold),
            Paragraph("Windows Server (Docker / Linux Containers)", style_table_cell),
        ],
        [
            Paragraph("<b>Primary Database:</b>", style_table_cell_bold),
            Paragraph("Self-Hosted MySQL 8.4 LTS", style_table_cell),
            Paragraph("<b>AI Gateway Engine:</b>", style_table_cell_bold),
            Paragraph("Local OSS (DeepSeek / Qwen) + Cloud API Adapter", style_table_cell),
        ],
    ]
    meta_table = Table(meta_data, colWidths=[38 * mm, 52 * mm, 38 * mm, 53 * mm])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), SLATE_BG),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)

    story.append(Spacer(1, 6 * mm))

    # Architecture Overview Callout Block
    arch_block_html = """
    <b>Core Ecosystem Architecture:</b><br/>
    • <b>Client Tier:</b> Flutter Mobile (Client) • Flutter Desktop/Web (Secretary) • React/Vite (Admin)<br/>
    • <b>Network & Security:</b> Caddy/Nginx Reverse Proxy • TLS 1.3 • HSTS • WebSockets • Rate Limiter<br/>
    • <b>Application Tier:</b> Unified Core Backend (<code>mysect_backend</code>) with Strict Multi-Tenant RBAC<br/>
    • <b>Data & Storage:</b> Dedicated MySQL 8.4 LTS (<code>mysect_database</code>) • Pluggable Storage Adapter (<code>mysect_storage</code>)<br/>
    • <b>AI Intelligence:</b> Provider-Agnostic LLM Gateway (Local Ollama: DeepSeek-R1 / Qwen 2.5 & Cloud Gemini Flash)
    """
    arch_box = Table([[Paragraph(arch_block_html, style_callout_text)]], colWidths=[CONTENT_W])
    arch_box.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), SLATE_ALT),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('LINEBEFORE', (0, 0), (0, -1), 4, BLUE_ACCENT),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(arch_box)

    story.append(Spacer(1, 6 * mm))
    stakeholder_html = """
    <b>Intended Stakeholders:</b> Project Owner, Executive Board, Lead Architect, Frontend Engineering Team (Flutter & React), 
    Backend Engineering Team, Compliance Advisors, and Partner Secretarial Firms (MAICSA / MIA).
    """
    story.append(Paragraph(stakeholder_html, style_body_muted))

    story.append(PageBreak())

    # =========================================================================
    # SECTION 1: ARCHITECTURAL STRATEGY & DESIGN JUSTIFICATION
    # =========================================================================
    story.append(Paragraph("1. Architectural Strategy & Design Justification", style_h1))
    story.append(HRFlowable(width="100%", thickness=1, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=6))

    story.append(Paragraph(
        "A critical engineering question for stakeholders is: <i>Why was this specific multi-role, hybrid architecture chosen over a generic monolith?</i> "
        "The MySect architecture separates concerns across three role-specific clients, a unified security-enforcing backend, a relational database, "
        "and a decoupled object storage adapter.",
        style_body
    ))

    story.append(Paragraph("1.1 The Tri-Frontend Topology", style_h2))
    frontend_table_data = [
        [
            Paragraph("System Product", style_table_header),
            Paragraph("Technology Stack", style_table_header),
            Paragraph("Target Form Factor", style_table_header),
            Paragraph("Architectural & UX Justification", style_table_header),
        ],
        [
            Paragraph("<b>Customer App</b><br/>(<code>mysect_app</code>)", style_table_cell_bold),
            Paragraph("Flutter 3.x (Dart)", style_table_cell),
            Paragraph("iOS & Android Native Mobile", style_table_cell),
            Paragraph("<b>Executive Velocity:</b> Company owners and directors operate primarily on mobile. They require instant push alerts for statutory deadlines, rapid biometrics, and one-tap document approvals without complex tabular navigation.", style_table_cell),
        ],
        [
            Paragraph("<b>Secretary Workspace</b><br/>(<code>mysect_secretary</code>)", style_table_cell_bold),
            Paragraph("Flutter 3.x Desktop & Responsive Web", style_table_cell),
            Paragraph("macOS, Windows Desktop & Tablet", style_table_cell),
            Paragraph("<b>Data-Dense Operational Throughput:</b> Licensed secretaries review multi-page statutory PDF lodgements (Section 68, Form 24/49, M&A constitutions), side-by-side dossiers, and manage queues across dozens of companies. Desktop screen real-estate is non-negotiable.", style_table_cell),
        ],
        [
            Paragraph("<b>Admin Portal</b><br/>(<code>mysect_admin</code>)", style_table_cell_bold),
            Paragraph("React 18 + Vite, TailwindCSS", style_table_cell),
            Paragraph("Desktop Web Browsers", style_table_cell),
            Paragraph("<b>Rapid Governance & Audit:</b> Super-admin operations require dynamic charting, role auditing, firm verification, and subscription tracking. React/Vite provides rapid iteration and static web hosting behind Nginx.", style_table_cell),
        ],
    ]
    frontend_table = Table(frontend_table_data, colWidths=[36 * mm, 32 * mm, 35 * mm, 78 * mm])
    frontend_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(frontend_table)
    story.append(Spacer(1, 3 * mm))

    story.append(Paragraph("1.2 Central Unified Backend Gatekeeper (<code>mysect_backend</code>)", style_h2))
    story.append(Paragraph(
        "All client applications communicate exclusively with a single centralized REST & WebSocket API (<code>/api/v1/*</code>). "
        "<b>Direct database access from any client is strictly prohibited.</b> The backend enforces three vital security barriers:",
        style_body
    ))
    story.append(Paragraph("• <b>Cryptographic Multi-Tenant Isolation:</b> Every incoming request verifies the user's authenticated firm and company mapping. No company can access another firm's statutory records.", style_bullet))
    story.append(Paragraph("• <b>Fine-Grained Role-Based Access Control (RBAC):</b> Strict role gates separate Platform Super-Admins, Firm Managing Secretaries, Staff Reviewers, and Company Directors.", style_bullet))
    story.append(Paragraph("• <b>Statutory State Machine:</b> Document approval transitions, filing statuses, and lodgement timestamps are validated server-side to prevent illegal or out-of-order statutory submissions.", style_bullet))

    story.append(Paragraph("1.3 Relational Database Strategy: Dedicated MySQL 8.4 LTS (<code>mysect_database</code>)", style_h2))
    story.append(Paragraph(
        "Corporate secretarial administration is strictly relational under the Malaysian <b>Companies Act 2016</b>. "
        "Every company profile, director appointment, share distribution, and annual return requires ACID transaction compliance and rigid foreign-key relationships. "
        "<b>Self-hosted MySQL 8.4 LTS</b> provides lightweight predictability, low memory footprint on Windows Server virtual environments, and automated point-in-time binary logging. "
        "<i>Note: phpMyAdmin is categorized strictly as an internal development tool and is never deployed to public endpoints.</i>",
        style_body
    ))

    story.append(Paragraph("1.4 Private Document Storage Adapter (<code>mysect_storage</code>)", style_h2))
    story.append(Paragraph(
        "Storing binary statutory PDFs (e.g. Form 9, Section 14, Board Resolutions, Director NRIC scans) directly in MySQL causes severe database bloat and slow backups. "
        "MySect uses an abstracted <b>Storage Adapter Pattern</b>: MySQL stores only metadata (SHA-256 hash, byte size, MIME type, upload timestamp, and opaque UUID). "
        "The underlying storage provider is pluggable: Local Private Encrypted Disk for Staging/Pilot, migrating seamlessly to <b>TM Cloud Object Storage / MinIO (S3-compatible)</b> for production. "
        "Files are accessed exclusively via <b>5-minute time-limited pre-signed URLs</b>.",
        style_body
    ))

    story.append(Paragraph("1.5 Deployment Architecture on Windows Server Host", style_h2))
    story.append(Paragraph(
        "The production environment runs on the existing enterprise Windows Server host using a supported Linux container arrangement (WSL2 with Ubuntu LTS or dedicated Hyper-V Linux VM running Docker CE Engine). "
        "Docker Desktop is prohibited for production runtime. A reverse proxy (Caddy / Nginx) handles TLS 1.3 termination, HSTS enforcement, rate-limiting, and WebSocket connection upgrades.",
        style_body
    ))

    story.append(PageBreak())

    # =========================================================================
    # SECTION 2: ARTIFICIAL INTELLIGENCE STRATEGY & ECONOMIC MODEL
    # =========================================================================
    story.append(Paragraph("2. Artificial Intelligence Strategy & Economic Model", style_h1))
    story.append(HRFlowable(width="100%", thickness=1, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=6))

    story.append(Paragraph(
        "A central requirement is identifying the appropriate AI model, pricing tiers, and infrastructure footprint—evaluating "
        "<b>Cloud Managed APIs (Google Gemini, DeepSeek API)</b> against <b>Local / On-Premise Open-Source AI (DeepSeek-R1 Distill, Qwen 2.5, Gemma 2)</b>. "
        "The AI subsystem acts as an automated intake and triage assistant, preparing structured dossiers for human secretary review.",
        style_body
    ))

    story.append(Paragraph("2.1 Model Evaluation & Cost Comparison Matrix", style_h2))
    ai_table_data = [
        [
            Paragraph("Model & Engine", style_table_header),
            Paragraph("Deployment Tier", style_table_header),
            Paragraph("Token Pricing (Cloud)", style_table_header),
            Paragraph("Hardware Needed (Local)", style_table_header),
            Paragraph("Estimated Cost / Month", style_table_header),
            Paragraph("Data Privacy & PDPA Fitness", style_table_header),
        ],
        [
            Paragraph("<b>Google Gemini 2.0 / 1.5 Flash</b>", style_table_cell_bold),
            Paragraph("Cloud API", style_table_cell),
            Paragraph("Input: $0.075 / 1M<br/>Output: $0.30 / 1M", style_table_cell),
            Paragraph("None (Zero local GPU footprint)", style_table_cell),
            Paragraph("<b>$5 - $20 / mo</b><br/>(1,000 cases)", style_table_cell),
            Paragraph("Processed on Google Cloud. Requires enterprise Data Processing Agreement.", style_table_cell),
        ],
        [
            Paragraph("<b>DeepSeek-V3 / R1</b><br/>(Official API)", style_table_cell_bold),
            Paragraph("Cloud API", style_table_cell),
            Paragraph("Input: $0.14 / 1M<br/>Output: $0.28 / 1M", style_table_cell),
            Paragraph("None (Zero local GPU footprint)", style_table_cell),
            Paragraph("<b>$8 - $30 / mo</b><br/>(1,000 cases)", style_table_cell),
            Paragraph("Processed on DeepSeek servers. High reasoning value for legal drafting.", style_table_cell),
        ],
        [
            Paragraph("<b>DeepSeek-R1-Distill-8B</b><br/>or <b>Qwen 2.5-7B</b>", style_table_cell_bold),
            Paragraph("Local On-Prem<br/>(Entry Tier)", style_table_cell),
            Paragraph("<b>$0.00</b><br/>(Open-Source)", style_table_cell),
            Paragraph("16GB RAM + Modern CPU<br/>or RTX 3060 (12GB)", style_table_cell),
            Paragraph("<b>$0 added</b><br/>(or ~$350 one-off GPU)", style_table_cell),
            Paragraph("<b>100% On-Premise Sovereignty.</b> Zero data leakage. Great for intake wizards.", style_table_cell),
        ],
        [
            Paragraph("<b>DeepSeek-R1-Distill-14B</b><br/>or <b>Qwen 2.5-14B</b>", style_table_cell_bold),
            Paragraph("Local On-Prem<br/><b>(Recommended)</b>", style_table_cell),
            Paragraph("<b>$0.00</b><br/>(Open-Source)", style_table_cell),
            Paragraph("32GB RAM + 1x RTX 4090 (24GB VRAM)", style_table_cell),
            Paragraph("<b>~$1,600 one-off</b><br/>(Zero monthly token bill)", style_table_cell),
            Paragraph("<b>Enterprise Data Security.</b> Excellent bilingual (EN/BM) legal and SSM extraction accuracy.", style_table_cell),
        ],
        [
            Paragraph("<b>DeepSeek-R1-Distill-32B</b><br/>or <b>Qwen 2.5-32B</b>", style_table_cell_bold),
            Paragraph("Local On-Prem<br/>(Enterprise)", style_table_cell),
            Paragraph("<b>$0.00</b><br/>(Open-Source)", style_table_cell),
            Paragraph("64GB RAM + 2x RTX 4090 or 1x RTX A5000", style_table_cell),
            Paragraph("<b>~$3,800 one-off</b><br/>(Zero monthly token bill)", style_table_cell),
            Paragraph("<b>Maximum Legal Fidelity.</b> Capable of parsing complex M&A constitutions and deep corporate audit trails.", style_table_cell),
        ],
    ]
    ai_table = Table(ai_table_data, colWidths=[36 * mm, 24 * mm, 28 * mm, 32 * mm, 26 * mm, 35 * mm])
    ai_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(ai_table)
    story.append(Spacer(1, 3 * mm))

    ai_recom_html = """
    <b>Strategic Recommendation: Hybrid Staging-to-Production Rollout</b><br/>
    • <b>Phase 1 (Staging & Early Pilot):</b> Utilize <b>Google Gemini 2.0 / 1.5 Flash API</b>. At ~$5-$20/month, it provides instant multimodal PDF parsing and questionnaire intelligence without immediate GPU capital expenditure.<br/>
    • <b>Phase 2 (Production On-Premise Target):</b> Deploy <b>Ollama with DeepSeek-R1-Distill-14B or Qwen 2.5-14B</b> on a dedicated workstation equipped with an <b>NVIDIA RTX 4090 (24GB VRAM)</b>. This guarantees 100% Malaysian data sovereignty under the Personal Data Protection Act 2010 (PDPA) with zero per-token operating expenditure.<br/>
    • <b>Provider-Agnostic LLM Gateway:</b> The backend interacts via a standard OpenAI-compatible endpoint (<code>/v1/chat/completions</code>). Switching between Cloud Gemini and Local DeepSeek requires only changing two environment variables in <code>.env</code> without altering any frontend or backend business logic.
    """
    ai_box = Table([[Paragraph(ai_recom_html, style_callout_text)]], colWidths=[CONTENT_W])
    ai_box.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), TEAL_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, TEAL_ACCENT),
        ('LINEBEFORE', (0, 0), (0, -1), 4, TEAL_ACCENT),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(ai_box)

    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("2.2 Strict AI Safety Guardrails", style_h2))
    story.append(Paragraph("• <b>No Direct Statutory Filings:</b> The AI is strictly barred from lodging forms to SSM or executing statutory actions.", style_bullet))
    story.append(Paragraph("• <b>No Legal Signatures:</b> The AI cannot sign or approve board resolutions or annual accounts.", style_bullet))
    story.append(Paragraph("• <b>Zero Cross-Tenant Leakage:</b> AI prompts receive only company-isolated context; no cross-company memory exists.", style_bullet))
    story.append(Paragraph("• <b>Mandatory Escalation Triggers:</b> Inquiries involving shareholder disputes, cross-border share capital changes, or direct human secretary requests are immediately escalated to the licensed secretary's queue.", style_bullet))

    story.append(PageBreak())

    # =========================================================================
    # SECTION 3: FRONTEND PROTOTYPE AUDIT & REALIGNMENT
    # =========================================================================
    story.append(Paragraph("3. Frontend Prototype Audit & Scope Realignment", style_h1))
    story.append(HRFlowable(width="100%", thickness=1, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=6))

    story.append(Paragraph(
        "A rigorous codebase inspection of <code>mysect_app</code>, <code>mysect_secretary</code>, and <code>mysect_admin</code> reveals "
        "high visual styling but several critical engineering and scope gaps that must be aligned before production backend integration begins.",
        style_body
    ))

    audit_table_data = [
        [
            Paragraph("Repository", style_table_header),
            Paragraph("Current Implemented Features", style_table_header),
            Paragraph("Critical Gaps & Red Flags", style_table_header),
            Paragraph("Corrective Action Plan", style_table_header),
        ],
        [
            Paragraph("<b>mysect_app</b><br/>(Client Mobile)", style_table_cell_bold),
            Paragraph("• Corporate dossier theme<br/>• Section 68 tracker<br/>• Retainer countdown card<br/>• Document upload tabs<br/>• Mock chat interface", style_table_cell),
            Paragraph("• <b>Scope Creep:</b> Invoicing, e-commerce, banking, referrals.<br/>• <b>Chat Mismatch:</b> Open chat instead of guided AI intake wizard.<br/>• Hardcoded localhost fallbacks.", style_table_cell),
            Paragraph("<b>Prune non-core pages</b> (ecom, invoicing, referrals). Refactor chat into structured AI questionnaire. Integrate real JWT auth and push notifications.", style_table_cell),
        ],
        [
            Paragraph("<b>mysect_secretary</b><br/>(Secretary Workspace)", style_table_cell_bold),
            Paragraph("• Desktop top header<br/>• Intake review queue<br/>• Client company dossier<br/>• Subscription tiers<br/>• MAICSA/MIA credential fields", style_table_cell),
            Paragraph("• Lacks explicit statutory lifecycle actions (Request Info, Issue Resolution, Lodge to SSM).<br/>• Missing split-pane PDF viewer.<br/>• Responsive mobile mode creates dual maintenance.", style_table_cell),
            Paragraph("<b>Prioritize Desktop/Web</b> view for Phase 1. Implement side-by-side statutory PDF document viewer and multi-state case transitions.", style_table_cell),
        ],
        [
            Paragraph("<b>mysect_admin</b><br/>(Platform Portal)", style_table_cell_bold),
            Paragraph("• Overview KPI cards<br/>• Firm verification actions<br/>• Company transfer flows<br/>• Escalation monitors<br/>• Audit log inspection", style_table_cell),
            Paragraph("• <b>In-memory mock data</b> resets on server restart.<br/>• Insecure browser localStorage auth.<br/>• Displays sensitive mock document URLs without access audit.", style_table_cell),
            Paragraph("Replace mock middleware with real backend API integration. Enforce HTTP-only secure cookie sessions. Enforce audit logging on all document previews.", style_table_cell),
        ],
    ]
    audit_table = Table(audit_table_data, colWidths=[32 * mm, 45 * mm, 50 * mm, 54 * mm])
    audit_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(audit_table)
    story.append(Spacer(1, 3 * mm))

    story.append(Paragraph("3.1 MVP Boundary: In-Scope vs. Deferred Modules", style_h2))
    story.append(Paragraph(
        "To guarantee delivery within the 12-week timeframe, the following boundary separates Phase 1 MVP commitments from Post-MVP enhancements:",
        style_body
    ))

    scope_data = [
        [
            Paragraph("<b>IN-SCOPE: Phase 1 Production MVP</b>", style_table_header),
            Paragraph("<b>DEFERRED: Post-MVP Roadmap</b>", style_table_header),
        ],
        [
            Paragraph("• Multi-tenant Authentication (JWT + Session Control)<br/>"
                      "• Company Dossier & Officer Registers (Sdn Bhd)<br/>"
                      "• AI-Guided Statutory Intake Wizard & Triage<br/>"
                      "• Section 68 Annual Return Lodgement Tracking<br/>"
                      "• In-App Document Approvals & Audit Signatures<br/>"
                      "• Ephemeral Storage Adapter (Local Disk / TM Cloud S3)<br/>"
                      "• Secretary Desktop Queue & Dossier Management<br/>"
                      "• Admin Firm Verification, Plan Assignment & Audit Logs", style_table_cell),
            Paragraph("• Multi-currency Commercial Invoicing & Payouts<br/>"
                      "• E-Commerce (Shopify/WooCommerce) Connectors<br/>"
                      "• Automated Commercial e-KYC Facial Biometrics<br/>"
                      "• Marketplace Client Bidding / Lead Generation<br/>"
                      "• Affiliate & Referral Commission Tracking<br/>"
                      "• Direct Automated MBRS / SSM Lodgement API<br/>"
                      "• Physical Mailbox & Post Scanning Workflows<br/>"
                      "• Native Mobile Secretary Operational Workspace", style_table_cell),
        ]
    ]
    scope_table = Table(scope_data, colWidths=[90 * mm, 91 * mm])
    scope_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, 0), NAVY_PRIMARY),
        ('BACKGROUND', (1, 0), (1, 0), colors.HexColor('#475569')),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('BACKGROUND', (0, 1), (0, 1), WHITE),
        ('BACKGROUND', (1, 1), (1, 1), SLATE_BG),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 7),
        ('RIGHTPADDING', (0, 0), (-1, -1), 7),
    ]))
    story.append(scope_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 4: REGULATORY COMPLIANCE & OPERATING FLOW
    # =========================================================================
    story.append(Paragraph("4. Regulatory Compliance & End-to-End Operating Flow", style_h1))
    story.append(HRFlowable(width="100%", thickness=1, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=6))

    reg_box_html = """
    <b>Malaysian Regulatory Framework & Fiduciary Boundaries:</b><br/>
    • <b>Companies Act 2016 (Section 241):</b> Requires every company secretary to be a qualified member of a prescribed body (e.g. MAICSA, MIA) or licensed by SSM. <i>MySect is an operating software platform; legal fiduciary responsibility remains strictly with the appointed licensed secretary.</i><br/>
    • <b>SSM MBRS Lodgement Reality:</b> SSM does not currently provide public write-APIs for third-party automated filing lodgement. MySect automates intake, resolution drafting, and client approval; final lodgement is executed by the licensed secretary via MBRS.<br/>
    • <b>Digital Signature Act 1997 & ECA 2006:</b> Digital approvals capture signer identity, verified email/mobile OTP, document SHA-256 hash, IP address, and UTC timestamp to maintain enforceable corporate consent records.<br/>
    • <b>Personal Data Protection Act 2010 (PDPA):</b> Processing of director ICs and passport scans requires AES-256 encryption at rest, restricted role access, and immutable audit logging.
    """
    reg_table = Table([[Paragraph(reg_box_html, style_callout_text)]], colWidths=[CONTENT_W])
    reg_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), AMBER_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, AMBER_ACCENT),
        ('LINEBEFORE', (0, 0), (0, -1), 4, AMBER_ACCENT),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(reg_table)
    story.append(Spacer(1, 3 * mm))

    story.append(Paragraph("4.1 End-to-End Request Operating Flow", style_h2))

    flow_data = [
        [
            Paragraph("Stage", style_table_header),
            Paragraph("Actor / System", style_table_header),
            Paragraph("Operational Action & State Transition", style_table_header),
            Paragraph("Compliance & Security Verification", style_table_header),
        ],
        [
            Paragraph("<b>1. Intake</b>", style_table_cell_bold),
            Paragraph("Client Director<br/>& AI Engine", style_table_cell),
            Paragraph("Director selects company, describes requirement. AI validates statutory prerequisites, asks follow-up questions, and compiles dossier.", style_table_cell),
            Paragraph("AI operates within safety boundaries; zero filing execution. Case created in MySQL with <code>ai_intake</code> status.", style_table_cell),
        ],
        [
            Paragraph("<b>2. Triage</b>", style_table_cell_bold),
            Paragraph("Licensed Secretary<br/>(Workspace)", style_table_cell),
            Paragraph("Secretary reviews AI dossier in Document Intake Queue. Accepts case, assigns staff reviewer, or requests additional documents.", style_table_cell),
            Paragraph("Only authorized firm users access the case. State transitions to <code>waiting_secretary_review</code>.", style_table_cell),
        ],
        [
            Paragraph("<b>3. Drafting</b>", style_table_cell_bold),
            Paragraph("Secretary / Staff", style_table_cell),
            Paragraph("Secretary drafts board resolution or annual return package and issues approval request to the client.", style_table_cell),
            Paragraph("Draft PDF uploaded to Storage Adapter; SHA-256 checksum recorded in MySQL ledger.", style_table_cell),
        ],
        [
            Paragraph("<b>4. Approval</b>", style_table_cell_bold),
            Paragraph("Client Director<br/>(Mobile App)", style_table_cell),
            Paragraph("Director receives push notification, reviews draft PDF via ephemeral URL, and signs electronically.", style_table_cell),
            Paragraph("Captures signer identity, IP address, user agent, document hash, and UTC timestamp into <code>document_approvals</code>.", style_table_cell),
        ],
        [
            Paragraph("<b>5. Lodgement</b>", style_table_cell_bold),
            Paragraph("Licensed Secretary<br/>& External SSM", style_table_cell),
            Paragraph("Secretary submits signed package via official SSM MBRS portal. Uploads statutory lodgement receipt to MySect.", style_table_cell),
            Paragraph("Case status marked <code>completed</code>. Client receives notification and permanent access in Corporate Dossier.", style_table_cell),
        ],
    ]
    flow_table = Table(flow_data, colWidths=[24 * mm, 32 * mm, 65 * mm, 60 * mm])
    flow_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(flow_table)

    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("4.2 Identity Verification & e-KYC Strategy", style_h2))
    story.append(Paragraph(
        "Third-party commercial e-KYC facial biometrics are <b>not mandatory for Phase 1 MVP</b>. "
        "SSM Customer Due Diligence (CDD) guidelines require reliable verification of directors and beneficial owners. "
        "For Phase 1, MySect implements a <b>Structured Manual Due Diligence Workflow</b>: capturing NRIC/Passport scans, proof of residential address, "
        "and relationship declarations, reviewed and certified directly by the licensed secretary. "
        "Commercial e-KYC API integration will be introduced in Phase 2 once compliance wording, biometric retention policies, and transaction costs are approved.",
        style_body
    ))

    story.append(PageBreak())

    # =========================================================================
    # SECTION 5: IMPLEMENTATION SCHEDULE, CRITERIA & APPROVALS
    # =========================================================================
    story.append(Paragraph("5. Implementation Roadmap & Governance Signoff", style_h1))
    story.append(HRFlowable(width="100%", thickness=1, color=NAVY_PRIMARY, spaceBefore=2, spaceAfter=6))

    story.append(Paragraph("5.1 Twelve-Week Production Implementation Schedule", style_h2))

    gantt_data = [
        [
            Paragraph("Workstream / Activity", style_table_header),
            Paragraph("W1-2", style_table_header),
            Paragraph("W3-4", style_table_header),
            Paragraph("W5-6", style_table_header),
            Paragraph("W7-8", style_table_header),
            Paragraph("W9-10", style_table_header),
            Paragraph("W11-12", style_table_header),
        ],
        [
            Paragraph("Scope Freeze & Stakeholder Signoff", style_table_cell_bold),
            Paragraph("■■", style_table_cell_bold), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("MySQL Schema & Core Backend Setup", style_table_cell_bold),
            Paragraph("■", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Docker & Windows Server Infrastructure", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Multi-Tenant Auth & RBAC Engine", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("■", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("AI Gateway (Ollama / Gemini Adapter)", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■■", style_table_cell_bold), Paragraph("", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Customer App Integration (mysect_app)", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■", style_table_cell), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Secretary Workspace (mysect_secretary)", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■■", style_table_cell_bold), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Storage Adapter & Document Signing", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("", style_table_cell),
        ],
        [
            Paragraph("Admin Portal Real API (mysect_admin)", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■■", style_table_cell_bold), Paragraph("■", style_table_cell),
        ],
        [
            Paragraph("End-to-End Pilot Testing & UAT", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■", style_table_cell), Paragraph("■■", style_table_cell_bold),
        ],
        [
            Paragraph("Security Hardening & Go-Live Prep", style_table_cell_bold),
            Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("", style_table_cell), Paragraph("■■", style_table_cell_bold),
        ],
    ]
    gantt_table = Table(gantt_data, colWidths=[65 * mm, 19 * mm, 19 * mm, 19 * mm, 19 * mm, 20 * mm, 20 * mm])
    gantt_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('ALIGN', (1, 0), (-1, -1), 'CENTER'),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TEXTCOLOR', (1, 1), (-1, -1), BLUE_ACCENT),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (0, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(gantt_table)

    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("5.2 Pilot Acceptance Gateways (Pre-Flight Checklist)", style_h2))
    story.append(Paragraph("1. <b>Tenant Isolation:</b> Verified that Firm A cannot query, view, or search companies or cases belonging to Firm B under any circumstance.", style_bullet))
    story.append(Paragraph("2. <b>Zero Database Credentials on Clients:</b> Confirmed zero connection strings or API secrets in Flutter binaries or web bundles.", style_bullet))
    story.append(Paragraph("3. <b>AI Guardrails:</b> Confirmed AI refuses legal advice, cannot execute filings, and escalates complex requests to human secretaries.", style_bullet))
    story.append(Paragraph("4. <b>Signed URL Ephemerality:</b> Document pre-signed download tokens expire strictly after 300 seconds.", style_bullet))
    story.append(Paragraph("5. <b>Digital Signature Integrity:</b> Approvals record signer identity, IP address, user agent, document SHA-256 hash, and UTC timestamp.", style_bullet))
    story.append(Paragraph("6. <b>Container Resilience:</b> MySQL data and uploaded files survive container restarts and host reboots without corruption.", style_bullet))
    story.append(Paragraph("7. <b>Disaster Recovery:</b> Automated MySQL dump and file backup pipeline tested with recovery time under 30 minutes (RTO < 30m).", style_bullet))

    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("5.3 Governance & Document Signoff", style_h2))

    signoff_data = [
        [
            Paragraph("Role", style_table_header),
            Paragraph("Designated Stakeholder", style_table_header),
            Paragraph("Organization / Title", style_table_header),
            Paragraph("Date", style_table_header),
            Paragraph("Formal Signoff", style_table_header),
        ],
        [
            Paragraph("<b>Project Sponsor</b>", style_table_cell_bold),
            Paragraph("Executive Leadership", style_table_cell),
            Paragraph("MySect Platform Board", style_table_cell),
            Paragraph("____ / ____ / 2026", style_table_cell),
            Paragraph("<code>[ PENDING APPROVAL ]</code>", style_table_cell_bold),
        ],
        [
            Paragraph("<b>Lead Architect</b>", style_table_cell_bold),
            Paragraph("Engineering Leadership", style_table_cell),
            Paragraph("Infrastructure & Core API", style_table_cell),
            Paragraph("____ / ____ / 2026", style_table_cell),
            Paragraph("<code>[ PENDING APPROVAL ]</code>", style_table_cell_bold),
        ],
        [
            Paragraph("<b>Frontend Lead</b>", style_table_cell_bold),
            Paragraph("Frontend Engineering", style_table_cell),
            Paragraph("Mobile & Web Workspaces", style_table_cell),
            Paragraph("____ / ____ / 2026", style_table_cell),
            Paragraph("<code>[ PENDING APPROVAL ]</code>", style_table_cell_bold),
        ],
        [
            Paragraph("<b>Legal & Compliance</b>", style_table_cell_bold),
            Paragraph("Secretarial Partner", style_table_cell),
            Paragraph("Licensed Secretary (MAICSA/MIA)", style_table_cell),
            Paragraph("____ / ____ / 2026", style_table_cell),
            Paragraph("<code>[ PENDING APPROVAL ]</code>", style_table_cell_bold),
        ],
    ]
    signoff_table = Table(signoff_data, colWidths=[35 * mm, 40 * mm, 45 * mm, 28 * mm, 33 * mm])
    signoff_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SLATE_BG]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(signoff_table)

    # Build Document using NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"[SUCCESS] Enterprise PDF successfully compiled: {PDF_OUTPUT}")


if __name__ == '__main__':
    build_pdf()
