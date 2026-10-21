import { Stage } from "@/components/Shell";
import { PrivacyPage } from "@/components/legal";

export const metadata = { title: "Privacy — Blot" };

export default function Privacy() {
  return (
    <Stage hint={false}>
      <PrivacyPage />
    </Stage>
  );
}
