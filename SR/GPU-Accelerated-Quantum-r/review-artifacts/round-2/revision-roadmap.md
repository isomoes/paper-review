# Revision Roadmap — Round-2 Re-Review

## Use and ordering

This roadmap contains the decision-driving items reported by the five role-separated reviewers. It is **non-ranking**: numbering records source order by first appearance in the review package (Journal-Fit, Methodology, Domain, Perspective, then Devil’s Advocate), not priority. Corroborating reviewers are listed on the same item to avoid duplicating the required work. All anchors refer to the revised manuscript line ranges cited in the reports.

## 1. Establish the exact Salsa20 implementation and standard conformance

- **Source reviewers:** Journal-Fit Reviewer (Major 1); Methodology Reviewer (Critical 1); Domain Reviewer (Critical 1, Major 1, Major 2); Perspective Reviewer (C2); Devil’s Advocate (C1).
- **Precise manuscript anchors:** title/abstract lines 1–32; state matrix lines 287–302; serial methods lines 359–515; GPU description lines 527–545; Algorithms 6–7 lines 639–723, especially 682–700; results lines 802–873; conclusion lines 1184–1222.
- **Problem:** The headline evidence concerns Salsa20-256, while the detailed CPU/GPU methods repeatedly describe Salsa20-128. Variant-specific key loading and state initialization are incomplete, and Algorithm 7 places counter and nonce words in positions that conflict with the manuscript’s own standard layout. Round-trip decryption alone does not establish conformance.
- **Consequence:** The tested primitive, claimed key strength, interoperability, and all dependent security/performance results are unverifiable; the implementation may be a nonstandard Salsa20-like construction.
- **Minimum remedy:** Select one primary variant or specify 128- and 256-bit variants separately; enumerate all 16 state words, constants, byte decoding, key words, nonce, 64-bit counter, feed-forward, and serialization; identify the exact executable/configuration behind every table; correct the implementation as necessary and rerun affected experiments; publish byte-exact known-answer and independent cross-implementation tests for both CPU and GPU over zero/nonzero inputs, boundary lengths, and counter carry.
- **Verification criterion:** Version-pinned code and manuscript pseudocode agree exactly; published test commands show byte-for-byte agreement with trusted Salsa20/20 vectors and an independent implementation for each retained variant; every result table names the tested binary, variant, key size, and parameters.

## 2. Correct image-buffer byte coverage and CPU/GPU workload equivalence

- **Source reviewers:** Journal-Fit Reviewer (Major 2); Methodology Reviewer (Critical 1); Domain Reviewer (Critical 2); Perspective Reviewer (C1); Devil’s Advocate (minor m2, corroborating a decision-critical panel finding).
- **Precise manuscript anchors:** CPU length lines 409–420; GPU length/copy description lines 530–547; Algorithms 6–8 lines 637–742, especially 643–660; RGB claim lines 911–915; conclusion lines 1212–1220.
- **Problem:** The CPU path defines `W × H × C`, whereas the GPU path defines `width × height`, omitting channels. Row stride, bit depth, alpha handling, encoded-file versus decoded-pixel handling, and exact copied/processed bytes are not fully specified.
- **Consequence:** RGB/RGBA bytes may remain in plaintext, colour-image confidentiality may fail, and CPU/GPU timing and throughput may compare unequal workloads.
- **Minimum remedy:** Use the exact decoded byte count, including channels and any row pitch; audit allocation, transfer, kernel bounds, tail handling, and output encoding; rerun all affected correctness, performance, and image-statistics results on identical buffers.
- **Verification criterion:** Automated grayscale, RGB, and RGBA tests at non-multiple-of-64 lengths show every intended byte transformed and recovered; published byte counts, hashes, and unchanged-byte checks match across CPU and GPU paths; pseudocode and released code implement the same rule.

## 3. Reconcile comparative conclusions with the tables and equalize baseline functionality

- **Source reviewers:** Journal-Fit Reviewer (Major 3); Methodology Reviewer (Major 6); Domain Reviewer (Major 5); Perspective Reviewer (M5); Devil’s Advocate (C2).
- **Precise manuscript anchors:** AES/ASCON results lines 917–946; comparative discussion lines 1052–1109; Table 11 lines 1086–1094.
- **Problem:** The prose says Salsa20 has minimal latency and that AES-256-CTR and ASCON-128a cost more, while the reported ASCON values show lower best kernel time, higher throughput, and lower energy per encryption. Baseline methods, byte/thread mapping, optimization policy, nonce/tag/associated-data handling, and correctness validation are also absent, so unlike security services may be compared.
- **Consequence:** The central superiority and lightweight conclusions are contradicted by the paper’s own results and may reflect unequal functionality or implementation maturity.
- **Minimum remedy:** Predefine the comparison objective; fully document and validate each baseline; compare identical byte counts and equivalent functionality, including authentication costs where claimed; recompute all results and rankings; separate latency, throughput, energy, confidentiality, and authenticated functionality; remove the cross-cipher “rounds per byte” inference and unsupported winner language.
- **Verification criterion:** Recalculation scripts reproduce every comparative value from raw data; each compared construction has documented standard-vector passes and identical timing boundaries/security services; abstract, Discussion, and Conclusion statements agree with corrected tables without exception.

## 4. Bound the post-quantum claim to the evidence

- **Source reviewers:** Journal-Fit Reviewer (Major 4); Domain Reviewer (Major 3); Perspective Reviewer (M5); Devil’s Advocate (M4).
- **Precise manuscript anchors:** lines 24, 53–56, 217–245, 989–990, 1052–1100, and 1212–1220.
- **Problem:** Grover’s generic-search query reduction is treated as comprehensive proof of “quantum resistance” and as the only applicable attack. The manuscript also treats ASCON-128a’s stated 128-bit key space as providing the same approximately 128-bit generic quantum key-search margin as a 256-bit key.
- **Consequence:** Readers may mistake a conditional key-search estimate for proof of full primitive, implementation, or system security, and the baseline security accounting is internally inconsistent.
- **Minimum remedy:** State a conditional generic exhaustive-key-search claim under an explicit attack/resource and single-/multi-target model; distinguish query complexity from practical circuit resources and from implementation/system security; remove “only applicable attack,” “hard floor,” and unqualified “quantum-resistant” language; correct the ASCON-128a comparison and precisely source any NIST category statement.
- **Verification criterion:** Every post-quantum statement is parameter-specific and conditional; a 256-bit key is described only as targeting roughly 128-bit generic quantum query complexity under the stated assumptions; no 128-bit-key baseline is assigned that same margin under the manuscript’s Grover model.

## 5. Rebuild the timing, speedup, and statistical protocol

- **Source reviewers:** Journal-Fit Reviewer (Major 5); Methodology Reviewer (Majors 2–3); Domain Reviewer (Major 5); Perspective Reviewer (M4); Devil’s Advocate (M1).
- **Precise manuscript anchors:** timing/results lines 605–607 and 758–946; abstract lines 20–32; deployment lines 1178–1182; speedup qualification lines 1184–1192.
- **Problem:** GPU event placement, synchronization, stream, warm-up, repetition, aggregation, and clock controls are unspecified; CPU timer boundaries and optimization status are absent; GPU kernel-only times are compared with CPU times; AES/ASCON CPU denominators are missing; no variability or uncertainty is reported; “1.34 Mb” and the MB convention are ambiguous.
- **Consequence:** Speedups, small configuration differences, scalability, and real-time benefit cannot be reproduced or distinguished from noise, boundary effects, or CPU/GPU implementation asymmetry.
- **Minimum remedy:** Define exact CPU/GPU timing boundaries, timer/event placement, synchronization, warm-ups, process-level repetitions, in-process iterations, outlier policy, compiler settings, CPU threading/SIMD status, clock/temperature/power controls, byte count, and unit convention; report kernel-only and complete H2D+kernel+D2H latency separately; add missing CPU baselines or remove their speedups; publish raw trials and uncertainty summaries.
- **Verification criterion:** An independent run using the archived commands reproduces medians/means and uncertainty within a declared tolerance; every speedup uses matched bytes, variant, functionality, hardware pairing, and timing boundary; all tables state sample size and dispersion/interval estimates.

## 6. Test rather than assert the 8192×8 architectural explanation

- **Source reviewers:** Journal-Fit Reviewer (Major 5); Methodology Reviewer (Major 4); Domain Reviewer (Major 6); Perspective Reviewer (prior-comment verification); Devil’s Advocate (M5).
- **Precise manuscript anchors:** launch sweep lines 790–794; occupancy/optimality claims lines 993–1000 and 1102–1109; conclusion lines 1197–1204.
- **Problem:** The manuscript calls 8192×8 occupancy-maximizing and spill-free without occupancy, register, resident-warp/block, spill, bandwidth, cache, stall, or profiler evidence. An 8-thread block underutilizes a 32-lane warp, and a finite sweep establishes only the fastest observed point for the tested workload.
- **Consequence:** The claimed optimization mechanism, novelty, causality, and generality across workloads/devices are unsupported.
- **Minimum remedy:** Report compiler resource output and named-version Nsight Compute metrics for every tested block size on both GPUs; explain useful-thread counts and sub-warp behavior; repeat across payload sizes with uncertainty; use “fastest among tested settings” unless the mechanistic and broader optimality claims are demonstrated.
- **Verification criterion:** Archived profiler commands/exports reproduce registers/thread, memory use, theoretical/achieved occupancy, active warps, spill traffic, bandwidth, cache/stall metrics, and error-aware timing for each configuration; prose claims do not exceed those measurements.

## 7. Separate implementation assurance from descriptive image statistics

- **Source reviewers:** Journal-Fit Reviewer (Major 6); Domain Reviewer (Major 4); Perspective Reviewer (prior-comment verification); Devil’s Advocate (M2).
- **Precise manuscript anchors:** histogram inference lines 769–785; metric definitions lines 952–990; Tables 8–10 lines 1004–1081; conclusion lines 1193–1196.
- **Problem:** Histogram, entropy, chi-square, correlation, NPCR/UACI, key sensitivity, and ciphertext-corruption PSNR are presented or implied as cryptographic security evidence. NPCR/UACI labels/protocols are ambiguous, and noise/cropping output demonstrates malleability rather than authenticated robustness.
- **Consequence:** Non-probative or expected visual statistics may be mistaken for conformance, CPA security, differential-attack resistance, or integrity.
- **Minimum remedy:** Define every metric’s changed variable, input, key, nonce, and expected interpretation; correct table structure; label histogram/entropy/correlation as descriptive checks only; explain stream-cipher NPCR/UACI behavior; remove attack-resistance and robustness inferences; prioritize standard-vector, nonce-reuse, reference-output, and—if applicable—tamper-rejection tests.
- **Verification criterion:** Tables and methods allow each metric to be reproduced unambiguously; no image statistic is cited as proof of cryptographic security; security conclusions map to an explicit adversary/security notion and standard implementation tests.

## 8. Provide an immutable, complete reproducibility package

- **Source reviewers:** Journal-Fit Reviewer (Major 7); Methodology Reviewer (Major 8); Devil’s Advocate (M8); Domain and Perspective Reviewers (corroborating reproducibility concerns).
- **Precise manuscript anchors:** experimental tables lines 762–946 and 1004–1094; Data Availability lines 1227–1229.
- **Problem:** The repository root is mutable and is not tied to a release, commit, DOI, licence, environment, inputs, raw timing/power/profiler data, or scripts that regenerate the tables. OS, CUDA/driver/compiler versions and flags, CPU/GPU execution settings, and benchmark-image provenance are incomplete.
- **Consequence:** Another laboratory cannot reconstruct the binaries, experimental conditions, or reported results, contrary to the reproducibility expected for the venue.
- **Minimum remedy:** Archive a licensed, immutable release containing exact source, dependency/toolchain versions, hardware/software configuration, build/run/profiler commands, fixed inputs and hashes, test vectors, raw trials and power traces, profiler exports, metric scripts, and table-regeneration scripts; revise Data Availability to identify it precisely.
- **Verification criterion:** A clean-environment reproduction using the archived release rebuilds the programs, passes correctness tests, and regenerates the reported tables/figures from included raw data; the manuscript cites a DOI or immutable commit/tag.

## 9. Demonstrate or narrow originality relative to prior GPU work

- **Source reviewers:** Journal-Fit Reviewer (Major 8); Methodology Reviewer (prior-comment verification); Domain Reviewer (Major 6, novelty discussion); Devil’s Advocate (M3).
- **Precise manuscript anchors:** prior GPU work lines 194–201; optimization/novelty lines 993–1000 and 1102–1109.
- **Problem:** The manuscript asserts greater efficiency than prior GPU Salsa20 work without normalized hardware, workload, timing-boundary, functionality, or implementation comparison. The cited prior throughput of 43.44 GB/s is not reconciled with the present 7.98 GB/s, and a launch-grid sweep does not by itself establish originality.
- **Consequence:** The current evidence may support a hardware-specific benchmark but not the stated state-of-the-art advantage or broader novelty.
- **Minimum remedy:** Add a focused related-work table and reproducible normalized comparisons covering algorithm/version, hardware, payload, timing scope, authentication, throughput, code availability, and optimization technique; identify the exact new optimization and evidence for it, or narrow the contribution to a rigorously validated comparative characterization/replication study.
- **Verification criterion:** Every novelty statement points to a specific, evidenced distinction from the closest work; “more efficient” is defined by a reproducible metric under comparable conditions, or removed.

## 10. Make energy and memory measurements auditable and arithmetically consistent

- **Source reviewers:** Methodology Reviewer (Major 5); Journal-Fit Reviewer (Majors 5 and 7); Domain Reviewer (Major 5); Perspective Reviewer (prior-comment verification); Devil’s Advocate (M8).
- **Precise manuscript anchors:** Table 11 lines 1086–1094; related energy/memory discussion lines 883–905.
- **Problem:** No instrument/API, sampling rate, idle baseline, integration interval, repetition, uncertainty, or definition of memory use is reported. Energy-efficiency arithmetic implies an approximately 4.19 MB payload, while throughput reconstructs only from an approximately 1.34 MB payload; identical 6.29 MB entries may reflect common allocation rather than cipher-specific memory.
- **Consequence:** Energy-efficiency and lightweight-resource claims cannot be audited and may use inconsistent denominators.
- **Minimum remedy:** State and correct the payload/formula for every value; document the power method, sample interval, baseline, integration window, repetitions, and uncertainty; distinguish kernel-only from full-operation energy; define allocated versus peak measured memory and itemize buffers/context overhead.
- **Verification criterion:** Published raw samples and scripts reproduce every Table 11 energy, efficiency, and memory value using one explicitly stated payload per experiment; dimensional checks close without unexplained discrepancies.

## 11. Supply controlled dataset and scaling evidence

- **Source reviewers:** Methodology Reviewer (Major 7); Journal-Fit Reviewer (prior-comment resolution); Perspective Reviewer (M4); Devil’s Advocate (M1 and prior-response verification).
- **Precise manuscript anchors:** principal image/timing lines 762–794; Lenna lines 911–915; scaling/launch discussion lines 1197–1222.
- **Problem:** Only a 1.34 MB airport image and a 512 KB Lenna image are mentioned, without complete dimensions, source/licence, hashes, a controlled size series, or per-image cross-cipher results. There is no replicated scaling analysis.
- **Consequence:** Launch overhead, saturation, tail behavior, channel handling, content effects, and generalization to social-media workloads cannot be assessed.
- **Minimum remedy:** Define a benchmark corpus with dimensions, channels, bit depth, decoded bytes, source/licence, and hashes; run a controlled payload/resolution sweep from small images through GPU saturation; use identical buffers across CPU/GPU and ciphers; report latency/throughput distributions and correctness hashes; evaluate launch-selection sensitivity.
- **Verification criterion:** Archived inputs and raw trials reproduce uncertainty-bearing scaling plots/tables across grayscale, RGB, and RGBA sizes, including non-multiple-of-64 tails, on both tested GPUs.

## 12. Specify and enforce the nonce and key lifecycle

- **Source reviewers:** Domain Reviewer (Critical 3); Perspective Reviewer (C3); Journal-Fit Reviewer (Major 4/6); Devil’s Advocate (M7).
- **Precise manuscript anchors:** nonce discussion lines 269–295; serial/GPU initialization lines 410–460 and 542–547; Algorithms 6–7 lines 639–700; threat model lines 1115–1128.
- **Problem:** The manuscript says nonces must be unique but gives no generation/allocation mechanism, per-key uniqueness enforcement, collision/restart/multi-sender policy, ciphertext binding, key scope/storage/rotation, or counter-exhaustion rule.
- **Consequence:** Key/nonce reuse repeats the Salsa20 keystream and can expose relationships between, or content from, structured images; a kernel alone is not a secure message protocol.
- **Minimum remedy:** Implement a complete message/key/nonce lifecycle with unique 64-bit nonce allocation or a vetted extended-/misuse-resistant construction, persistent crash-safe state, multi-sender collision prevention, authenticated binding and transmission, key scope/rotation/revocation, and counter-wrap prohibition; otherwise narrow the work to a primitive kernel microbenchmark and remove system-security claims.
- **Verification criterion:** Automated multi-message, concurrent-sender, restart, collision, and counter-boundary tests demonstrate that no key/nonce pair is reused and that malformed/reused state fails safely; the message format and lifecycle are documented end to end.

## 13. Align authentication and replay protection with the claimed threat model

- **Source reviewers:** Domain Reviewer (Critical 4); Perspective Reviewer (C4); Journal-Fit Reviewer (Major 4/6); Devil’s Advocate (M6–M7).
- **Precise manuscript anchors:** encryption/decryption workflow lines 348–355, 409–438, and 601–625; threat model lines 1117–1128; admitted limitation lines 1163–1178; deployment/conclusion lines 1178–1182 and 1212–1220.
- **Problem:** Raw Salsa20 provides confidentiality only, while the manuscript calls the system secure under untrusted intermediaries. It implements no tag, associated data, tag-failure handling, replay protection, message ordering, substitution/truncation defense, or downgrade/version binding.
- **Consequence:** Active attackers can alter, replace, truncate, reorder, or replay image ciphertext without detection; this is incompatible with secure social-media deployment claims.
- **Minimum remedy:** Either implement and benchmark a standardized authenticated construction, authenticating the ciphertext, nonce, dimensions/format, sender/context, version, and sequence metadata with fail-closed processing and replay handling, or restrict all claims to a passive-adversary confidentiality-only kernel prototype.
- **Verification criterion:** If deployment claims remain, tests demonstrate rejection of bit flips, tag changes, substitution, truncation, reordering, replay, and downgrade before plaintext release, and all timing includes tag generation/verification; otherwise, title, abstract, threat model, Discussion, and Conclusion contain no authenticated-security or deployment claim.

## 14. Test platform transformations or remove ordinary social-media-path claims

- **Source reviewers:** Perspective Reviewer (M1); Journal-Fit Reviewer (minor abstract qualification and deployment assessment); Domain Reviewer (deployment limitation); Devil’s Advocate (M6 and minor m3).
- **Precise manuscript anchors:** image metrics lines 951–988 and 1004–1081; recompression discussion lines 1129–1145; deployment lines 1178–1182; conclusion lines 1212–1220.
- **Problem:** JPEG quality-75 corruption is described as empirically tested without a reported method or result. Typical recompression/resizing destroys ciphertext, and a lossless document attachment is a different use case from ordinary photo sharing.
- **Consequence:** The named social-media use case may be incompatible with standard media pipelines, and the claimed empirical support is not auditable.
- **Minimum remedy:** Report reproducible JPEG/WebP quality sweeps, resizing, thumbnailing, orientation normalization, metadata stripping, container transcoding, and representative real-platform upload/download tests with quantitative byte-preservation and authenticated-decryption outcomes; otherwise remove direct social-media deployment claims and describe only lossless transport conditions.
- **Verification criterion:** A transformation matrix and raw artifacts reproduce every claimed platform result; the title, abstract, and conclusion distinguish ordinary photo posting from lossless file transport and make no unsupported deployment claim.

## 15. Define system boundaries, trust assumptions, and stakeholder effects

- **Source reviewers:** Perspective Reviewer (M2); Domain Reviewer (Critical 3–4); Devil’s Advocate (stakeholder blind spots and M6–M7).
- **Precise manuscript anchors:** threat model and metadata/deployment discussion lines 1115–1182.
- **Problem:** “Trusted” and “honest-but-curious” platform assumptions are conflated; endpoints, malicious recipients, account compromise, transport authentication, downgrade resistance, backups/caches, moderation, accessibility, abuse response, key recovery, and residual metadata are not integrated into a coherent model.
- **Consequence:** It is unclear who is protected from whom, while pixel encryption may shift risk to endpoints, preserve metadata leakage, or create operational and stakeholder harms.
- **Minimum remedy:** Provide a deployment/data-flow diagram with explicit trust boundaries; select one platform-adversary model; define authenticated transport, endpoint/server authentication, account/downgrade assumptions, storage and recovery boundaries; discuss user, recipient, operator, moderation, accessibility, and abuse-investigation trade-offs; measure residual metadata after any proposed mitigation.
- **Verification criterion:** Every claimed threat is mapped to a control, assumption, residual risk, or explicit exclusion; the architecture contains no contradictory trust labels, and measured metadata leakage is reported for the proposed workflow.

## 16. Constrain mobile, handheld, lightweight, and real-time claims to tested systems

- **Source reviewers:** Perspective Reviewer (M3–M4); Journal-Fit Reviewer (minor abstract qualification); Methodology Reviewer (timing/scaling findings); Devil’s Advocate (M6).
- **Precise manuscript anchors:** abstract lines 20–32; CUDA hardware/results lines 786–873; deployment lines 1178–1182; conclusion lines 1212–1222.
- **Problem:** CUDA kernels are tested on Tesla T4 and RTX A4000 hardware, but suitability is claimed for mobile GPUs/NPUs and resource-limited handheld devices without a mobile implementation, supported API path, end-to-end latency, battery/thermal data, codec/memory movement, or authentication overhead.
- **Consequence:** Desktop/data-centre kernel timing cannot establish user-perceived real-time performance, lightweight operation, or deployability on mainstream phones.
- **Minimum remedy:** Either implement and benchmark a complete client on representative mobile hardware using an available API—including decode, preprocessing, metadata handling, key/nonce management, authenticated encryption, containerization, transfer preparation, energy, memory, and thermal behavior—or remove mobile/NPU/handheld and end-to-end real-time claims and limit conclusions to the tested NVIDIA CUDA platforms.
- **Verification criterion:** Each retained platform claim is supported by measurements on that platform with complete operation boundaries and uncertainty; otherwise all prominent claims consistently identify the work as a CUDA kernel benchmark on Tesla T4 and RTX A4000.

## Roadmap completion test

The roadmap is complete only when each item’s verification criterion is supported by manuscript text and an immutable evidence artifact, or when the corresponding unsupported claim has been removed everywhere it appears. Completion of textual edits alone is insufficient for items that require corrected implementation, conformance testing, or regenerated experiments.