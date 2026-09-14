export default async function Home() {
  const ApiProbe =
    process.env.NODE_ENV === "development"
      ? (await import("./api-probe")).default
      : null;

  return (
    <main>
      <div>Hello world!</div>
      {ApiProbe && <ApiProbe />}
    </main>
  );
}
