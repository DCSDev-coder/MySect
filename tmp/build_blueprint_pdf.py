from pathlib import Path
import shutil
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, Image
)
from reportlab.graphics.shapes import Drawing, Rect, String, Line, Polygon, Circle
import math

ROOT = Path('/Users/marketingdeveloper/DCStack_Development/MySect')
SOURCE = ROOT / 'Documentation/MYSECT_APP_BUILD_BLUEPRINT.md'
OUTPUT_MAIN = ROOT / 'output/pdf/MYSECT_APP_BUILD_BLUEPRINT.pdf'
OUTPUT_NUMBERED = ROOT / 'output/pdf/1.MYSECT_APP_BUILD_BLUEPRINT.pdf'
LOGO_PATH = ROOT / 'admin_website/public/mysect_logo.png'

OUTPUT_MAIN.parent.mkdir(parents=True, exist_ok=True)

# Brand & Presentation Color Palette
NAVY = colors.HexColor('#0F2D59')
NAVY_DARK = colors.HexColor('#091D3A')
BLUE = colors.HexColor('#1D6FA5')
BLUE_LIGHT = colors.HexColor('#EBF4FA')
TEAL = colors.HexColor('#0A7E8C')
TEAL_LIGHT = colors.HexColor('#E6F5F7')
AMBER = colors.HexColor('#B45309')
AMBER_LIGHT = colors.HexColor('#FEF3C7')
GREEN = colors.HexColor('#15803D')
GREEN_LIGHT = colors.HexColor('#DCFCE7')
SLATE_BG = colors.HexColor('#F4F7FA')
CARD_BG = colors.HexColor('#F8FAFC')
BORDER = colors.HexColor('#CBD5E1')
BORDER_LIGHT = colors.HexColor('#E2E8F0')
INK = colors.HexColor('#1E293B')
MUTED = colors.HexColor('#64748B')
WHITE = colors.white

PAGE_W, PAGE_H = A4
MARGIN_X = 15 * mm
CONTENT_W = PAGE_W - 2 * MARGIN_X  # ~510 pt

styles = getSampleStyleSheet()

styles.add(ParagraphStyle(
    name='Badge',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=8,
    leading=10,
    textColor=BLUE,
    alignment=TA_LEFT,
    spaceAfter=3,
))
styles.add(ParagraphStyle(
    name='CoverTitle',
    parent=styles['Title'],
    fontName='Helvetica-Bold',
    fontSize=23,
    leading=27,
    textColor=NAVY,
    alignment=TA_LEFT,
    spaceAfter=3,
))
styles.add(ParagraphStyle(
    name='CoverSubtitle',
    parent=styles['Normal'],
    fontName='Helvetica',
    fontSize=10.5,
    leading=14,
    textColor=MUTED,
    alignment=TA_LEFT,
    spaceAfter=6,
))
styles.add(ParagraphStyle(
    name='PageHeaderTag',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=7.5,
    leading=9.5,
    textColor=TEAL,
    spaceBefore=0,
    spaceAfter=1.5,
))
styles.add(ParagraphStyle(
    name='H1x',
    parent=styles['Heading1'],
    fontName='Helvetica-Bold',
    fontSize=15,
    leading=18.5,
    textColor=NAVY,
    spaceBefore=1,
    spaceAfter=3.5,
    keepWithNext=True,
))
styles.add(ParagraphStyle(
    name='H2x',
    parent=styles['Heading2'],
    fontName='Helvetica-Bold',
    fontSize=11,
    leading=14,
    textColor=NAVY,
    spaceBefore=6,
    spaceAfter=3,
    keepWithNext=True,
))
styles.add(ParagraphStyle(
    name='Bodyx',
    parent=styles['BodyText'],
    fontName='Helvetica',
    fontSize=8.8,
    leading=12.4,
    textColor=INK,
    spaceAfter=4,
))
styles.add(ParagraphStyle(
    name='Smallx',
    parent=styles['BodyText'],
    fontName='Helvetica',
    fontSize=7.8,
    leading=10.5,
    textColor=MUTED,
    spaceAfter=2,
))
styles.add(ParagraphStyle(
    name='TableHead',
    parent=styles['BodyText'],
    fontName='Helvetica-Bold',
    fontSize=8.2,
    leading=10.5,
    textColor=WHITE,
))
styles.add(ParagraphStyle(
    name='TableCell',
    parent=styles['BodyText'],
    fontName='Helvetica',
    fontSize=8.0,
    leading=11.0,
    textColor=INK,
))
styles.add(ParagraphStyle(
    name='TableCellBold',
    parent=styles['BodyText'],
    fontName='Helvetica-Bold',
    fontSize=8.2,
    leading=11.0,
    textColor=NAVY,
))
styles.add(ParagraphStyle(
    name='MetricBig',
    parent=styles['BodyText'],
    fontName='Helvetica-Bold',
    fontSize=13.5,
    leading=16,
    textColor=NAVY,
    alignment=TA_CENTER,
))
styles.add(ParagraphStyle(
    name='MetricLabel',
    parent=styles['BodyText'],
    fontName='Helvetica',
    fontSize=7.4,
    leading=9.5,
    textColor=MUTED,
    alignment=TA_CENTER,
))


def p(text, style='Bodyx'):
    formatted = text.replace('\n', '<br/>')
    return Paragraph(formatted, styles[style])


def callout_box(title, body_text, accent=NAVY, bg=BLUE_LIGHT):
    content = Paragraph(
        f'<font name="Helvetica-Bold" color="{accent.hexval()}">{title}</font><br/>{body_text}',
        ParagraphStyle(
            name='CalloutInner',
            parent=styles['Bodyx'],
            fontSize=8.5,
            leading=12.2,
            textColor=INK,
        )
    )
    t = Table([[content]], colWidths=[CONTENT_W])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), bg),
        ('LINEBEFORE', (0, 0), (0, -1), 3.5, accent),
        ('BOX', (0, 0), (-1, -1), 0.5, BORDER),
        ('LEFTPADDING', (0, 0), (-1, -1), 9),
        ('RIGHTPADDING', (0, 0), (-1, -1), 9),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    return t


def styled_table(headers, rows, col_widths, accent=NAVY, pad_v=4.5):
    data = [[p(h, 'TableHead') for h in headers]]
    for r in rows:
        row_cells = []
        for idx, cell in enumerate(r):
            if isinstance(cell, Paragraph):
                row_cells.append(cell)
            elif idx == 0:
                row_cells.append(p(cell, 'TableCellBold'))
            else:
                row_cells.append(p(cell, 'TableCell'))
        data.append(row_cells)

    t = Table(data, colWidths=col_widths, repeatRows=1)
    style_cmds = [
        ('BACKGROUND', (0, 0), (-1, 0), accent),
        ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
        ('BOX', (0, 0), (-1, -1), 0.8, BORDER),
        ('LEFTPADDING', (0, 0), (-1, -1), 6.5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6.5),
        ('TOPPADDING', (0, 0), (-1, -1), pad_v),
        ('BOTTOMPADDING', (0, 0), (-1, -1), pad_v),
    ]
    for i in range(1, len(data)):
        bg = WHITE if i % 2 == 1 else SLATE_BG
        style_cmds.append(('BACKGROUND', (0, i), (-1, i), bg))
    t.setStyle(TableStyle(style_cmds))
    return t


# ==============================================================================
# VECTOR DIAGRAM HELPERS (Clean, Zero-Overlap Presentation Graphics)
# ==============================================================================

def draw_card(d, x, y, w, h, header_text, subtitle, bullets=None,
              header_fill=NAVY, body_fill=WHITE, border_color=BORDER, badge=None):
    d.add(Rect(x, y, w, h, rx=5, ry=5, fillColor=body_fill, strokeColor=border_color, strokeWidth=1))
    hh = 19
    d.add(Rect(x, y + h - hh, w, hh, rx=5, ry=5, fillColor=header_fill, strokeColor=header_fill, strokeWidth=0.5))
    d.add(Rect(x, y + h - hh, w, 6, fillColor=header_fill, strokeColor=header_fill, strokeWidth=0))

    title_x = x + w / 2
    if badge:
        d.add(Circle(x + 11, y + h - hh / 2, 6, fillColor=WHITE, strokeColor=header_fill, strokeWidth=0.5))
        d.add(String(x + 11, y + h - hh / 2 - 2.8, str(badge), fontName='Helvetica-Bold', fontSize=7.2,
                     fillColor=header_fill, textAnchor='middle'))
        title_x = x + (w + 13) / 2

    d.add(String(title_x, y + h - hh + 5.5, header_text, fontName='Helvetica-Bold', fontSize=8.2,
                 fillColor=WHITE, textAnchor='middle'))

    curr_y = y + h - hh - 11
    if subtitle:
        d.add(String(x + w / 2, curr_y, subtitle, fontName='Helvetica-Oblique', fontSize=7.0,
                     fillColor=MUTED, textAnchor='middle'))
        curr_y -= 11.5

    if bullets:
        for b in bullets:
            d.add(String(x + 7, curr_y, f'• {b}', fontName='Helvetica', fontSize=7.0,
                         fillColor=INK, textAnchor='start'))
            curr_y -= 10.2


def draw_store(d, x, y, w, h, title, subtitle, accent=BLUE):
    d.add(Rect(x, y, w, h, rx=4, ry=4, fillColor=SLATE_BG, strokeColor=accent, strokeWidth=1.1))
    d.add(Rect(x, y, 5, h, rx=2, ry=2, fillColor=accent, strokeColor=accent, strokeWidth=0))
    d.add(String(x + w / 2 + 2, y + h / 2 + 2.5, title, fontName='Helvetica-Bold', fontSize=8.0,
                 fillColor=NAVY, textAnchor='middle'))
    d.add(String(x + w / 2 + 2, y + h / 2 - 7.5, subtitle, fontName='Helvetica', fontSize=6.7,
                 fillColor=MUTED, textAnchor='middle'))


def draw_arrow(d, x1, y1, x2, y2, color=BLUE, dashed=False, both=False):
    line = Line(x1, y1, x2, y2, strokeColor=color, strokeWidth=1.25)
    if dashed:
        line.strokeDashArray = [3, 2]
    d.add(line)
    dx, dy = x2 - x1, y2 - y1
    length = max(math.sqrt(dx * dx + dy * dy), 1)
    ux, uy = dx / length, dy / length
    px, py = -uy, ux
    bx, by = x2 - 6.0 * ux, y2 - 6.0 * uy
    d.add(Polygon([x2, y2, bx + 3.0 * px, by + 3.0 * py, bx - 3.0 * px, by - 3.0 * py],
                  fillColor=color, strokeColor=color))
    if both:
        bx1, by1 = x1 + 6.0 * ux, y1 + 6.0 * uy
        d.add(Polygon([x1, y1, bx1 + 3.0 * px, by1 + 3.0 * py, bx1 - 3.0 * px, by1 - 3.0 * py],
                      fillColor=color, strokeColor=color))


def draw_pill_label(d, cx, cy, text, border_color=BORDER, bg=WHITE, text_color=INK, w_override=None):
    w = w_override or (len(text) * 3.5 + 10)
    h = 11.5
    d.add(Rect(cx - w / 2, cy - h / 2, w, h, rx=5.5, ry=5.5, fillColor=bg, strokeColor=border_color, strokeWidth=0.65))
    d.add(String(cx, cy - 2.6, text, fontName='Helvetica-Bold', fontSize=6.4, fillColor=text_color, textAnchor='middle'))


def diagram_1_ecosystem():
    """Page 2 Diagram: Clean 3-Product Ecosystem & Information Flow (Zero Overlap)"""
    d = Drawing(CONTENT_W, 215)
    d.add(Rect(0, 0, CONTENT_W, 215, rx=6, ry=6, fillColor=CARD_BG, strokeColor=BORDER_LIGHT, strokeWidth=0.8))

    d.add(String(CONTENT_W / 2, 199, 'MYSECT THREE-PRODUCT ECOSYSTEM & INFORMATION FLOW',
                 fontName='Helvetica-Bold', fontSize=9.2, fillColor=NAVY, textAnchor='middle'))
    d.add(String(CONTENT_W / 2, 188, 'Three role-specific applications connected to one shared, access-controlled platform',
                 fontName='Helvetica', fontSize=7.3, fillColor=MUTED, textAnchor='middle'))

    # Left Card: Customer App (x=10..124, w=114)
    draw_card(
        d, 10, 96, 114, 82,
        'Customer App', 'Mobile App (Flutter)',
        ['View my companies', 'Ask MySect assistant', 'Upload & approve docs', 'Track request status'],
        header_fill=BLUE, badge='1'
    )

    # Center Hub: MySect Shared Platform (x=196..314, w=118) -> 72pt gap on both sides!
    draw_card(
        d, 196, 92, 118, 90,
        'MySect Platform', 'Shared Backend & DB',
        ['Role & company security', 'AI intake → Case record', 'Case & human chat engine', 'Document & sign-off vault', 'Full activity audit log'],
        header_fill=NAVY, body_fill=BLUE_LIGHT, border_color=NAVY
    )

    # Right Card: Secretary Website (x=386..500, w=114)
    draw_card(
        d, 386, 96, 114, 82,
        'Secretary Website', 'Firm Web Workspace',
        ['Receive prepared cases', 'Accept & assign work', 'Open human case chat', 'Request docs & close'],
        header_fill=TEAL, badge='2'
    )

    # Bottom Card: MySect Admin Website (x=120..390, w=270)
    draw_card(
        d, 120, 8, 270, 52,
        'MySect Admin Website (Internal Operations)', 'Platform Governance & Support Portal',
        ['Onboard Secretary Firms  •  Assign Companies to Firms  •  Manage Users & Audit'],
        header_fill=NAVY_DARK, badge='3'
    )

    # Horizontal arrows between Customer (124) <-> Platform (196), center x = 160
    draw_arrow(d, 124, 152, 196, 152, color=BLUE)
    draw_pill_label(d, 160, 164, 'Requests & approvals', border_color=BLUE, text_color=NAVY, w_override=68)

    draw_arrow(d, 196, 122, 124, 122, color=BLUE)
    draw_pill_label(d, 160, 110, 'Status & notifications', border_color=BLUE, text_color=BLUE, w_override=68)

    # Horizontal arrows between Platform (314) <-> Secretary Firm (386), center x = 350
    draw_arrow(d, 314, 152, 386, 152, color=TEAL)
    draw_pill_label(d, 350, 164, 'Prepared cases & files', border_color=TEAL, text_color=TEAL, w_override=68)

    draw_arrow(d, 386, 122, 314, 122, color=TEAL)
    draw_pill_label(d, 350, 110, 'Chat, docs & updates', border_color=TEAL, text_color=NAVY, w_override=68)

    # Vertical arrows between Admin (y=60) <-> Platform (y=92)
    draw_arrow(d, 225, 60, 225, 92, color=NAVY)
    draw_pill_label(d, 168, 76, 'Firms, assignments, rules', border_color=NAVY, text_color=NAVY, w_override=90)

    draw_arrow(d, 285, 92, 285, 60, color=NAVY)
    draw_pill_label(d, 342, 76, 'Reports, alerts & audit', border_color=NAVY, text_color=NAVY, w_override=86)

    return d


def diagram_2_request_flow():
    """Page 3 Diagram: End-to-End Customer Request & Secretary Workflow (5 Clean Stages + 3 Stores)"""
    d = Drawing(CONTENT_W, 220)
    d.add(Rect(0, 0, CONTENT_W, 220, rx=6, ry=6, fillColor=CARD_BG, strokeColor=BORDER_LIGHT, strokeWidth=0.8))

    d.add(String(CONTENT_W / 2, 204, 'END-TO-END CUSTOMER REQUEST & SECRETARY WORKFLOW',
                 fontName='Helvetica-Bold', fontSize=9.2, fillColor=NAVY, textAnchor='middle'))
    d.add(String(CONTENT_W / 2, 193, 'How a customer question becomes a structured case, human conversation, approved document, and completed record',
                 fontName='Helvetica', fontSize=7.3, fillColor=MUTED, textAnchor='middle'))

    box_w = 86
    box_h = 74
    gap = 14
    start_x = 13
    top_y = 108

    stages = [
        ('1', 'Customer Asks', 'Customer App', ['Selects company', 'Asks question', 'Answers prompts'], BLUE),
        ('2', 'Guided Intake', 'Digital Assistant', ['Checks context', 'Finds missing info', 'Builds summary'], AMBER),
        ('3', 'Case Handover', 'Shared Backend', ['Creates Case ID', 'Alerts assigned', 'Secretary Firm'], NAVY),
        ('4', 'Secretary Owns', 'Secretary Website', ['Accepts case', 'Opens human chat', 'Requests/sends doc'], TEAL),
        ('5', 'Approve & Close', 'Customer + Sec.', ['Customer approves', 'Timestamp saved', 'Case completed'], GREEN),
    ]

    for i, (num, title, sub, bullets, col) in enumerate(stages):
        x = start_x + i * (box_w + gap)
        draw_card(d, x, top_y, box_w, box_h, title, sub, bullets, header_fill=col, badge=num)
        if i < len(stages) - 1:
            ax1 = x + box_w
            ax2 = ax1 + gap
            ay = top_y + box_h / 2
            draw_arrow(d, ax1, ay, ax2, ay, color=NAVY)

    # Feedback / Document Exchange Loop bar
    loop_y = 82
    d.add(Rect(56, loop_y - 7, 398, 15, rx=7.5, ry=7.5, fillColor=BLUE_LIGHT, strokeColor=BLUE, strokeWidth=0.7))
    d.add(String(CONTENT_W / 2, loop_y - 2.5,
                 'Controlled Case Channel: Human Chat, Document Requests, Draft Uploads & Formal Customer Approvals',
                 fontName='Helvetica-Bold', fontSize=7.0, fillColor=NAVY, textAnchor='middle'))
    draw_arrow(d, 56, loop_y + 8, 56, top_y, color=BLUE)
    draw_arrow(d, 356, top_y, 356, loop_y + 8, color=TEAL)
    draw_arrow(d, 454, loop_y + 8, 454, top_y, color=GREEN)

    # Bottom 3 Data Stores
    store_w = 148
    store_h = 38
    store_y = 10
    s_positions = [16, 181, 346]
    stores = [
        ('Company Information Store', 'Verified company & firm assignment', BLUE),
        ('Case & Conversation History', 'AI summary, human chat & statuses', NAVY),
        ('Document & Approval Records', 'Versioned files & approval timestamps', TEAL),
    ]
    for sx, (stitle, ssub, scol) in zip(s_positions, stores):
        draw_store(d, sx, store_y, store_w, store_h, stitle, ssub, accent=scol)

    draw_arrow(d, 90, loop_y - 7, 90, store_y + store_h, color=BLUE)
    draw_pill_label(d, 90, 61, 'Verify access', border_color=BLUE, text_color=NAVY, w_override=62)

    draw_arrow(d, 255, loop_y - 7, 255, store_y + store_h, color=NAVY)
    draw_pill_label(d, 255, 61, 'Save case & chat', border_color=NAVY, text_color=NAVY, w_override=72)

    draw_arrow(d, 420, loop_y - 7, 420, store_y + store_h, color=TEAL)
    draw_pill_label(d, 420, 61, 'Save docs & sign-off', border_color=TEAL, text_color=TEAL, w_override=82)

    return d


def diagram_3_ai_intake():
    """Page 4 Diagram: How the Digital Assistant Prepares a Case (Zero-Crossing Orthogonal Arrows)"""
    d = Drawing(CONTENT_W, 215)
    d.add(Rect(0, 0, CONTENT_W, 215, rx=6, ry=6, fillColor=CARD_BG, strokeColor=BORDER_LIGHT, strokeWidth=0.8))

    d.add(String(CONTENT_W / 2, 199, 'HOW THE "ASK MYSECT" DIGITAL ASSISTANT PREPARES A CASE',
                 fontName='Helvetica-Bold', fontSize=9.2, fillColor=NAVY, textAnchor='middle'))
    d.add(String(CONTENT_W / 2, 188, 'AI handles structured intake and missing-info collection; the licensed Secretary controls human advice & completion',
                 fontName='Helvetica', fontSize=7.3, fillColor=MUTED, textAnchor='middle'))

    # Left Column: Customer (x=12..120, y=62..176)
    draw_card(
        d, 12, 62, 108, 114,
        'Customer', 'Mobile App User',
        ['Starts in Ask MySect', 'Confirms company', 'Answers follow-ups', 'Uploads initial files', 'Reviews summary'],
        header_fill=BLUE
    )

    # Center Container: Digital Assistant 5-Step Pipeline (x=142..368, y=54..178)
    d.add(Rect(142, 54, 226, 124, rx=6, ry=6, fillColor=AMBER_LIGHT, strokeColor=AMBER, strokeWidth=0.9))
    d.add(String(255, 167, 'MySect Digital Assistant (Guided Intake Pipeline)',
                 fontName='Helvetica-Bold', fontSize=8.0, fillColor=AMBER, textAnchor='middle'))

    steps = [
        ('1. Identify', 'Confirm customer & authorised company'),
        ('2. Understand', 'Classify service category & urgency'),
        ('3. Collect', 'Ask structured follow-up questions & files'),
        ('4. Prepare', 'Generate clean case summary & checklist'),
        ('5. Notify', 'Save Case Record & alert Secretary Firm'),
    ]
    sy = 144
    for idx, (stitle, sdesc) in enumerate(steps):
        d.add(Rect(150, sy, 210, 15.5, rx=3.5, ry=3.5, fillColor=WHITE, strokeColor=AMBER, strokeWidth=0.6))
        d.add(String(156, sy + 4.5, stitle, fontName='Helvetica-Bold', fontSize=7.1, fillColor=NAVY, textAnchor='start'))
        d.add(String(214, sy + 4.5, sdesc, fontName='Helvetica', fontSize=6.9, fillColor=INK, textAnchor='start'))
        if idx < len(steps) - 1:
            draw_arrow(d, 255, sy, 255, sy - 4.5, color=AMBER)
        sy -= 20

    # Right Column: Assigned Secretary (x=390..498, y=62..176)
    draw_card(
        d, 390, 62, 108, 114,
        'Secretary Staff', 'Firm Web Workspace',
        ['Receives alert', 'Reads AI summary', 'Accepts ownership', 'Opens human chat', 'Completes filing/work'],
        header_fill=TEAL
    )

    # Clean Horizontal Arrows between Customer (120) <-> AI Pipeline (142)
    draw_arrow(d, 120, 151, 150, 151, color=BLUE)
    draw_arrow(d, 150, 111, 120, 111, color=AMBER, both=True)

    # Clean Horizontal Arrow from AI Pipeline (360) -> Secretary Staff (390)
    draw_arrow(d, 360, 72, 390, 72, color=TEAL)

    # Bottom Data Stores (y=8..40)
    draw_store(d, 24, 8, 215, 32, 'Company Information Database', 'Checks user permission & assigned firm', accent=BLUE)
    draw_store(d, 271, 8, 215, 32, 'Structured Case & Transcript Store', 'Saves intake chat, checklist & summary', accent=NAVY)

    # Clean Straight Vertical Arrows between AI Pipeline bottom (y=54) and Bottom Stores (y=40)
    draw_arrow(d, 190, 54, 190, 40, color=BLUE, both=True)
    draw_arrow(d, 320, 54, 320, 40, color=NAVY)

    return d


def diagram_4_governance():
    """Page 5 Diagram: Sign-In, Multi-Firm Company Assignment & Governance Flow"""
    d = Drawing(CONTENT_W, 200)
    d.add(Rect(0, 0, CONTENT_W, 200, rx=6, ry=6, fillColor=CARD_BG, strokeColor=BORDER_LIGHT, strokeWidth=0.8))

    d.add(String(CONTENT_W / 2, 184, 'SIGN-IN, MULTI-FIRM COMPANY ASSIGNMENT & PLATFORM GOVERNANCE',
                 fontName='Helvetica-Bold', fontSize=9.2, fillColor=NAVY, textAnchor='middle'))
    d.add(String(CONTENT_W / 2, 173, 'How MySect controls who can sign in, which firm manages each company, and how every action is audited',
                 fontName='Helvetica', fontSize=7.3, fillColor=MUTED, textAnchor='middle'))

    col_w = 148
    gap = 19
    xs = [14, 14 + col_w + gap, 14 + 2 * (col_w + gap)]

    pillars = [
        ('1', 'Sign-In & Role Access', 'All Platform Users',
         ['Verify account credentials', 'Enforce role permissions', 'Restrict to authorised companies'], BLUE),
        ('2', 'Company & Firm Mapping', 'Admin + Firm Manager',
         ['Admin assigns Company → Firm', 'Manager assigns Firm Staff', 'Link authorised Customer users'], TEAL),
        ('3', 'Admin Controls & Audit', 'MySect Administrator',
         ['Configure service categories', 'Monitor escalations & support', 'Record immutable audit trail'], NAVY),
    ]

    for x, (num, title, sub, bullets, col) in zip(xs, pillars):
        draw_card(d, x, 84, col_w, 80, title, sub, bullets, header_fill=col, badge=num)

    draw_arrow(d, xs[0] + col_w, 124, xs[1], 124, color=BLUE)
    draw_arrow(d, xs[1] + col_w, 124, xs[2], 124, color=TEAL)

    stores = [
        ('User Accounts & Roles', 'Credentials, roles & status', BLUE),
        ('Company & Staff Assignments', 'Firm-to-company & staff links', TEAL),
        ('Immutable Activity Audit Log', 'Sign-ins, assignments & changes', NAVY),
    ]
    for x, (stitle, ssub, scol) in zip(xs, stores):
        draw_store(d, x, 10, col_w, 40, stitle, ssub, accent=scol)
        draw_arrow(d, x + col_w / 2, 84, x + col_w / 2, 50, color=scol, both=True)

    draw_pill_label(d, xs[0] + col_w / 2, 67, 'Verify & log access', border_color=BLUE, text_color=NAVY, w_override=80)
    draw_pill_label(d, xs[1] + col_w / 2, 67, 'Enforce tenant scope', border_color=TEAL, text_color=TEAL, w_override=84)
    draw_pill_label(d, xs[2] + col_w / 2, 67, 'Write audit events', border_color=NAVY, text_color=NAVY, w_override=78)

    return d


# ==============================================================================
# PAGE HEADER & FOOTER DECORATION
# ==============================================================================

def decorate_page(canvas, doc):
    canvas.saveState()
    width, height = A4

    canvas.setFillColor(NAVY)
    canvas.rect(0, height - 4 * mm, width * 0.65, 4 * mm, fill=1, stroke=0)
    canvas.setFillColor(TEAL)
    canvas.rect(width * 0.65, height - 4 * mm, width * 0.35, 4 * mm, fill=1, stroke=0)

    if doc.page > 1:
        canvas.setFont('Helvetica-Bold', 7.5)
        canvas.setFillColor(NAVY)
        canvas.drawString(MARGIN_X, height - 10.5 * mm, 'MySect App Build Blueprint')
        canvas.setFont('Helvetica', 7.5)
        canvas.setFillColor(MUTED)
        canvas.drawRightString(width - MARGIN_X, height - 10.5 * mm,
                               'Customer App  •  Secretary Website  •  MySect Admin Website')
        canvas.setStrokeColor(BORDER_LIGHT)
        canvas.setLineWidth(0.6)
        canvas.line(MARGIN_X, height - 12.5 * mm, width - MARGIN_X, height - 12.5 * mm)

    canvas.setStrokeColor(BORDER_LIGHT)
    canvas.setLineWidth(0.6)
    canvas.line(MARGIN_X, 13 * mm, width - MARGIN_X, 13 * mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(MARGIN_X, 8.5 * mm,
                      'MySect App Build Blueprint  |  Confirmed 3-Month MVP Scope  |  Prepared for Partner & Meeting Presentation')
    canvas.setFont('Helvetica-Bold', 7.5)
    canvas.setFillColor(NAVY)
    canvas.drawRightString(width - MARGIN_X, 8.5 * mm, f'Page {doc.page} of 10')
    canvas.restoreState()


# ==============================================================================
# BUILD DOCUMENT STORY (10 SELF-CONTAINED PRESENTATION PAGES)
# ==============================================================================

story = []

# ------------------------------------------------------------------------------
# PAGE 1: EXECUTIVE COVER & PLATFORM OVERVIEW
# ------------------------------------------------------------------------------
if LOGO_PATH.exists():
    logo_img = Image(str(LOGO_PATH), width=40 * mm, height=40 * mm)
    logo_img.hAlign = 'RIGHT'
else:
    logo_img = Spacer(1, 10)

title_block = [
    p('BUSINESS & TECHNICAL BUILD BLUEPRINT  •  CONFIRMED PHASE 1 SCOPE', 'Badge'),
    p('MySect App Build Blueprint', 'CoverTitle'),
    p('Customer Mobile App, Secretary Firm Website, and MySect Admin Website', 'CoverSubtitle'),
    p('Prepared for Business Partner Alignment & Executive Presentation  |  28 October 2026', 'Smallx'),
]

header_table = Table([[title_block, logo_img]], colWidths=[CONTENT_W - 44 * mm, 44 * mm])
header_table.setStyle(TableStyle([
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 0),
    ('RIGHTPADDING', (0, 0), (-1, -1), 0),
    ('TOPPADDING', (0, 0), (-1, -1), 0),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 0),
]))
story.append(header_table)
story.append(Spacer(1, 2.5 * mm))

story.append(callout_box(
    'EXECUTIVE DECISION — THE 3-MONTH MVP GOAL',
    'Build <b>one shared platform</b> powering <b>three role-specific products</b>. Rather than building disconnected screens, '
    'the first 12-week release proves <b>one complete, end-to-end service flow</b>: guided customer intake via the Digital Assistant, '
    'structured case routing to the assigned Secretary Firm, human conversation, document exchange, formal customer approval, '
    'case completion, and central Admin oversight.',
    accent=NAVY, bg=BLUE_LIGHT
))
story.append(Spacer(1, 2.5 * mm))

kpi_data = [[
    [p('3 Months', 'MetricBig'), p('12-Week MVP Target', 'MetricLabel')],
    [p('3 Products', 'MetricBig'), p('1 Shared Backend', 'MetricLabel')],
    [p('AI + Human', 'MetricBig'), p('Guided Intake, Human Control', 'MetricLabel')],
    [p('100% Isolated', 'MetricBig'), p('Firm & Company Data Security', 'MetricLabel')],
]]
kpi_table = Table(kpi_data, colWidths=[CONTENT_W / 4] * 4)
kpi_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, -1), SLATE_BG),
    ('BOX', (0, 0), (-1, -1), 0.8, BORDER),
    ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_LIGHT),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
]))
story.append(kpi_table)
story.append(Spacer(1, 3 * mm))

story.append(p('Why MySect? (The Business Problem & Platform Solution)', 'H2x'))
story.append(p(
    'Today, company-secretarial work is slowed down by scattered WhatsApp messages, lost email attachments, and repetitive follow-ups. '
    'Business owners lack visibility into their requests, while licensed secretaries spend valuable hours chasing basic details. '
    'MySect connects all three stakeholders on a single, structured workflow:',
    'Bodyx'
))

product_rows = [
    [
        '1. Customer App\n(Flutter Mobile App)',
        'Company owners, directors & authorised contacts',
        '• View authorised companies and compliance reminders at a glance.\n'
        '• Start any request through the Ask MySect Digital Assistant.\n'
        '• Upload requested documents, review prepared drafts, and approve/reject with a reason.\n'
        '• Track live request status and chat with the assigned Secretary once a case is opened.'
    ],
    [
        '2. Secretary Website\n(Responsive Web App)',
        'Partner company-secretary firms (Managers & Staff)',
        '• Receive structured cases pre-packaged by the Digital Assistant (company context + checklist).\n'
        '• Manage all client companies and staff workloads from a central Work Queue.\n'
        '• Take ownership of cases, open human conversations, request files, and send drafts for approval.\n'
        '• Track deadlines, internal notes, and completion records in one workspace.'
    ],
    [
        '3. MySect Admin Website\n(Responsive Web App)',
        'MySect internal operations & support team',
        '• Onboard and manage partner Secretary Firms and their staff accounts.\n'
        '• Assign or transfer client companies to responsible Secretary Firms.\n'
        '• Monitor escalated cases, support issues, and failed notifications.\n'
        '• Configure service categories, Digital Assistant intake rules, and review the full audit history.'
    ],
]
story.append(styled_table(
    ['Product & Platform', 'Who Uses It', 'What It Delivers in Phase 1 (Months 1–3)'],
    product_rows,
    [110, 115, CONTENT_W - 225],
    pad_v=4.0
))
story.append(Spacer(1, 3 * mm))

story.append(p('Document Guide (10-Page Presentation Structure)', 'H2x'))
toc_rows = [
    ['Pages 1–2', 'Executive Summary, Three-Product Ecosystem Diagram & User Roles Breakdown',
     'Pages 6–8', 'Screen-by-Screen Scope: Customer App, Secretary Website, Admin Website & Architecture'],
    ['Pages 3–5', 'Visual Workflows: End-to-End Request Flow, AI Intake Pipeline & Governance/Access Rules',
     'Pages 9–10', '12-Week Delivery Plan, Pilot Acceptance Checklist & Deferred Commercial Decisions'],
]
toc_table = Table(
    [[p(c, 'TableCellBold' if i % 2 == 0 else 'TableCell') for i, c in enumerate(r)] for r in toc_rows],
    colWidths=[56, 199, 56, 199]
)
toc_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, -1), CARD_BG),
    ('BOX', (0, 0), (-1, -1), 0.6, BORDER),
    ('INNERGRID', (0, 0), (-1, -1), 0.4, BORDER_LIGHT),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ('TOPPADDING', (0, 0), (-1, -1), 4.5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4.5),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
]))
story.append(toc_table)
story.append(Spacer(1, 2 * mm))
story.append(p(
    '<b>Scope Note:</b> This document covers confirmed application build requirements only. Unconfirmed vendor pricing, legal conclusions, '
    'direct government (SSM/MBRS) integration, subscription pricing, and external e-KYC providers are listed on Page 10 for partner confirmation.',
    'Smallx'
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 2: ECOSYSTEM DIAGRAM & USER ROLES
# ------------------------------------------------------------------------------
story.append(p('SECTION 1 & 2  •  PLATFORM ECOSYSTEM & STAKEHOLDER ROLES', 'PageHeaderTag'))
story.append(p('How Information Moves Across the Three MySect Products', 'H1x'))
story.append(p(
    'Every user interacts with a product tailored to their role, while the shared MySect platform enforces permissions, '
    'routes cases to the correct Secretary Firm, and saves a complete record of every conversation and document.',
    'Bodyx'
))
story.append(diagram_1_ecosystem())
story.append(Spacer(1, 3 * mm))

story.append(p('Confirmed User Roles & Responsibilities', 'H2x'))
roles_rows = [
    [
        '2.1 Customer\n(Mobile App)',
        'Company owner, director, or authorised representative',
        '• Views only the companies they are explicitly authorised to access.\n'
        '• Starts questions and service requests through the Ask MySect Digital Assistant.\n'
        '• Tracks live request statuses and responds to checklists for missing information.\n'
        '• Uploads requested supporting documents and reviews prepared drafts.\n'
        '• Approves or rejects prepared items (with a reason) and receives status notifications.'
    ],
    [
        '2.2 Secretary Staff\n(Secretary Website)',
        'Licensed secretary or operational staff at a partner firm',
        '• Views only companies and cases assigned to their firm.\n'
        '• Receives structured cases prepared by the Digital Assistant.\n'
        '• Accepts ownership of a case and opens human conversation with the customer.\n'
        '• Requests missing information/documents and uploads prepared items for approval.\n'
        '• Updates case status, records internal notes, and completes the work.'
    ],
    [
        '2.3 Secretary Firm Manager\n(Secretary Website)',
        'Partner, director, or team lead at a secretary firm',
        '• Manages firm staff accounts, roles, and internal access permissions.\n'
        '• Assigns client companies and incoming cases to responsible staff members.\n'
        '• Reviews team workload, urgent queues, and tracked compliance deadlines.\n'
        '• Controls firm templates, service settings, and operational reports.'
    ],
    [
        '2.4 MySect Administrator\n(Admin Website)',
        'MySect platform operations and support team',
        '• Creates, onboards, and manages partner Secretary Firms.\n'
        '• Manages platform users, roles, and access permissions.\n'
        '• Assigns or transfers companies to partner Secretary Firms.\n'
        '• Reviews escalated cases, customer support issues, and failed notifications.\n'
        '• Configures service categories, notification templates, AI intake rules, and audit logs.'
    ],
]
story.append(styled_table(
    ['User Role', 'Who They Are', 'Confirmed Capabilities & Responsibilities'],
    roles_rows,
    [110, 120, CONTENT_W - 230],
    pad_v=3.8
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 3: END-TO-END CUSTOMER REQUEST & WORKFLOWS
# ------------------------------------------------------------------------------
story.append(p('SECTION 6  •  CORE OPERATIONAL WORKFLOWS', 'PageHeaderTag'))
story.append(p('End-to-End Customer Request & Document Workflow', 'H1x'))
story.append(p(
    'This diagram and walkthrough show how a customer question is captured, converted into a structured case, assigned to the '
    'responsible Secretary Firm, supported with documents and approvals, and tracked until completion.',
    'Bodyx'
))
story.append(diagram_2_request_flow())
story.append(Spacer(1, 3 * mm))

story.append(p('Step-by-Step Application Workflows', 'H2x'))
workflow_rows = [
    [
        '6.1 Customer Request\nWorkflow\n(10-Step Core Journey)',
        '1. Customer asks the MySect Digital Assistant in the app.\n'
        '2. The app confirms the company and request type.\n'
        '3. Digital Assistant asks follow-ups for missing info.\n'
        '4. Shared backend creates a structured Case record.\n'
        '5. The assigned Secretary Firm is notified immediately.',
        '6. A Secretary accepts and takes ownership of the case.\n'
        '7. Secretary opens human conversation if required.\n'
        '8. Documents and approvals are exchanged in the case.\n'
        '9. The Secretary completes the case.\n'
        '10. Customer receives final status and full history.'
    ],
    [
        '6.2 Company Assignment\nWorkflow\n(5-Step Onboarding)',
        '1. MySect Admin creates or confirms a company record.\n'
        '2. Admin assigns the company to a Secretary Firm.\n'
        '3. Secretary Firm Manager assigns responsible staff.',
        '4. Authorised customers are linked to the company.\n'
        '5. Every access and assignment is recorded in the audit history.'
    ],
    [
        '6.3 Document & Approval\nWorkflow\n(5-Step Sign-Off)',
        '1. Secretary requests a document or uploads a prepared draft.\n'
        '2. Customer receives a notification in the mobile app.\n'
        '3. Customer uploads, approves, or rejects with a reason.',
        '4. The system records the exact action and timestamp.\n'
        '5. The case status updates automatically for both sides.'
    ],
]
story.append(styled_table(
    ['Workflow Name', 'Initial Stages (Intake & Setup)', 'Execution & Completion Stages'],
    workflow_rows,
    [115, 197, 198],
    pad_v=3.8
))
story.append(Spacer(1, 2.5 * mm))
story.append(callout_box(
    'KEY WORKFLOW CONTROL PRINCIPLE',
    'Every request, chat message, uploaded file, and customer approval passes through the structured MySect Case record. '
    'Nothing gets lost in personal WhatsApp chats or unmonitored email threads.',
    accent=TEAL, bg=TEAL_LIGHT
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 4: DIGITAL ASSISTANT INTAKE PIPELINE (AI PREPARES, HUMANS DECIDE)
# ------------------------------------------------------------------------------
story.append(p('SECTION 3.4 & 6.1  •  AI-GUIDED INTAKE VS. HUMAN SECRETARY CONTROL', 'PageHeaderTag'))
story.append(p('How the Digital Assistant Prepares a Case for the Secretary', 'H1x'))
story.append(p(
    'A core differentiator of MySect is how it combines AI speed with licensed human professionalism. Customers cannot open '
    'random human chats directly—the Digital Assistant prepares a complete, structured case first so Secretaries never start from a blank page.',
    'Bodyx'
))
story.append(diagram_3_ai_intake())
story.append(Spacer(1, 3.5 * mm))

story.append(p('Clear Division of Responsibility: Digital Assistant vs. Human Secretary', 'H2x'))
ai_vs_human_rows = [
    [
        '1. Initial Contact',
        'Greets the customer 24/7 in Ask MySect, confirms which company they are asking about, and identifies the request category.',
        'Not interrupted by vague or incomplete initial messages; receives an alert only when a structured case is ready.'
    ],
    [
        '2. Information Gathering',
        'Asks structured follow-up questions based on Admin-configured rules and collects initial supporting files from the customer.',
        'Reviews the AI-prepared issue summary, transcript, and missing-information checklist in the Secretary Website.'
    ],
    [
        '3. Case Ownership & Chat',
        'Packages the structured Case Record and hands off to the firm queue. Cannot impersonate a licensed company secretary.',
        'Accepts ownership of the case and decides when to open a direct human conversation thread with the customer.'
    ],
    [
        '4. Documents & Approvals',
        'Can only use information the requesting customer is already authorised to access.',
        'Prepares official resolutions/documents, uploads them for customer sign-off, verifies approvals, and marks the case complete.'
    ],
]
story.append(styled_table(
    ['Stage', 'What the Digital Assistant Does (Automated Prep)', 'What the Assigned Human Secretary Controls'],
    ai_vs_human_rows,
    [95, 207, 208],
    accent=TEAL,
    pad_v=4.2
))
story.append(Spacer(1, 3 * mm))
story.append(callout_box(
    'WHY PARTNER SECRETARY FIRMS VALUE THIS MODEL',
    'The Digital Assistant acts as an intelligent front-desk intake coordinator—eliminating repetitive back-and-forth '
    'questions while keeping <b>100% of professional judgment, statutory compliance, and client approvals under the control of the assigned Secretary</b>.',
    accent=AMBER, bg=AMBER_LIGHT
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 5: SIGN-IN, GOVERNANCE & ACCESS RULES
# ------------------------------------------------------------------------------
story.append(p('SECTION 9  •  SECURITY, MULTI-TENANT GOVERNANCE & ACCESS RULES', 'PageHeaderTag'))
story.append(p('Sign-In, Company Assignment & Data Isolation Rules', 'H1x'))
story.append(p(
    'Because MySect hosts multiple company-secretary firms and many client companies on one platform, strict tenant isolation '
    'is built into every database record and API check.',
    'Bodyx'
))
story.append(diagram_4_governance())
story.append(Spacer(1, 3.5 * mm))

story.append(p('Confirmed Access & Data Protection Rules (Section 9)', 'H2x'))
access_rows = [
    [
        '1. Customer Company Isolation',
        'A Customer sees and interacts ONLY with companies they are explicitly authorised to access. If a director owns three companies, they see only those three.'
    ],
    [
        '2. Secretary Firm Isolation',
        'Secretary Firm staff see ONLY companies assigned to their specific firm. One partner firm can never see another firm\'s clients, staff, or cases.'
    ],
    [
        '3. Role-Based Case Visibility',
        'Within a Secretary Firm, staff see cases assigned to their firm and filtered according to their staff role (Secretary Staff vs. Firm Manager).'
    ],
    [
        '4. Administrator Scope Control',
        'MySect Admin access is strictly limited by administrator role permissions for platform operations, firm onboarding, and support.'
    ],
    [
        '5. Document & File Security',
        'File access follows the exact same company and case permissions as the parent record. Uploaded and generated files are never exposed via public links.'
    ],
    [
        '6. Digital Assistant Data Boundary',
        'The Digital Assistant can access ONLY information that the requesting user is already authorised to view—preventing any cross-company data leakage.'
    ],
    [
        '7. Mandatory Audit Trail',
        'Every important access, sign-in, company assignment, document upload, approval decision, or configuration change is written to the immutable Audit History.'
    ],
]
story.append(styled_table(
    ['Security & Governance Rule', 'How It Is Enforced Across MySect'],
    access_rows,
    [150, CONTENT_W - 150],
    pad_v=4.0
))
story.append(Spacer(1, 3 * mm))
story.append(callout_box(
    'DATABASE ENFORCEMENT RULE',
    'Every business record in MySect includes both the <b>Company ID</b> and the <b>Responsible Organisation (Secretary Firm ID)</b> '
    'so access permissions are verified consistently on every screen, API request, and file download.',
    accent=NAVY, bg=BLUE_LIGHT
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 6: PRODUCT 1 — CUSTOMER MOBILE APP PAGES
# ------------------------------------------------------------------------------
story.append(p('SECTION 3  •  PRODUCT 1 SCOPE & SCREEN INVENTORY', 'PageHeaderTag'))
story.append(p('Product 1: Customer Mobile App (Flutter — iOS & Android)', 'H1x'))
story.append(p(
    'The Customer App gives business owners and company representatives a clean mobile experience to view their companies, '
    'start requests through Ask MySect, upload files, and approve documents without needing to understand internal secretarial jargon.',
    'Bodyx'
))

cust_pages_rows = [
    [
        '3.1 Access\n(Onboarding & Auth)',
        '• Welcome screen\n• Sign in & Registration\n• Password recovery\n• Account verification',
        'Provides secure onboarding, credential recovery, and account verification before granting access to any company records.'
    ],
    [
        '3.2 Home\n(Action Dashboard)',
        '• Company summary\n• Open requests overview\n• Items requiring customer action\n• Important reminders\n• Recent notifications',
        'Highlights urgent items (such as pending document uploads or approvals) immediately upon opening the app.'
    ],
    [
        '3.3 My Companies\n(Company Portfolio)',
        '• Authorised company list\n• Company overview & contacts\n• Assigned Secretary Firm details\n• Open and completed requests\n• Company documents & approvals',
        'Organises all records cleanly by company so directors managing multiple entities can switch between them effortlessly.'
    ],
    [
        '3.4 Ask MySect\n(Guided AI Intake)',
        '• Start a question with Digital Assistant\n• Select or confirm the company\n• Answer structured follow-up questions\n• Upload supporting files\n• Review issue summary & submit case',
        'Guides the customer through a structured intake conversation and packages a complete case for the assigned Secretary Firm.\n'
        '<i>Note: Customers cannot open a raw human chat here; the Secretary opens human chat after accepting the case.</i>'
    ],
    [
        '3.5 Requests\n(Case Tracker & Chat)',
        '• Request list & Request details\n• Current status & Required information\n• Activity history & Assigned Secretary\n• Human conversation (once opened)',
        'Gives complete visibility into every active and past request, required actions, and direct conversation with the assigned Secretary.'
    ],
    [
        '3.6 Documents & Approvals\n(Vault & Sign-Off)',
        '• Document list & Upload requested doc\n• View prepared document\n• Review approval request\n• Approve or reject with a reason\n• View approval history',
        'Centralises all company files and captures formal, timestamped customer approvals or rejections with mandatory reasons.'
    ],
    [
        '3.7 Notifications & Profile\n(Account Settings)',
        '• Notification centre\n• Profile details\n• Security & Privacy settings\n• Help and support',
        'Allows customers to review past alerts, manage personal security settings, and reach platform support.'
    ],
]
story.append(styled_table(
    ['App Page Group', 'Confirmed Screens & Elements', 'How It Helps the Customer'],
    cust_pages_rows,
    [115, 165, CONTENT_W - 280],
    accent=BLUE,
    pad_v=4.5
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 7: PRODUCT 2 — SECRETARY WEBSITE PAGES
# ------------------------------------------------------------------------------
story.append(p('SECTION 4  •  PRODUCT 2 SCOPE & WORKSPACE INVENTORY', 'PageHeaderTag'))
story.append(p('Product 2: Secretary Website (Partner Firm Workspace)', 'H1x'))
story.append(p(
    'The Secretary Website is a responsive web workspace built for partner company-secretary firms. It organises incoming '
    'AI-prepared requests, team workloads, client chats, documents, and compliance deadlines into one unified operational system.',
    'Bodyx'
))

sec_pages_rows = [
    [
        '4.1 Access\n(Staff Security)',
        '• Staff sign in\n• Password recovery\n• Additional security verification',
        'Ensures only authorised firm staff can access their firm\'s assigned client companies and workspaces.'
    ],
    [
        '4.2 Dashboard\n(Firm Command Centre)',
        '• New requests prepared by Digital Assistant\n• Assigned work summary\n• Urgent and overdue cases\n• Items waiting for customer info/approval\n• Recent activity',
        'Gives staff and managers an instant daily overview of new escalations, urgent priorities, and items blocked by clients.'
    ],
    [
        '4.3 New Customer Requests\n(AI Triage Queue)',
        '• New case queue & AI issue summary\n• Company and customer context\n• Request category & urgency\n• Missing-information checklist\n• Accept, assign, or return for more info',
        'Eliminates manual intake—Secretaries review a structured brief and immediately accept ownership, assign to staff, or request missing details.'
    ],
    [
        '4.4 Work Queue\n(Case Management)',
        '• All firm cases in one view\n• Filters: owner, company, status, priority, due date\n• Bulk assignment & Case status changes\n• Internal notes',
        'Enables fast filtering, workload balancing, and status tracking across all active cases in the firm.'
    ],
    [
        '4.5 Case Workspace\n(Execution View)',
        '• Request summary & AI chat history\n• Human conversation & Internal notes\n• Requested information, Documents & Approvals\n• Activity timeline & Completion details',
        'Brings the entire lifecycle of a case onto a single screen—AI intake transcript, human client chat, private staff notes, files, and sign-off.'
    ],
    [
        '4.6 Companies\n(Client Portfolio)',
        '• Company list, Overview & Customer contacts\n• Directors/officers & Shareholders summary\n• Assigned staff\n• Requests, documents, and activity history',
        'Provides a complete digital corporate file for every company assigned to the Secretary Firm.'
    ],
    [
        '4.7 Calendar & Team\n(Deadlines & Staff)',
        '• Tracked deadlines & Work reminders\n• Team members, Roles and access\n• Staff workload view & Assignment rules',
        'Helps Firm Managers track statutory/work deadlines, manage team permissions, and distribute cases fairly.'
    ],
    [
        '4.8 Firm Settings\n(Firm Configuration)',
        '• Firm profile & Staff management\n• Service categories & Templates\n• Notification preferences & Security settings',
        'Lets each Secretary Firm maintain its own profile, standard document templates, and operational settings.'
    ],
]
story.append(styled_table(
    ['Workspace Module', 'Confirmed Screens & Features', 'Operational Value for the Secretary Firm'],
    sec_pages_rows,
    [115, 175, CONTENT_W - 290],
    accent=TEAL,
    pad_v=4.0
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 8: PRODUCT 3 — ADMIN WEBSITE + ARCHITECTURE & DATA RECORDS
# ------------------------------------------------------------------------------
story.append(p('SECTION 5, 7 & 8  •  ADMIN PORTAL, SYSTEM ARCHITECTURE & DATA MODEL', 'PageHeaderTag'))
story.append(p('Product 3: MySect Admin Website & Platform Architecture', 'H1x'))
story.append(p(
    'The MySect Admin Website provides central governance for onboarding partner firms, assigning companies, handling escalations, '
    'and auditing platform activity—all powered by a modular 4-layer technical architecture.',
    'Bodyx'
))

admin_pages_rows = [
    [
        '5.1 Dashboard',
        '• Active secretary firms & Active companies\n• Open escalations & Support cases\n• Failed notifications & Recent admin activity',
        'Real-time visibility into platform adoption, service exceptions, and operational health.'
    ],
    [
        '5.2 Secretary Firms',
        '• Firm list, Create and edit firm, Firm status\n• Staff accounts, Assigned companies, Operational history',
        'Full lifecycle onboarding and monitoring of partner company-secretary firms.'
    ],
    [
        '5.3 Companies & Assignments',
        '• Company list & Company details\n• Assign or transfer Secretary Firm\n• Customer contacts, Access review, Case/doc activity',
        'Central control to map companies to partner firms and transfer assignments cleanly when required.'
    ],
    [
        '5.4 Users & Access',
        '• Customer, Secretary, and Administrator users\n• Roles and permissions, Account status, Sign-in history',
        'Manage user accounts across all three products and audit sign-in security.'
    ],
    [
        '5.5 Cases & Support',
        '• Platform-wide case search & Escalated cases\n• Customer support cases, Assignment correction, Issue history',
        'Investigate escalated cases, resolve assignment issues, and support customers and firms.'
    ],
    [
        '5.6 Configuration & Audit',
        '• Service categories, Case statuses, Notification templates\n• Digital-Assistant question rules & Feature switches\n• Full Audit history & System activity',
        'Configure platform workflows and AI intake rules centrally while maintaining a complete audit trail.'
    ],
]
story.append(styled_table(
    ['Admin Module', 'Confirmed Screens & Controls', 'Platform Governance Purpose'],
    admin_pages_rows,
    [110, 185, CONTENT_W - 295],
    accent=NAVY,
    pad_v=3.8
))
story.append(Spacer(1, 2.5 * mm))

story.append(p('Application Architecture (Section 7) & Core Data Records (Section 8)', 'H2x'))
arch_rows = [
    [
        '7.1 Frontend Apps',
        '• <b>Customer Mobile App:</b> Flutter (iOS & Android).\n'
        '• <b>Secretary Website:</b> Responsive web application.\n'
        '• <b>MySect Admin Website:</b> Responsive web application.',
        '8. Core Database Records\n(15 Foundational Entities)',
        '• <b>Identity & Tenants:</b> User, Role, Secretary Firm, Company, Company User.\n'
        '• <b>Assignments:</b> Firm Assignment, Staff Assignment.\n'
        '• <b>Cases & Chat:</b> Case, Case Message, Internal Note.\n'
        '• <b>Files & Governance:</b> Document Record, Document Version, Approval Request, Notification, Audit Event.'
    ],
    [
        '7.2 Shared Backend &\n7.3 Data Services',
        '• Auth & role access control, Company/assignment mgmt, Case/chat mgmt, Document/approval mgmt, Notifications, Audit & Reporting.\n'
        '• Relational database + File-storage adapter + Notification adapter + <b>Provider-neutral Digital Assistant connection</b> (swap AI vendors without rebuilding workflows).',
        '7.4 Deployment Structure',
        '• Hosted on the <b>existing Windows Server</b> environment using agreed container services.\n'
        '• Strict separation of <b>Development</b>, <b>Testing</b>, and <b>Production</b> databases, files, and secrets.\n'
        '• Backup and restore procedures tested before pilot launch.'
    ],
]
story.append(styled_table(
    ['Architecture Layer', 'Confirmed Technical Scope', 'Data & Hosting Layer', 'Confirmed Records & Infrastructure'],
    arch_rows,
    [92, 163, 92, 163],
    accent=BLUE,
    pad_v=3.8
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 9: 3-MONTH DELIVERY PLAN & PILOT ACCEPTANCE CRITERIA
# ------------------------------------------------------------------------------
story.append(p('SECTION 10 & 11  •  EXECUTION ROADMAP & QUALITY GATES', 'PageHeaderTag'))
story.append(p('Three-Month (12-Week) Delivery Plan & Acceptance Criteria', 'H1x'))
story.append(p(
    'The first working version is structured into four pragmatic sprints over 12 weeks. Each phase builds toward proving one '
    'complete, secure customer request workflow across all three products.',
    'Bodyx'
))

roadmap_rows = [
    [
        'Phase 1\nWeeks 1–2',
        'Confirm & Prepare\n(Foundation)',
        '• Freeze the first priority customer service workflow.\n'
        '• Confirm final page list and role permissions across all 3 products.\n'
        '• Confirm database records and standard case status names.\n'
        '• Create clickable screen flows for visual alignment.\n'
        '• Prepare isolated development, testing, and container deployment environments.'
    ],
    [
        'Phase 2\nWeeks 3–6',
        'Shared Backend &\nCustomer App',
        '• Build core authentication and role-based access control.\n'
        '• Build company setup and firm/user assignment services.\n'
        '• Build Customer App: Home and My Companies screens.\n'
        '• Build Ask MySect guided intake flow.\n'
        '• Implement structured case creation, live status tracking, initial document upload, and notifications.'
    ],
    [
        'Phase 3\nWeeks 7–9',
        'Secretary Website\n(Firm Workspace)',
        '• Build Secretary Dashboard and New Customer Requests triage queue.\n'
        '• Build filterable Work Queue and unified Case Workspace.\n'
        '• Enable Secretary-initiated human conversation and information requests.\n'
        '• Complete end-to-end document exchange and formal customer approval/rejection workflows.'
    ],
    [
        'Phase 4\nWeeks 10–12',
        'Admin Website &\nPilot Preparation',
        '• Build Admin Website: Secretary Firm management, user management, and company assignment.\n'
        '• Build Admin case/support oversight, system configuration, and audit history pages.\n'
        '• Execute comprehensive role and company permission security testing.\n'
        '• Verify backup and restore procedures, load pilot data, and complete User Acceptance Testing (UAT).'
    ],
]
story.append(styled_table(
    ['Timeline', 'Milestone Focus', 'Confirmed Deliverables'],
    roadmap_rows,
    [72, 108, CONTENT_W - 180],
    accent=NAVY,
    pad_v=3.8
))
story.append(Spacer(1, 3 * mm))

story.append(p('Pilot Acceptance Criteria — Definition of Done for Version 1 (Section 11)', 'H2x'))
story.append(p(
    'The first working version is ready for live pilot use when all 11 end-to-end verification checks below pass:',
    'Bodyx'
))

criteria_rows = [
    ['✓  1. Customer Sign-In & Company View', 'Customer can sign in securely and view an authorised company.',
     '✓  7. Recorded Customer Approval', 'Customer approval or rejection (with reason) is recorded with a timestamp.'],
    ['✓  2. Guided Intake & Case Creation', 'Customer can complete the guided intake in Ask MySect and create a case.',
     '✓  8. Admin Firm & Company Control', 'MySect Admin can create firms, manage users, and assign companies.'],
    ['✓  3. Accurate Firm Routing', 'The correct assigned Secretary Firm receives the new case immediately.',
     '✓  9. Access Isolation Verification', 'All role, firm, and company access restriction tests pass 100%.'],
    ['✓  4. Full Secretary Case Lifecycle', 'Secretary can accept, assign, update, and complete the case.',
     '✓  10. Complete Audit History', 'Every important user, case, and admin action appears in the audit history.'],
    ['✓  5. Controlled Human Conversation', 'Secretary can open human conversation after taking case ownership.',
     '✓  11. Backup & Recovery Verified', 'Database and file backup and restore tests pass before pilot launch.'],
    ['✓  6. Case Document Exchange', 'Customer and Secretary can exchange documents securely through the case.',
     '✓  Pilot Sign-Off Ready', 'All three products operate seamlessly on the shared backend environment.'],
]
story.append(styled_table(
    ['Acceptance Check (Customer & Secretary)', 'Verification Requirement', 'Acceptance Check (Governance & Ops)', 'Verification Requirement'],
    criteria_rows,
    [115, 140, 115, 140],
    accent=TEAL,
    pad_v=3.8
))

story.append(PageBreak())

# ------------------------------------------------------------------------------
# PAGE 10: DECISIONS DELIBERATELY DEFERRED & FINAL RECOMMENDATION
# ------------------------------------------------------------------------------
story.append(p('SECTION 12  •  SCOPE BOUNDARIES & COMMERCIAL ALIGNMENT ITEMS', 'PageHeaderTag'))
story.append(p('Decisions Deliberately Deferred for Partner Confirmation', 'H1x'))
story.append(p(
    'To keep the 3-month build realistic and avoid locking in unconfirmed vendor contracts or legal assumptions prematurely, '
    'the nine items below are deliberately separated from Phase 1 engineering. These items will be added only after the '
    '<b>business owner, company-secretary expert, legal adviser, or selected vendor</b> confirms them.',
    'Bodyx'
))

deferred_rows = [
    [
        '1. Digital-Assistant Provider & Final Pricing',
        'Model vendor selection and commercial API/token pricing are under evaluation.',
        'Backend uses a provider-neutral AI adapter so the selected LLM vendor can be connected or changed without rebuilding app screens.'
    ],
    [
        '2. Cloud-Storage Vendor & Storage Pricing',
        'Final cloud object storage quotation and vendor contract are pending confirmation.',
        'File-storage adapter abstracts file handling so storage can switch seamlessly between host containers and cloud object storage.'
    ],
    [
        '3. External Identity Verification (e-KYC)',
        'Whether third-party e-KYC is legally/operationally required is still being confirmed.',
        'Account verification states are built into the User model; an external e-KYC provider can be plugged into registration later.'
    ],
    [
        '4. Payment Provider & Marketplace Model',
        'Payment gateway selection, fee splits, and marketplace billing terms require commercial sign-off.',
        'Phase 1 proves core service delivery first; billing and payment collection modules can be layered onto active company accounts next.'
    ],
    [
        '5. Customer & Secretary Subscription Prices',
        'Final monthly/annual pricing tiers and company allocation limits per firm are business decisions.',
        'Firm and Company assignment tables are structured to support plan limits and subscription tiers once pricing is finalised.'
    ],
    [
        '6. Direct Government-System Submission',
        'Direct electronic filing to SSM / MBRS requires regulatory approval and technical specification.',
        'Phase 1 tracks preparation, customer approvals, and filing status while licensed secretaries lodge via MBRS as they do today.'
    ],
    [
        '7. Final Legal & Compliance Workflow',
        'Specific statutory templates, resolution wordings, and compliance sign-offs require expert review.',
        'Case checklists, templates, and approval workflows are configurable by Admin and Secretary Firms without code changes.'
    ],
    [
        '8. Secretary Mobile App',
        'Secretarial work involves multi-company tables and document review best suited for desktop web.',
        'The responsive Secretary Website covers Phase 1; the shared backend API can power a companion mobile app in a future phase.'
    ],
    [
        '9. Advanced Reporting & Automation',
        'Advanced analytics and automated workflows are most effective after gathering real pilot usage data.',
        'Structured case timestamps and audit logs capture all foundational data needed for Phase 2 business intelligence.'
    ],
]
story.append(styled_table(
    ['Deferred Item (Section 12)', 'Why It Is Deferred Now', 'How the Phase 1 Architecture Stays Ready'],
    deferred_rows,
    [135, 165, CONTENT_W - 300],
    accent=NAVY,
    pad_v=4.0
))
story.append(Spacer(1, 4 * mm))

story.append(callout_box(
    'FINAL BUILD RECOMMENDATION — PROVE ONE COMPLETE END-TO-END FLOW FIRST',
    '<b>Build and test one complete request workflow across all three products before adding more service types.</b><br/>'
    'The true first milestone is not the raw number of static screens completed—it is a <b>secure, auditable end-to-end flow</b> '
    'that a real Customer, Partner Secretary Firm, and MySect Administrator can use together successfully from initial question to completed case.',
    accent=TEAL, bg=TEAL_LIGHT
))

# Build PDF
doc = SimpleDocTemplate(
    str(OUTPUT_MAIN),
    pagesize=A4,
    leftMargin=MARGIN_X,
    rightMargin=MARGIN_X,
    topMargin=15 * mm,
    bottomMargin=16 * mm,
    title='MySect App Build Blueprint — Business & Technical Presentation',
    author='MySect Platform Team',
)
doc.build(story, onFirstPage=decorate_page, onLaterPages=decorate_page)

shutil.copyfile(OUTPUT_MAIN, OUTPUT_NUMBERED)
print('Compiled successfully:', OUTPUT_MAIN, 'and', OUTPUT_NUMBERED)
