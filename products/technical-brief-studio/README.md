# Technical Brief Studio

This is the first productized output path for `Northbridge Systems`.

It turns a bounded intake file into:

- `delivery.md`
- `quote.md`
- `order-packet.md`
- `generation.json`

using the local model runtime through Ollama.

## Entry Point

Use:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\generate-technical-brief-product.ps1 `
  -IntakePath .\products\technical-brief-studio\intake-samples\windows-unattended-runtime.v1.json
```

## Current Scope

- technical brief
- decision memo style output
- bounded sponsor-safe documentation support

## Current Limits

- one intake in, one delivery pack out
- no client portal
- no billing integration
- no external send automation
