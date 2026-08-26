# Reviewer 2 — Round-2 Domain Re-review

**Expertise:** symmetric cryptography, stream ciphers, and GPU implementations  
**Venue:** *Scientific Reports*  
**Recommendation:** **Reject**

## Overall assessment

The revision has genuine improvements: it now states the 64-bit nonce and 64-bit block counter, presents the standard Salsa20 quarter-round equations, bounds the final partial block, specifies little-endian output, discloses that the headline GPU timings exclude PCIe transfer, adds comparison baselines, and openly acknowledges compression, metadata, key-management, and authentication limitations. These changes improve transparency.

However, the central implementation is not presently shown to be Salsa20-conformant or even to encrypt all bytes of an RGB image. The GPU pseudocode reverses the standard nonce and counter positions, while the GPU image length omits the channel count. No known-answer test is reported; a round-trip test cannot detect either a nonstandard permutation or a mutually cancelling implementation error. Nonce generation and uniqueness are unspecified. In addition, the application remains unauthenticated despite an active/untrusted communication setting. These are not presentational issues: they undermine the claimed primitive identity, confidentiality coverage, security, comparisons, and deployment conclusions. The paper therefore does not yet satisfy the baseline technical-soundness requirement for publication.

## Genuine strengths

1. **Several low-level operations are described correctly.** The quarter-round sequence and rotations are consistent with Salsa20 (lines 317–323 and 491–495), the feed-forward step is included (lines 479–482 and 719–722), and the GPU output is explicitly serialized little-endian (lines 719–722).
2. **Partial final blocks are bounded.** Both serial and GPU pseudocode limit XOR to the remaining bytes (lines 451–460 and 698–701), avoiding an obvious out-of-bounds tail operation at the specification level.
3. **The revision is more candid about measurement scope.** Kernel timing and exclusion of PCIe transfer are now disclosed (lines 1184–1192), although end-to-end figures remain necessary.
4. **Deployment limitations are recognized.** The manuscript now identifies lossy recompression, metadata leakage, external key management, and lack of authentication (lines 1115–1158 and 1163–1182). This is useful, even though the proposed system does not yet remedy these limitations.
5. **The evaluation includes common-GPU baselines and reports throughput/energy/memory.** Tables 6–7 and 11 (lines 917–946 and 1086–1094) are a useful direction, subject to the conformance and functional-validity concerns below.

## Verification of prior Reviewer-2 comments

| Prior item | Status | Verification with exact manuscript anchors |
|---|---|---|
| R2-1: justify “quantum-resistant,” define threat model | **Partly addressed** | Grover search is discussed at lines 221–228 and a threat model is added at lines 1115–1128. The wording remains overstrong: “the only quantum attack applicable” and a “hard mathematical floor” are not established for the complete Salsa20 construction; see Major 3. |
| R2-2: clarify novelty beyond a CUDA port | **Partly addressed** | A comparative/tuning contribution is claimed at lines 993–1000 and 1102–1109. Yet the claimed occupancy/no-spill mechanism is not supported by reported occupancy, register, resident-block, cache, or profiler values, and the stated latency advantage contradicts Table 11; see Major 6. |
| R2-3: expand security evaluation | **Partly addressed, but materially misinterpreted** | Entropy, chi-square, correlation, NPCR/UACI, key sensitivity, and noise measures are added at lines 952–988 and Tables 8–10 (lines 1004–1023, 1028–1047, 1062–1081). NPCR/UACI and histogram statistics are interpreted as security evidence in ways inappropriate for a standard stream cipher; see Major 4. NIST keystream testing and KPA/CPA analysis remain deferred rather than performed. |
| R2-4: report throughput, kernel scope, and PCIe overhead | **Mostly addressed for kernel-only measurements** | Throughput appears in Table 11 (lines 1086–1094), and PCIe exclusion is stated at lines 1189–1192. End-to-end latency, including decode/encode, allocation, transfer, synchronization, and tag handling, is still absent, so the real-time application claim remains unsupported. |
| R2-5: threat model, compression, metadata, deployment | **Partly addressed** | These topics are discussed at lines 1115–1182. The model is internally inconsistent with an unauthenticated cipher and an untrusted network, and nonce lifecycle is absent; see Critical 3 and Critical 4. |
| R2-6: justify “lightweight” quantitatively | **Partly addressed** | Energy, memory, and throughput are reported at lines 1086–1094, and a rounds-per-byte comparison is offered at lines 1102–1106. “Rounds per byte” is not a cipher-independent complexity measure, and equal 6.29 MB application allocation does not establish primitive-level lightweight resource use. |
| R2-7: compare with ChaCha20, AES-GCM, and Ascon | **Partly addressed** | AES-256-CTR and ASCON-128a are implemented (lines 917–946 and 1086–1094), but ChaCha20 and AES-GCM are absent. More importantly, ASCON-128a is an AEAD baseline, whereas Salsa20 and AES-CTR are confidentiality-only here; tag generation/verification and associated-data treatment are not described, making functionality and timing non-equivalent. |
| Minor: define LWC | **Addressed** | Defined in the abstract at lines 22–24. |
| Minor: explain CUDA optimization and 8192×8 selection | **Partly addressed** | The selected configuration is reported at lines 790–794 and an occupancy/no-spill explanation is asserted at lines 993–1000, but no supporting hardware-counter evidence is reported. |
| Minor: report throughput | **Addressed, subject to validation** | Table 11, lines 1086–1094. |

## Critical and Major findings

### Critical 1 — The documented GPU state layout is not standard Salsa20

**Problem.** The manuscript itself gives the standard layout with nonce words at state positions 6–7 and counter words at 8–9 (matrix at lines 297–302). Algorithm 7 instead assigns the counter to `state[6]` and `state[7]` and the nonce to `state[8]` and `state[9]` (lines 690–697). This reversal is not a cosmetic indexing choice because the Salsa20 double-round is position-dependent. The 256-bit GPU initialization is not specified at all, while most security and headline claims concern Salsa20-256 (lines 24–32, 802–814, 840–852, and 1212–1220). For the 128-bit path, Algorithm 3 labels “expand 16-byte k” as sigma rather than tau and leaves `InitializeState` undefined (lines 446–455); Algorithm 7 merely says the key is “repeated” (lines 690–697). Thus neither variant is specified with sufficient precision to establish conformance.

**Consequence.** If the code follows Algorithm 7, the output is a nonstandard Salsa20-like construction and cannot inherit Salsa20’s test vectors or security record. If the code does not follow Algorithm 7, the manuscript does not accurately document the evaluated implementation. Either case invalidates the central primitive-identification and security claims.

**Minimum remedy.** Correct and fully enumerate the 16-word state for both Salsa20/128 (tau constants and repeated 16-byte key) and Salsa20/256 (sigma constants and eight distinct key words), including byte decoding, word indices, nonce, 64-bit counter, feed-forward, and serialization. Re-run all results using the corrected implementation and report byte-exact conformance tests as required in Major 1.

### Critical 2 — The GPU path appears to encrypt only one channel of an RGB image

**Problem.** The serial path correctly defines `L = W × H × C` (lines 412–415). The GPU description and Algorithm 6 instead define `data_len = width × height`, omitting channels (lines 542–547 and 643–655). The manuscript nevertheless claims RGB/colour-image operation (lines 914–915 and 1212–1220).

**Consequence.** For a conventional interleaved RGB buffer, only one third of the pixel bytes would be transformed; the remaining two thirds would stay in plaintext. This is catastrophic content leakage. It also means the reported timing, throughput, ciphertext histograms, and colour-image validation may describe a partial buffer rather than full-image encryption.

**Minimum remedy.** Define the exact decoded buffer layout and set the byte length to `width × height × channels` (or the library-reported stride/byte count, including any intended alpha handling). Demonstrate that every decoded pixel byte is covered using RGB, RGBA, grayscale, and non-multiple-of-64 test cases; report unchanged-byte checks and regenerate all performance and security tables.

### Critical 3 — No nonce lifecycle prevents catastrophic keystream reuse

**Problem.** The paper explains that a nonce must be unique (lines 269–274 and 287–295), but both serial and GPU algorithms merely “initialize” a nonce and reset the counter to zero (lines 410–425, 446–460, and 648–671). There is no CSPRNG or allocation mechanism, no uniqueness enforcement per key, no storage/transmission format, no collision or restart policy, no multi-sender coordination, and no counter-exhaustion rule. The social-media scenario necessarily processes many messages under long-lived keys.

**Consequence.** Reusing a Salsa20 key/nonce pair reuses the keystream, so XORing two ciphertexts reveals the XOR of the plaintexts and enables well-known recovery attacks on structured images. GPU parallelism does not mitigate this failure.

**Minimum remedy.** Specify and implement an end-to-end nonce protocol: generate or allocate a unique 64-bit nonce for every message under a key, bind it to the ciphertext, persist uniqueness across crashes/restarts and devices, prevent multi-sender collisions, and prohibit counter wrap. For a practical application, prefer a standard misuse-resistant or extended-nonce authenticated construction/library rather than inventing nonce management. Test repeated encryptions, restarts, and concurrent senders.

### Critical 4 — The proposed system offers no integrity despite an active communication setting

**Problem.** The manuscript correctly admits that ciphertext is unauthenticated and malleable (lines 1163–1177), yet the abstract still calls the result “secure” (lines 29–32), the threat model places no trust in network intermediaries (lines 1117–1128), and deployment claims continue through lines 1178–1182 and 1212–1220. Raw Salsa20 permits controlled ciphertext bit flips, truncation, reordering, and substitution. A decrypted-image equality test using the same local buffer is not received-ciphertext authentication.

**Consequence.** An active intermediary can alter image content without detection. In safety-relevant images, manipulated pixels could have serious consequences. The proposed construction therefore does not meet ordinary secure-messaging or social-media protection requirements.

**Minimum remedy.** Implement and evaluate a standardized authenticated-encryption construction with explicit nonce, tag, associated-data, and failure handling (for example, a vetted Salsa-family AEAD construction or another standard AEAD). Authenticate container-critical metadata such as dimensions, channel mode, message identity, and sequence context; reject before releasing plaintext on tag failure. Include tag generation/verification and failed-verification costs in all baselines and end-to-end timings. If this is not done, restrict every claim to a confidentiality-only kernel prototype under a passive-adversary model and remove practical “secure” deployment claims.

### Major 1 — No known-answer tests establish Salsa20 correctness

**Problem.** Validation consists mainly of encrypting and decrypting with the same function and comparing the result (lines 368–396, 423–438, and 728–742). Because XOR is involutive, this test succeeds even when the same wrong keystream generator is used twice. No official/eSTREAM Salsa20 known-answer vectors, intermediate state vectors, CPU-versus-GPU cross-checks, or independent implementation comparisons are reported.

**Consequence.** The state-layout defect, endianness errors, key-variant errors, counter errors, or GPU indexing/race errors can all survive the current round-trip test. Consequently, none of the security or performance results is anchored to a verified Salsa20 implementation.

**Minimum remedy.** Report byte-exact known-answer tests for Salsa20/20 with both 128- and 256-bit keys, including zero and nonzero key/nonce/counter cases. Test lengths 0, 1, 63, 64, 65, and multiple blocks; test counter carry; compare CPU and GPU output byte-for-byte against an independent vetted implementation; and publish reproducible test commands and pass/fail output.

### Major 2 — 128-bit and 256-bit variants are not treated consistently

**Problem.** The abstract and conclusion center Salsa20-256 (lines 20–32 and 1212–1220), whereas Sections 3 and 4 and Algorithms 1–8 describe only Salsa20-128 (lines 359–515 and 639–723). The manuscript states that Salsa20-256 has the same computation time as Salsa20-128 without a justified measurement model (lines 769–786), even though separate tables vary. It never provides the 256-bit state initialization or a variant-specific correctness test.

**Consequence.** Readers cannot reproduce the main claimed implementation or determine whether the 256-bit key is actually loaded as eight independent words rather than a repeated 128-bit key. The claimed 128-bit post-quantum margin depends precisely on using the 256-bit variant correctly.

**Minimum remedy.** Make one variant the explicit primary contribution and fully specify it. If both remain, provide separate state mappings, constants, key-loading code/pseudocode, KATs, configuration/timing methodology, and results for each; remove unsupported claims of identical timing.

### Major 3 — The quantum-search wording overstates what Grover/Bennett proves

**Problem.** Lines 221–228 state that Grover search is “the only quantum attack applicable” and that `2^(n/2)` is a “hard mathematical floor.” Bennett et al. provide an oracle/query lower bound for unstructured search, not a proof that every attack on the full Salsa20 construction reduces to unstructured key search. Structural quantum cryptanalysis, multi-target settings, data/query tradeoffs, and the enormous fault-tolerant circuit cost are not considered. Furthermore, lines 1057–1100 say both AES-256-CTR and ASCON-128a meet a 128-bit post-quantum requirement, while Table 10 lists ASCON-128a’s key space as `2^128` (line 1076), for which generic Grover key search is nominally about `2^64` queries, not `2^128`.

**Consequence.** The paper turns a qualified generic-search estimate into an unconditional proof and makes internally inconsistent baseline-security claims. This misleads readers about the scope of “quantum resistant.”

**Minimum remedy.** Replace categorical wording with: “under generic exhaustive key search, an idealized quantum adversary obtains a quadratic query reduction; a 256-bit key therefore targets roughly 128-bit generic quantum query complexity, subject to the stated attack and resource model.” State that this is not a proof of Salsa20 post-quantum security. Define single- versus multi-target assumptions and distinguish query complexity from practical quantum gates/depth. Correct the ASCON-128a comparison and avoid asserting a NIST-mandated universal “floor” without an exact applicable source and category mapping.

### Major 4 — Image-security metrics are not evidence of cryptographic security here

**Problem.** The conclusion infers statistical-attack resistance from a balanced histogram (lines 1193–1196). For a standard synchronous stream cipher, flipping one plaintext bit under the same key/nonce changes only that ciphertext bit; therefore the near-zero plaintext-differential NPCR/UACI reported at lines 1004–1017 is expected and is not an attack failure or success criterion. Conversely, changing the key and observing approximately random ciphertext differences (“key sensitivity”) is only a sanity check, not evidence against key recovery. Entropy, chi-square, and adjacent-pixel correlation likewise cannot establish CPA security. Noise/cropping PSNR on unauthenticated ciphertext measures graceful malleability/data corruption, not robustness or security; a secure authenticated receiver should reject modified ciphertext rather than output a partially corrupted image.

**Consequence.** The evaluation may cause readers to treat generic image statistics as cryptographic evidence, while missing the decisive requirements: standard conformance, nonce uniqueness, authentication, and a formal security notion.

**Minimum remedy.** Reframe histogram, entropy, and correlation results as descriptive sanity checks only. Explain the expected NPCR/UACI behavior of XOR stream encryption and do not label it differential-attack resistance. Remove or clearly reinterpret ciphertext-noise PSNR. Evaluate against an explicit confidentiality/integrity notion and adversary model; prioritize KATs, nonce-reuse tests, tamper rejection, and standard AEAD security over image-specific randomness metrics.

### Major 5 — Baseline functionality and performance claims are not equivalent or internally consistent

**Problem.** ASCON-128a is an authenticated-encryption algorithm, yet the paper does not specify nonce use, associated data, tag generation, tag verification, or rejection behavior. Comparing it to raw Salsa20/AES-CTR may therefore compare different functionality. Table 11 reports ASCON-128a as faster in encryption throughput (9,310 versus 7,980 MB/s), decryption throughput (12,880 versus 7,790 MB/s), and energy efficiency (841.02 versus 780.38 MB/J) (lines 1086–1094), contradicting the claim that Salsa20 has minimal latency and both alternatives cost more (lines 1052–1100). The “rounds per byte” values at lines 1102–1106 are not meaningful cross-family operation counts: a Salsa double-round, AES round, and ASCON permutation round have different work and granularity. The identical 6.29 MB memory figure appears dominated by common image/application allocation rather than cipher working state.

**Consequence.** The comparative conclusion and lightweight classification are not supported by like-for-like functionality or the paper’s own table. Omitting authentication costs from one scheme while including them for another can materially bias the ranking.

**Minimum remedy.** Define each baseline completely and verify it with standard vectors. Compare equivalent authenticated functionality, identical byte counts, nonce/tag/AD handling, and identical timing boundaries. Report kernel-only and end-to-end distributions over repeated runs, with synchronization, transfer, allocation, image coding, and authentication clearly separated. Correct conclusions to match Tables 6–7 and 11. Replace rounds-per-byte rhetoric with measured instruction, occupancy, register, bandwidth, and energy evidence.

### Major 6 — The 8192×8 architectural explanation is asserted rather than demonstrated

**Problem.** The paper says the 8192-block × 8-thread setting “maximizes SM occupancy without spilling registers” (lines 993–1000), but reports no achieved occupancy, registers/thread, shared memory, active warps, resident blocks, memory transactions, cache behavior, or profiler values by configuration. The grid also fixes 65,536 total threads (lines 790–794), while Algorithm 6 derives the grid from data length (lines 656–660); the relationship between the test image size, useful Salsa blocks, and potentially excess threads is not reconciled.

**Consequence.** The proposed optimization mechanism and generality across image sizes and GPUs are unsupported. An observed minimum on two devices is not evidence of the stated cause or a portable optimum.

**Minimum remedy.** Report Nsight Compute metrics for every tested configuration, explain how many threads perform useful work, and analyze warp underutilization from 8-thread blocks, occupancy limits, launch overhead, register pressure, and memory bandwidth. Repeat over multiple image sizes and enough runs to report variability. Describe 8192×8 only as the best tested point unless the mechanistic claim is demonstrated.

## Required revision threshold

A publishable resubmission would require more than textual clarification. At minimum it needs: (1) corrected and fully specified 128/256-bit Salsa20 state initialization; (2) full byte coverage for all image channel formats; (3) standard known-answer and cross-implementation tests; (4) a complete nonce lifecycle; (5) authenticated encryption or a strictly passive, confidentiality-only scope; and (6) complete re-execution of security and performance experiments using equivalent, conformant baselines. The conclusions must then be rewritten to match the resulting data and the limited meaning of image-statistical metrics.

## Recommendation

**Reject.** The revision addresses several earlier requests at the narrative level, but critical implementation and security-baseline defects remain. In particular, the documented state is nonconformant, RGB byte coverage is incomplete, nonce reuse is unmanaged, authentication is absent, and no KAT validates the primitive. Correcting these issues would require reimplementation and a new experimental campaign rather than a bounded revision of the present manuscript.
