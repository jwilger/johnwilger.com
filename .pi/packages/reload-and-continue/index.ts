import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const command = "johnwilger-apply-pending-reload";
const handoffKey = Symbol.for("@johnwilger/reload-and-continue/handoffs");

type PendingReload = {
	continuation: string;
	dispatch?: { ticket: number; leafId: string | null };
};

type Handoff = { leafId: string | null; resume?: (continuation: string) => void };

// Pi reevaluates the extension on reload. This map bridges only that reload,
// not a later session resume or a process restart.
const globals = globalThis as typeof globalThis & { [handoffKey]?: Map<string, Handoff> };
const handoffs = (globals[handoffKey] ??= new Map<string, Handoff>());

export default function (pi: ExtensionAPI) {
	let pending: PendingReload | undefined;
	let nextTicket = 0;
	const cancelPending = () => { pending = undefined; };

	pi.registerTool({
		name: "reload_and_continue",
		label: "Reload and Continue",
		description: "After saving a skill, extension, Pi package, or MCP configuration that needs loading, reload interactive Pi and start the next turn automatically. Call this tool alone. Name the saved resource, say how to verify it loaded before using it, and say what to do next for the current request.",
		exposure: "model-only",
		parameters: Type.Object({
			continuation: Type.String({
				minLength: 1,
				description: "Name the saved resource, how to verify it is loaded, and the next step.",
			}),
		}, { additionalProperties: false }),
		async execute(_id, { continuation }, signal, _onUpdate, ctx) {
			if (ctx.mode !== "tui") throw new Error("reload_and_continue requires interactive Pi.");
			if (signal?.aborted) throw new Error("Reload cancelled.");
			const alreadyPending = pending !== undefined;
			if (!alreadyPending) {
				const next = continuation.trim();
				if (!next) throw new Error("Provide a non-blank continuation.");
				if (!pi.getCommands().some((entry) => entry.source === "extension" && entry.name === command)) {
					throw new Error(`Cannot dispatch /${command}; check for conflicting extensions.`);
				}
				pending = { continuation: next };
			}
			return {
				content: [{
					type: "text",
					text: alreadyPending
						? "Reload already scheduled. Pi will use the first continuation."
						: "Reload scheduled. Pi will continue this task after reloading.",
				}],
				details: {},
				terminate: true,
			};
		},
	});

	pi.on("agent_start", () => {
		if (pending?.dispatch) cancelPending();
	});
	pi.on("session_before_switch", cancelPending);
	pi.on("session_before_fork", cancelPending);
	pi.on("session_before_tree", cancelPending);
	pi.on("session_shutdown", cancelPending);

	pi.on("agent_settled", (event, ctx) => {
		if (event.aborted) cancelPending();
		if (!pending) return;
		const ticket = ++nextTicket;
		pending.dispatch = { ticket, leafId: ctx.sessionManager.getLeafId() };
		// Pi dispatches this command after all settled handlers complete.
		pi.sendUserMessage(`/${command} ${ticket}`, { expandPromptTemplates: true });
	});

	pi.on("session_start", (event, ctx) => {
		cancelPending();
		if (event.reason !== "reload") return;
		const handoff = handoffs.get(ctx.sessionManager.getSessionId());
		if (!handoff) return;
		// Capture the replacement API, but wait for reload to finish before using it.
		handoff.resume = (continuation) => {
			if (!ctx.isIdle() || ctx.hasPendingMessages() || ctx.sessionManager.getLeafId() !== handoff.leafId) {
				throw new Error("The session changed during reload; the continuation was cancelled.");
			}
			pi.sendMessage({
				customType: "johnwilger-reload-continuation",
				content: `Pi reloaded. Continue the current user task. Verify the named resource is loaded before relying on it. If it did not load, report the problem instead of assuming it is available.\n\n${continuation}`,
				display: true,
			}, { triggerTurn: true, deliverAs: "followUp" });
		};
	});

	pi.registerCommand(command, {
		description: "Apply a pending reload_and_continue request (internal)",
		async handler(args, ctx) {
			const request = pending;
			if (!request?.dispatch || args !== String(request.dispatch.ticket)) return;
			cancelPending();
			const { leafId } = request.dispatch;
			if (!ctx.isIdle() || ctx.hasPendingMessages() || ctx.sessionManager.getLeafId() !== leafId) {
				throw new Error("The session changed before reload; the continuation was cancelled.");
			}

			const id = ctx.sessionManager.getSessionId();
			const handoff: Handoff = { leafId };
			handoffs.set(id, handoff);
			try {
				await ctx.reload();
			} finally {
				handoffs.delete(id);
			}
			if (!handoff.resume) throw new Error("Reload did not load the continuation extension; resume the task manually.");
			handoff.resume(request.continuation);
		},
	});
}
