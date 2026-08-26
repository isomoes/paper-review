# Re-Review Report

## Manuscript

**Title:** *GPU-Accelerated Quantum-resistant Image Encryption for Social Media using Lightweight Cryptographic Stream Cipher*  
**Review date:** 2026-08-26  
**Review type:** Verification re-review  
**Recommendation:** **Major Revision**; if the journal cannot permit a complete implementation audit and benchmark rerun, rejection with an invitation to resubmit would be reasonable.  
**Confidence:** 4/5 for cryptographic and GPU-methodology findings; venue fit was not assessed because no target journal criteria were supplied.  
**Calibration status:** `NOT_CALIBRATED`

## Review Basis and Input Limitations

The package contains the revised manuscript, a highlighted manuscript, and a point-by-point review/response document. The highlighted and revised manuscripts have substantively identical extracted text; the package does **not** contain the original pre-revision manuscript, a formal revision roadmap, reviewer configuration cards, or a revision-evidence bundle. Consequently, this is an evidence-based standalone verification against the supplied reviewer comments, not a fully replayable contract re-review. Statements about what changed from the original cannot be independently verified.

## Executive Assessment

The revision makes visible improvements: it adds AES-256-CTR and ASCON-128a comparison tables, reports kernel-only timing and throughput, introduces image-security metrics, discusses a threat model and deployment limitations, and provides a code-repository link. These additions respond to the topics raised by the reviewers.

However, the central validity problems remain unresolved. The manuscript claims a 256-bit, quantum-resistant system, while the detailed CPU and CUDA methods repeatedly specify Salsa20-128. The CUDA pseudocode also reverses the standard nonce/counter state positions, does not establish unique nonce generation, and computes the image buffer length as `width × height` while claiming RGB-image validation. These inconsistencies prevent verification that the evaluated implementation is standard Salsa20-256 or that it encrypts all image bytes.

The performance evidence also requires a full rerun. The advertised 265× and 1381× speedups compare explicitly described Salsa20-128 CPU measurements with GPU tables that include Salsa20-256; end-to-end transfers are excluded; no repeated-trial statistics are reported; occupancy, register spilling, power, and memory claims are asserted without the underlying profiler measurements; and throughput and energy-efficiency rows appear to use different payload-size denominators. The claimed Salsa20 latency advantage is contradicted by the manuscript's own ASCON-128a results.

Accordingly, the manuscript is not publishable in its current form. The deficiencies are potentially repairable, but only through implementation correction/validation, benchmark redesign, and substantial rewriting—not through additional discussion alone.

## Genuine Improvements

1. **Timing scope is now disclosed.** The manuscript states that CUDA events measure kernel execution and that PCIe transfer is excluded from headline speedups (`revision 30.txt`, lines 605–607 and 1184–1192).
2. **Comparative GPU baselines were added.** AES-256-CTR and ASCON-128a timing and summary tables are present (lines 917–946 and 1086–1095).
3. **Security and deployment limitations are discussed.** The revision acknowledges missing authentication, lossy-recompression incompatibility, metadata leakage, and external key management (lines 1115–1182).
4. **Reproducibility is improved in principle.** A public code-repository link is supplied (lines 1227–1229), although the manuscript still lacks a commit hash, build configuration, and validation record.

## Critical and Major Findings

### C1. The evaluated cipher variant is internally inconsistent

**Severity:** Critical  
**Evidence anchors:** Abstract, lines 20–32; serial methods, lines 359–512; CUDA methods, lines 514–742; Results, lines 762–789.

The title, abstract, security argument, and principal conclusions concern Salsa20-256. In contrast, the complete serial and parallel pseudocode is labeled Salsa20-128 and initializes a 128-bit key. Algorithm 7 says the key is “repeated,” which is the 128-bit-key construction. The CPU results are explicitly for Salsa20-128, while speedups are then stated for the proposed 256-bit system. The assertion that Salsa20-256 “will have the same computation time” (lines 784–785) is not a substitute for measuring and validating that implementation.

**Required remedy:** Select one cipher variant and make the title, state construction, code, test vectors, experiments, tables, and security claims consistent. If Salsa20-256 is the contribution, provide its full 256-bit state initialization and published known-answer test results for both CPU and GPU implementations. Rerun every benchmark using the same variant and payload on both devices.

### C2. Standard Salsa20 state construction is not demonstrated

**Severity:** Critical  
**Evidence anchors:** State matrix, lines 287–302; CUDA kernel pseudocode, lines 682–702.

The earlier matrix places the nonce in words 6–7 and counter in words 8–9, but Algorithm 7 assigns the counter to words 6–7 and nonce to words 8–9. Standard Salsa20 uses words 6–7 for the nonce/IV and words 8–9 for the block counter. The manuscript therefore contains mutually incompatible definitions, one of which is nonstandard. See the documented standard layout in [Nettle's Salsa20 interface](https://fossies.org/linux/nettle/salsa20.h).

**Required remedy:** Correct the state layout, validate against authoritative Salsa20/20 test vectors, and report byte-for-byte agreement between CPU and GPU outputs over boundary cases, multiple message lengths, both key sizes if retained, counter carries, and non-block-aligned inputs.

### C3. Nonce management is absent, creating a catastrophic reuse risk

**Severity:** Critical  
**Evidence anchors:** Salsa20 inputs, lines 269–295; Algorithms 6–7, lines 639–702; threat model, lines 1117–1128.

The pseudocode merely “initializes” a nonce and resets the base counter to zero. It does not specify unique nonce generation, storage/transmission, collision handling, or prevention of reuse under the same key. Reusing a Salsa20 key/nonce pair produces the same keystream, allowing an attacker to XOR ciphertexts and recover the XOR of plaintexts. This is central to the claimed multi-image social-media use case, not an optional deployment detail.

**Required remedy:** Define and implement a nonce lifecycle that guarantees uniqueness per key; bind the nonce and relevant metadata into an authenticated construction; include reuse-negative tests; and revise the threat model accordingly.

### C4. RGB image processing length appears incorrect

**Severity:** Critical  
**Evidence anchors:** Data initialization, lines 542–547; Algorithm 6, lines 643–660; claimed Lenna RGB validation, lines 911–915.

The manuscript calculates `data_len = width × height`, despite loading a channel count and elsewhere correctly defining image bytes as `width × height × channels` (lines 409–415). For an RGB image, the CUDA pseudocode therefore processes only one third of the decoded pixel buffer unless an undocumented conversion to one channel occurs. This contradicts the claimed color-image validation.

**Required remedy:** Define the exact decoded buffer layout and byte count; process `width × height × channels` bytes; add tests that verify every byte is encrypted; and report hashes or exact comparisons for original/decrypted buffers across grayscale, RGB, and RGBA inputs.

### C5. The paper incorrectly explains Salsa20 as public-key encryption

**Severity:** Major  
**Evidence anchor:** Introduction, lines 63–71.

The text describes encryption with a public key and decryption with a private key. Salsa20 is a symmetric stream cipher using the same secret key for encryption and decryption. This is a foundational conceptual error and conflicts with the later shared-secret threat model.

**Required remedy:** Replace Figure 1 and its explanation with a correct symmetric-encryption model showing shared secret key, unique nonce, counter, ciphertext, and authentication tag.

### C6. No authentication or integrity is implemented for an active-channel setting

**Severity:** Critical  
**Evidence anchors:** Threat model, lines 1117–1128; limitations, lines 1163–1178; deployment claims, lines 1212–1220.

The manuscript assumes untrusted network intermediaries but acknowledges that ciphertext is unauthenticated and vulnerable to bit flipping. Salsa20 alone cannot detect modification, substitution, truncation, or replay. Disclosing this limitation does not support the abstract's and conclusion's claim of a secure social-media encryption system. The “robustness” tables also report degraded outputs for ASCON-128a after ciphertext corruption; a correctly verified authenticated ASCON construction should reject modified ciphertext, suggesting that its tag may have been omitted or ignored.

**Required remedy:** Either narrow the entire contribution to a confidentiality-only kernel benchmark or implement and benchmark a standardized authenticated construction with explicit nonce, tag, associated-data, tamper, truncation, and replay handling. State whether ASCON tag generation and verification were included; if not, relabel and rerun that baseline.

### M1. Headline speedups do not establish a fair CPU/GPU comparison

**Severity:** Major  
**Evidence anchors:** CPU timing, lines 762–767; GPU variants, lines 784–789; headline conclusion, lines 1184–1192.

The CPU measurement is explicitly Salsa20-128, while the main security and GPU claims concern Salsa20-256. Compiler version/flags, CPU vectorization, core/thread use, warm-up, repetitions, clock control, and optimized reference library are not reported. The headline excludes PCIe transfer and image decoding/encoding, so it is kernel speedup rather than application speedup.

**Required remedy:** Benchmark a correctness-validated identical implementation and payload; compare against a recognized optimized CPU implementation; report kernel-only and end-to-end latency separately; include warm-up, synchronization, trial count, distribution/dispersion, compiler flags, clocks, and complete hardware/software versions.

### M2. Occupancy and “8192 × 8” architectural claims lack evidence

**Severity:** Major  
**Evidence anchors:** Results, lines 790–794; novelty claim, lines 993–1000; conclusion, lines 1197–1204.

The manuscript says that 8192 blocks × 8 threads maximizes SM occupancy without register spilling, but reports no achieved occupancy, active-warps-per-SM, registers per thread, resident block limit, memory throughput, or cache metrics by configuration. An eight-thread CUDA block occupies a 32-lane warp with most lanes inactive, so the occupancy claim is especially implausible without profiler evidence. Grid size and block size are also varied while keeping 65,536 launched threads, most of which are unnecessary for the stated payload.

**Required remedy:** Report Nsight Compute metrics for every launch configuration and explain resource limits mechanistically. Separate grid-size sufficiency from threads-per-block tuning, and test conventional block sizes with enough grid blocks to cover the payload.

### M3. Throughput and energy-efficiency denominators are inconsistent or undocumented

**Severity:** Major  
**Evidence anchors:** Input size, lines 762–767; Table 11, lines 1086–1095.

For a stated 1.34 MB payload, 0.168 ms yields about 7,976 MB/s, matching the reported Salsa20 throughput. But 5.37 mJ over 1.34 MB yields about 250 MB/J, not 780.38 MB/J. Each reported energy-efficiency value multiplied by energy implies a payload of approximately 4.19 MB. The table therefore appears to mix compressed file size and decoded pixel-buffer size. The power sampling method is not described.

**Required remedy:** Use one explicitly defined byte count per operation, show formulas, and reconcile every table row. Report power source, sampling rate, baseline subtraction, integration window, repeated trials, and uncertainty.

### M4. The manuscript's own results contradict the claimed latency advantage

**Severity:** Major  
**Evidence anchors:** Tables 6–7, lines 917–946; claims, lines 1052–1100.

ASCON-128a is reported at 0.144 ms encryption and 0.104 ms decryption, compared with Salsa20 at approximately 0.168 and 0.172 ms. Table 11 likewise reports higher ASCON throughput. The statement that Salsa20 uniquely provides minimal latency and that both baselines have higher computational cost is therefore false on the presented data. Separately, ASCON-128a has a 128-bit key, so the manuscript cannot claim both a generic 128-bit post-quantum key-search margin and equivalence to Salsa20-256.

**Required remedy:** Correct all comparative claims, distinguish performance from security-strength comparisons, and compare algorithms at explicitly matched security targets and functionality (including authentication).

### M5. “Rounds per byte” is not a valid cross-cipher complexity comparison

**Severity:** Major  
**Evidence anchor:** Discussion, lines 1102–1109.

A round in Salsa20, AES, and ASCON performs different operations over different states, rates, and modes. Dividing nominal rounds by bytes does not produce a cipher-independent complexity metric and cannot explain measured GPU performance.

**Required remedy:** Remove this metric or replace it with operation counts, instruction mix, achieved throughput, memory traffic, occupancy, and profiler-supported bottleneck analysis.

### M6. Security evaluation remains incomplete and partly misinterpreted

**Severity:** Major  
**Evidence anchors:** Metric definitions, lines 952–990; Tables 8–10, lines 1004–1081; author note, `Review.txt`, lines 397–400.

NIST keystream testing and known-/chosen-plaintext analysis were deferred rather than performed. NPCR/UACI are zero when a single plaintext pixel is changed under the same stream-cipher keystream because XOR encryption is locally malleable; presenting this as an image-security evaluation neither validates nor invalidates Salsa20, but it demonstrates that these diffusion metrics are not directly transferable from permutation/diffusion image ciphers. Noise/cropping PSNR values lack a protocol, baseline, repetitions, and interpretation; localized corruption is expected for unauthenticated stream encryption and is not evidence of cryptographic robustness.

**Required remedy:** Prioritize standard primitive validation, nonce-reuse analysis, authentication, and explicit adversarial security properties. If image metrics are retained, define exact experiments, repetitions, confidence intervals, and their limited meaning.

### M7. “Quantum-resistant” remains overstated and inconsistent

**Severity:** Major  
**Evidence anchors:** Title and abstract, lines 1–32; quantum discussion, lines 217–245; claims, lines 989–990 and 1052–1100.

A 256-bit symmetric key can retain a substantial generic-search margin under idealized Grover analysis, but this does not make the presented application a standardized post-quantum cryptosystem, and the security of the complete system depends on correct implementation, nonce handling, authentication, and key establishment. NIST notes that AES-192 and AES-256 are expected to remain safe for a long time and recommends authenticated encryption such as AES-256-GCM in relevant guidance; see the [NIST PQC FAQ](https://csrc.nist.gov/Projects/post-quantum-cryptography/faqs). The manuscript's detailed 128-bit implementation would not support its stated 128-bit post-quantum margin.

**Required remedy:** Use precise wording such as “GPU implementation of Salsa20-256 evaluated under a generic quantum key-search model,” conditional on actually implementing Salsa20-256. Remove categorical statements such as “the only applicable quantum attack,” and separate primitive-level key-search arguments from complete-system security.

### M8. State-of-the-art and novelty comparisons remain incomplete

**Severity:** Major  
**Evidence anchors:** Prior implementation discussion, lines 194–201; comparison claims, lines 993–1000 and 1102–1109.

The revision compares three in-house CUDA implementations but does not provide a quantitative comparison with recent GPU stream-cipher/image-encryption systems, ChaCha20 GPU work, OpenCL/OpenMP implementations, or the cited 2013 autotuned Salsa20 implementation. More seriously, the manuscript itself reports 43.44 GB/s for Khalid et al. (lines 194–197) versus 7.98 GB/s for the present method (lines 1086–1090), directly undermining the unqualified claim of greater efficiency. Hardware generations and timing scopes differ, so neither superiority nor inferiority can be established without normalization.

**Required remedy:** Add a normalized related-work table and either provide reproducible same-hardware implementations or clearly label cross-paper comparisons as non-equivalent. The contribution should be framed as an empirical implementation study unless a genuinely new kernel or architectural method is demonstrated.

### M9. Experimental breadth and statistics remain inadequate

**Severity:** Major  
**Evidence anchors:** Airport image experiment, lines 762–789; Lenna addition, lines 911–915; limitations, lines 1163–1182.

Only two images are described, one grayscale and one RGB. No dataset suite, resolution sweep, batch-size analysis, trial count, mean/median, variance, confidence interval, or outlier handling is reported. A second image is not a scalability study.

**Required remedy:** Evaluate multiple standard images across controlled resolutions, channel counts, and batch sizes; report repeated trials and uncertainty; and include end-to-end scaling curves.

### M10. Baseline implementation and functionality are insufficiently documented

**Severity:** Major  
**Evidence anchors:** AES/ASCON tables, lines 917–946 and 1028–1095.

The manuscript does not describe the CUDA kernels, libraries, correctness tests, nonce/counter handling, or authentication behavior of AES-CTR and ASCON-128a. ASCON-128a is an authenticated-encryption algorithm, but the comparison appears to reduce it to confidentiality timing without explaining tag generation/verification. AES-CTR and unauthenticated Salsa20 are not equivalent to AES-GCM or full ASCON-128a functionality.

**Required remedy:** Document each baseline fully, validate it with official vectors, include equivalent functionality and timing scope, and release the exact source commit used for every table.

### M11. The Salsa20 specification contains additional contradictory statements

**Severity:** Major  
**Evidence anchors:** Quarter-round equations, lines 304–324; feed-forward explanation, lines 337–342; Algorithm 5, lines 488–495.

The equations use left-shift notation where Salsa20 requires rotate-left, while Algorithm 5 later uses `ROTL`. The description of the quarter round/row and column structure is inaccurate, and feed-forward addition is described as if its purpose were simply to prevent reversing the state. These inconsistencies make the algorithm impossible to reproduce reliably from the paper.

**Required remedy:** Rewrite the primitive description directly against the authoritative Salsa20 specification, use unambiguous modular-addition and rotation notation, and treat official known-answer tests—not successful self-decryption—as the conformance criterion.

## Verification Matrix Against Prior Comments

Legend: **Full** = substantively satisfied; **Partial** = relevant material added but acceptance criterion remains unmet; **Not addressed** = requested evidence absent or only deferred/asserted; **Cannot verify** = package lacks the original evidence needed for comparison.

| Prior item | Verdict | Verification summary |
|---|---|---|
| R1.1 State-of-the-art comparison | **Partial** | Same-GPU AES-CTR and ASCON tables were added, but recent related image/stream/GPU methods and normalized prior-work comparisons are absent. |
| R1.2 Standard security metrics | **Partial** | Several metrics were added; NIST/CPA/KPA were deferred, and robustness/diffusion interpretations remain methodologically weak. |
| R1.3 Performance evaluation | **Partial** | Kernel timing, throughput, memory, energy, and one extra image appear, but comparability, statistics, end-to-end timing, complexity, and scalability are unresolved. |
| R1.4 Figure improvement | **Cannot verify / Partial** | Resolution change cannot be checked without the original. Current figures remain inconsistently scaled and several occupy excessive page area. |
| R1.5 Multiple datasets and averaging | **Not addressed** | Only two images are shown; no multiple independent trials or uncertainty are reported. |
| R1.6 Expanded discussion | **Partial** | Dedicated discussion and limitations were added, but several explanations are assertions contradicted by the methods/results. |
| R2.1 Quantum-resistance justification | **Partial** | Grover discussion was added, but the implementation is described as 128-bit and system-level claims remain overstated. |
| R2.2 Novelty over prior CUDA Salsa20 | **Partial** | A comparative-framework claim was added, but no validated new kernel method or normalized prior-implementation evidence is demonstrated. |
| R2.3 Comprehensive security evaluation | **Partial** | Metrics were added; NIST tests and CPA/KPA analysis remain future work, while nonce reuse and authentication are not solved. |
| R2.4 Throughput, kernel time, PCIe scope | **Partial** | These are reported/disclosed, but the headline speedups remain an unfair or unverifiable comparison and omit end-to-end costs. |
| R2.5 Threat model and deployment | **Partial** | The discussion is substantially expanded, but the actual scheme lacks nonce management and authentication and is incompatible with ordinary recompressing platforms. |
| R2.6 Lightweight classification | **Not addressed** | Equal buffer allocation and unsupported energy/rounds-per-byte figures do not establish a lightweight classification. |
| R2.7 ChaCha20, AES-GCM, ASCON comparison | **Partial** | ASCON and AES-CTR are included; ChaCha20 and AES-GCM are not. AES-CTR is not AES-GCM. |
| R2 minor: define LWC | **Full** | Defined in the abstract/introduction. |
| R2 minor: CUDA strategy | **Partial** | Parameter sweeping is described, but the claimed architectural mechanism lacks profiler evidence. |
| R2 minor: explain 8192 × 8 | **Not addressed** | The manuscript repeats an occupancy assertion without measurements. |
| R2 minor: throughput | **Full, arithmetically qualified** | Throughput is reported, but its payload denominator must be reconciled with energy calculations. |
| R2 minor: abstract readability | **Partial** | Shorter than before cannot be verified; current abstract still overclaims security and omits key limitations. |
| R3.1 New scientific contribution | **Partial** | Contribution is reframed as comparative characterization, but evidence for novelty and superiority remains insufficient. |
| R3.2 Post-quantum theory | **Partial** | Theory is added, but it does not repair the 128/256 implementation mismatch or complete-system assumptions. |
| R3.3 Security/attack tests | **Partial** | Several metrics added; CPA/KPA and NIST tests deferred, and metric interpretation is problematic. |
| R3.4 OpenMP/OpenCL/ChaCha/AES-GPU | **Not addressed / Partial** | AES-GPU included; OpenMP, OpenCL, and ChaCha comparisons are deferred. |
| R3.5 Architectural explanation | **Not addressed** | No occupancy/register/cache/memory-latency measurements support the optimum claim. |
| R3.6 Add three references | **Full** | The requested references appear in the manuscript/reference list. |
| R3.7 Multiple resolutions/datasets | **Partial** | One additional RGB image was added, not a multi-resolution or multi-dataset evaluation. |
| R3.8 Oversized Figures 3–6 | **Not addressed** | The response explicitly retained them large; current layout still uses excessive space. |
| R3.9 Professional English editing | **Not addressed** | Numerous grammatical and technical-language errors remain throughout. |
| R3.10 Variable consistency | **Not addressed** | Examples include Salsa20-128 versus Salsa20-256, `width × height` versus `width × height × channels`, and inconsistent security claims. |

## Required Revision Plan

### Priority 1 — Validity blockers

1. Freeze a single specification for Salsa20-256; correct state layout and image-byte length.
2. Implement unique nonce management and authenticated encryption or an encrypt-then-MAC design suitable for the stated threat model.
3. Validate CPU, GPU, and baselines against authoritative known-answer tests and cross-implementation byte equality.
4. Rerun all performance experiments with identical cipher variant, bytes, functionality, and timing scopes.
5. Release the exact source commit, build scripts, compiler flags, datasets, raw timing/power logs, and analysis scripts.

### Priority 2 — Experimental reconstruction

1. Report kernel-only and end-to-end latency, throughput, energy, and memory with consistent denominators.
2. Use repeated trials and uncertainty estimates across multiple resolutions, channel formats, and batch sizes.
3. Provide Nsight Compute evidence for occupancy, register use, warp efficiency, memory throughput, and cache behavior.
4. Compare against optimized CPU code and equivalent authenticated GPU baselines.
5. Correct all claims contradicted by Table 11, especially ASCON latency and security-strength statements.

### Priority 3 — Framing and presentation

1. Retitle/rewrite the paper to avoid unqualified “quantum-resistant” and “secure social-media encryption” claims.
2. Rebuild the Introduction around the actual research gap; remove unrelated GPU literature.
3. Replace invalid “rounds per byte” reasoning with profiler-supported analysis.
4. Professionally edit the English, terminology, equations, captions, and figure sizing.
5. Provide a revised response letter that states exactly what was implemented, rerun, or declined—without treating future work as completion of a required revision.

## Questions Requiring Author Response

1. Which exact source file and commit produced every Salsa20-256 result, and does it pass published Salsa20/20 256-bit test vectors?
2. Why does Algorithm 7 place the counter in state words 6–7 and nonce in 8–9, contrary to both the manuscript's earlier matrix and the standard layout?
3. For the RGB Lenna experiment, what exact byte count was encrypted, and how was `width × height` sufficient for all color channels?
4. What payload definition, power sampling procedure, and integration window produce 5.37 mJ and 780.38 MB/J while throughput is calculated from a 1.34 MB payload?

## Final Recommendation

**Major Revision.** The revision addresses many reviewer topics at the level of added text and tables, but it does not yet satisfy the evidentiary requirements behind those comments. The cipher identity, correctness, nonce safety, RGB byte coverage, benchmark comparability, and performance/security conclusions must be reconstructed and independently verifiable before publication can be considered.
