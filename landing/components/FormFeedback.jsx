export default function FormFeedback({ children, error = false, id }) {
  return <p id={id} className={`form-feedback ${error ? "error" : ""}`} role={error ? "alert" : "status"}>{children}</p>;
}
