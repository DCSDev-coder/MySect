import os
import json
import math
import wave
import struct
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path('/Users/marketingdeveloper/DCStack_Development/MySect')
WORK = ROOT / 'tmp/pitch_video_3d'
SCREENS_DIR = WORK / 'screens'
SLICES_DIR = WORK / 'slices'
AUDIO_DIR = WORK / 'audio'

for d in [WORK, SCREENS_DIR, SLICES_DIR, AUDIO_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# 1. Crop exact UI cards from the user's 470x1024 screenshots and give them rounded corners + subtle glow frame
# Coordinates are (left, top, right, bottom) in 470x1024 space
SLICES_SPEC = [
    # Screen 1 (Home + Company Dropdown + Calendar)
    ('s1_dropdown', 'screen_1_home_dropdown.jpg', (14, 228, 352, 540), '#062AAE'),
    ('s1_calendar', 'screen_1_home_dropdown.jpg', (16, 590, 454, 885), '#0A7E8C'),

    # Screen 2 (SSM Filings)
    ('s2_counters', 'screen_2_ssm_filings.jpg', (14, 290, 456, 405), '#F59E0B'),
    ('s2_card_s68', 'screen_2_ssm_filings.jpg', (14, 535, 456, 792), '#062AAE'),
    ('s2_submit_btn', 'screen_2_ssm_filings.jpg', (308, 214, 456, 274), '#1D6FA5'),

    # Screen 3 (Files + TM Cloud + Quick Access)
    ('s3_tmcloud', 'screen_3_files.jpg', (18, 340, 452, 480), '#062AAE'),
    ('s3_attention', 'screen_3_files.jpg', (18, 555, 232, 720), '#EF4444'),
    ('s3_unsorted', 'screen_3_files.jpg', (238, 555, 452, 720), '#38BDF8'),

    # Screen 4 & 5 (Chats List + Active Chat Bubbles)
    ('s4_chat_card', 'screen_4_chats_list.jpg', (18, 412, 452, 520), '#062AAE'),
    ('s5_bubble_1', 'screen_5_chat_detail.jpg', (14, 305, 382, 396), '#64748B'),
    ('s5_bubble_2', 'screen_5_chat_detail.jpg', (14, 405, 456, 515), '#062AAE'),
    ('s5_bubble_3', 'screen_5_chat_detail.jpg', (14, 522, 456, 634), '#0A7E8C'),
]

def make_rounded_slice(name, src_file, box, border_hex):
    im = Image.open(SCREENS_DIR / src_file).convert('RGBA')
    cropped = im.crop(box)
    w, h = cropped.size
    radius = 22

    # Rounded mask
    mask = Image.new('L', (w, h), 0)
    draw_m = ImageDraw.Draw(mask)
    draw_m.rounded_rectangle((0, 0, w - 1, h - 1), radius=radius, fill=255)

    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    out.paste(cropped, (0, 0), mask)

    # Draw crisp glowing border
    draw_o = ImageDraw.Draw(out)
    draw_o.rounded_rectangle((1, 1, w - 2, h - 2), radius=radius, outline=border_hex, width=4)

    out_path = SLICES_DIR / f'{name}.png'
    out.save(out_path)
    return {
        'name': name,
        'path': str(out_path),
        'box': box,
        'w': w,
        'h': h,
        # Normalized center on 470x1024 phone screen (-0.5..+0.5 in X, -0.5..+0.5 in Y where +Y is up)
        'nx': ((box[0] + box[2]) / 2.0) / 470.0 - 0.5,
        'ny': 0.5 - ((box[1] + box[3]) / 2.0) / 1024.0,
        'nw': w / 470.0,
        'nh': h / 1024.0,
    }

slices_meta = {}
for name, src_f, box, bhex in SLICES_SPEC:
    slices_meta[name] = make_rounded_slice(name, src_f, box, bhex)
print(f'Created {len(slices_meta)} 3D pop-out UI slices!')

# 2. Define the 6 fast-paced, energetic scenes
SCENES = [
    {
        'id': 1,
        'badge': 'MYSECT MOBILE EXPERIENCE',
        'title': 'Your Company Secretary.\nNow in Your Pocket.',
        'subtitle': 'No more messy WhatsApp threads or lost emails. Experience MySect in 3D.',
        'pills': ['5 Real Live Screens', 'Multi-Company Control', 'Direct CoSec Sync'],
        'vo': 'Tired of managing your company through messy WhatsApp chats and lost emails? Meet MySect — your entire company secretary experience, right in your pocket.',
    },
    {
        'id': 2,
        'badge': 'HOME & MULTI-COMPANY SWITCHER',
        'title': 'Switch Companies in One Tap.\nNever Miss a Dateline.',
        'subtitle': 'Data Center Specialists, C2 Coffee + Candle, 5Luxe Scents & Borneo Marine — all in one view.',
        'pills': ['Instant Company Dropdown', 'Role-Locked Access', 'Upcoming Dateline Calendar'],
        'vo': 'Own more than one business? Switch between Data Center Specialists, C2 Coffee, or Borneo Marine in a single tap, and spot every upcoming October deadline instantly.',
    },
    {
        'id': 3,
        'badge': 'SSM FILINGS & LIVE TRACKER',
        'title': 'Real-Time SSM Filings.\nZero Guessing Games.',
        'subtitle': 'Track Review, Action, Lodged & Done statuses with live notes from your licensed Secretary.',
        'pills': ['Section 68 Annual Return', 'Section 58 Director Change', '+ Submit SSM in Seconds'],
        'vo': 'Tap into SSM Filings to see live progress across Review, Action Needed, Lodged, and Done. Read instant updates from your licensed secretary on Section 68 Annual Returns and Section 58 changes.',
    },
    {
        'id': 4,
        'badge': 'SMART CLOUD FILES & ALERTS',
        'title': 'Powered by TM Cloud.\n9 Attention Files Highlighted.',
        'subtitle': 'Auto-sync corporate folders and immediately spot which documents need your action.',
        'pills': ['TM Cloud Auto-Sync', 'Attention: 9 Files', 'Unsorted & Accounting Vault'],
        'vo': 'In the Files vault powered by TM Cloud, MySect automatically highlights the exact nine files needing your attention and organises unsorted and accounting documents cleanly.',
    },
    {
        'id': 5,
        'badge': 'INSTANT CHAT & ONE-TAP RESOLVE',
        'title': 'Direct Secretary Chat.\nFast, Tracked & Resolved.',
        'subtitle': 'Ask questions about your uploads, attach documents, and mark threads Resolved when done.',
        'pills': ['Live Support Thread', 'File Attachments', 'One-Tap Resolve'],
        'vo': 'Need quick help on a recent document upload? Jump straight into Chat, message your support and secretarial team in real time, and tap Resolve the moment your issue is settled.',
    },
    {
        'id': 6,
        'badge': 'READY FOR PARTNER LAUNCH',
        'title': 'MySect — Your Secretary Company.\nBuilt for Modern Business.',
        'subtitle': 'Home • SSM Filings • TM Cloud Files • Live Chat — Connected to the Secretary Workspace.',
        'pills': ['iOS & Android (Flutter)', 'Partner Firm Web Portal', 'MySect Admin Governance'],
        'vo': 'From multi-company switching and SSM filing trackers to TM Cloud file sync and instant chat — MySect makes corporate compliance effortless. Let us launch the future together!',
    },
]

# 3. Generate energetic voiceover clips and measure exact durations
def read_wav_mono(wav_path: Path):
    with wave.open(str(wav_path), 'rb') as w:
        nch = w.getnchannels()
        sampwidth = w.getsampwidth()
        fr = w.getframerate()
        nframes = w.getnframes()
        raw = w.readframes(nframes)
    samples = struct.unpack(f'<{nframes * nch}h', raw)
    if nch > 1:
        samples = samples[0::nch]
    return [s / 32768.0 for s in samples], fr

SR = 44100
scene_timings = []
current_t = 0.0

for sc in SCENES:
    sid = sc['id']
    aiff_p = AUDIO_DIR / f'vo_{sid}.aiff'
    wav_p = AUDIO_DIR / f'vo_{sid}.wav'
    subprocess.run(['say', '-v', 'Samantha', '-r', '184', '-o', str(aiff_p), sc['vo']], check=True)
    subprocess.run(['afconvert', '-f', 'WAVE', '-d', f'LEI16@{SR}', '-c', '1', str(aiff_p), str(wav_p)], check=True)
    vo_samples, _ = read_wav_mono(wav_p)
    vo_dur = len(vo_samples) / float(SR)
    scene_dur = round(vo_dur + 1.15, 2)
    sc['start_time'] = round(current_t, 2)
    sc['vo_duration'] = round(vo_dur, 2)
    sc['duration'] = scene_dur
    sc['wav_path'] = str(wav_p)
    current_t += scene_dur
    scene_timings.append(sc)
    print(f"Scene {sid}: start={sc['start_time']}s, dur={sc['duration']}s (vo={sc['vo_duration']}s)")

total_duration = round(current_t, 2)
print('Total 3D video duration:', total_duration, 'seconds')

# 4. Synthesize upbeat 120 BPM Electronic / Corporate-Pop Soundtrack + Transition Whoosh/Chime SFX + Voiceover Mix!
total_samples = int(total_duration * SR) + SR
left_mix = [0.0] * total_samples
right_mix = [0.0] * total_samples

# Chord progression in A Major / F#m (uplifting tech launch vibe: F#m7 - Dmaj7 - A - E)
chords = [
    [185.00, 220.00, 277.18, 329.63, 369.99], # F#m7
    [146.83, 220.00, 277.18, 369.99, 440.00], # Dmaj7
    [220.00, 277.18, 329.63, 440.00, 554.37], # A add9
    [164.81, 246.94, 329.63, 415.30, 493.88], # E
]
bpm = 124.0
beat_sec = 60.0 / bpm
sixteenth_sec = beat_sec / 4.0

print('Synthesizing stereo upbeat background soundtrack & transition SFX...')
for i in range(total_samples):
    t = i / float(SR)
    if t > total_duration:
        break
    # Envelope fade in/out
    env = 1.0
    if t < 0.8:
        env = t / 0.8
    elif t > total_duration - 1.5:
        env = max(0.0, (total_duration - t) / 1.5)

    bar_idx = int(t / (beat_sec * 4.0)) % 4
    chord = chords[bar_idx]

    # Warm pad (stereo chorus)
    pad_l = 0.0
    pad_r = 0.0
    for idx_n, freq in enumerate(chord[:4]):
        pad_l += math.sin(2.0 * math.pi * (freq * 0.999) * t + idx_n) * 0.032
        pad_r += math.sin(2.0 * math.pi * (freq * 1.001) * t + idx_n + 0.4) * 0.032

    # Pluck arpeggio on 16th notes
    step_16 = int(t / sixteenth_sec)
    local_16 = (t - step_16 * sixteenth_sec) / sixteenth_sec
    arp_env = math.exp(-local_16 * 5.5)
    arp_freq = chord[step_16 % len(chord)] * (2.0 if (step_16 % 8 == 7) else 1.0)
    arp_sig = (math.sin(2.0 * math.pi * arp_freq * t) + 0.4 * math.sin(4.0 * math.pi * arp_freq * t)) * arp_env * 0.045
    pan = 0.35 * math.sin(step_16 * 0.9)

    # Soft punchy 4-on-the-floor kick & crisp offbeat hi-hat
    beat_pos = (t % beat_sec) / beat_sec
    kick_env = math.exp(-beat_pos * 14.0)
    kick_freq = 52.0 + 95.0 * math.exp(-beat_pos * 28.0)
    kick = math.sin(2.0 * math.pi * kick_freq * (t % beat_sec)) * kick_env * 0.11

    # Sub bass
    bass_freq = chord[0] * 0.5
    sidechain = 1.0 - 0.55 * kick_env
    bass = math.sin(2.0 * math.pi * bass_freq * t) * 0.065 * sidechain

    left_mix[i] = env * (pad_l * sidechain + arp_sig * (0.5 - pan) + kick + bass)
    right_mix[i] = env * (pad_r * sidechain + arp_sig * (0.5 + pan) + kick + bass)

# Add transition whoosh + crystalline chime at the start of each scene and pop SFX when 3D cards pop out!
for sc in scene_timings:
    st = sc['start_time']
    # Scene transition chime + whoosh
    chime_notes = [554.37, 659.25, 880.0, 1108.73]
    for n_idx, cfreq in enumerate(chime_notes):
        t0 = st + n_idx * 0.055
        s0 = int(t0 * SR)
        s_len = int(0.45 * SR)
        for k in range(s_len):
            if s0 + k < total_samples:
                lt = k / float(SR)
                c_env = math.exp(-lt * 7.5)
                val = math.sin(2.0 * math.pi * cfreq * lt) * c_env * 0.08
                left_mix[s0 + k] += val
                right_mix[s0 + k] += val

    # Pop-out card sound effects at +1.2s and +3.2s into each scene
    for pop_offset, pop_freq in [(1.2, 740.0), (3.0, 880.0), (5.0, 987.77)]:
        pt = st + pop_offset
        if pt < total_duration - 0.5:
            p0 = int(pt * SR)
            plen = int(0.18 * SR)
            for k in range(plen):
                if p0 + k < total_samples:
                    lt = k / float(SR)
                    p_env = math.exp(-lt * 22.0)
                    f_glide = pop_freq * (1.0 + 0.5 * (1.0 - math.exp(-lt * 30.0)))
                    pval = math.sin(2.0 * math.pi * f_glide * lt) * p_env * 0.09
                    left_mix[p0 + k] += pval
                    right_mix[p0 + k] += pval

    # Overlay voiceover at start_time + 0.35s (with music ducking so VO is crystal clear)
    vo_samples, _ = read_wav_mono(Path(sc['wav_path']))
    vo_start_idx = int((st + 0.35) * SR)
    for k, vs in enumerate(vo_samples):
        idx = vo_start_idx + k
        if idx < total_samples:
            left_mix[idx] = left_mix[idx] * 0.52 + vs * 0.92
            right_mix[idx] = right_mix[idx] * 0.52 + vs * 0.92

master_wav = AUDIO_DIR / 'master_mix.wav'
master_m4a = AUDIO_DIR / 'master_mix.m4a'
with wave.open(str(master_wav), 'wb') as wf:
    wf.setnchannels(2)
    wf.setsampwidth(2)
    wf.setframerate(SR)
    buf = bytearray(total_samples * 4)
    for i in range(total_samples):
        l_int = max(-32700, min(32700, int(left_mix[i] * 32767.0)))
        r_int = max(-32700, min(32700, int(right_mix[i] * 32767.0)))
        struct.pack_into('<hh', buf, i * 4, l_int, r_int)
    wf.writeframes(buf)

subprocess.run(['afconvert', '-f', 'm4af', '-d', 'aac', '-b', '192000', str(master_wav), str(master_m4a)], check=True)
print('Master stereo soundtrack + SFX + voiceover exported to:', master_m4a)

manifest = {
    'total_duration': total_duration,
    'master_audio': str(master_m4a),
    'scenes': scene_timings,
    'slices': slices_meta,
}
(WORK / 'manifest.json').write_text(json.dumps(manifest, indent=2))
print('Saved manifest.json!')
