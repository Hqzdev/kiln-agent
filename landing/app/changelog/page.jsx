import { Stage } from "@/components/Shell";
import {
  Hero, Subscribe, ThisWeek, NextUp, WeekCounter, LatestRelease, Release, FirstCommit, Follow,
} from "@/components/pages";

export const metadata = { title: "Changelog — Blot" };

export default function Changelog() {
  return (
    <Stage hint={false}>
      <div className="grid">
        <Hero
          title={<>Blot<span className="muted"> build log</span>.</>}
          lines={[
            "one release every monday.",
            "what shipped. what broke. what's next.",
            "real numbers, even the bad ones*.",
            "you ask for it in the beta chat,",
            "it shows up here.",
          ]}
          footnote="also on RSS and in the beta Telegram."
        >
          <Subscribe />
        </Hero>
        <ThisWeek />
        <NextUp />
        <WeekCounter />
        <LatestRelease />
        <Release v="v0.3" date="Oct 5, 2026" title="Parallel tasks in worktrees." items={[
          ["NEW", "Run up to 3 tasks at once, each in its own git worktree."],
          ["IMPROVED", "Sidebar shows which tasks are running, ready or queued."],
          ["FIXED", "Diff panel jumped to the top after every edit."],
        ]} />
        <Release v="v0.2" date="Sep 28, 2026" title="Cost before it runs." items={[
          ["NEW", "Estimated cost per task and a hard cap you set."],
          ["NEW", "Usage page with weekly limit and tokens per task."],
          ["FIXED", "Model picker forgot the last choice after restart."],
        ]} />
        <Release v="v0.1" date="Sep 21, 2026" title="First private build." items={[
          ["NEW", "Plan → edit → test loop on a single repo."],
          ["NEW", "Approvals for every command outside the sandbox."],
          ["NEW", "Review pane with per-file diffs and commit."],
        ]} />
        <FirstCommit />
        <Follow />
      </div>
    </Stage>
  );
}
