import { chromium } from '/opt/npm-tools/node_modules/playwright/index.mjs';
import { spawn } from 'child_process';
import fs from 'fs';
const FPS=30, DUR=23.9, N=Math.round(DUR*FPS);
const ff = spawn('ffmpeg', ['-y','-loglevel','error','-f','image2pipe','-framerate',String(FPS),'-c:v','png','-i','-','-c:v','libx264','-preset','slow','-crf','15','-pix_fmt','yuv420p','-tune','animation','video.mp4'], { stdio: ['pipe','inherit','inherit'] });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
page.on('pageerror', e => console.log('pageerror:', e.message));
await page.goto('file://' + process.cwd() + '/scene.html');
const talk = JSON.parse(fs.readFileSync('talk.json'));
await page.evaluate(async (talk) => { for (const f of ['400 16px JBM','500 16px JBM','600 16px Inter','300 16px Inter','400 16px Inter','500 16px Inter']) await document.fonts.load(f); setup(talk); await document.fonts.ready; }, talk);
const t0=Date.now();
for (let i=0;i<N;i++){
  await page.evaluate(t => render(t), i/FPS);
  const buf = await page.screenshot({ type:'png' });
  if (!ff.stdin.write(buf)) await new Promise(r=>ff.stdin.once('drain',r));
  if (i%60===0) console.log('frame',i,'/',N, ((Date.now()-t0)/1000).toFixed(0)+'s');
}
ff.stdin.end();
await new Promise(r=>ff.on('close',r));
await browser.close();
console.log('done', ((Date.now()-t0)/1000).toFixed(0)+'s');
