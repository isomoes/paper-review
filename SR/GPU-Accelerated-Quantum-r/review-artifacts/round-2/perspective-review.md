# Round-2 Re-Review — Reviewer 3 (Deployment and Multimedia-Security Perspective)

## Reviewer remit

I re-reviewed the revision from the perspective of multimedia security and deployable social-media privacy systems. I focused on whether the implementation and experiments support the manuscript's practical social-media, real-time, mobile, and security claims. The original comments and author responses were treated as claims to verify against the revised manuscript, not as evidence by themselves.

## Overall assessment

The revision is more candid than the prior version about platform recompression, metadata leakage, missing authentication, and out-of-scope key management. Those disclosures are useful and materially improve the discussion. The added AES-256-CTR/ASCON-128a results and the explicit exclusion of PCIe transfer time also make the performance claim easier to interpret.

However, the work still demonstrates a GPU kernel benchmark rather than a deployable social-media privacy system. Several security-critical implementation descriptions remain internally inconsistent: the GPU pseudocode processes `width × height` bytes while claiming RGB support; the security headline concerns Salsa20-256 while the documented CPU/GPU algorithms are Salsa20-128; and the stated state-word placement in the CUDA pseudocode conflicts with the manuscript's own Salsa20 state layout. In addition, nonce lifecycle, key storage/distribution, authentication, replay protection, endpoint trust, and authenticated transport are not implemented or experimentally evaluated. Platform recompression is discussed, but the claimed JPEG-quality-75 experiment is not reported with a method or quantitative result. Mobile/NPU suitability and practical social-media use are inferred from desktop/data-centre NVIDIA kernel timings without a mobile implementation or end-to-end platform test.

These are not presentation-only gaps. They prevent the evidence from supporting the abstract's “secure,” “real-time social media” conclusion. I therefore recommend **Major Revision**.

## Strengths

1. **More realistic acknowledgement of platform transformation.** The manuscript now explicitly states that common photo endpoints recompress or resize uploads and that either operation destroys the ciphertext-to-pixel mapping (revision lines 1124–1145). This is an important deployment constraint that was previously missing.
2. **Clearer metadata boundary.** Pixel confidentiality is distinguished from visible dimensions, channel count, EXIF, account identity, upload time, and file size, with possible mitigations identified (revision lines 1146–1158).
3. **Explicit recognition of missing security services.** The revision acknowledges that the construction is unauthenticated and that production use needs integrity protection, key management, and key distribution (revision lines 1163–1178).
4. **Improved performance transparency.** Throughput, energy, memory, and GPU speedup are tabulated (revision lines 1086–1095), and the conclusion now states that the headline speedups exclude PCIe transfer overhead (revision lines 1184–1192).
5. **Broader, though still limited, evaluation.** A second RGB image is reported (revision lines 911–915), and both Tesla T4 and RTX A4000 measurements are presented (revision lines 786–794, 802–873).

## Verification of relevant prior comments

Status vocabulary: **Fully addressed**, **Partially addressed**, **Not addressed**, or **Cannot verify**.

| Prior comment | Prior anchor | Status | Verification against revision |
|---|---:|---|---|
| Reviewer 1: validate multiple datasets/sizes and average multiple independent experiments | Review.txt lines 59–67 | **Partially addressed** | Only one additional 512 KB Lenna image is identified (revision lines 911–915). No dataset breadth, repeated-run protocol, variance, confidence interval, or run count is reported. |
| Reviewer 1: discuss limitations and real-world social-media deployment | Review.txt lines 68–78 | **Partially addressed** | Sections 6.3–6.4 now discuss recompression, metadata, missing key management, and missing authentication (revision lines 1115–1182), but no platform, client, recipient, or end-to-end deployment is implemented or tested. |
| Reviewer 2: report throughput/kernel time and clarify PCIe overhead | Review.txt lines 121–129 | **Partially addressed** | Throughput is reported (revision lines 1086–1095) and PCIe exclusion is disclosed (revision lines 1189–1191). The headline remains a kernel-only speedup, with image decoding/encoding, host-device copies, file I/O, key handling, authentication, upload/download, and recipient processing excluded. |
| Reviewer 2: explain threat model, compression, metadata, and deployment | Review.txt lines 130–174 | **Partially addressed** | The prose additions are substantial (revision lines 1115–1182). Nevertheless, the model alternates between “trusted (or honest-but-curious)” platform assumptions, leaves endpoint compromise and malicious platform behaviour unresolved, and offers no deployable protocol or platform evidence. |
| Reviewer 2: justify “lightweight” using resource and power evidence | Review.txt lines 175–199 | **Partially addressed** | Desktop-GPU energy and memory values are reported (revision lines 1086–1095), but identical 6.29 MB entries are unexplained and no constrained/mobile device is evaluated. Desktop kernel efficiency does not establish lightweight operation on social-media endpoints. |
| Reviewer 3: provide architectural evidence for the 8192-block × 8-thread optimum | Review.txt lines 327–338 | **Not addressed** | The revision asserts that this configuration maximizes SM occupancy without register spilling (revision lines 994–1000, 1102–1109), but supplies no occupancy values, register counts, resident-block limits, cache/memory-stall measurements, or cross-GPU architectural analysis supporting that mechanism. |
| Reviewer 3: test different resolutions, grayscale/RGB images, and multiple datasets | Review.txt lines 367–385 | **Partially addressed** | A second RGB Lenna example is added (revision lines 911–915), but the manuscript still lacks multiple datasets, a resolution sweep, content diversity representative of social media, and statistical replication. |
| Reviewer 3: expand image-security evaluation, including CPA/KPA, randomness, and occlusion/cropping | Review.txt lines 281–301 | **Partially addressed** | Entropy/correlation and noise/loss values appear in Tables 8–10 (revision lines 1004–1081), but CPA/KPA and raw-keystream randomness remain future work. NPCR/UACI are reported as zero for plaintext sensitivity while separate key-sensitivity values are high; this does not establish protocol security or replace standard cryptographic validation. |

## Critical problems

### C1. The documented GPU length calculation can leave RGB image bytes unencrypted

**Problem.** The serial algorithm defines the buffer length as `W × H × C` (revision lines 409–420), but the GPU description and Algorithm 6 define `data_len = width × height`, omitting the channel count (revision lines 542–547 and 639–664). The manuscript nevertheless claims RGB operation and presents a colour Lenna image (revision lines 911–915). If the implementation follows the documented GPU algorithm, a three-channel image is only partially transformed; if the code differs, the manuscript is not a reproducible description of the evaluated system.

**Consequence.** Unencrypted channels or trailing bytes can directly expose image content. This independently invalidates the claimed confidentiality and the assertion that RGB operation has been demonstrated.

**Minimum remedy.** Correct the GPU length to the exact decoded byte count (`width × height × channels`, accounting for row stride and bit depth); audit all allocations, copies, boundary checks, and output encoding against that length; add tests proving every byte is transformed for grayscale, RGB, and RGBA inputs of non-multiple-of-64 sizes; and report plaintext/ciphertext byte-difference coverage. Reconcile the manuscript pseudocode with the released implementation.

### C2. The evaluated primitive and state layout are internally inconsistent

**Problem.** The abstract and principal security claim concern Salsa20-256 (revision lines 20–32), yet Sections 3 and 4 and Algorithms 1–8 document Salsa20-128 (revision lines 359–360, 409–419, 514–515, 639–664). Algorithm 7 places the counter in state words 6–7 and the nonce in words 8–9 (revision lines 682–697), while the manuscript's earlier state matrix places the nonce before the counter (revision lines 287–302). No standard Salsa20 test vectors or implementation-equivalence results are reported.

**Consequence.** Readers cannot determine whether the timed code is Salsa20-128, Salsa20-256, or a nonstandard state permutation. The claimed 256-bit key security, interoperability, and comparison with standard ciphers therefore cannot be trusted from the manuscript as written.

**Minimum remedy.** Provide unambiguous pseudocode for the exact 256-bit implementation used in every headline result, including standard key/nonce/counter word positions and endianness. Identify which tables use which binary. Validate CPU and GPU outputs against published full-round Salsa20/20 known-answer vectors over multiple lengths and counter values, publish the pass/fail results, and remove or clearly segregate all 128-bit results from 256-bit post-quantum claims.

### C3. Nonce and key lifecycle are absent, while the pseudocode suggests fixed initialization

**Problem.** The text correctly says a nonce must be unique (revision lines 269–274, 287–295), but the executable workflow only says to initialize a key and nonce and sets `base_counter = 0` (revision lines 542–547, 639–664). It gives no nonce-generation algorithm, per-key uniqueness guarantee, collision analysis, persistent state, key scope, rotation, storage, recipient binding, multi-recipient handling, or failure behaviour. Section 6.3 places key exchange and rotation outside scope (revision lines 1117–1128).

**Consequence.** Reusing a Salsa20 key/nonce pair reuses the keystream, allowing XOR of ciphertexts to reveal relationships between images and potentially recover content. A fast kernel with an unspecified nonce lifecycle is not a secure messaging or social-media scheme.

**Minimum remedy.** Specify and implement a complete message format and lifecycle: CSPRNG-generated or deterministically unique nonce per key, collision/restart handling, authenticated transmission of the nonce and algorithm/version identifiers, per-user/per-conversation key scope, secure endpoint storage, rotation and revocation rules, and counter-overflow limits. Add multi-message and process-restart tests that detect or prevent nonce reuse. If these components remain out of scope, narrow all system/deployment claims to “kernel microbenchmark of the Salsa20 primitive.”

### C4. Confidentiality-only encryption cannot support the manuscript's “secure social-media” claim

**Problem.** The construction performs raw stream-cipher XOR and verifies only equality after decrypting its own output (revision lines 348–355, 409–438, 601–625). The authors acknowledge that no authentication is present (revision lines 1163–1178), but do not implement an integrity tag, authenticated associated data, replay protection, message ordering, or downgrade/version binding. The threat model simultaneously places no trust in network intermediaries (revision lines 1117–1124).

**Consequence.** An intermediary, platform, or storage attacker can flip chosen ciphertext bits, truncate/substitute images, replay old media, or alter visible headers without detection. This invalidates “secure” and deployable privacy claims even if confidentiality and nonce uniqueness were otherwise correct.

**Minimum remedy.** Implement and evaluate a standard authenticated construction rather than proposing one as future infrastructure (for example, an appropriate standardized AEAD design). Authenticate ciphertext plus dimensions, format/version, sender/conversation binding, nonce, and relevant metadata; reject modified or truncated inputs before image decoding; and define replay protection using authenticated message identifiers/sequence state and an explicit replay window. Report tamper, substitution, truncation, reordering, and replay rejection tests.

## Major problems

### M1. Platform recompression/resizing is acknowledged but not experimentally reported or solved

**Problem.** Section 6.3 says JPEG quality-75 recompression was empirically tested and caused unrecoverable corruption (revision lines 1129–1138), yet the Results section reports Gaussian noise, salt-and-pepper noise, cut-out, and pixel loss only (revision lines 951–988, 1004–1081). There is no JPEG/WebP quality sweep, resize/crop/orientation test, byte-preservation measurement, decryption success rate, or real platform upload/download test. The proposed workaround—generic file/document attachment or a channel that does not recompress (revision lines 1138–1145)—is a different usage mode from ordinary in-feed image sharing.

**Consequence.** The primary “for social media” use case is incompatible with typical media pipelines, and the claimed empirical evidence is not auditable. A document attachment that recipients must separately download and decrypt does not establish practical social-media image use.

**Minimum remedy.** Report a reproducible transformation matrix covering at least JPEG and WebP recompression, resizing, thumbnailing, orientation normalization, metadata stripping, and container transcoding, with quantitative corruption and authenticated-decryption outcomes. Test representative real platform upload/download paths and clearly distinguish ordinary photo posting from lossless document transport. If no common photo path preserves ciphertext exactly, revise the title, abstract, and conclusion to remove direct social-media deployment claims.

### M2. Endpoint, authenticated-transport, and stakeholder assumptions are incomplete

**Problem.** The platform is described as “trusted (or honest-but-curious)” (revision lines 1117–1124), two materially different assumptions. Sender and recipient applications, device compromise, malicious recipients, account takeover, backups, notification previews, local decrypted caches, accessibility workflows, moderation/reporting, abuse response, and key recovery are not modelled. The manuscript says network intermediaries are untrusted but does not require authenticated transport, server/account authentication, certificate validation, or downgrade resistance. Metadata mitigations are proposed but not integrated or measured (revision lines 1146–1158).

**Consequence.** The system boundary is too vague to assess who is protected from whom. Pixel encryption may shift risk to endpoints, leak sensitive metadata, impede moderation/accessibility, and remain vulnerable to active transport or account-layer attacks.

**Minimum remedy.** Provide a deployment architecture and data-flow diagram identifying trust boundaries, sender/recipient processing, platform services, key service, local storage, and transport. Select one platform-adversary model; require authenticated transport and endpoint/server authentication even when content is end-to-end encrypted; define downgrade and account-compromise assumptions; and discuss concrete stakeholder trade-offs for users, recipients, platform operators, moderators, accessibility users, and abuse investigators. Measure residual metadata after the proposed stripping/padding pipeline.

### M3. Mobile/GPU and real-time relevance do not follow from the evaluated hardware

**Problem.** The implementation is CUDA C on Tesla T4 and RTX A4000 GPUs (revision lines 786–794, 1184–1188), but the manuscript claims suitability for GPU/NPU-equipped mobile devices (revision lines 1178–1182) and resource-limited handheld devices (revision lines 1212–1220). No Android/iOS implementation, mobile GPU/NPU kernel, browser/WebGPU path, CPU fallback, thermal/power measurement, memory-copy cost, or battery impact is evaluated. CUDA availability on the tested NVIDIA hardware does not itself establish deployability on mainstream social-media phones.

**Consequence.** The mobile and handheld conclusions are extrapolations outside the experimental domain. Kernel latency on workstation/data-centre GPUs may be irrelevant once mobile APIs, image codecs, memory movement, authentication, radio upload, and thermal throttling are included.

**Minimum remedy.** Either implement and benchmark an end-to-end client on representative mobile hardware using an actually available mobile API, including decode, preprocessing/metadata removal, key/nonce handling, authenticated encryption, encode/containerization, upload preparation, energy, memory, and thermal behaviour, or remove mobile/NPU/handheld claims and limit conclusions to the tested NVIDIA CUDA platforms.

### M4. Experimental external validity is insufficient for deployment and scalability claims

**Problem.** The headline CPU/GPU comparison uses a single 1.34 MB airport image (revision lines 762–768), and only one additional 512 KB Lenna example is stated (revision lines 911–915). No run count, warm-up policy, distribution, variance, confidence interval, cold-start cost, image-resolution sweep, channel/bit-depth sweep, concurrent-user load, or end-to-end latency is given. The speedups exclude PCIe transfer (revision lines 1189–1191), while Section 4 confirms that loading and host/device transfer are sequential (revision lines 514–526, 728–742). The manuscript also acknowledges that thread counts must be manually adjusted by image size (revision lines 1220–1222).

**Consequence.** The reported 265×/1381× values cannot establish stable user-perceived speed, scalability, or real-time operation. Fixed-grid results on two images do not generalize to social-media workloads or different devices.

**Minimum remedy.** Add repeated, statistically summarized benchmarks across a preregistered or clearly defined corpus spanning realistic resolutions, aspect ratios, grayscale/RGB/RGBA, compressible content, and file sizes. Report warm/cold end-to-end latency and throughput with all transfers, codecs, allocation, authentication, and file operations included; separate kernel-only results as microbenchmarks. Evaluate automatic launch-configuration selection and report cross-device sensitivity.

### M5. Comparative security-service and post-quantum claims need correction

**Problem.** Table 10 identifies ASCON-128a with a `2^128` key space (revision lines 1062–1081), while the text then states that ASCON-128a meets the same 128-bit post-quantum requirement as 256-bit-key designs (revision lines 1057–1100). Under the manuscript's own Grover argument, a 128-bit key does not yield a 128-bit brute-force margin. Moreover, Salsa20/AES-CTR confidentiality-only timing is not directly comparable to an authenticated-encryption implementation unless the same security service and tag verification are included.

**Consequence.** The claimed quantum-resistance-aware trade-off and “secure” comparative conclusion are misleading, and the fastest result may reflect unequal functionality rather than a superior deployable design.

**Minimum remedy.** Correct the post-quantum security accounting for each exact parameter set and use consistent terminology (“symmetric primitive with an estimated Grover-limited key-search margin,” not a standardized post-quantum scheme). Compare constructions that deliver the same confidentiality, integrity, associated-data, and nonce-misuse assumptions, including tag-generation/verification costs and failure handling.

## Required claim narrowing pending new evidence

Unless the critical and major remedies are completed, the title, abstract, and conclusion should describe a **CUDA kernel microbenchmark for Salsa20 image-buffer transformation on Tesla T4 and RTX A4000**, not a secure, real-time, mobile, or deployable social-media encryption system. In particular, the abstract's “secure and time-efficient ... for real-time social media image encryption” statement (revision lines 20–32) and the handheld/social-media conclusions (revision lines 1212–1220) exceed the evidence.

## Recommendation

**Major Revision**

The deployment discussion has improved, but the residual problems require implementation clarification, standard test-vector validation, a nonce/key protocol, authenticated encryption and replay handling, end-to-end evaluation, and substantial claim narrowing or new mobile/platform experiments. These are substantial but potentially repairable; the present evidence is not sufficient for acceptance in *Scientific Reports*.
