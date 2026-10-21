import { Stage } from "@/components/Shell";
import { DocsPage } from "@/components/docs";

export const metadata = { title: "Docs — Blot" };

export default function Docs() {
  return (
    <Stage hint={false}>
      <DocsPage />
    </Stage>
  );
}
