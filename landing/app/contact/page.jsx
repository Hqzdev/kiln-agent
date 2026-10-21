import { Stage } from "@/components/Shell";
import { ContactPage } from "@/components/contact";

export const metadata = { title: "Contact — Blot" };

export default function Contact() {
  return (
    <Stage hint={false}>
      <ContactPage />
    </Stage>
  );
}
