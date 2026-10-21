import { Stage } from "@/components/Shell";
import {
  Hero, AnyModel, Cost, Parallel, ReviewFirst, Approvals, BigType, LocalHistory, Stack, Benchmark, CTA,
} from "@/components/pages";

export const metadata = { title: "Features — Blot" };

export default function Features() {
  return (
    <Stage hint={false}>
      <div className="grid">
        <Hero
          title={<><span className="muted">Why </span>Blot<span className="muted">,<br />not just another agent.</span></>}
          lines={[
            "codex is great if you're all-in on one model vendor.",
            "claude code is great if you live in a terminal.",
            { b: "blot is for everyone else*." },
            "any model, switched per task.",
            "a native mac app, not a tab in your terminal.",
            "every task ends as a diff you can read.",
            "you see the cost before it runs.",
          ]}
          footnote="and for anyone who wants to own their setup."
        />
        <AnyModel />
        <Cost />
        <Parallel />
        <ReviewFirst />
        <Approvals />
        <BigType
          words={[["Native", "SwiftUI, menu bar, ⌘K"], ["Fast", "opens in 0.3s"], ["Quiet", "lives in the menu bar"], ["Mac", "built for Apple silicon"]]}
          caption={{ title: "Native", text: "not a web view" }}
        />
        <LocalHistory />
        <Stack />
        <Benchmark />
        <CTA />
      </div>
    </Stage>
  );
}
