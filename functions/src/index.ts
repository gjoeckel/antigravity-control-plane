import {https, logger} from "firebase-functions";
import * as admin from "firebase-admin";

import {Request, Response} from "express";

admin.initializeApp();

/**
 * Antigravity Webhook Listener
 * sender: SYNAPSE (SYNP-9P8K-2J7M)
 * receiver: George (Admin)
 * protocol: Sender-Name, Sender-ID, Receiver-Name, Receiver-ID, Timestamp (UTC)
 */
export const bridgeStatus = https.onRequest((req: Request, res: Response) => {
  const ts = new Date().toISOString();

  // Formal Antigravity Protocol Header
  const bridgeHeader = `SYNAPSE, SYNP-9P8K-2J7M, George, ADMIN, ${ts}`;

  logger.info("Bridge status check initiated", {
    protocol: bridgeHeader,
    agent: "SYNAPSE",
  });

  res.send({
    status: "Bridge Active",
    protocolHeader: bridgeHeader,
    project: "hazel-service-489900-f3",
    agents: [
      {name: "LEXICONA", role: "Architect", id: "LEXC-74Q2-K1T8"},
      {name: "SYNAPSE", role: "Infrastructure", id: "SYNP-9P8K-2J7M"},
    ],
    ts,
  });
});
/**
 * Sovereign Forge Trigger
 * Triggers the GitHub Actions workflow to rebuild and deploy the cloud infrastructure.
 */
export const triggerSovereignBuild = https.onCall(async (data: any, context: any) => {
  const GITHUB_PAT = process.env.ACP_GITHUB_PAT;
  const REPO_OWNER = "gjoeckel";
  const REPO_NAME = "antigravity-control-plane";
  const WORKFLOW_ID = "sovereign_deploy.yml";

  if (!GITHUB_PAT) {
    logger.error("ACP_GITHUB_PAT is not defined");
    return {success: false, error: "Configuration Error"};
  }

  try {
    const response = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows/${WORKFLOW_ID}/dispatches`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${GITHUB_PAT}`,
          "Accept": "application/vnd.github+json",
          "X-GitHub-Api-Version": "2022-11-28",
        },
        body: JSON.stringify({
          ref: "main",
        }),
      }
    );

    if (response.ok) {
      logger.info("Sovereign Forge ignition successful");
      return {success: true, message: "Forge Ignited"};
    } else {
      const errorText = await response.text();
      logger.error("GitHub API Error", {status: response.status, body: errorText});
      return {success: false, error: "Ignition Failed", details: errorText};
    }
  } catch (error) {
    logger.error("Internal Error", {error});
    return {success: false, error: "Internal Error"};
  }
});
