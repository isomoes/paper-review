# Round-2 Devil’s Advocate Re-Review

**Role:** Fixed Devil’s Advocate, role-separated report  
**Target venue:** *Scientific Reports*  
**Calibration status:** `NOT_CALIBRATED`

## 1. Strongest Counter-Argument

The paper does not establish that it contributes a new, secure, quantum-resistant image-encryption system for social media; at most, it reports kernel timings for an internally inconsistent CUDA implementation of a well-known stream cipher. The manuscript alternates between Salsa20-128 in the CPU/GPU methods and pseudocode (lines 359–515, 527–545, 639–700) and Salsa20-256 in its title, abstract, principal tables, and conclusions (lines 1–32, 802–815, 1184–1222). Consequently, the reader cannot determine which primitive produced the headline results or whether its state/key schedule matches the claimed cipher.

Even taking the tables at face value, they refute the central performance narrative. ASCON-128a has higher encryption and decryption throughput and lower energy per encryption than Salsa20 (lines 1086–1094), and its best tabulated kernel times are lower (lines 934–946 versus 861–873). Yet the paper claims Salsa20 has “minimal encryption latency” and that both alternatives cost more (lines 1052–1100). The 1381× headline further compares a GPU kernel-only time, explicitly excluding PCIe transfer, against a serial CPU result, without repeated trials, uncertainty, end-to-end latency, or controlled implementation parity (lines 762–794, 1184–1192).

Security is inherited rhetorically from Salsa20 rather than demonstrated for this implementation. Round-trip decryption and image histograms cannot establish implementation correctness or resistance to attack; NPCR/UACI reporting is internally malformed and conceptually mismatched to an ordinary stream cipher (lines 769–785, 952–990, 1004–1018). The scheme is unauthenticated, incompatible with normal social-media recompression, omits key management, and was tested on desktop/datacenter GPUs rather than handheld devices (lines 1115–1182). Thus the evidence supports neither the claimed comparative superiority nor the proposed deployment thesis.

## 2. Issue List

### CRITICAL

**All CRITICAL issues are explicit below: C1 and C2. Each independently blocks acceptance until resolved.**

| ID | Exact manuscript line anchor(s) | Logical problem | Why it matters | Minimum remedy | Confidence |
|---|---|---|---|---|---|
| **C1** | Lines **1–32**, **359–515**, **527–545**, **639–700**, **802–835**, **1184–1222** | The claimed experimental object is not identifiable: the headline contribution is Salsa20-256, while both serial and CUDA methods/pseudocode repeatedly specify Salsa20-128, including a four-word key and repeated-key state construction. The manuscript then reports 256-bit results without a corresponding reproducible 256-bit method. | If the tested implementation cannot be tied unambiguously to the claimed primitive, correctness, security level, and every comparative result are unverifiable. This is a foundation-level identity failure, not a wording issue. | Provide separate, specification-faithful 128- and 256-bit implementations or restrict the paper to one variant; give exact state layouts, key loading, test-vector results against a trusted implementation, code/version identifiers, and map every table to the exact executable and parameters used. | **5/5 — cryptographic implementation traceability** |
| **C2** | Lines **934–946**, **1052–1100**, especially Table 11 at **1086–1094** | The paper’s own data contradict the central superiority claim: ASCON-128a reports faster best kernel times, higher throughput, and lower energy per encryption than Salsa20, while the prose says Salsa20 has minimal latency and both baselines have higher cost. | The advertised novelty and “better performance” conclusion do not follow from the reported evidence. A core conclusion contradicted by the results cannot be accepted through clarification alone. | Recompute and independently check every performance/energy result; define the comparison objective and security level; correct or withdraw “minimal latency,” “uniquely combines,” and “both are computed at higher cost”; present a trade-off analysis rather than a winner claim unless the data support one. | **5/5 — direct table-to-claim comparison** |

### MAJOR

| ID | Exact manuscript line anchor(s) | Logical problem | Why it matters | Minimum remedy | Confidence |
|---|---|---|---|---|---|
| **M1** | Lines **762–794**, **802–873**, **917–946**, **1184–1192** | Headline speedups compare GPU kernel-only timings (PCIe excluded) with CPU timings, with no repeated runs, dispersion, warm-up protocol, compiler flags, synchronization details, or matched end-to-end path. CPU/GPU hardware also changes between the two speedups. | The 265×/1381× figures can primarily reflect benchmark boundary and implementation asymmetry rather than usable acceleration. | Report matched CPU and GPU implementations under a preregistered timing boundary; include transfer/allocation and end-to-end results separately; provide repetitions, central tendency, uncertainty, warm-up, synchronization, build flags, and raw timing data. | **5/5 — benchmarking logic** |
| **M2** | Lines **769–785**, **952–990**, Tables 8–10 at **1004–1018**, **1028–1047**, **1062–1081** | Histogram, entropy, adjacent-pixel correlation, and ciphertext-image robustness are treated as security evidence for a standard stream cipher. NPCR/UACI rows are malformed: “0%/0” appears under NPCR/UACI while 99.61%/≈33.5% appears under key sensitivity, without a coherent protocol. | These metrics neither validate the Salsa20 implementation nor justify “secure”; ambiguous results cannot support differential-attack claims. | Validate with official/independent known-answer vectors and byte-for-byte reference outputs; state exactly which input/key/nonce change defines each metric; correct table structure; separate generic image statistics from cryptographic security and avoid claiming attack resistance from them. | **5/5 — security-evidence logic** |
| **M3** | Lines **194–201**, **993–1000**, **1102–1109** | Novelty is asserted against prior GPU Salsa20 work without a controlled comparison. The cited Khalid et al. result is 43.44 GB/s, whereas this paper reports 7.98 GB/s, yet the manuscript calls the present method “more efficient.” No evidence establishes that the comparative framework itself is novel. | A hardware-specific grid sweep is not automatically a scientific contribution, and the stated advantage over prior work is unsupported. | Compare against reproducible recent CUDA/OpenCL/OpenMP/ChaCha implementations under normalized conditions, or narrow the contribution to a transparent replication/characterization study; define and substantiate “more efficient.” | **5/5 — novelty claim/evidence match** |
| **M4** | Lines **217–245**, **989–990**, **1052–1100** | Grover’s optimality for unstructured search is used as if it proves a hard lower bound on all quantum attacks against Salsa20. The text also says ASCON-128a meets a 128-bit post-quantum margin despite its reported 128-bit key space, which under the manuscript’s own Grover reasoning yields about 64 bits. | The “quantum-resistant” framing and security-level comparison are materially overstated and internally inconsistent. | State a bounded claim: no better quantum attack is considered under the specified key-search threat model; distinguish primitive key sizes and post-quantum estimates; correct the ASCON comparison and cite the exact NIST security-level statement being applied. | **4/5 — symmetric post-quantum reasoning** |
| **M5** | Lines **790–794**, **993–1000**, **1197–1204** | The 8192×8 setting is called occupancy-maximizing and spill-free, but no occupancy, register, achieved-warp, cache, bandwidth, or profiler measurements are reported. The tested configuration set only establishes the fastest observed point for one workload/hardware setup. | The architectural explanation and “optimal” language are assertions; they cannot support general optimization claims. | Report Nsight metrics and launch-resource data for all configurations, repeat across image sizes and both GPUs, and replace “optimal/maximizes” with “fastest among tested settings” unless a broader optimization study supports it. | **5/5 — GPU performance interpretation** |
| **M6** | Lines **1115–1182**, **1212–1222** | The social-media use case requires a lossless bypass, separate key management, metadata handling, and authentication, while typical recompression/resizing destroys the ciphertext. Mobile suitability is claimed without tests on mobile GPUs/NPUs, thermal constraints, battery cost, or full application latency. | The deployment thesis is largely negated by admitted constraints and is unsupported for the named stakeholder environment. | Reframe as a GPU kernel study, or implement and evaluate an end-to-end authenticated client workflow on representative mobile/social-media paths, including key handling, recompression behavior, energy, and latency. | **5/5 — claim-to-deployment mismatch** |
| **M7** | Lines **64–71**, **269–302**, **585–700** | The introduction explains public-key encryption even though Salsa20 is symmetric, and the pseudocode does not establish nonce uniqueness across messages or a production key/nonce lifecycle. | This confuses the system model and omits the principal catastrophic misuse condition for a stream cipher: keystream reuse. | Replace the public-key diagram/explanation with an accurate symmetric authenticated-encryption dataflow and specify enforceable key/nonce generation, storage, uniqueness, counter limits, and failure handling. | **5/5 — cryptographic system model** |
| **M8** | Lines **883–905**, **1086–1094**, **1227–1229** | Energy, memory, and throughput values are presented without a measurement method, sampling window, instrumentation, baseline power treatment, profiler export, or uncertainty; the repository URL alone does not bind the reported results to a commit/environment. | The expanded comparison is not reproducible, a key requirement for a broad empirical claim. | Add a complete experimental protocol, hardware/software versions, code commit and scripts, raw profiler/timing data, derivations for every Table 11 value, and uncertainty from repeated runs. | **5/5 — reproducibility assessment** |

### MINOR

| ID | Exact manuscript line anchor(s) | Logical problem | Why it matters | Minimum remedy | Confidence |
|---|---|---|---|---|---|
| **m1** | Lines **41–57**, **120–125**, **250–256** | The introduction contains sentence fragments, malformed list numbering, and an unfocused survey of unrelated CUDA applications. | It obscures the research gap and falls below publication-ready exposition. | Professional language edit and restructure the introduction around directly relevant cryptography/GPU evidence. | **5/5 — textual inspection** |
| **m2** | Lines **544–545**, compared with **412–415** | GPU data length is defined as width×height, while the CPU path uses width×height×channels. | This creates ambiguity over whether RGB channels are fully processed and whether compared workloads are equal. | Define buffer length consistently in bytes and document channel/layout handling in code and pseudocode. | **5/5 — algorithm consistency** |
| **m3** | Lines **1129–1145** | JPEG-quality-75 corruption is described as empirically established, but no anchored result, metric, table, or figure is supplied. | A concrete empirical claim is not auditable. | Add the test protocol and quantitative result, or label it as an expected consequence rather than a reported experiment. | **5/5 — missing reported evidence** |
| **m4** | Lines **1189–1191** | “PCIe data transfer overload” is technically incorrect wording; the intended concept is transfer overhead. | It can mislead readers about the benchmark boundary. | Replace with “excluding host–device transfer overhead” and define precisely what the timer includes. | **5/5 — terminology** |

## 3. Ignored Alternative Explanations for Speed, Security, and Novelty

### Speed

1. **Benchmark-boundary effect:** The spectacular speedup may arise because only the GPU kernel is timed while data movement and integration costs are omitted.
2. **Implementation-quality effect:** An unoptimized scalar CPU baseline, compiler settings, or absent SIMD/multithreading may explain much of the ratio.
3. **Workload-size effect:** One principal 1.34 MB image and one weakly documented Lenna demonstration may favor launch geometry that does not generalize.
4. **Hardware-specific scheduling:** The 8192×8 result may be a device/workload artifact rather than an architectural optimum.
5. **Measurement noise:** Single values without repetitions or error bars could reflect warm-up, clock boosting, contention, or synchronization artifacts.

### Security

1. **Primitive security, not implementation security:** Acceptable ciphertext histograms may merely reflect Salsa20’s known keystream behavior while hiding implementation bugs, nonce reuse, or state-layout errors.
2. **Metric-category error:** NPCR/UACI and pixel correlation may measure visual diffusion conventions rather than the confidentiality guarantees of a conventional stream cipher.
3. **Confidentiality-only failure:** Apparent robustness after noise/cropping can mask malleability; an attacker can alter ciphertext without detection because there is no authentication.
4. **Operational compromise:** Metadata, traffic patterns, key distribution, endpoint compromise, and nonce management may dominate real social-media security.
5. **Qualified post-quantum status:** A large symmetric key protects against generic quantum key search under assumptions; it does not make this implementation a validated post-quantum system.

### Novelty

1. **Replication rather than invention:** The work may be a hardware-specific reimplementation and launch-parameter sweep of a cipher already accelerated on GPUs.
2. **Baseline-selection effect:** Omitting controlled ChaCha20, optimized prior Salsa20, OpenCL, OpenMP/SIMD, and authenticated-encryption baselines can manufacture apparent distinctiveness.
3. **Reporting-bundle novelty:** Jointly listing latency, power, and memory is a presentation contribution unless the measurement design or resulting scientific insight is itself new and validated.
4. **Security-label novelty:** Rebranding a 256-bit symmetric cipher as “quantum-resistant” does not create a new cryptographic construction.

## 4. Stakeholder Blind Spots

- Mobile users on integrated GPUs/NPUs, especially under battery, thermal, and memory constraints.
- Recipients and group participants who must obtain, rotate, revoke, and recover keys.
- Social-media platform operators whose pipelines resize, recompress, moderate, deduplicate, and scan uploads.
- Security engineers responsible for nonce allocation, authentication, key storage, update mechanisms, and incident response.
- Users whose safety depends on metadata confidentiality, traffic-analysis resistance, or account unlinkability.
- Moderation, abuse-prevention, legal-compliance, and accessibility stakeholders affected by opaque encrypted imagery.
- Users on CPU-only or low-end devices, for whom a discrete-GPU design may increase inequity or be unusable.
- Reproducibility stakeholders who need immutable code versions, raw measurements, and executable benchmarks.

## 5. “So What?” Test

Even if every timing number is correct, the demonstrated result is that an embarrassingly parallel, established stream cipher can achieve sub-millisecond kernel execution on two NVIDIA GPUs after a small launch-configuration sweep. The paper does not show an end-to-end social-media system, and its own comparison makes ASCON-128a faster and more energy-efficient on the tested GPU. The claimed quantum property is inherited from key length under a generic-search model, not created by the implementation. Therefore, what changes for science or practice is unclear: developers already know stream ciphers parallelize; prior Salsa20 GPU work reports higher throughput; and production deployment still requires authentication, nonce/key management, metadata protection, and a lossless transport path. The surviving contribution could be a reproducible comparative benchmark, but only if the cipher identity, benchmark fairness, raw data, and trade-off conclusions are corrected and independently checkable.

## 6. Prior-Response Commitments That Remain Assertions Rather Than Verified Fixes

| Prior-response commitment | Response anchor | Verification against revised manuscript |
|---|---|---|
| Identical datasets/conditions and comprehensive state-of-the-art comparison were added. | Review lines **3–16** | **Assertion/unverified.** Tables 6–11 provide selected in-paper baselines, but no controlled comparison to recent image-encryption or prior optimized Salsa20 implementations, no repeated protocol, and no raw evidence of identical implementations/conditions (manuscript lines **917–946**, **1086–1109**). |
| Standard security metrics significantly expand the security validation. | Review lines **17–35**, **110–120** | **Nominally present but not verified as a fix.** Tables 8–10 are structurally ambiguous, NPCR/UACI conflict with the response note, no NIST test is run, and image statistics do not validate implementation correctness (manuscript lines **952–990**, **1004–1081**). |
| Performance evaluation now includes throughput, memory, power, and scalability. | Review lines **36–47**, **121–129** | **Values are asserted, methods absent.** Table 11 lists numbers without derivation, instrumentation, repeats, or uncertainty; speedup remains kernel-only and transfer-excluding (manuscript lines **1086–1094**, **1184–1192**). |
| Multiple benchmark images and robust/reliable independent experiments were provided. | Review lines **59–67**, **367–385** | **Not fulfilled.** Only one additional Lenna demonstration is described; no multiple independent trials, averages, variances, or clearly image-specific timing table appears (manuscript lines **762–794**, **911–915**). |
| The 8192×8 configuration maximizes SM occupancy without register spilling. | Review lines **94–109**, **327–338** | **Assertion only.** The manuscript repeats the mechanism but reports no occupancy, register-spill, resident-block, cache, or memory-latency measurements (manuscript lines **993–1000**, **1197–1204**). |
| The new comparison shows Salsa20 uniquely provides minimal latency with the required security margin. | Review lines **94–109**, **215–248** | **Contradicted by the manuscript.** ASCON-128a is faster and more energy-efficient in Tables 7 and 11; the manuscript also inconsistently says ASCON meets the same post-quantum requirement (manuscript lines **934–946**, **1052–1100**). |
| JPEG quality-75 recompression corruption was empirically demonstrated. | Review lines **130–174** | **Assertion without displayed evidence.** The Discussion states the result but provides no experimental method, metric, table, or figure (manuscript lines **1129–1145**). |
| The method is new and better than Khalid et al.’s prior CUDA Salsa20 implementation. | Review lines **215–248** | **Unverified and facially doubtful.** The manuscript cites 43.44 GB/s for Khalid et al. but reports 7.98 GB/s here, without hardware-normalized reimplementation or efficiency metric (manuscript lines **194–201**, **1086–1109**). |
| Grammar and variable consistency were checked and corrected. | Review lines **386–394** | **Not verified as fixed.** Numerous fragments, malformed numbering, inconsistent Salsa20 variants, and inconsistent byte/channel length definitions remain (manuscript lines **41–57**, **120–125**, **359–545**). |

## 7. Recommendation

# **Reject**

The recommendation follows from two explicit CRITICAL defects: the manuscript does not establish which cipher variant generated its evidence, and its own comparative tables contradict the central performance/novelty conclusion. These are compounded by non-reproducible benchmarking, non-probative security validation, and a deployment claim that the admitted system constraints largely defeat. A publishable study would require a ground-up, specification-verified implementation and a newly executed experimental evaluation rather than a bounded textual revision.