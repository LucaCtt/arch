/*
  This is a Deno script that starts the Emby server's systemctl unit,
  and also optionally launches the web UI.

  To launch it, use the bash wrapper:

  chmod +x ./start-emby.sh
  ./start-emby.sh [--ui]
  Or run it directly with Deno:

  deno run --allow-run start-emby.ts [--ui]
*/

const UI_ARG = "--ui";
const UI_URL = "http://localhost:8096";

/**
 * Returns a Promise that is resolved after the specified amount of time.
 * It can be used to suspend the current process.
 * 
 * @param ms The amount of time after which the promise is resolved, in milliseconds.
 */
const timeout = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(resolve, ms));

// Start the Emby server process.
const server = Deno.run({
  cmd: ["sudo", "systemctl", "start", "emby-server"],
});
const { success } = await server.status();

if (success && Deno.args.includes(UI_ARG)) {
  // Wait for the server to actually be up,
  // so the browser doesn't show a "This site can't be reached" error.
  await timeout(300);

  // Start the web UI, hiding all the logging done by nohup and xdg-open.
  // nohup here is used because xdg-open does not exit
  // until the opened app returns (the web browser in this case).
  const ui = Deno.run({
    cmd: [
      "nohup",
      "xdg-open",
      UI_URL,
    ],
    stdout: "null",
    stderr: "null",
  });
  await ui.status();
}
