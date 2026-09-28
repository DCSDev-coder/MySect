import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { Presentation, PresentationFile } from '@oai/artifact-tool';

const { SKILL_DIR, TMP_DIR, RUNTIME_PYTHON } = process.env;
const workspaceDir = '/Users/marketingdeveloper/DCStack/MySect';
const finalPath = path.join(workspaceDir, 'output/pptx/MYSECT_PLATFORM_BLUEPRINT_DECK.pptx');
await fs.mkdir(TMP_DIR, { recursive: true });
await fs.mkdir(path.dirname(finalPath), { recursive: true });

const { resolvePresentationFont, finalizePresentation } = await import(
  pathToFileURL(path.join(SKILL_DIR, 'container_tools/artifact_tool_utils.mjs')).href,
);
const family = resolvePresentationFont();
const W = 1280, H = 720;
const C = { navy:'#123B6D', blue:'#1D6FA5', teal:'#087E8B', ink:'#243447', muted:'#607080', pale:'#EEF4F8', white:'#FFFFFF', gold:'#F4B942', green:'#2E8B70', line:'#D8E3EA' };
const presentation = Presentation.create({ slideSize: { width: W, height: H } });

function box(slide, {x,y,w,h,text='',size=22,color=C.ink,bold=false,fill='none',line='none',align='left',valign='top',padding=0,italic=false}) {
  const s = slide.shapes.add({ geometry:'textbox', position:{left:x,top:y,width:w,height:h}, fill, line:{fill:line,width: line==='none'?0:1} });
  s.text = text;
  s.text.style = { typeface:family, fontSize:size, color, bold, italic, align, verticalAlign:valign, autoFit:'shrinkText', inset:padding };
  return s;
}
function base(title, kicker='MYSECT PLATFORM BLUEPRINT') {
  const slide = presentation.slides.add();
  slide.background.fill = C.white;
  box(slide,{x:58,y:28,w:1164,h:24,text:kicker,size:12,color:C.teal,bold:true});
  box(slide,{x:58,y:55,w:1164,h:58,text:title,size:32,color:C.navy,bold:true});
  box(slide,{x:58,y:682,w:1164,h:18,text:'MySect | Confidential planning document | 28 September 2026',size:10,color:C.muted});
  return slide;
}
function notes(slide, text) { slide.speakerNotes.textFrame.setText(text); }
function card(slide,x,y,w,h,title,body,accent=C.blue) {
  box(slide,{x,y,w,h,fill:C.pale,line:C.line,text:''});
  box(slide,{x:x+18,y:y+17,w:w-36,h:28,text:title,size:19,color:accent,bold:true});
  box(slide,{x:x+18,y:y+53,w:w-36,h:h-68,text:body,size:16,color:C.ink});
}

// 1 Cover
{
  const s = presentation.slides.add(); s.background.fill = C.navy;
  box(s,{x:78,y:95,w:1100,h:35,text:'MYSECT PLATFORM BLUEPRINT',size:15,color:'#9FD7E0',bold:true});
  box(s,{x:78,y:166,w:1080,h:120,text:'A secure operating platform\nfor company-secretary services',size:44,color:C.white,bold:true});
  box(s,{x:82,y:332,w:820,h:62,text:'Customer mobile app  |  Secretary workspace  |  MySect admin console',size:21,color:'#D9E8F1'});
  box(s,{x:82,y:552,w:500,h:54,text:'Management decision deck\n28 September 2026',size:16,color:'#BBD4E3'});
  box(s,{x:970,y:570,w:220,h:54,text:'AI-first\nsecretary-controlled',size:16,color:C.gold,bold:true,align:'right'});
  notes(s,'Purpose: introduce the proposed MySect product and delivery blueprint. Source: MYSECT_PLATFORM_BLUEPRINT.md.');
}

// 2 operating model
{
  const s=base('One platform, three controlled experiences');
  card(s,58,165,350,300,'01  Customer','Mobile app\n\n• Company profile and compliance tasks\n• Documents and approvals\n• AI intake for every new issue\n• Status, notifications and billing',C.blue);
  card(s,465,165,350,300,'02  Secretary firm','Web workspace\n\n• Assigned client portfolio\n• Human chat and case work\n• Filing calendar and evidence\n• Team workload and quality controls',C.teal);
  card(s,872,165,350,300,'03  MySect admin','Admin console\n\n• Tenants, firms, users and plans\n• Escalation and SLA monitoring\n• Audit, security and reporting\n• Configuration and support',C.navy);
  box(s,{x:130,y:530,w:1020,h:70,text:'The commercial value is not “another chat app”. It is a traceable workflow that turns a customer request into an owned, reviewable company-secretary case.',size:22,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:12});
  notes(s,'Business model: three role-specific products share one backend and authorization model. The secretary firm is a tenant/partner organization; MySect remains the platform operator.');
}

// 3 architecture
{
  const s=base('Recommended architecture and trust boundaries');
  box(s,{x:65,y:155,w:1150,h:68,text:'Flutter customer app        Secretary web        MySect admin web',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  box(s,{x:65,y:270,w:1150,h:70,text:'API gateway / authentication / tenant and permission checks',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.blue,line:C.blue,padding:10});
  const xs=[65,300,535,770,1005]; const labs=['Cases & chat','Documents','Compliance','Billing','AI orchestration'];
  xs.forEach((x,i)=>box(s,{x,y:390,w:190,h:82,text:labs[i],size:18,color:C.navy,bold:true,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8}));
  box(s,{x:65,y:520,w:550,h:70,text:'PostgreSQL\nusers, companies, assignments, cases, audit events',size:17,color:C.ink,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:8});
  box(s,{x:665,y:520,w:550,h:70,text:'TM Cloud Object Storage\noriginal files, versions, retention, signed downloads',size:17,color:C.ink,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:8});
  notes(s,'Architecture recommendation: one backend with modular domains, strict tenant isolation, backend-controlled AI tools, and signed file access. Source: blueprint sections 6, 7 and 9.');
}

// 4 AI workflow
{
  const s=base('Customer support should be AI-first, not human-chat-first');
  const steps=[['1','Customer asks AI','The AI identifies intent, company context, urgency and missing information.'],['2','AI creates case','Structured summary, category, priority, suggested next action and evidence checklist.'],['3','Secretary notified','The case appears in the firm queue with SLA and full AI transcript.'],['4','Human chat opens','Only an assigned secretary starts the human conversation when work or judgment is required.']];
  steps.forEach((a,i)=>{ const x=58+i*300; box(s,{x,y:170,w:54,h:54,text:a[0],size:24,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal}); box(s,{x:x+68,y:165,w:220,h:36,text:a[1],size:18,color:C.navy,bold:true}); box(s,{x:x+68,y:210,w:220,h:115,text:a[2],size:15,color:C.ink}); });
  box(s,{x:70,y:420,w:1140,h:105,text:'Guardrails: no legal conclusion without review; no filing submission without an authorized human; no direct public file URLs; every AI action and handoff is logged.',size:22,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:15});
  box(s,{x:78,y:575,w:1120,h:42,text:'Design principle: AI reduces intake and repetition; it does not replace secretary accountability.',size:19,color:C.teal,bold:true,align:'center'});
  notes(s,'This reflects the agreed MySect workflow: customers speak to AI first; the secretary controls the human chat. AI must use backend tools and escalation rules, not free-form authority.');
}

// 5 deployment and storage
{
  const s=base('Deployment: keep Windows Server, run Linux containers safely');
  box(s,{x:75,y:150,w:1125,h:62,text:'Windows Server host',size:23,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:8});
  box(s,{x:145,y:260,w:985,h:62,text:'Hyper-V Linux VM  →  Docker Engine + Docker Compose',size:23,color:C.white,bold:true,align:'center',valign:'middle',fill:C.blue,line:C.blue,padding:8});
  const labs=[['API','auth, tenant checks, cases'],['Worker','notifications, OCR, scheduled jobs'],['DB','PostgreSQL + backup'],['Proxy','TLS, rate limits, routing']];
  labs.forEach((a,i)=>box(s,{x:75+i*285,y:380,w:245,h:92,text:a[0]+'\n'+a[1],size:17,color:C.navy,bold:i===0,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8}));
  box(s,{x:180,y:535,w:920,h:64,text:'TM Cloud Object Storage  |  encrypted originals  |  metadata in PostgreSQL  |  short-lived signed URLs',size:19,color:C.teal,bold:true,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:10});
  notes(s,'Deployment choice: Windows Server remains the operational host, but production Linux containers should run inside a Hyper-V Linux VM rather than relying on Docker Desktop as the server runtime. Sources: Microsoft Windows containers/Linux containers documentation and TM One cloud service references.');
}

// 6 AI pricing
{
  const s=base('AI provider decision: start cheap, stay replaceable');
  box(s,{x:62,y:143,w:1160,h:42,text:'Illustrative API price per 1M tokens (USD, researched 28 Sep 2026)',size:15,color:C.muted});
  const rows=[['Gemini 2.5 Flash-Lite','Recommended intake','0.10','0.40'],['OpenAI GPT-6 Luna','Strong fallback','0.10','0.50'],['Mistral Small 4','Good alternative','0.15','0.60'],['DeepSeek Flash','Cost option; review data terms','0.15–0.30','0.60–1.20']];
  box(s,{x:62,y:195,w:1160,h:40,text:'Provider / role                                      Input       Output',size:17,color:C.white,bold:true,fill:C.navy,line:C.navy,padding:10});
  rows.forEach((r,i)=>{const y=240+i*54; box(s,{x:62,y,w:1160,h:46,text:`${r[0]}  |  ${r[1]}                                      $${r[2]}       $${r[3]}`,size:16,color:i===0?C.navy:C.ink,bold:i===0,fill:i===0?'#E7F5F4':(i%2?'#F8FBFD':C.white),line:C.line,padding:10});});
  box(s,{x:75,y:500,w:1125,h:85,text:'Example: 10,000 AI conversations/month at 4,000 input + 800 output tokens each ≈ $7–$11/month for the listed low-cost models before OCR, storage and engineering.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:12});
  notes(s,'Pricing sources: Google Gemini API pricing, Mistral API pricing, DeepSeek API pricing, and OpenAI API pricing. Prices are subject to provider changes and do not include OCR, storage, observability, development, or support. Recommended implementation: provider-neutral AiProvider interface, Gemini Flash-Lite for pilot intake, with a controlled fallback.');
}

// 7 billing model
{
  const s=base('Two billing relationships, kept operationally separate');
  box(s,{x:70,y:155,w:500,h:72,text:'MySect Admin\n→ Secretary Firm',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  box(s,{x:710,y:155,w:500,h:72,text:'Secretary Firm\n→ Customer Company',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal,padding:10});
  box(s,{x:70,y:270,w:500,h:190,text:'Platform subscription\n\n• Starter / Growth / Professional\n• Seats, companies, AI and storage limits\n• MySect invoice, payment status and entitlements\n• Grace period and suspension rules',size:17,color:C.ink,fill:C.pale,line:C.line,padding:16});
  box(s,{x:710,y:270,w:500,h:190,text:'Professional service subscription\n\n• Firm-defined package and price\n• Customer agreement and service invoice\n• Firm owns refund, cancellation and dispute\n• One-off filing/government fees stay visible',size:17,color:C.ink,fill:'#F8FBFD',line:C.line,padding:16});
  box(s,{x:170,y:520,w:940,h:70,text:'Pilot recommendation: MySect bills firms directly; firms collect customer payments directly. Add marketplace payouts only after legal, tax, KYC and dispute ownership are approved.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:12});
  notes(s,'Payment architecture: two independent billing ledgers and merchant relationships. Evaluate Stripe first for Malaysia, using recurring card billing for MySect firm subscriptions and one-off FPX/card checkout for secretary invoices. FPX is not recurring according to Stripe documentation. Sources: Stripe Malaysia pricing, Billing, FPX and Connect pages.');
}

// 8 budget and roadmap
{
  const s=base('Two-year plan: validate the workflow before scaling it');
  box(s,{x:58,y:150,w:550,h:68,text:'Phase 1  |  0–3 months\nFoundation + customer/secretary MVP',size:20,color:C.white,bold:true,fill:C.blue,line:C.blue,padding:14});
  box(s,{x:672,y:150,w:550,h:68,text:'Phase 2  |  4–6 months\nPilot with controlled secretary firms',size:20,color:C.white,bold:true,fill:C.teal,line:C.teal,padding:14});
  box(s,{x:58,y:245,w:550,h:170,text:'• Auth, tenant model, cases\n• AI intake and escalation\n• TM Cloud storage + signed URLs\n• Secretary queue and human chat\n• Audit events and backups',size:18,color:C.ink,fill:C.pale,line:C.line,padding:14});
  box(s,{x:672,y:245,w:550,h:170,text:'• Real client/firm onboarding\n• SLA, billing and notifications\n• Security testing and restore drills\n• Measure AI resolution and handoff\n• Refine packages and operations',size:18,color:C.ink,fill:'#F8FBFD',line:C.line,padding:14});
  box(s,{x:58,y:470,w:1164,h:105,text:'Planning range for 24 months: RM1.68m–RM3.52m total. Biggest drivers are people, product scope, security/support, and operational scale—not AI tokens alone.',size:22,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:15});
  notes(s,'Budget is a planning range, not a vendor quotation. Detailed categories are in the PDF: product/engineering, Windows/VM, storage/backups, AI, security/legal, support, and contingency.');
}

// 9 next steps
{
  const s=base('Management decisions required before UI design');
  const items=['Confirm launch scope: company secretary services and first filing workflows','Confirm Secretary Firm commercial model, onboarding and revenue share','Confirm TM Cloud product, region, API, backup and retention terms','Approve pilot AI provider and data-processing review','Approve two-year budget envelope and first 90-day delivery team','Name the first pilot firm and 5–10 customer companies'];
  items.forEach((t,i)=>{const y=145+i*64; box(s,{x:75,y,w:42,h:42,text:String(i+1),size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal}); box(s,{x:140,y:y-2,w:1040,h:45,text:t,size:20,color:C.ink,valign:'middle'});});
  box(s,{x:75,y:565,w:1125,h:48,text:'Recommended next milestone: approve the blueprint, then write the MVP product requirements and data model before visual design.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8});
  notes(s,'Close: the next deliverable after management approval should be the MVP product requirements, permission matrix, data model, and clickable role flows.');
}

const candidatePath = path.join(TMP_DIR, 'candidate.pptx');
await (await PresentationFile.exportPptx(presentation)).save(candidatePath);

const requirements = {
  explicitTotalSlideCount: 9,
  requiredNativeTableOwnerSlides: [],
  requiredNativeChartOwnerSlides: [],
  fontPolicy: { basis:'design', families:[family] },
};
const result = await finalizePresentation({
  ...requirements,
  workspaceDir,
  candidatePath,
  finalPath,
  pythonExecutable: RUNTIME_PYTHON,
  integrityValidatorPath: path.join(SKILL_DIR,'container_tools/inspect_presentation_package_integrity.py'),
  layoutValidatorPath: path.join(SKILL_DIR,'container_tools/inspect_presentation_layout_geometry.py'),
  layoutArgs: ['--expected-slide-size-emu','12192000,6858000','--validate-bullet-geometry','--validate-heading-fit'],
  fontPolicy: requirements.fontPolicy,
  verifyArtifactToolImport: true,
  receiptPath: path.join(TMP_DIR,'MYSECT_PLATFORM_BLUEPRINT_DECK.validation.json'),
});
console.log(JSON.stringify(result));
