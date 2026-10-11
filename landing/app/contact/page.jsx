import { Stage } from "@/components/Shell";
import { ContactPage } from "@/components/contact";

export const metadata = { title: "Contact — Kiln" };

export default function Contact() {
  return (
    <Stage hint={false}>
      <ContactPage />
    </Stage>
  );
}
