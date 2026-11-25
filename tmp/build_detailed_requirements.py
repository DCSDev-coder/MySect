from pathlib import Path
import re, html, textwrap
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted, PageBreak
from pypdf import PdfReader, PdfWriter

root=Path('/Users/marketingdeveloper/DCStack_Development/MySect')
src=root/'Documentation/MYSECT_PROJECT_REQUIREMENTS.md'
front=root/'Documentation/MYSECT_PROJECT_REQUIREMENTS_REVISED.pdf'
detail=Path('/tmp/mysect_detailed_appendix.pdf')
out=Path('/tmp/mysect_detailed_complete.pdf')
pdfmetrics.registerFont(TTFont('ArialUnicode','/System/Library/Fonts/Supplemental/Arial Unicode.ttf'))
navy=colors.HexColor('#102d52')
normal=ParagraphStyle('body',fontName='ArialUnicode',fontSize=9,leading=13,spaceAfter=6,textColor=colors.HexColor('#1a2b3d'))
heading=ParagraphStyle('heading',parent=normal,fontSize=14,leading=19,spaceBefore=11,spaceAfter=6,textColor=navy,keepWithNext=True)
sub=ParagraphStyle('sub',parent=heading,fontSize=11,leading=15,spaceBefore=8)
code=ParagraphStyle('code',fontName='Courier',fontSize=7,leading=9,textColor=colors.HexColor('#26384b'))
bullet=ParagraphStyle('bullet',parent=normal,leftIndent=15,firstLineIndent=-12,spaceAfter=5)
note=ParagraphStyle('note',parent=normal,fontSize=8.3,leading=11,textColor=colors.HexColor('#6b4350'))
doc=SimpleDocTemplate(str(detail),pagesize=A4,leftMargin=48,rightMargin=48,topMargin=59,bottomMargin=48,title='MySect detailed requirements appendix')
story=[Paragraph('Detailed requirements and historical planning material',heading),Paragraph('Read with the current decision register and the updated diagrams and schedule at the front of this document. Detailed technical examples, model prices, legal statements, performance claims, schema, signature and filing examples below are historical or proposed and are not approved or verified. The current decision register takes precedence in case of conflict.',note)]
def clean(s):
    s=html.escape(s.strip()); s=re.sub(r'\*\*(.*?)\*\*',r'<b>\1</b>',s); s=re.sub(r'(?<!\*)\*([^*]+)\*',r'<i>\1</i>',s); s=re.sub(r'`([^`]+)`',r'\1',s); s=re.sub(r'\[([^]]+)\]\([^)]+\)',r'\1',s); s=s.replace('&lt;br&gt;','<br/>').replace('&lt;br/&gt;','<br/>'); return s
def add(text,st=normal):
    text=text.replace('Every database query is cryptographically scoped','Database access should be scoped').replace('Cross-tenant data leakage is prevented','Cross-tenant data leakage must be prevented').replace('Self-hosted MySQL 8.4 LTS operates','A self-hosted MySQL deployment can operate').replace('hardcoded mock lists (`Data Center Specialists Sdn Bhd`, `5Luxe Scents Co.`)','hardcoded example company lists').replace('hardcoded mock lists (`Data Center Specialists Sdn Bhd`, `5Luxe Scents Co.`)','hardcoded example company lists')
    if text.strip(): story.append(Paragraph(clean(text),st))
lines=src.read_text().splitlines(); i=0
while i<len(lines):
    line=lines[i]
    if line.startswith('### 1.5 '):
        add('1.5 Host and deployment architecture',sub)
        add('Windows Server is the intended host. Confirm the supported container runtime and hosting configuration before implementation. The following remain proposals:')
        for item in ['Deploy the backend, administration and other approved services with suitable isolation and resource limits.', 'Use a reverse proxy and HTTPS for application entry, subject to security review.', 'Monitor the system and maintain separate, tested database and file backups.', 'Confirm host capacity, operating ownership, encryption and recovery objectives.']: add('• '+item,bullet)
        i+=1
        while i<len(lines) and not lines[i].startswith('## 2. '): i+=1
        continue
    if line.startswith('### 2.1 '):
        add('2.1 Proposed AI functions and boundaries',sub)
        for item in ['Guide customer intake and identify information that may be missing.', 'Produce a case summary for secretary review; accuracy and performance must be tested.', 'Document extraction and pre-screening are possible future capabilities, subject to scope, privacy review and validation.', 'The secretary remains responsible for professional decisions. AI must not independently file or approve documents.']: add('• '+item,bullet)
        i+=1
        while i<len(lines) and not lines[i].startswith('### 2.2 '): i+=1
        continue
    if line.startswith('### 2.2 '):
        add('2.2 AI options and cost review',sub)
        add('AI provider, hosting location, model, hardware, cost and privacy terms remain undecided. Earlier price estimates and performance or data-sovereignty guarantees have been removed because they were not verified and may no longer be accurate.')
        add('Compare options using actual workloads, current vendor pricing, contractual terms, security review and testing before selecting a provider.')
        i+=1
        while i<len(lines) and not lines[i].startswith('### 2.3 '): i+=1
        continue
    if line.startswith('### 2.3 '):
        add('2.3 AI integration approach',sub)
        add('A replaceable AI integration is proposed. Local and external providers require assessment of compatibility, privacy, cost, security and performance. Changing providers can require configuration changes and additional testing.')
        i+=1
        while i<len(lines) and not lines[i].startswith('## 3. '): i+=1
        continue
    if line.startswith('## 4. '):
        add('4. Malaysian legal and regulatory review',heading)
        add('The following are discussion points for qualified advisers, not a legal opinion or confirmation of compliance.')
        for item in [
          'SSM states that a qualified person must register and obtain a practising certificate to act as a company secretary under section 241. Confirm the requirements applicable to each role.',
          'SSM describes MBRS 2.0 roles for makers and lodgers. Determine the appropriate submission process for each service; an external filing integration is not yet approved.',
          'Review the Personal Data Protection Act 2010, its amendments and applicable standards and guidance with qualified advisers. Confirm the controls and obligations that apply to MySect.',
          'The appropriate approval and signature method depends on the document and applicable law. No electronic-signature approach is approved.'
        ]: add('• '+item,bullet)
        add('Official references: SSM registered secretaries: https://www.ssm.com.my/Pages/Licensed_Secretary_Auditors/List-Registered-Secretaries.aspx')
        add('SSM MBRS 2.0: https://www.ssm.com.my/Pages/Services/Other-Services/MBRS.aspx')
        add('Personal Data Protection Department: https://www.pdp.gov.my/en/akta/personal-data-protection-amendment-act-2024/')
        i+=1
        while i<len(lines) and not lines[i].startswith('## 5. '): i+=1
        continue
    if line.startswith('## 5. '):
        add('5. End-to-end operating workflow',heading)
        add('See the current workflow diagram on page 4. It is a proposal for client review. Missing information returns to customer follow-up; the secretary determines readiness and initiates the human conversation. Approval, signature, filing and retention arrangements require confirmation.')
        i+=1
        while i<len(lines) and not lines[i].startswith('## 6. '): i+=1
        continue
    if line.startswith('## 6. '):
        add('6. Proposed functional scope and future options',heading)
        add('The following items are discussion points, not approved commitments. Confirm priorities with secretarial staff and project owners.')
        for item in ['Proposed first release: sign-in, company access, request intake, secretary queue, document handling, communication and essential administration.', 'Potential later work: commercial e-KYC, external filing integration, signature methods, advanced billing, analytics and additional mobile capabilities.', 'Annual-return filing, specific storage products and secretary mobile scope require separate approval.']: add('• '+item,bullet)
        i+=1
        while i<len(lines) and not lines[i].startswith('## 7. '): i+=1
        continue
    if line.startswith('## 9. '):
        add('9. Proposed pilot acceptance and verification',heading)
        add('These are proposed checks, not completed results. Test targets and acceptance criteria require approval.')
        for item in ['Verify access boundaries among firms, companies and roles.', 'Confirm that application packages do not contain database passwords or private provider keys.', 'Test AI handover, limitations and escalation to a secretary.', 'Test document authorisation, upload, download and access-link behaviour.', 'Verify audit records, with approved rules for access and retention.', 'Test backups, restoration, application recovery and agreed recovery targets.', 'Conduct end-to-end customer and secretary workflow testing and review the results with stakeholders.', 'Obtain appropriate professional review of identity, data protection, signature and filing requirements.']: add('• '+item,bullet)
        i+=1
        while i<len(lines) and not lines[i].startswith('## 10. '): i+=1
        continue
    if line.startswith('```'):
        i+=1; chunk=[]
        while i<len(lines) and not lines[i].startswith('```'):
            chunk.append(lines[i].rstrip()); i+=1
        if any(any(ch in row for ch in '┌┐└┘├┤┬┴┼') for row in chunk):
            add('Earlier text diagram omitted. Refer to the updated architecture and workflow diagrams at the front of this document.',note)
        else:
            for start in range(0,len(chunk),18):
                part=chunk[start:start+18]; wrapped=[]
                for item in part: wrapped.extend(textwrap.wrap(item,width=100,replace_whitespace=False,drop_whitespace=False) or [''])
                story.append(Preformatted('\n'.join(wrapped),code)); story.append(Spacer(1,6))
    elif line.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].startswith('|'):
            cells=[x.strip() for x in lines[i].strip().strip('|').split('|')]
            if not all(re.fullmatch(r'[:\- ]+',x or '-') for x in cells): rows.append(cells)
            i+=1
        i-=1
        if len(rows)>1:
            headers=rows[0]
            for row in rows[1:]:
                parts=[f'<b>{clean(headers[k])}:</b> {clean(v)}' for k,v in enumerate(row) if k<len(headers) and v]
                if parts: story.append(Paragraph('&#8226; '+('<br/>'.join(parts)),bullet))
        elif rows: add(' | '.join(rows[0]))
    elif line.startswith('# '): pass
    elif line.startswith('## '): add(line[3:].replace('MySQL 8.4 LTS','MySQL version to be confirmed'),heading)
    elif line.startswith('### '): add(line[4:].replace('Dedicated MySQL 8.4 LTS','MySQL version subject to review').replace('MySQL 8.4 LTS','MySQL version subject to review'),sub)
    elif line.strip()=='---': story.append(Spacer(1,5))
    elif re.match(r'^\s*[-*] ',line): add('• '+re.sub(r'^\s*[-*] ','',line),bullet)
    elif line.strip():
        line=line.replace('Every database query is cryptographically scoped','Database access should be scoped').replace('Cross-tenant data leakage is prevented','Cross-tenant data leakage must be prevented').replace('reducing case triage time from 20 minutes to under 60 seconds','with time savings to be measured during testing')
        add(line)
    i+=1
def frame(c,doc):
    c.saveState(); w,h=A4; c.setFont('ArialUnicode',7); c.setFillColor(colors.HexColor('#63788a')); c.drawString(48,h-31,'DETAILED PLANNING APPENDIX  |  CURRENT DECISIONS TAKE PRECEDENCE'); c.drawRightString(w-48,27,f'Appendix {doc.page}'); c.restoreState()
doc.build(story,onFirstPage=frame,onLaterPages=frame)
writer=PdfWriter()
for p in PdfReader(str(front)).pages: writer.add_page(p)
for p in PdfReader(str(detail)).pages: writer.add_page(p)
writer.add_metadata({'/Title':'MySect detailed project requirements and architecture','/Subject':'Planning draft, revised four-month timeline'})
with out.open('wb') as f: writer.write(f)
print(f'{len(writer.pages)} pages saved to {out}')
