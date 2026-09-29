import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { Presentation, PresentationFile } from '@oai/artifact-tool';

const { SKILL_DIR, TMP_DIR, RUNTIME_PYTHON } = process.env;
const workspaceDir = '/Users/marketingdeveloper/DCStack/MySect';
const finalPath = path.join(workspaceDir, 'output/pptx/MYSECT_PLATFORM_BLUEPRINT_DECK_PLAIN_LANGUAGE_V3.pptx');
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

// 3 product pages
{
  const s=base('What each product needs to contain');
  card(s,58,155,350,390,'Customer app','Home and companies\n\nAsk MySect AI\nRequests and status\nDocuments\nApprovals and signatures\nNotifications\nBilling and profile',C.blue);
  card(s,465,155,350,390,'Secretary website','Dashboard and work queue\n\nAI escalations\nCompany workspace\nHuman customer conversation\nCompliance calendar\nTeam and reports\nFirm settings',C.teal);
  card(s,872,155,350,390,'MySect admin website','Platform dashboard\n\nFirm onboarding\nCompanies and assignments\nPlans and subscriptions\nPayments and support\nAudit and security\nReports and settings',C.navy);
  box(s,{x:90,y:592,w:1100,h:42,text:'For the first three months, build the pages needed for one complete customer request from intake to secretary completion.',size:18,color:C.navy,bold:true,align:'center'});
  notes(s,'Page inventory summary. The detailed page-by-page checklist is in the blueprint PDF section 3.4.');
}

// 4 how the products work together
{
  const s=base('How the three products work together');
  box(s,{x:65,y:155,w:1150,h:68,text:'Customer app        Secretary workspace        MySect admin',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  box(s,{x:65,y:270,w:1150,h:70,text:'One shared MySect service centre\nKeeps the right information with the right people',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.blue,line:C.blue,padding:10});
  const xs=[65,300,535,770,1005]; const labs=['Customer requests','Documents','Company tasks','Payments','AI assistance'];
  xs.forEach((x,i)=>box(s,{x,y:390,w:190,h:82,text:labs[i],size:18,color:C.navy,bold:true,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8}));
  box(s,{x:65,y:520,w:550,h:70,text:'Company records\npeople, companies, tasks, payments and history',size:17,color:C.ink,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:8});
  box(s,{x:665,y:520,w:550,h:70,text:'Secure document storage\noriginal files, version history and controlled access',size:17,color:C.ink,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:8});
  notes(s,'Architecture recommendation: one shared backend with strict tenant isolation, backend-controlled AI tools, and signed file access. Source: blueprint sections 6, 7 and 9.');
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
  const s=base('How the system is hosted and protected');
  box(s,{x:75,y:150,w:1125,h:62,text:'Company Windows Server',size:23,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:8});
  box(s,{x:145,y:260,w:985,h:62,text:'Protected application environment\nRuns the MySect services safely and consistently',size:23,color:C.white,bold:true,align:'center',valign:'middle',fill:C.blue,line:C.blue,padding:8});
  const labs=[['Main service','accounts, companies and tasks'],['Background work','notifications and document reading'],['Company records','records plus regular backups'],['Secure connection','website protection and traffic control']];
  labs.forEach((a,i)=>box(s,{x:75+i*285,y:380,w:245,h:92,text:a[0]+'\n'+a[1],size:17,color:C.navy,bold:i===0,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8}));
  box(s,{x:180,y:535,w:920,h:64,text:'TM Cloud secure file storage  |  protected originals  |  controlled downloads  |  backup copies',size:19,color:C.teal,bold:true,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:10});
  notes(s,'Deployment choice: Windows Server remains the operational host, but production Linux containers should run inside a Hyper-V Linux VM rather than relying on Docker Desktop as the server runtime. Sources: Microsoft Windows containers/Linux containers documentation and TM One cloud service references.');
}

// 6 AI pricing
{
  const s=base('AI provider decision: start cheap, stay replaceable');
  box(s,{x:62,y:143,w:1160,h:42,text:'Illustrative AI service price comparison (USD, researched 28 Sep 2026)',size:15,color:C.muted});
  const rows=[['Gemini 2.5 Flash-Lite','Recommended intake','0.10','0.40'],['OpenAI GPT-6 Luna','Strong fallback','0.10','0.50'],['Mistral Small 4','Good alternative','0.15','0.60'],['DeepSeek Flash','Cost option; review data terms','0.15–0.30','0.60–1.20']];
  box(s,{x:62,y:195,w:1160,h:40,text:'Provider / role                                      Customer message       AI reply',size:17,color:C.white,bold:true,fill:C.navy,line:C.navy,padding:10});
  rows.forEach((r,i)=>{const y=240+i*54; box(s,{x:62,y,w:1160,h:46,text:`${r[0]}  |  ${r[1]}                                      $${r[2]}       $${r[3]}`,size:16,color:i===0?C.navy:C.ink,bold:i===0,fill:i===0?'#E7F5F4':(i%2?'#F8FBFD':C.white),line:C.line,padding:10});});
  box(s,{x:75,y:500,w:1125,h:85,text:'Example: 10,000 AI conversations/month ≈ $7–$11/month for the listed low-cost models before document reading, storage and engineering.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:12});
  notes(s,'Pricing sources: Google Gemini API pricing, Mistral API pricing, DeepSeek API pricing, and OpenAI API pricing. Prices are subject to provider changes and do not include OCR, storage, observability, development, or support. Recommended implementation: provider-neutral AiProvider interface, Gemini Flash-Lite for pilot intake, with a controlled fallback.');
}

// 8 e-KYC and TM Cloud pricing
{
  const s=base('Other important service costs');
  box(s,{x:60,y:140,w:560,h:38,text:'e-KYC identity check options',size:20,color:C.navy,bold:true});
  const ekyc=[['Epsilon ID V3','RM2.99 / full check'],['TrueIdentity','RM8,000 setup + RM3.50 / check + RM4,000/year'],['MasChain','RM3.50 down to RM1.50 / check'],['Tekkis T-Verify','RM1.50 / API call shown publicly']];
  ekyc.forEach((r,i)=>box(s,{x:60,y:185+i*47,w:560,h:38,text:r[0]+'   '+r[1],size:15,color:C.ink,fill:i%2? '#F8FBFD':C.pale,line:C.line,padding:9}));
  box(s,{x:660,y:140,w:560,h:38,text:'TM Cloud storage references',size:20,color:C.navy,bold:true});
  box(s,{x:660,y:185,w:560,h:118,text:'Exact production price: not publicly listed; request a quotation.\n\nOlder Cloud Alpha reference: RM0.49/GB/month mid-performance or RM2.20/GB/month high-performance.\n\nSeparate Unifi storage plans are not automatically suitable for application storage.',size:15,color:C.ink,fill:C.pale,line:C.line,padding:10});
  box(s,{x:660,y:330,w:560,h:104,text:'For a 100–500GB MVP, the older reference implies approximately RM49–RM1,100/month for raw storage only, before backup, server, support, and other services.',size:17,color:C.navy,bold:true,fill:'#FFF8E8',line:'#F4D79A',padding:12});
  box(s,{x:75,y:500,w:1125,h:72,text:'Recommendation: test e-KYC with 20–50 people, request the TM quote, and choose on privacy, Malaysia coverage, support and reliability—not price alone.',size:19,color:C.teal,bold:true,align:'center',valign:'middle',fill:'#F8FBFD',line:C.line,padding:12});
  notes(s,'Public reference prices only. Epsilon ID V3, TrueIdentity, MasChain and Tekkis pages were reviewed for published pricing. TM One Cloud Alpha pages do not publish the exact production Object Storage line-item price; an older Cloud Alpha VPC catalogue provides a planning reference only.');
}

// 9 billing model
{
  const s=base('Two billing relationships, kept operationally separate');
  box(s,{x:70,y:155,w:500,h:72,text:'MySect Admin\n→ Secretary Firm',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  box(s,{x:710,y:155,w:500,h:72,text:'Secretary Firm\n→ Customer Company',size:22,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal,padding:10});
  box(s,{x:70,y:270,w:500,h:190,text:'Platform subscription\n\n• Starter / Growth / Professional\n• Seats, companies, AI and storage limits\n• MySect invoice, payment status and entitlements\n• Grace period and suspension rules',size:17,color:C.ink,fill:C.pale,line:C.line,padding:16});
  box(s,{x:710,y:270,w:500,h:190,text:'Professional service subscription\n\n• Firm-defined package and price\n• Customer agreement and service invoice\n• Firm owns refund, cancellation and dispute\n• One-off filing/government fees stay visible',size:17,color:C.ink,fill:'#F8FBFD',line:C.line,padding:16});
  box(s,{x:170,y:520,w:940,h:70,text:'Pilot recommendation: MySect bills firms directly; firms collect customer payments directly. Add shared payment collection only after legal, tax, identity checks and dispute ownership are approved.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:12});
  notes(s,'Payment architecture: two independent billing ledgers and merchant relationships. Evaluate Stripe first for Malaysia, using recurring card billing for MySect firm subscriptions and one-off FPX/card checkout for secretary invoices. FPX is not recurring according to Stripe documentation. Sources: Stripe Malaysia pricing, Billing, FPX and Connect pages.');
}

// 10 three-month MVP
{
  const s=base('What we can realistically complete in 12 weeks');
  box(s,{x:58,y:150,w:265,h:62,text:'Weeks 1–2\nConfirm and design',size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  box(s,{x:345,y:150,w:265,h:62,text:'Weeks 3–6\nCustomer flow',size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.blue,line:C.blue,padding:10});
  box(s,{x:632,y:150,w:265,h:62,text:'Weeks 7–9\nSecretary operations',size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal,padding:10});
  box(s,{x:919,y:150,w:265,h:62,text:'Weeks 10–12\nPilot readiness',size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.navy,line:C.navy,padding:10});
  const cols=[['• Freeze first service\n• Page checklist\n• Pilot firm\n• Data and access plan'],['• Sign-in and company setup\n• AI intake\n• Request status\n• Documents'],['• AI escalation queue\n• Human conversation\n• Information requests\n• Approvals'],['• Admin controls\n• Billing status\n• Backup test\n• Pilot training']];
  [58,345,632,919].forEach((x,i)=>box(s,{x,y:245,w:265,h:180,text:cols[i],size:17,color:C.ink,fill:i%2? '#F8FBFD':C.pale,line:C.line,padding:14}));
  box(s,{x:80,y:510,w:1120,h:76,text:'To meet three months, defer full statutory automation, complex marketplace payouts, the secretary mobile app, advanced analytics, and every possible service type.',size:20,color:C.navy,bold:true,align:'center',valign:'middle',fill:'#FFF8E8',line:'#F4D79A',padding:14});
  notes(s,'Three-month target is an MVP and controlled pilot, not the complete long-term platform. Scope and sequencing are detailed in blueprint section 16.1.');
}

// 11 next steps
{
  const s=base('Management decisions required before UI design');
  const items=['Confirm launch scope: company secretary services and first workflow','Confirm Secretary Firm commercial model and pilot firm','Request TM Cloud quote for 100–500GB plus backups','Shortlist e-KYC provider and run 20–50 test checks','Approve pilot AI provider and data-processing review','Name the first 5–10 customer companies for testing'];
  items.forEach((t,i)=>{const y=145+i*64; box(s,{x:75,y,w:42,h:42,text:String(i+1),size:19,color:C.white,bold:true,align:'center',valign:'middle',fill:C.teal,line:C.teal}); box(s,{x:140,y:y-2,w:1040,h:45,text:t,size:20,color:C.ink,valign:'middle'});});
  box(s,{x:75,y:565,w:1125,h:48,text:'Recommended next milestone: approve the blueprint, then write the detailed feature and workflow plan before visual design.',size:19,color:C.navy,bold:true,align:'center',valign:'middle',fill:C.pale,line:C.line,padding:8});
  notes(s,'Close: the next deliverable after management approval should be the MVP product requirements, permission matrix, data model, and clickable role flows.');
}

const candidatePath = path.join(TMP_DIR, 'candidate.pptx');
await (await PresentationFile.exportPptx(presentation)).save(candidatePath);

const requirements = {
  explicitTotalSlideCount: 11,
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
