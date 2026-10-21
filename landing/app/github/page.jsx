import { Stage } from "@/components/Shell";
import { GithubPage } from "@/components/legal";
import { projectPlan } from "@/lib/workspace/data.mjs";

const progress = { done: projectPlan.completedTasks.length, total: projectPlan.tasks.length };

export const metadata = { title: "GitHub — Blot" };

export default function Github() {
  return (
    <Stage hint={false}>
      <GithubPage progress={progress} />
    </Stage>
  );
}
