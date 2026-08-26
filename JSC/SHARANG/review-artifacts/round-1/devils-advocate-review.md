# Devil’s Advocate Review — SHARANG

**Target venue stated by caller:** *The Journal of Supercomputing*  
**Criteria disclosure:** `criteria_binding_unavailable`. No resolved target-criteria binding manifest was supplied, so I make **no venue-alignment claim**; the recommendation below concerns scientific validity, security substantiation, comparative fairness, and submission readiness.

## Strongest counter-argument (≈250 words)

The strongest counter-argument is that SHARANG demonstrates a functionally correct, platform-specific optimization prototype, but not the security-hardened implementation claimed by the title and conclusions. Its central security novelty—“zero-cost SPA resistance”—replaces independent per-NTT entropy with a deterministic 32-bit function of the very polynomial being processed. That construction has at most 32 bits of seed-state uncertainty, not the claimed “>1000 bits” obtained by multiplying factorial permutation counts, and it can be predictable when coefficients are public, repeated, chosen, or partly recoverable. When coefficients are secret, making the schedule a function of them may itself create exploitable data-dependent leakage. No power/EM traces, leakage statistics, attack-success measurements, seed-collision analysis, or chosen-input analysis establish that this shuffle resists SPA. Indeed, deterministic shuffling may reproduce schedules for repeated inputs and does not automatically defeat a single-trace attacker who can identify operation boundaries.

The broader hardening case is similarly feature-count driven rather than adversarially validated. The asserted NTT checksum rests on the unexplained claim that coefficient sum is invariant, although a standard butterfly `(a+ζb, a−ζb)` changes the pair sum from `a+b` to `2a`; SP 800-90B tests are applied without showing compliant placement, state handling, or failure behavior; and “constant-time” is inferred from implementation idioms rather than measured or formally checked. Meanwhile, the performance case mixes own-device measurements, literature values from different ARM and x86 systems, and GPU results against a sequential CPU rather than an optimized multicore throughput baseline. Thus the evidence supports “correct outputs and promising speed on one Jetson,” not “first,” “highest performance,” “comprehensive security hardening,” or security at zero cost.

## Issue list

### CRITICAL

1. **Dimension: Side-channel security / validity of the core novelty**  
   **Exact manuscript anchor:** Abstract lines 24–30; contribution 4, lines 81–83; §V-A lines 234–241; §VIII-D lines 433–435; §IX-C lines 589–597; conclusion lines 608–615.  
   **Evidence:** The Fisher–Yates schedule is seeded by `xorshift32` from selected polynomial coefficients. The schedule therefore has at most a 32-bit PRNG state and is deterministic conditional on data; summing `log2(ℓ!)` over layers does not create >1000 bits of entropy. The paper does not distinguish public, attacker-chosen, ephemeral, and secret NTT inputs or analyze schedule repetition, seed collisions, modulo bias, chosen-input predictability, or leakage introduced by secret-dependent scheduling. No physical leakage experiment supports “SPA resistance.” Shuffling can impede trace alignment without defeating within-trace SPA.  
   **Minimum remedy:** Withdraw “SPA resistance,” “unpredictability,” and “zero-cost” until substantiated. Specify every shuffled NTT call and the secrecy/control of its inputs; quantify actual schedule entropy and collisions; use an independent cryptographic seed/PRF construction; and perform reproducible power/EM evaluation against stated single- and multi-trace attackers, reporting attack success and accepted leakage tests against unprotected and properly randomized baselines.

2. **Dimension: Fault security / correctness of the claimed invariant**  
   **Exact manuscript anchor:** §V-B lines 245–251; §VIII-D lines 433–451; Table XVIII lines 505–518.  
   **Evidence:** The paper says `Σc_i mod q` is invariant under the NTT, but for the documented butterfly the pair sum generally changes: `(a+ζb)+(a−ζb)=2a`, not `a+b`. No transform-specific derivation, expected weighted checksum, injection location model, or end-to-end detection experiment is provided. The claimed `1−1/q` detection probability consequently lacks a demonstrated event space, while coordinated and control-flow faults are largely outside the model.  
   **Minimum remedy:** Supply a correct algebraic derivation tied to the exact forward/inverse NTT implementation and checksum placement, or replace the mechanism. Define fault distributions and injection points, then report software and physical/emulated fault-injection coverage, false negatives, false positives, and failure handling.

3. **Dimension: Security-claim substantiation / threat-model validity**  
   **Exact manuscript anchor:** contribution 5 lines 84–86; §V lines 222–242; §VIII-D/E lines 426–451; §IX-C lines 589–603; conclusion lines 605–615.  
   **Evidence:** “Comprehensive security hardening” is inferred from a checklist and feature count, not security evaluation. There is no timing test, binary/compiler audit, TVLA or attack evaluation, fault campaign, formal information-flow analysis, or examination of shuffle leakage. DPA and EM are explicitly uncovered, GPU timing/cache behavior is admitted, and the fault checksum excludes coordinated faults. A compiler barrier alone does not prove constant-time conditional move, and bit-exact KATs prove functionality rather than side-channel/fault resistance.  
   **Minimum remedy:** Narrow the paper to “candidate countermeasures” or conduct an explicit, reproducible adversarial evaluation. Define assets, capabilities, observables, attack surfaces, compiler/binary assumptions, and pass/fail criteria; separately validate timing, power/EM, fault, zeroization, and failure paths. Stop using feature counts as security evidence.

### MAJOR

1. **Dimension: Internal consistency / “zero measurable cost”**  
   **Exact manuscript anchor:** Abstract lines 24–30; introduction lines 58–60; Table X lines 354–361; §VII-G lines 401–403; Table XIX lines 524–538; conclusion lines 605–610.  
   **Evidence:** The hardened NEON build is 73/72/85 µs versus 69/70/84 µs unprotected; Table XIX reports `<5 µs` total and ~140 ticks for wiping. These measurements contradict unqualified “six features … at zero measurable runtime cost.” Faster than a different reference is not zero marginal hardening cost.  
   **Minimum remedy:** Report paired per-feature and cumulative deltas with uncertainty and equivalence bounds; phrase only the shuffle’s observed marginal timing as below a stated detection limit if supported.

2. **Dimension: Comparative fairness / “highest performance” and “first” claims**  
   **Exact manuscript anchor:** §II-C lines 127–137; Table XIV lines 488–498; §VIII-A lines 466–473; conclusion lines 611–615.  
   **Evidence:** Comparisons mix A78AE measurements, A72 and generic ARM literature numbers, x86 Skylake, differing compilers, clocks, assembly maturity, RNGs, and likely measurement protocols. The literature review is too sparse to establish “first,” while “highest performance among ARM” is not supported by same-platform builds of current alternatives. Security-feature counts further compare unlike configurations and treat checkmarks as equivalent assurance.  
   **Minimum remedy:** Reproduce current pq-crystals, wolfSSL, liboqs, and relevant optimized ARM/GPU implementations on the same board under identical compiler, RNG, clock, and API conditions; normalize scope and security configuration. Replace priority/superlative claims with bounded wording unless supported by a documented systematic search.

3. **Dimension: GPU baseline fairness and end-to-end scope**  
   **Exact manuscript anchor:** §VI-A/B lines 253–320; Algorithm 2 lines 284–306; Table XII lines 421–432; §IX-B lines 553–561.  
   **Evidence:** A many-SM GPU at batch 256 is compared with sequential CPU execution, omitting six-core/NEON parallel throughput, energy, CPU utilization, synchronization, managed-memory page migration, random-coin generation, and allocation/setup boundaries. `cudaMallocManaged` does not by itself prove “zero-copy” or eliminate data movement. Encaps includes some CPU hashing, making scope and resource accounting unclear.  
   **Minimum remedy:** Benchmark against an optimized six-core CPU batch implementation and report wall time, throughput, latency distribution, energy/operation, CPU occupancy, transfers/page faults, initialization, RNG, synchronization, and all host/device work with a clearly defined end-to-end boundary.

4. **Dimension: Reproducibility and statistical reporting**  
   **Exact manuscript anchor:** §VII-A lines 309–320; availability lines 642–644.  
   **Evidence:** One device and medians alone are reported, without dispersion, confidence intervals, repetitions across processes/boots, CPU/GPU power mode, thermal state, frequency locking, core affinity, OS load, raw data, commit hashes, or scripts. Source is only “upon reasonable request,” preventing verification of security-sensitive code and benchmark scope.  
   **Minimum remedy:** Release source, exact revisions, build/run scripts, raw samples, and test vectors; document system/power/thermal controls; provide distributions and confidence intervals across independent runs and, ideally, more than one device.

5. **Dimension: Standards claims / RNG-health and CBD monitoring**  
   **Exact manuscript anchor:** §V-C lines 253–273; Table XVIII lines 512–518.  
   **Evidence:** SP 800-90B health tests concern an entropy-source model and require justified symbol source, placement, state continuity, startup/continuous behavior, cutoffs, and failure response. The manuscript applies ad hoc byte-level RCT/APT calculations to `getrandom()` outputs without establishing those requirements. It likewise treats a global CBD-sum threshold as broad fault/bias detection without power analysis or attack coverage, and does not explain whether monitoring branches leak or what happens on failure.  
   **Minimum remedy:** Either remove the SP 800-90B compliance implication or provide a standards-mapped design, parameter derivation, persistent state and failure semantics. Define and experimentally evaluate detectable RNG/noise faults and monitor leakage.

6. **Dimension: Functional-validation scope and GPU key format**  
   **Exact manuscript anchor:** Table I lines 73–83; Algorithm 2 lines 284–306; §VII-B lines 323–346.  
   **Evidence:** Table I gives an ML-KEM secret key of 2,400 bytes, while “CUDA Batch KeyGen” outputs `sk[N][1152]`, apparently an IND-CPA secret rather than the full KEM secret. Yet the text calls the kernel full KEM and claims all GPU outputs are bit-exact. The statement that deterministic KeyGen/Encaps KATs cover “all three KEM operations and all code paths” is also not demonstrated, especially for optional configurations and GPU paths.  
   **Minimum remedy:** Resolve the key-format/API discrepancy; enumerate exactly which APIs, operations, backends, flags, and negative decapsulation cases each test covers. Distinguish legacy PQC KAT compatibility from FIPS 203/ACVP validation and publish the vectors/harness.

7. **Dimension: Practical significance / “so what?”**  
   **Exact manuscript anchor:** deployment analysis lines 408–416; §IX-B lines 553–561; limitations lines 622–630.  
   **Evidence:** The 3.1× result applies mainly to batches of pre-independent KeyGen operations, while secret-key Decaps—the claimed server bottleneck—remains CPU-only. No real workload establishes that Jetson-class edge systems regularly batch 64–512 KeyGen/Encaps operations, and no end-to-end TLS measurements show application benefit.  
   **Minimum remedy:** Evaluate representative TLS, gateway, certificate-precomputation, or key-rotation workloads with observed batch distributions and queueing latency; report complete handshake/server throughput and identify where the GPU path materially changes a deployment outcome.

### MINOR

1. **Dimension: Claim/count consistency**  
   **Exact manuscript anchor:** Abstract lines 24–27 and §V line 223 say six features; contribution 5 lines 84–86 and conclusion lines 605–613 say nine; Table VI counts nine.  
   **Evidence:** Features, baseline requirements, monitors, and compliance properties are counted inconsistently.  
   **Minimum remedy:** Define one taxonomy and stop counting KAT compliance or generic properties as equivalent countermeasures.

2. **Dimension: Related-work accuracy and coverage**  
   **Exact manuscript anchor:** §II-B/C lines 115–137; references [9], [13] lines 670–679.  
   **Evidence:** The cited Bos et al. paper is not enough to support the masking-cost characterization, and the cited FPGA NewHope work does not substantiate the statement about prior discrete-GPU lattice cryptography.  
   **Minimum remedy:** Correct citation-to-claim mappings and substantially update ARM ML-KEM, GPU PQC, shuffling, masking, and fault-detection literature.

3. **Dimension: Projection validity**  
   **Exact manuscript anchor:** §IX-A lines 478–483; Table XXII lines 578–586; future-work lines 622–637.  
   **Evidence:** ML-KEM-512/1024 timings and ~2× future GPU improvement are extrapolations without implementation, occupancy, memory, or bottleneck validation.  
   **Minimum remedy:** Label them explicitly as nonvalidated estimates with a derivation and uncertainty, or remove quantitative projections.

4. **Dimension: Presentation and traceability**  
   **Exact manuscript anchor:** Table XIV “Sec.” column lines 491–498; Table XVIII checkmarks lines 503–520; scattered “TEMPLATE” headers and malformed table text.  
   **Evidence:** Numerical security counts imply an unjustified ordinal ranking; checkmarks obscure assurance levels; extraction/pagination artifacts and notation errors reduce readability.  
   **Minimum remedy:** Replace counts/checkmarks with scoped claims and evidence levels, and thoroughly proofread/retypeset tables and equations.

## Ignored alternative explanations/paths

- Most CPU improvement may come from replacing inefficient file-based RNG calls and adopting the same unrolled Keccak as pq-crystals, rather than from the claimed NTT/NEON novelty; an ablation by operation and identical system primitives is needed.
- GPU gains may primarily reflect hardware-resource multiplication and batching against one CPU core, not an algorithmically superior heterogeneous design; multicore CPU, CUDA library, and energy-normalized baselines could reverse the conclusion.
- Managed-memory gains may depend on warm residency and prefetch behavior rather than absence of transfers; explicit pinned memory, prefetching, conventional copies, and zero-copy mappings are alternative designs.
- Independent randomness, a cryptographic PRF keyed once per process/session, masking, or hiding may provide better-defined side-channel properties than data-derived xorshift schedules at modest amortized cost.
- Redundant/complementary NTT checks, infective computation, recomputation, or control-flow integrity may outperform a single sum checksum under realistic fault models.
- Real deployments could benefit more from parallel CPU Decaps, protocol-level batching, or accelerator support for Keccak than from batch KeyGen.

## Missing stakeholder perspectives

- **Side-channel and fault evaluators:** need traces, physical setup, attack code, leakage criteria, and realistic probe/fault capabilities.
- **Cryptographic implementers/auditors:** need public source, binary/compiler analysis, API boundaries, error handling, and dependency provenance.
- **Jetson/edge operators:** need power, thermal throttling, memory contention, GPU availability, reliability, and real-time latency data.
- **TLS/server operators:** need queueing effects, batch availability, tail latency, CPU/GPU contention, and complete handshake results, especially Decaps.
- **Standards and validation laboratories:** need precise FIPS 203/ACVP claims and defensible SP 800-90B terminology.
- **Downstream users affected by silent failures:** need monitor-failure policy, availability/DoS analysis, fault recovery, logging, and key-erasure guarantees.
- **Open-source maintainers and reproducibility reviewers:** cannot inspect or maintain code available only by request.

## Observations / non-defects

- Restricting non-constant-time GPU execution to KeyGen and Encaps and retaining Decaps on CPU is a sensible security boundary, and the manuscript openly acknowledges GPU, DPA, EM, and coordinated-fault limitations.
- Bit-exact comparisons, round-trip tests, edge-coefficient tests, and reporting the NEON basemul regression are useful functional-engineering practices, though they do not validate the security claims.
- Separating latency-oriented CPU execution from throughput-oriented GPU batching is architecturally plausible for integrated SoCs.
- The lazy-reduction bounds argument is a useful starting point and the reported coefficient magnitudes fit signed 16-bit storage, but code-level equivalence and complete range analysis still need independent verification.
- The paper usefully reports crossover behavior and identifies CPU-side hashing and low CUDA thread utilization as bottlenecks rather than hiding negative results.

## Recommendation

**Reject in current form, with encouragement to resubmit after fundamental re-evaluation.** The implementation may contain a publishable systems contribution, but the central security claims are presently unsupported and, for the data-derived shuffle entropy and stated NTT checksum invariant, appear technically invalid as written. A resubmission should either narrow itself to a reproducible Jetson performance paper with defensible same-platform comparisons, or add genuine side-channel/fault evaluation and corrected constructions. The current lack of public artifacts, statistical rigor, fair throughput baselines, and real-workload validation further prevents reliable assessment.