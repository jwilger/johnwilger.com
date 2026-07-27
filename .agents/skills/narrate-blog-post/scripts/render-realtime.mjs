import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import WebSocket from "ws";

const workDir = process.argv[2];
if (!workDir) {
  throw new Error("usage: render-realtime.mjs WORK_DIR");
}
if (!process.env.OPENAI_API_KEY) {
  throw new Error("OPENAI_API_KEY is required");
}

const model = process.env.NARRATION_MODEL || "gpt-realtime-2";
const voice = process.env.NARRATION_VOICE || "cedar";
const maxAttempts = Number(process.env.NARRATION_MAX_ATTEMPTS || "5");
const segments = JSON.parse(
  await fs.readFile(path.join(workDir, "segments.json"), "utf8"),
);
const signoff = (
  await fs.readFile(path.join(workDir, "signoff.txt"), "utf8")
).trim();

const articleStyle = [
  "This is a verbatim audio rendering task, not a conversation.",
  "Your entire spoken output must be exactly the supplied article passage, beginning with its first word and ending with its last word.",
  "Do not add, remove, repeat, paraphrase, summarize, introduce, acknowledge, comment on, or frame the passage in any way.",
  "Never say phrases such as 'let me read,' 'as written,' 'alright,' or anything before or after the passage.",
  "Use a deep, warm, soothing timbre and an intimate public-radio storytelling delivery.",
  "Sound engaged and thoughtful, with natural phrasing and subtle emotional shape.",
  "Avoid announcer cadence, sales cadence, sponsor-read rhythm, and synthetic monotony.",
  "Keep the pace unhurried but conversational.",
  "Treat the passage as part of one continuous article and do not announce boundaries.",
].join(" ");

const signoffStyle = [
  "This is a verbatim audio rendering task, not a conversation.",
  "Your entire spoken output must be exactly the supplied sign-off, beginning with its first word and ending with its last word.",
  "Do not add, remove, repeat, paraphrase, acknowledge, or frame anything.",
  "Never say phrases such as 'let me read,' 'as written,' 'alright,' or anything before or after the sign-off.",
  "Use the same deep, warm, soothing register and intimate storytelling tone as the article.",
].join(" ");

function normalizedWords(text) {
  return (
    text
      .toLowerCase()
      .replaceAll("’", "'")
      .match(/[a-z0-9]+(?:'[a-z0-9]+)?/g) || []
  );
}

function transcriptMatches(source, spoken) {
  const expected = normalizedWords(source);
  const actual = normalizedWords(spoken);
  return (
    expected.length === actual.length &&
    expected.every((word, index) => word === actual[index])
  );
}

function render(text, instructions, label) {
  return new Promise((resolve, reject) => {
    const audio = [];
    const transcript = [];
    let sessionConfigured = false;
    let settled = false;
    const ws = new WebSocket(
      `wss://api.openai.com/v1/realtime?model=${encodeURIComponent(model)}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
          "OpenAI-Safety-Identifier": "johnwilger-blog-narration",
        },
      },
    );
    const timeout = setTimeout(() => {
      ws.terminate();
      finish(new Error(`${label} timed out`));
    }, 10 * 60 * 1000);

    function finish(error, value) {
      if (settled) return;
      settled = true;
      clearTimeout(timeout);
      if (error) reject(error);
      else resolve(value);
    }

    ws.on("open", () => {
      ws.send(
        JSON.stringify({
          type: "session.update",
          session: {
            type: "realtime",
            instructions,
            output_modalities: ["audio"],
            audio: {
              output: {
                format: { type: "audio/pcm", rate: 24000 },
                voice,
              },
            },
          },
        }),
      );
    });

    ws.on("message", (raw) => {
      const event = JSON.parse(raw.toString());
      if (event.type === "session.updated" && !sessionConfigured) {
        sessionConfigured = true;
        ws.send(
          JSON.stringify({
            type: "conversation.item.create",
            item: {
              type: "message",
              role: "user",
              content: [{ type: "input_text", text }],
            },
          }),
        );
        ws.send(
          JSON.stringify({
            type: "response.create",
            response: {
              output_modalities: ["audio"],
              instructions,
            },
          }),
        );
      } else if (event.type === "response.output_audio.delta") {
        audio.push(Buffer.from(event.delta, "base64"));
      } else if (event.type === "response.output_audio_transcript.delta") {
        transcript.push(event.delta);
      } else if (event.type === "response.done") {
        if (event.response?.status !== "completed") {
          finish(
            new Error(
              `${label} ended with ${event.response?.status}: ${JSON.stringify(event.response?.status_details ?? {})}`,
            ),
          );
        } else {
          ws.close();
          finish(null, {
            pcm: Buffer.concat(audio),
            transcript: transcript.join("").trim(),
          });
        }
      } else if (event.type === "error") {
        finish(new Error(`${label}: ${JSON.stringify(event.error)}`));
      }
    });

    ws.on("error", (error) => finish(error));
    ws.on("close", () => {
      if (!settled) finish(new Error(`${label} closed before completion`));
    });
  });
}

async function renderVerified(text, instructions, stem) {
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    const result = await render(text, instructions, stem);
    await fs.writeFile(
      path.join(workDir, `${stem}-attempt-${attempt}-transcript.txt`),
      `${result.transcript}\n`,
    );
    if (transcriptMatches(text, result.transcript)) {
      await fs.writeFile(path.join(workDir, `${stem}.pcm`), result.pcm);
      await fs.writeFile(
        path.join(workDir, `${stem}-transcript.txt`),
        `${result.transcript}\n`,
      );
      const seconds = result.pcm.length / 2 / 24000;
      console.log(`${stem}: verified ${seconds.toFixed(2)}s on attempt ${attempt}`);
      return;
    }
    console.error(`${stem}: transcript mismatch on attempt ${attempt}`);
  }
  throw new Error(`${stem} failed transcript verification after ${maxAttempts} attempts`);
}

for (let index = 0; index < segments.length; index += 1) {
  const stem = `segment-${String(index + 1).padStart(2, "0")}`;
  await renderVerified(segments[index], articleStyle, stem);
}
await renderVerified(signoff, signoffStyle, "signoff");
