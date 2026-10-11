import { Stage } from "@/components/Shell";
import {
  Manifesto, Tasks, AgentCrop, Builder, PromptStack, BetaPass, AgentLoop, CommandCard,
  Keycaps, DiffCrop, LocalType, KilnMark, AgentLog, Sandbox, DownloadCard,
} from "@/components/home";

export default function Home() {
  return (
    <Stage>
      <div className="grid">
        <Manifesto />
        <Tasks />
        <AgentCrop />
        <Builder />
        <PromptStack />
        <BetaPass />
        <AgentLoop />
        <CommandCard />
        <Keycaps />
        <DiffCrop />
        <LocalType />
        <KilnMark />
        <AgentLog />
        <Sandbox />
        <DownloadCard />
      </div>
    </Stage>
  );
}
