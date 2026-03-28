/**
 * deepidv MCP Server — Entrypoint
 *
 * Model Context Protocol server enabling Claude and Grok to operate
 * within the deepidv backoffice on behalf of authenticated users.
 */

// TODO: Part 2 implementation
// - MCP protocol over SSE (Claude) with WebSocket fallback (Grok)
// - OAuth 2.0 token validation
// - Role-based tool registry
// - Health check at /health
// - Metrics at /metrics (Prometheus format)

const PORT = process.env.PORT || 3000;

console.log(`deepidv MCP Server starting on port ${PORT}...`);
console.log("MCP Server is a stub — Part 2 implementation pending.");
