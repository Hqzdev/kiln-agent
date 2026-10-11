# Kiln

**Kiln is a coding agent for macOS.** It reads your repo, writes a plan, edits code, runs the tests and asks before anything risky. Every task ends as a diff you can read, then commit or open as a PR.

> Status: early design. This repository currently holds the marketing site; the macOS app is not public yet.

## Repository layout

```
kiln-agent/
└── landing/        Marketing site (Next.js)
```

## Landing site

A bento-style landing page with motion and sound, built with:

- [Next.js 16](https://nextjs.org) (App Router)
- React 19
- [Motion](https://motion.dev) for animations
- [Lucide](https://lucide.dev) + [Simple Icons](https://simpleicons.org) for icons
- Inter and JetBrains Mono, self-hosted via Fontsource

No backend: forms show a success state but don't send anything yet.

### Pages

| Route        | What's there                                                    |
| ------------ | --------------------------------------------------------------- |
| `/`          | Manifesto, product widgets, live UI crops                       |
| `/features`  | Why Kiln, models, cost, approvals, benchmark chart               |
| `/beta`      | Beta sign-up, FAQ, app screens in a wallet-style stack          |
| `/changelog` | Weekly build log with releases and metrics                      |
| `/docs`      | Getting started, sandbox, models, automations, skills, shortcuts |
| `/privacy`   | Privacy policy (draft)                                          |
| `/github`    | Open-source parts, activity, recent commits                     |
| `/contact`   | Contact form and channels                                       |

### Run locally

Requires Node.js 20 or newer.

```bash
cd landing
npm install
npm run dev
```

Open http://localhost:3000. On macOS you can also double-click `landing/start.command`.

```bash
npm run build   # production build
npm start       # serve the build
```

### Project structure

```
landing/
├── app/            Routes, global styles (globals.css, cards.css, pages.css)
├── components/     Cards, page sections and the mini app-UI kit
│   ├── ui.jsx        Shared UI atoms (buttons, badges, composer, diff lines…)
│   ├── home.jsx      Home page cards and their interactions
│   ├── pages.jsx     Features, Beta and Changelog sections
│   ├── screens.jsx   App screens rendered in HTML for the Beta gallery
│   └── wallet.jsx    Wallet-style screen stack + lightbox
└── lib/sound.js    Synthesized UI sounds (Web Audio, no audio files)
```

### Notes

- Sound can be toggled from the navigation bar; it starts muted when the system prefers reduced motion.
- Numbers, repositories and handles on Changelog, GitHub and Contact are placeholders.
- Benchmark data on `/features` is illustrative.

## License

Not licensed yet. All rights reserved until a license is added.
