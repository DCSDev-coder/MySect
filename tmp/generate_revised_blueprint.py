from pathlib import Path
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle

ROOT=Path('/Users/marketingdeveloper/DCStack_Development/MySect')
OUT=ROOT/'Documentation/MYSECT_PROJECT_REQUIREMENTS_REVISED.pdf'
LOGO=ROOT/'mysect_admin/public/mysect_main_logo.png'
W,H=A4; M=48; NAVY=colors.HexColor('#102d52'); BLUE=colors.HexColor('#236fae'); PALE=colors.HexColor('#eef5fa'); GREY=colors.HexColor('#536477')
c=canvas.Canvas(str(OUT), pagesize=A4)
c.setTitle('MySect Project Requirements and Architecture')
body=ParagraphStyle('body',fontName='Helvetica',fontSize=10,leading=15,textColor=colors.HexColor('#182b40'),spaceAfter=0)
small=ParagraphStyle('small',parent=body,fontSize=9,leading=12)

def para(text,x,y,w,style=body):
    p=Paragraph(text,style); _,h=p.wrap(w,800); p.drawOn(c,x,y-h); return y-h-8
def title(t,sub=None):
    c.setFillColor(NAVY); c.setFont('Helvetica-Bold',19); c.drawString(M,H-61,t)
    if sub: c.setFillColor(GREY); c.setFont('Helvetica',9); c.drawString(M,H-78,sub)
def footer(n):
    c.setStrokeColor(colors.HexColor('#d9e4ed')); c.line(M,37,W-M,37)
    c.setFont('Helvetica',8); c.setFillColor(GREY); c.drawString(M,25,'MYSECT  |  PLANNING DRAFT  |  STAKEHOLDER REVIEW'); c.drawRightString(W-M,25,str(n)); c.showPage()
def box(x,y,w,h,head,desc='',fill=PALE):
    c.setFillColor(fill); c.setStrokeColor(colors.HexColor('#b9cddd')); c.roundRect(x,y,w,h,6,fill=1,stroke=1)
    c.setFillColor(NAVY); c.setFont('Helvetica-Bold',9); c.drawCentredString(x+w/2,y+h-16,head)
    if desc:
        st=ParagraphStyle('center',parent=small,alignment=1,fontSize=8,leading=10)
        p=Paragraph(desc,st); _,ph=p.wrap(w-12,h-20); p.drawOn(c,x+6,y+(h-20-ph)/2+2)
def arrow(x1,y1,x2,y2):
    from math import atan2,cos,sin,pi
    c.setStrokeColor(BLUE); c.setFillColor(BLUE); c.setLineWidth(1.1); c.line(x1,y1,x2,y2)
    a=atan2(y2-y1,x2-x1); p=c.beginPath(); p.moveTo(x2,y2); p.lineTo(x2-7*cos(a-.4),y2-7*sin(a-.4)); p.lineTo(x2-7*cos(a+.4),y2-7*sin(a+.4)); p.close(); c.drawPath(p,fill=1,stroke=0)
def section(y,h,txt):
    c.setFillColor(NAVY); c.setFont('Helvetica-Bold',12); c.drawString(M,y,h); return para(txt,M,y-8,W-2*M)

# Cover
c.drawImage(ImageReader(str(LOGO)),(W-150)/2,H-205,width=150,height=97.5,mask='auto',preserveAspectRatio=True,anchor='c')
c.setFillColor(NAVY); c.setFont('Helvetica-Bold',23); c.drawCentredString(W/2,H-260,'MYSECT ENTERPRISE PLATFORM')
c.setFillColor(BLUE); c.setFont('Helvetica',13); c.drawCentredString(W/2,H-284,'Project requirements and architectural blueprint')
y=H-330
y=para('<b>Purpose.</b> A planning document for stakeholder review of the proposed customer, secretary and platform administration applications, shared services, infrastructure and delivery plan.',M,y,W-2*M)
y=para('<b>Current status.</b> The applications are prototypes with mock data and development endpoints. The shared production backend and its controls are not yet implemented. Architecture and workflows require client and technical review.',M,y-8,W-2*M)
y=para('<b>Planning window.</b> 1 December 2026 to 31 March 2027, approximately four months. Delivery and launch remain subject to agreed scope, resources, testing and approval.',M,y-8,W-2*M)
y=para('<b>Infrastructure direction.</b> The organisation intends to host the application, MySQL database and private company files on its own server. TM Cloud is on hold.',M,y-8,W-2*M)
footer(1)

title('1  Product scope and decisions','Working assumptions for client and project-team review')
y=H-105
for head,txt in [
('Customer application','Mobile experience for authorised company representatives to select a company, begin requests, provide information and documents, receive updates and respond to the secretary.'),
('Secretary workspace','Desktop and web oriented workspace for company records, request queues, assignment, document review, customer communication and case progress. Mobile scope remains to be confirmed.'),
('Platform administration','Separate administrative interface for firm and user onboarding, access management, operations and audit oversight. Access to client content must be explicitly defined.'),
('Confirmed direction','Separate role-specific applications will share a backend. New inquiries begin with AI-assisted intake; a secretary receives the case and initiates human communication. Professional decisions remain with the secretary.'),
('Still subject to approval','Detailed client workflows and permissions, MVP features, storage product, AI provider and privacy terms, identity verification, electronic signatures, filing methods, server capacity, backup targets and operating ownership.'),
('Prototype boundary','Screens do not prove live authentication, isolation, persistence, secure document storage or a functioning AI service. Use sample data during demonstrations.')]:
    y=section(y,head,txt); y-=7
footer(2)

title('2  Full platform architecture','Conceptual target; interfaces, products and deployment details require approval')
left=M; width=W-2*M; gap=10; bw=(width-2*gap)/3
for i,(h,d) in enumerate([('CUSTOMER APP','Flutter mobile<br/>company requests and documents'),('SECRETARY WORKSPACE','Flutter desktop / web<br/>case and document review'),('ADMIN PORTAL','React web<br/>platform operations')]): box(left+i*(bw+gap),H-160,bw,56,h,d)
for i in range(3): arrow(left+i*(bw+gap)+bw/2,H-160,left+i*(bw+gap)+bw/2,H-184)
box(left,H-225,width,41,'SECURE APPLICATION ENTRY','HTTPS / reverse proxy and request routing (proposed)')
arrow(W/2,H-225,W/2,H-247)
box(left,H-304,width,57,'SHARED BACKEND AND API','Authentication and company permissions | cases, tasks and messages | audit events | notifications')
for i in range(3): arrow(left+i*(bw+gap)+bw/2,H-304,left+i*(bw+gap)+bw/2,H-331)
for i,(h,d) in enumerate([('MYSQL','Users, firms, companies,<br/>cases and file metadata'),('PRIVATE FILE STORAGE','Company files on own server<br/>storage adapter proposed'),('AI INTEGRATION','Guided intake and summary<br/>provider undecided')]): box(left+i*(bw+gap),H-394,bw,63,h,d)
arrow(W/2,H-394,W/2,H-420)
box(left,H-470,width,50,'OWN SERVER AND OPERATIONS','Windows Server and suitable container runtime proposed | monitoring | separate backups and tested restore')
y=H-497
y=para('<b>Data boundary:</b> MySQL stores application records and file references; private storage holds the actual files. Access should be authorised by the backend. Backup, restoration, encryption and isolation require implementation and testing.',M,y,width,small)
y=para('<b>External services:</b> AI may be local or external, subject to separate privacy and provider approval. TM Cloud storage is on hold. SSM integration is unconfirmed; filing processes require professional validation.',M,y,width,small)
footer(3)

title('3  Request and secretary workflow','Illustrative process to validate with the company secretarial professional')
steps=[('1  Customer starts','Selects company and describes the request.'),('2  Guided intake','AI-assisted questions collect information and supporting documents.'),('3  Secretary queue','A case summary is sent to the secretary for review and assignment.'),('4  Review and follow up','Secretary checks information, requests missing items and initiates customer conversation.'),('5  Prepare and approve','Secretary prepares the work; customer reviews or approves as required.'),('6  Filing and completion','Secretary handles filing as applicable, records outcome and updates the customer.')]
x=85; ww=W-170; top=H-112; bh=65; gap=23
for i,(h,d) in enumerate(steps):
    yy=top-i*(bh+gap)-bh; box(x,yy,ww,bh,h,d)
    if i<len(steps)-1: arrow(W/2,yy,W/2,yy-gap+3)
y=top-6*(bh+gap)+8
para('<b>Decision points:</b> Missing or incorrect information returns to customer follow-up. The secretary decides whether work is ready to proceed. Signature method, filing process and retention rules remain unconfirmed.',M,y,W-2*M,small)
footer(4)

title('4  Four-month delivery plan','Indicative schedule  |  1 December 2026 to 31 March 2027')
y=H-112; rows=[('Client discovery and scope approval','X','X','',''),('Backend, database and server foundation','X','X','',''),('Authentication and company permissions','X','X','X',''),('Customer requests and secretary queue','','X','X',''),('Private documents and admin integration','','X','X',''),('AI intake and handover, if approved','','X','X',''),('Integration, security and recovery testing','','','X','X'),('Client review, pilot and release preparation','','','','X')]
cols=[M,M+260,M+318,M+376,M+434,W-M]; rh=31
c.setFillColor(NAVY); c.rect(M,y-rh,W-2*M,rh,fill=1,stroke=0); c.setFillColor(colors.white); c.setFont('Helvetica-Bold',9); c.drawString(M+8,y-20,'WORKSTREAM')
for i,m in enumerate(['DEC 26','JAN 27','FEB 27','MAR 27']): c.drawCentredString((cols[i+1]+cols[i+2])/2,y-20,m)
y-=rh
for j,row in enumerate(rows):
    c.setFillColor(PALE if j%2==0 else colors.white); c.rect(M,y-rh,W-2*M,rh,fill=1,stroke=0); c.setFillColor(NAVY); c.setFont('Helvetica',9); c.drawString(M+8,y-19,row[0])
    for i,mark in enumerate(row[1:]):
        if mark: c.setFillColor(BLUE); c.roundRect((cols[i+1]+cols[i+2])/2-15,y-21,30,10,5,fill=1,stroke=0)
    y-=rh
y-=28
y=para('<b>December:</b> confirm workflows and scope with stakeholders; design foundations and begin backend, database and access work.',M,y,W-2*M)
y=para('<b>January–February:</b> develop and integrate core request, secretary, document and administration flows; progress approved AI work.',M,y,W-2*M)
y=para('<b>March:</b> complete testing, address findings, conduct client review and prepare a pilot or release decision.',M,y,W-2*M)
para('This is a planning estimate, not a launch commitment. Timing depends on staffing, approved scope, dependencies and test results.',M,y-4,W-2*M)
footer(5)

title('5  Delivery scope and review gates','Proposed first release and decisions for project stakeholders')
y=H-105
for head,txt in [
('Proposed first release','Secure sign-in; company access; guided request intake; secretary queue and assignment; private documents; customer and secretary communication; notifications; essential administration and audit records. Confirm each item with the client.'),
('Future or undecided','Commercial e-KYC, specific electronic signature methods, direct external filing integration, full secretary mobile functions, advanced billing and analytics, and the selected AI and storage products are not approved commitments.'),
('Data and access','Define firm and company membership, user permissions, administrator access, file retention and case ownership before finalising the schema and API contracts. Identity checks are initially proposed as manual, pending review.'),
('Infrastructure and recovery','Confirm supported Windows Server and container configuration, capacity, private storage, encryption, off-server backups, restoration tests, monitoring, recovery targets and operational responsibility.'),
('Acceptance and pilot','Test customer and secretary workflows, access boundaries between companies, file upload and retrieval, notification and handover, audit records, backup restoration and failure handling. Client and project owners should approve pilot readiness.'),
('Professional and legal review','Confirm applicable filing, identity, document handling, privacy and signature requirements with qualified advisers and the relevant authorities. The platform does not replace the secretary’s professional judgement.')]:
    y=section(y,head,txt); y-=6
footer(6)
c.save(); print(OUT)
