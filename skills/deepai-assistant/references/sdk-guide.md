# deepidv SDK Integration Guide

<!-- TODO: Expand this guide -->

## Installation

### Node.js

```bash
npm install @deepidv/sdk
```

### Python

```bash
pip install deepidv
```

## Quick Start

```javascript
import { DeepIDV } from "@deepidv/sdk";

const client = new DeepIDV({
  apiKey: process.env.DEEPIDV_API_KEY,
});

// Run a liveness check
const result = await client.verify.liveness({
  image: base64Image,
});

console.log(result.result.is_live);
```

## Configuration

| Option    | Type   | Default                      | Description           |
| --------- | ------ | ---------------------------- | --------------------- |
| `apiKey`  | string | —                            | Your deepidv API key  |
| `baseUrl` | string | `https://api.deepidv.com/v1` | API base URL          |
| `timeout` | number | `30000`                      | Request timeout in ms |
| `retries` | number | `3`                          | Max retry attempts    |
