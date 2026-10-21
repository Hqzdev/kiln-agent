import "@fontsource-variable/inter";
import "@fontsource/jetbrains-mono/400.css";
import "@fontsource/jetbrains-mono/500.css";
import "@fontsource/jetbrains-mono/600.css";
import "./globals.css";
import "./cards.css";
import "./pages.css";
import "./interface.css";
import { Nav, MotionPreferences } from "@/components/Shell";

export const metadata = {
  title: "Blot — the coding agent for your Mac",
  description: "Blot reads your repo, plans, edits, runs the tests and asks before anything risky. Every task ends as a diff you can read.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <a className="skip-link" href="#main-content">Skip to content</a>
        <MotionPreferences>
          <Nav />
          {children}
        </MotionPreferences>
      </body>
    </html>
  );
}
