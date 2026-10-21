import { Stage } from "@/components/Shell";
import { Signup, WhatYouGet, FirstWave, Faq } from "@/components/pages";
import { Builder } from "@/components/home";
import { ScreensWallet } from "@/components/wallet";

export const metadata = { title: "Beta — Blot" };

export default function Beta() {
  return (
    <Stage hint={false}>
      <div className="grid">
        <Signup />
        <WhatYouGet />
        <FirstWave />
        <Builder />
        <Faq />
        <ScreensWallet />
      </div>
    </Stage>
  );
}
