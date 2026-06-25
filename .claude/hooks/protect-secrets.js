#!/usr/bin/env node
const fs = require('fs');

// Read the tool call details passed by Claude Code into stdin
const inputData = fs.readFileSync(0, 'utf-8');
if (!inputData) process.exit(0);

try {
  const payload = JSON.parse(inputData);
  const toolInput = payload.tool_input || {};
  
  // Extract targeted paths or executed terminal commands
  const filePath = (toolInput.file_path || '').toLowerCase();
  const bashCommand = (toolInput.command || '').toLowerCase();

  // Define patterns that indicate .env access
  const isEnvFile = filePath.includes('.env');
  const isEnvCommand = bashCommand.includes('.env') || 
                       bashCommand.includes('printenv') || 
                       bashCommand.includes('echo $');

  if (isEnvFile || isEnvCommand) {
    console.error("Security Block: Claude is restricted from accessing environment secrets.");
    // Exiting with code 2 explicitly instructs Claude Code to abort the tool execution
    process.exit(2); 
  }
} catch (e) {
  // Fallback safe exit if JSON parsing fails
  process.exit(0);
}
process.exit(0);