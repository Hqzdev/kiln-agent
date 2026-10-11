import { chromium } from '/opt/npm-tools/node_modules/playwright/index.mjs';
import fs from 'fs';
const times = process.argv.slice(2).map(Number);
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
page.on('console', m => { if (m.type()==='error') console.log('console:', m.text()); });
page.on('pageerror', e => console.log('pageerror:', e.message));
await page.goto('file://' + process.cwd() + '/scene.html');
const talk = JSON.parse(fs.readFileSync('talk.json'));
await page.evaluate(async (talk) => { await document.fonts.load('400 16px JBM'); await document.fonts.load('500 16px JBM'); await document.fonts.load('600 16px Inter'); await document.fonts.load('300 16px Inter'); setup(talk); await document.fonts.ready; }, talk);
fs.mkdirSync('stills', { recursive: true });
for (const t of times) {
  await page.evaluate(t => render(t), t);
  await page.screenshot({ path: `stills/t${t.toFixed(2)}.png` });
}
await browser.close();
