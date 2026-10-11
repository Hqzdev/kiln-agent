import "@fontsource-variable/inter";
import "@fontsource/jetbrains-mono/400.css";
import "@fontsource/jetbrains-mono/500.css";
import "@fontsource/jetbrains-mono/600.css";
import "./globals.css";
import "./cards.css";
import "./pages.css";
import { Loader, Nav } from "@/components/Shell";

export const metadata = {
  title: "Kiln — the coding agent for your Mac",
  description: "Kiln reads your repo, plans, edits, runs the tests and asks before anything risky. Every task ends as a diff you can read.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Loader />
        <Nav />
        {children}
      </body>
    </html>
  );
}
