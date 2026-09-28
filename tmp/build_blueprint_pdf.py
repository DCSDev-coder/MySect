from pathlib import Path
import re
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Preformatted, KeepTogether

ROOT = Path('/Users/marketingdeveloper/DCStack/MySect')
SOURCE = ROOT / 'Documentation/MYSECT_PLATFORM_BLUEPRINT.md'
OUTPUT = ROOT / 'output/pdf/MYSECT_PLATFORM_BLUEPRINT.pdf'
OUTPUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#123B6D')
BLUE = colors.HexColor('#1D6FA5')
TEAL = colors.HexColor('#087E8B')
INK = colors.HexColor('#243447')
MUTED = colors.HexColor('#5F6B76')
LIGHT = colors.HexColor('#EEF4F8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='DocTitle', parent=styles['Title'], fontName='Helvetica-Bold', fontSize=25, leading=31, textColor=NAVY, alignment=TA_CENTER, spaceAfter=8))
styles.add(ParagraphStyle(name='Subtitle', parent=styles['Normal'], fontName='Helvetica', fontSize=11, leading=15, textColor=MUTED, alignment=TA_CENTER, spaceAfter=20))
styles.add(ParagraphStyle(name='H1x', parent=styles['Heading1'], fontName='Helvetica-Bold', fontSize=17, leading=21, textColor=NAVY, spaceBefore=15, spaceAfter=7, keepWithNext=True))
styles.add(ParagraphStyle(name='H2x', parent=styles['Heading2'], fontName='Helvetica-Bold', fontSize=12.5, leading=16, textColor=BLUE, spaceBefore=10, spaceAfter=5, keepWithNext=True))
styles.add(ParagraphStyle(name='H3x', parent=styles['Heading3'], fontName='Helvetica-Bold', fontSize=10.5, leading=14, textColor=TEAL, spaceBefore=7, spaceAfter=3, keepWithNext=True))
styles.add(ParagraphStyle(name='Bodyx', parent=styles['BodyText'], fontName='Helvetica', fontSize=9.3, leading=13.2, textColor=INK, spaceAfter=5))
styles.add(ParagraphStyle(name='Bulletx', parent=styles['BodyText'], fontName='Helvetica', fontSize=9.1, leading=12.5, leftIndent=13, firstLineIndent=-8, textColor=INK, spaceAfter=3))
styles.add(ParagraphStyle(name='Smallx', parent=styles['BodyText'], fontName='Helvetica', fontSize=7.6, leading=10, textColor=MUTED, spaceAfter=3))
styles.add(ParagraphStyle(name='Callout', parent=styles['BodyText'], fontName='Helvetica-Bold', fontSize=10, leading=14, textColor=NAVY, backColor=LIGHT, borderColor=colors.HexColor('#C8DCEB'), borderWidth=0.6, borderPadding=8, spaceBefore=5, spaceAfter=9))
styles.add(ParagraphStyle(name='Codex', parent=styles['Code'], fontName='Courier', fontSize=7.2, leading=9.5, textColor=INK, backColor=colors.HexColor('#F5F7F9'), borderColor=colors.HexColor('#DDE5EB'), borderWidth=0.5, borderPadding=7, spaceBefore=4, spaceAfter=7))

def inline(text):
    text = text.strip()
    text = re.sub(r'!\[([^]]*)\]\([^)]*\)', r'\1', text)
    def link(m):
        return '<link href="%s" color="#1D6FA5">%s</link>' % (m.group(2), m.group(1))
    text = re.sub(r'\[([^]]+)\]\(([^)]+)\)', link, text)
    text = re.sub(r'`([^`]+)`', r'<font name="Courier">\1</font>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'__([^_]+)__', r'<b>\1</b>', text)
    text = re.sub(r'(?<!\*)\*([^*]+)\*(?!\*)', r'<i>\1</i>', text)
    return text

def add_text(story, text, style='Bodyx'):
    if text.strip():
        story.append(Paragraph(inline(text), styles[style]))

def footer(canvas, doc):
    canvas.saveState()
    width, height = A4
    canvas.setStrokeColor(colors.HexColor('#D8E3EA'))
    canvas.setLineWidth(0.5)
    canvas.line(18*mm, 14*mm, width-18*mm, 14*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(18*mm, 9*mm, 'MySect Platform Blueprint | Confidential planning document')
    canvas.drawRightString(width-18*mm, 9*mm, f'Page {doc.page}')
    canvas.restoreState()

lines = SOURCE.read_text(encoding='utf-8').splitlines()
story = []
story.append(Spacer(1, 12*mm))
story.append(Paragraph('MySect Platform Blueprint', styles['DocTitle']))
story.append(Paragraph('Company-secretary operating platform for Customers, Secretary Firms, and MySect Administration', styles['Subtitle']))
story.append(Paragraph('Decision document for product scope, architecture, AI, deployment, pricing, and implementation planning', styles['Subtitle']))
story.append(Spacer(1, 5*mm))
story.append(Paragraph('Executive decision', styles['H2x']))
story.append(Paragraph('MySect should be built as one secure multi-tenant platform with three role-specific experiences: a customer mobile app, a secretary firm workspace, and a MySect admin console. Customer support should be AI-first and secretary-controlled: the AI gathers the issue, creates a structured case, and escalates it; only an assigned secretary opens human chat.', styles['Callout']))
story.append(Spacer(1, 6*mm))
story.append(Paragraph('Prepared for management review | 28 September 2026', styles['Smallx']))
story.append(PageBreak())

in_code = False
code = []
list_mode = None
for raw in lines:
    line = raw.rstrip()
    if line.startswith('```'):
        if in_code:
            story.append(Preformatted('\n'.join(code), styles['Codex']))
            code = []
            in_code = False
        else:
            in_code = True
        continue
    if in_code:
        code.append(line)
        continue
    if not line.strip():
        continue
    if line.startswith('# '):
        continue
    if line.startswith('## '):
        add_text(story, line[3:], 'H1x')
        list_mode = None
        continue
    if line.startswith('### '):
        add_text(story, line[4:], 'H2x')
        list_mode = None
        continue
    if line.startswith('#### '):
        add_text(story, line[5:], 'H3x')
        list_mode = None
        continue
    m = re.match(r'^[-*]\s+(.*)', line)
    if m:
        add_text(story, u'• ' + m.group(1), 'Bulletx')
        list_mode = 'bullet'
        continue
    m = re.match(r'^\d+\.\s+(.*)', line)
    if m:
        add_text(story, m.group(0), 'Bulletx')
        list_mode = 'number'
        continue
    if line.startswith('> '):
        add_text(story, line[2:], 'Callout')
        continue
    if line.startswith('|'):
        # Render markdown tables as readable compact rows; preserve all decision content.
        if set(line.replace('|','').replace('-','').replace(':','').strip()) == set():
            continue
        cells = [c.strip() for c in line.strip('|').split('|')]
        rendered = '  |  '.join(cells)
        add_text(story, rendered, 'Smallx')
        continue
    add_text(story, line, 'Bodyx')

doc = SimpleDocTemplate(str(OUTPUT), pagesize=A4, rightMargin=18*mm, leftMargin=18*mm, topMargin=17*mm, bottomMargin=19*mm, title='MySect Platform Blueprint', author='MySect')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(OUTPUT)
