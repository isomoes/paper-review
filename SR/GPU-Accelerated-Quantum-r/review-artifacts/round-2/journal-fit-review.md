# Round-2 Journal-Fit Re-Review — Scientific Reports

## Recommendation: **Major Revision**

The manuscript is **within the venue’s engineering scope**, but scope fit is not the same as validity. *Scientific Reports* publishes original engineering research, while its publication test is scientific validity and technical soundness rather than perceived impact ([Aims & scope](https://www.nature.com/srep/about/aims); [Guide to referees](https://www.nature.com/srep/guide-to-referees)). The revisions add useful comparisons, a threat model, limitations, and a code link, but central implementation, benchmark, and security claims remain insufficiently supported. These are potentially remediable; rejection for venue mismatch is not warranted.

## Overall assessment

- **Scope fit:** Good. GPU computing, cryptographic implementation, and image processing fall within engineering/applied science.
- **Originality:** Not yet demonstrated convincingly. The manuscript reframes the contribution as a three-cipher GPU comparison and kernel tuning, but does not establish that the comparison protocol or optimization is new relative to recent GPU cryptography/image-encryption work.
- **Scientific validity:** Not yet adequate. The described 128-/256-bit implementations conflict, the GPU buffer length appears inconsistent with RGB processing, and several conclusions contradict the reported tables.
- **Reproducibility:** Inadequate despite the repository link. Experimental conditions, repetitions, raw measurements, energy-measurement procedure, software/toolchain versions, and an immutable code/data release are missing.
- **Claim–evidence alignment:** Weak for “quantum-resistant,” optimal occupancy, comparative superiority, security robustness, and real-time social-media suitability.

## Strengths

1. The revision adds direct AES-256-CTR and ASCON-128a measurements (lines 917–946, 1028–1094), extending the original evaluation.
2. The new threat-model and deployment discussion candidly identifies unauthenticated ciphertext, key-management exclusions, metadata leakage, and incompatibility with platform recompression (lines 1115–1182).
3. The manuscript now provides algorithm pseudocode, hardware identification, a Data Availability section, and a public code URL (lines 407–495, 637–723, 1184–1229).
4. The authors appropriately disclose that the reported speedups exclude PCIe transfer (lines 1189–1192), although the abstract still needs this qualification.

## Major issues

### 1. Central implementation identity is internally inconsistent

- **Location:** title/abstract, lines 1–3 and 24–32; serial and GPU method headings and pseudocode, lines 359–360, 409–495, 514–515, and 639–723; results, lines 762–789 and 802–873.
- **Problem:** The headline contribution is Salsa20-256, but the detailed serial and GPU methods implement and name Salsa20-128. Algorithm 7 even states that the 128-bit key is “repeated” (line 692). Separate 256-bit state initialization and code-path details are not given, although 256-bit results are reported.
- **Why it matters:** Readers cannot determine which implementation generated the central 256-bit results or reproduce the claimed post-quantum security level. This directly affects validity, not merely presentation.
- **Minimum remedy:** Provide separate, exact Salsa20-128 and Salsa20-256 state layouts and code paths; identify which version produced every table/figure; validate both against published known-answer test vectors; report those tests and reconcile all title, abstract, Methods, Results, and repository labels.

### 2. The GPU data-length specification appears incompatible with RGB encryption

- **Location:** CPU length definition, lines 412–415; GPU description and pseudocode, lines 530–546 and 643–660; RGB/Lenna claim, lines 911–915.
- **Problem:** The CPU method defines length as `W × H × C`, whereas the GPU method defines `data_len = width × height`, omitting channels. For an RGB image this would process only part of the decoded pixel buffer unless an undocumented representation is used.
- **Why it matters:** This threatens correctness of the advertised color-image validation and makes CPU/GPU comparisons potentially non-equivalent.
- **Minimum remedy:** Correct and fully specify byte-length computation for every image mode; report channel count, decoded byte count, bytes processed, and file encoding for each benchmark; add byte-for-byte round-trip tests covering grayscale, RGB, and non-multiple-of-64 lengths.

### 3. Several central comparative conclusions contradict the reported data

- **Location:** advantage claim, lines 1052–1100; performance table, lines 1086–1094; comparison claim, lines 1102–1109.
- **Problem:** The text says Salsa20 uniquely achieves minimal latency and the required post-quantum margin (lines 1057–1059), then says AES-256-CTR and ASCON-128a also meet that requirement (lines 1099–1100). Table 7 reports ASCON encryption time as low as 0.144 ms (lines 941–946), below Salsa20’s 0.168 ms (line 845), and Table 11 reports higher ASCON encryption/decryption throughput (lines 1089–1090). Moreover, applying the manuscript’s own Grover halving argument to the stated ASCON key space of 2^128 (line 1076) does not yield a 128-bit generic post-quantum key-search margin.
- **Why it matters:** The claimed comparative advantage and novelty are not supported by the manuscript’s own evidence.
- **Minimum remedy:** Define the comparison criterion in advance; recalculate all security margins and performance rankings; distinguish latency, throughput, confidentiality, and authenticated-encryption functionality; revise the abstract, Discussion, and Conclusion so every superiority statement follows the corrected tables.

### 4. “Quantum-resistant” remains overbroad and technically underqualified

- **Location:** lines 24, 53–56, 217–228, 233–245, 989–990, 1052–1059, and 1212–1220.
- **Problem:** The revision equates a 256-bit symmetric key and Grover’s generic search bound with proof that the complete implementation is “quantum-resistant,” and states that Grover is the only applicable quantum attack (lines 221–228). The argument does not establish security of the full construction/implementation against all quantum adversaries, nonce misuse, side channels, or active attacks; the implementation also provides no authentication (lines 1163–1177).
- **Why it matters:** “Quantum-resistant” is the title-level contribution and may mislead readers into treating a conditional generic key-search estimate as a comprehensive security result.
- **Minimum remedy:** Recast the claim precisely as an assumed approximately 128-bit generic key-search security target for Salsa20-256 under Grover-style search, subject to the stated threat model; avoid “only applicable attack” and unqualified “quantum-resistant” wording; separate primitive-level assumptions from implementation and system security, including nonce management and authentication.

### 5. Benchmark design does not substantiate speedup, optimality, or architectural explanations

- **Location:** timing description, lines 762–794; tables, lines 802–946; occupancy/optimality claims, lines 993–1000 and 1197–1204; speedups, lines 1184–1192.
- **Problem:** Only point timings are reported, with no repetition count, variance, warm-up policy, clock/power controls, compiler flags, CPU threading/vectorization conditions, or uncertainty. Kernel-only GPU timing is compared with CPU timing, while transfer overhead is excluded. The assertion that 8192×8 “maximizes SM occupancy without spilling registers” has no occupancy, register, cache, or profiler measurements in the presented results. Testing a finite configuration grid establishes only the fastest tested setting for the tested workload, not an architectural optimum.
- **Why it matters:** The 265×/1381× speedups and tuning explanation are central results but cannot be assessed for reliability, fairness, or generality.
- **Minimum remedy:** Report a reproducible benchmark protocol and repeated-run distributions; compare like-for-like kernel/compute time and end-to-end time; give compiler/toolchain settings and CPU optimization status; provide Nsight occupancy, registers/thread, resident blocks/SM, achieved bandwidth, and relevant cache/memory metrics for each configuration; limit “optimal” to the tested hardware/workload unless broader evidence is supplied.

### 6. Security/image metrics are misinterpreted and do not validate cryptographic security

- **Location:** histogram inference, lines 769–785; metric definitions, lines 952–990; Tables 8–10, lines 1004–1047 and 1062–1081; conclusion, lines 1193–1196; author-response note, Review.txt lines 397–400.
- **Problem:** Ciphertext histogram uniformity and entropy do not by themselves establish resistance to statistical attacks. Tables 8–10 ambiguously place zero NPCR/UACI beside separate key-sensitivity values, while the response concedes that plaintext-pixel-change NPCR/UACI are zero. Robustness PSNR values are reported without a complete perturbation/decryption protocol. No known-answer, nonce-uniqueness, chosen/known-plaintext, or raw-keystream randomness evaluation is provided.
- **Why it matters:** The manuscript presents these metrics as security validation, but some are expected visual statistics, some reveal the absence of image-level diffusion, and none substitutes for cryptographic security analysis.
- **Minimum remedy:** Separate (a) primitive assurance based on established Salsa20 cryptanalysis and known-answer tests, (b) implementation correctness, and (c) descriptive image statistics. Clearly label NPCR/UACI protocols and results, remove unsupported attack-resistance inferences, define all robustness experiments, and qualify security conclusions to confidentiality under unique nonces and the stated threat model.

### 7. Reproducibility and data availability do not meet the venue’s expected standard

- **Location:** experimental reporting, lines 762–946 and 1004–1094; Data Availability, lines 1227–1229.
- **Problem:** “The data ... is included in the paper” does not provide the raw timing runs, profiler exports, power samples, metric-generating scripts, exact benchmark images/provenance, or configuration metadata needed to recreate the tables. The GitHub URL has no cited release, commit, DOI, licence, or mapping from scripts to results.
- **Why it matters:** Scientific Reports requires enough methodological detail for reproduction and a Data Availability Statement identifying the minimal dataset needed to interpret and replicate the findings; custom code central to conclusions must be available for evaluation ([Submission guidelines](https://www.nature.com/srep/author-instructions/submission-guidelines); [Editorial policies](https://www.nature.com/srep/journal-policies/editorial-policies)).
- **Minimum remedy:** Archive an immutable, licensed release containing exact source, build/run scripts, dependency and compiler/CUDA versions, raw measurements and profiler outputs, metric scripts, test vectors, and benchmark-image identifiers/files where licensing allows; cite its DOI/commit and revise the Data Availability Statement accordingly.

### 8. Originality against prior GPU work remains asserted rather than demonstrated

- **Location:** prior GPU Salsa20 discussion, lines 194–201; novelty/comparison, lines 993–1000 and 1102–1109; response claims, Review.txt lines 94–109 and 215–248.
- **Problem:** The revised paper states that it is more efficient than Khalid et al. (2013) without a normalized comparison and does not provide a systematic comparison against recent close GPU stream-cipher/image-encryption implementations. AES and ASCON implementations created for this study are useful baselines but do not alone establish novelty over the state of the art.
- **Why it matters:** Original research is required for the venue; the current evidence supports an implementation benchmark, but not the broader novelty claims.
- **Minimum remedy:** Add a focused related-work table comparing algorithm/version, hardware, workload size, timing boundary, throughput, authentication, code availability, and optimization technique; identify the exact new optimization or, if the contribution is primarily a controlled benchmark, narrow the novelty claim and validate that benchmark rigorously.

## Minor issues

1. **Abstract qualification (lines 20–32):** State that speedups are kernel-only, identify the CPU/GPU pairings and test image size, and avoid “real-time social media” because actual platform and end-to-end deployment were not tested.
2. **Public-/private-key error (lines 64–71):** Figure 1’s explanation describes public-key encryption, whereas Salsa20 is symmetric-key cryptography. Replace it with an accurate symmetric encryption/key-sharing diagram.
3. **Round terminology (lines 275–280, 324, 327–335):** Use Salsa20’s standard ten double-rounds (20 rounds) terminology consistently; “10 row rounds and 10 column rounds” and “four column rounds and four row rounds” are confusing/inaccurate descriptions.
4. **Image/file handling (lines 421–427, 607–624):** Explain how arbitrary ciphertext bytes are stored as an image without encoder transformation and how dimensions/channels are preserved; distinguish encoded-file encryption from decoded-pixel encryption.
5. **Presentation:** Extensive grammatical and typographic problems remain (e.g., lines 41–57, 120–125, 898–905, 1197–1222). Professional language editing and systematic correction of figure/table cross-references are still needed.
6. **Required end matter:** Add an explicit Competing Interests statement and Author Contributions section in the final journal format; the submission guidelines list these alongside the mandatory Data Availability Statement.

## Prior-comment resolution

| Prior concern group | Round-2 status | Evidence-based assessment |
|---|---|---|
| Recent state-of-the-art comparison and novelty | **Partly resolved** | AES/ASCON baselines were added, but recent close GPU methods and normalized comparison remain absent; superiority over Khalid et al. is asserted (lines 1102–1109). |
| Standard image-security metrics | **Partly resolved** | Metrics and formulas were added (lines 952–1081), but NPCR/UACI labeling and security interpretation remain defective; NIST/CPA/KPA analyses were deferred. |
| Performance, throughput, memory, energy, speedup | **Partly resolved** | Tables now report these outputs (lines 1086–1094), but measurement methods, repeated trials, uncertainty, and fair timing boundaries are missing. |
| Multiple datasets/resolutions and independent repetitions | **Not resolved** | Only airport and Lenna examples are described, and no repeated-run statistics are reported (lines 762–789, 911–915). |
| Figures and readability | **Partly/not verifiable from extracted text** | Additional captions/timelines appear, but captions remain terse and language/cross-reference problems persist. |
| Discussion, threat model, compression, metadata, deployment limitations | **Largely resolved** | Sections 6.3–6.4 directly address these points (lines 1115–1182), though headline deployment claims remain too broad. |
| Post-quantum justification | **Partly resolved** | Grover-based reasoning and references were added (lines 217–245), but the title-level claim remains overgeneralized and internally inconsistent across baselines. |
| CUDA architectural explanation and 8192×8 choice | **Not substantively resolved** | The explanation was added as prose (lines 993–1000), but no occupancy/register/cache evidence supports it. |
| Grayscale/RGB and broader validation | **Partly resolved** | Lenna was added (lines 911–915), but the GPU length omission creates a correctness concern and broader dataset validation is absent. |
| English and variable consistency | **Not resolved** | Material errors and unclear terminology remain throughout.

## Decision rationale

The manuscript is a plausible fit for *Scientific Reports* and contains a potentially publishable engineering benchmark. However, the current version does not yet satisfy the journal’s scientific-validity/technical-soundness criterion: the precise implementation is unclear, RGB correctness is questionable, performance and occupancy claims lack reproducible evidence, and key security/comparative statements contradict the reported data. A **Major Revision** is therefore appropriate. Acceptance should depend on corrected implementation documentation and validation, repeated and fair benchmarking, complete reproducibility materials, and substantial narrowing or evidentiary support of the security and novelty claims.
