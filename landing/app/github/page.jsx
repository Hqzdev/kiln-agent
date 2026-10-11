import { Stage } from "@/components/Shell";
import { GithubPage } from "@/components/legal";

export const metadata = { title: "GitHub — Kiln" };

export default function Github() {
  return (
    <Stage hint={false}>
      <GithubPage />
    </Stage>
  );
}
