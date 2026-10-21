import { Stage } from "@/components/Shell";
import {
  Manifesto, Tasks, AgentCrop, Builder, PromptStack, BetaPass, AgentLoop, CommandCard,
  Keycaps, DiffCrop, LocalType, BlotMark, AgentLog, Sandbox, DownloadCard,
} from "@/components/home";
import { projectPlan } from "@/lib/workspace/data.mjs";

const progress = { done: projectPlan.completedTasks.length, total: projectPlan.tasks.length };

export default function Home() {
  return (
    <Stage>
      <div className="grid">
        <Manifesto />
        <Tasks />
        <AgentCrop />
        <Builder progress={progress} />
        <PromptStack />
        <BetaPass />
        <AgentLoop />
        <CommandCard />
        <Keycaps />
        <DiffCrop />
        <LocalType />
        <BlotMark />
        <AgentLog />
        <Sandbox />
        <DownloadCard />
      </div>
    </Stage>
  );
}
