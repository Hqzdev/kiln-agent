"use client";

import Link from "next/link";
import { forwardRef } from "react";
import { ArrowUpRight } from "lucide-react";
import { play } from "@/lib/sound";

// Bento card. `w`/`h` are grid spans. The art layer is absolutely positioned
// so designs can bleed past the edges like the reference site's crops.
const Card = forwardRef(function Card(
  { w = 1, h = 1, arrow = true, caption, href = "/features", noSpot, className = "", style, artStyle, artClass = "", children, ...rest },
  ref
) {
  return (
    <div
      ref={ref}
      className={`card ${w === 2 ? "c2" : w === 4 ? "c4" : ""} ${h === 2 ? "r2" : h === 3 ? "r3" : ""} ${noSpot ? "no-spot" : ""} ${className}`}
      style={style}
      {...rest}
    >
      <div className={`art ${artClass}`} style={artStyle}>{children}</div>
      {arrow && (
        <div className="foot">
          <Link href={href} className="arrow-btn" aria-label={caption?.title || "Open"} onMouseEnter={() => play("tick")}>
            <ArrowUpRight size={18} />
          </Link>
          {caption && (
            <span className="caption">
              <b>{caption.title}</b> — {caption.text}
            </span>
          )}
        </div>
      )}
    </div>
  );
});

export default Card;
