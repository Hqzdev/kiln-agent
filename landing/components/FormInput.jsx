"use client";

import { useId, useState } from "react";
import FormFeedback from "./FormFeedback";

export default function FormInput({ pill = false, multiline = false, icon: Icon, onChange, ...props }) {
  const id = useId();
  const [error, setError] = useState("");
  const validate = (input) => setError(input.validity.valid ? "" : input.validationMessage);
  const Control = multiline ? "textarea" : "input";
  const input = <Control {...props} required className={multiline ? "textarea" : undefined}
        aria-label={props["aria-label"] ?? props.name}
        aria-invalid={Boolean(error)} aria-describedby={error ? id : undefined}
        onInvalid={(event) => {
          event.preventDefault();
          const field = event.currentTarget;
          validate(field);
          if (field.form?.querySelector(":invalid") === field) {
            field.focus({ preventScroll: true });
            field.scrollIntoView({ block: "center", behavior: "instant" });
          }
        }}
        onBlur={(event) => { if (event.currentTarget.value || error) validate(event.currentTarget); }}
        onChange={(event) => { if (error) validate(event.currentTarget); onChange?.(event); }} />;
  return <div className="form-control">
    {multiline ? input : <span className={`input-wrap ${pill ? "pill" : ""}`} data-invalid={Boolean(error)}>
      {Icon && <Icon size={16} aria-hidden="true" />}
      {input}
    </span>}
    <FormFeedback id={id} error>{error}</FormFeedback>
  </div>;
}
