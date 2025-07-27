const express = require('express');
const { MCPServer } = require('@microsoft/mcp');
const { AtlassianService } = require('./atlassian-service');

async function main() {
  const app = express();
  const port = process.env.PORT || 3000;
  
  // Create and initialize MCP server
  const mcpServer = new MCPServer({
    services: [new AtlassianService()],
    app,
  });
  
  await mcpServer.initialize();
  
  app.listen(port, () => {
    console.log(`Atlassian MCP server listening on port ${port}`);
  });
}

main().catch((error) => {
  console.error('Error starting server:', error);
  process.exit(1);
});
