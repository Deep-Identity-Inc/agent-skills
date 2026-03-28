# deepidv FAQ

<!-- TODO: Expand with the top 30 integration questions -->

## General

**Q: What is deepidv?**
A: deepidv is an identity verification and compliance platform offering face liveness detection, KYC, deepfake analysis, adverse media screening, and AML/sanctions checks via API.

**Q: What document types are supported?**
A: Passports, driver's licenses, and national ID cards from 190+ countries.

**Q: Is there a sandbox environment?**
A: Yes. Use `https://sandbox.api.deepidv.com/v1` with `sk_test_` prefixed API keys.

## API

**Q: What's the maximum image size?**
A: 10MB per image, 20MB total per request.

**Q: What image formats are accepted?**
A: JPEG and PNG for images. MP4 and MOV for video.

**Q: How do I handle rate limits?**
A: Check the `X-RateLimit-Remaining` header. On `429` responses, wait for `Retry-After` seconds.

## Compliance

**Q: Which sanctions lists are checked?**
A: OFAC SDN, UN Consolidated, EU Sanctions, FINTRAC, FinCEN, and 160+ regulatory body lists.

**Q: Is deepidv SOC 2 compliant?**
A: Yes. Contact sales@deepidv.com for our SOC 2 Type II report.
