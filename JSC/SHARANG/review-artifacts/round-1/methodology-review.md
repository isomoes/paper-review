# Methodology Review — SHARANG GPU

**Role:** Methodology Reviewer (role-separated seat; no peer outputs consulted)  
**Target venue:** *The Journal of Supercomputing*  
**Criteria status:** `criteria_binding_unavailable` — no formal venue criteria manifest was supplied, so I make no criteria-bound venue-alignment claim. I assess systems/experimental rigor using standard reproducible supercomputing and cryptographic-implementation methodology.

## Summary
The manuscript presents a potentially useful ARM–CUDA ML-KEM-768 implementation and reports scalar, NEON, and GPU batch results on one Jetson Orin Nano Super. Its strongest methodological features are a named hardware/compiler configuration, a reasonably large nominal iteration count, primitive and end-to-end tables, explicit CPU/GPU timing APIs, KAT/differential-testing claims, and some limitations. However, the central performance and security conclusions are not presently auditable. GPU synchronization and timing boundaries are unspecified; CPU–GPU workloads and resources are not demonstrably comparable; decimal “median ticks” are incompatible with an integer hardware counter; statistical uncertainty and run-level replication are absent; the hardening/zero-overhead claims are contradicted by the manuscript’s own ablation table; the GPU KeyGen pseudocode emits an IND-CPA-sized secret key rather than an ML-KEM secret key; KAT provenance is unclear; and the claimed SPA/fault resistance is not established experimentally and appears theoretically under-specified. Source is only “available on request.”

## Strengths
1. The platform, clocks, timing sources, warm-up, nominal iterations, and compiler options are at least partially reported (Sec. VII-A, p. 5, lines 309–320).
2. Results span primitive timing, end-to-end KEM timing, configuration comparisons, cycle breakdown, batch scaling, and code size (Tables VIII–XIII, pp. 6–7, lines 351–461).
3. The authors report 14 internal tests, 100 claimed KAT vectors, and CPU/GPU bytewise differential tests over several batch sizes (Sec. VII-B, p. 5, lines 323–346).
4. Some negative results and constraints are acknowledged: NEON basemul regression, GPU Decaps exclusion, CPU-side Encaps hashing, and absence of DPA resistance (Sec. IX-D, pp. 9–10, lines 606–630; Table XVIII, lines 502–520).
5. Several reported percentage calculations are internally consistent: 77→73 µs ≈5%, 85→72 µs ≈15%, 108→85 µs ≈21%; 256/6.6 ms ≈38,800 KeyGen/s; and 73+85 µs ≈158 µs (Tables XI–XII, lines 364–416).

## Critical findings

### C1. GPU timing is not defined well enough to support any GPU speedup or crossover claim
**Anchors:** Sec. VII-A, p. 5, lines 309–320; Sec. VI-B, p. 5, lines 306–313; Table XII/Sec. VII-H, pp. 6–7, lines 406–431; Sec. IX-B, p. 8, lines 553–561.  
`clock_gettime(CLOCK_MONOTONIC)` is named, but the manuscript never states whether a blocking `cudaDeviceSynchronize`, event synchronization, or equivalent occurs inside the timed interval. CUDA launches are asynchronous, so host wall-clock timing without an explicit synchronization boundary can measure launch rather than completion. It is also unclear whether managed-memory page migration/prefetch, allocation, CPU-side Encaps hashes, random-coin generation, output copies/coherence, and correctness checks are included. The text simultaneously says persistent buffers amortize allocation for single operations but that batch buffers are allocated “once per batch”; a ~500 µs allocation is material at N=32 (2.1–3.3 ms total). Thus Tables XII and the N≈32 crossover are not reproducible or interpretable.

**Minimum remedy:** Publish pseudocode for every timed region; use synchronized CUDA events for device-only time and a separately synchronized end-to-end host wall time; state inclusion/exclusion of allocation, managed-memory migration/prefetch, RNG, CPU hashing, initialization, and verification; report both kernel-only and end-to-end distributions. Re-run all batch sizes under these definitions.

### C2. The GPU “ML-KEM KeyGen” path appears incomplete
**Anchors:** Table I, p. 2, lines 73–83 gives |sk|=2,400 B; Algorithm 2, p. 5, lines 284–305 gives `sk[N][1152]` and only the IND-CPA key-generation steps; Sec. VII-B, lines 334–346 and Table XII, lines 421–432 call this KEM KeyGen and claim bit-exact correctness.  
The pseudocode output size (1,152 B) is the IND-CPA secret-vector size, not the 2,400-byte ML-KEM-768 secret key stated in Table I. Algorithm 2 omits construction of the full decapsulation key (including the encoded public key, H(pk), and rejection value). If Table XII times only IND-CPA KeyGen, comparison with CPU KEM KeyGen is invalid; if the omitted work occurs elsewhere, the algorithm and timing boundary are incomplete.

**Minimum remedy:** Reconcile the size and name the exact API. Show the full FIPS 203 KeyGen dataflow and all 2,400 output bytes, identify where omitted fields are generated, and include them in GPU timing and differential/KAT testing. Otherwise relabel the benchmark as IND-CPA/PKE key generation and remove KEM-level comparisons.

### C3. “Zero-cost” hardening is contradicted by measured results, and the ablation does not isolate features
**Anchors:** Abstract/Introduction, pp. 1–2, lines 24–26, 58–60; Table X, p. 6, lines 351–361; Table XIX, p. 8, lines 524–538; Sec. IX-C, p. 9, lines 589–603; conclusion, lines 602–607.  
Table X changes NEON KeyGen from 0.069 ms (“no sec.”) to 0.073 ms (“hardened”), a 5.8% increase and a visible 4 µs difference. Table XIX reports secure wipe at ~140 ticks/KeyGen (~4.48 µs at 31.25 MHz) and total hardening <5 µs. These data directly contradict “six … at zero measurable runtime cost” and “comprehensive security hardening … at zero measurable runtime cost.” Moreover, “no sec.” is misleading because secure wipe and constant-time operations are said to be unconditional (Sec. V, lines 222–230). The six-versus-nine feature count is also inconsistent (lines 24, 58, 84–86, 222–242, 602–607).

**Minimum remedy:** Replace “zero cost” with a statistically bounded overhead claim, if supported. Run factorial/one-feature-at-a-time ablations from an identical codebase for shuffle, checksum, health/CBD, wipe, verify/cmov, and combinations; report paired medians, uncertainty, and equivalence margins. Define exactly what “no sec.” disables and consistently distinguish six configurable/operational mechanisms from nine table rows.

### C4. SPA and fault-detection claims lack the required security experiment and a soundly specified invariant
**Anchors:** Sec. V-A/B, p. 4, lines 234–251; Sec. VIII-D/E, p. 7, lines 426–451; Sec. IX-C, p. 9, lines 589–597.  
The shuffle seed is a deterministic function of polynomial coefficients; the paper supplies no argument that it is secret/unpredictable for relevant public or repeatable inputs and no power/EM traces, fixed-vs-random test, attack success rate, or comparison to an unshuffled control. Counting theoretical permutations does not establish entropy when the permutation is data-derived (lines 433–435), and “2,304 concurrent SHAKE instances” is not evidence of security. More seriously, the stated checksum `sum c_i mod q` is not generally invariant under an NTT butterfly: for a standard butterfly `(a+ζb, a−ζb)`, the output sum is `2a`, not `a+b`. The manuscript gives no weighted invariant or checking algorithm. The 1−1/q detection probability also depends on an unstated random-fault distribution and is inappropriate as a blanket adversarial-fault guarantee.

**Minimum remedy:** Provide the exact shuffle scope and seed threat model; conduct leakage/attack evaluation on the target board using a recognized methodology (e.g., fixed-vs-random tests plus concrete single-trace attack success) against controlled unshuffled and entropy-seeded baselines. Formally derive the actual NTT checksum invariant, publish the checking algorithm, and inject exhaustive/random/adversarial faults by layer/type/location, reporting detection and false-positive rates. Until then, describe these as unvalidated countermeasure candidates, not SPA/fault resistance.

## Major findings

### M1. CPU timing values are not statistically or arithmetically traceable to the stated estimator
**Anchors:** Sec. VII-A, lines 314–320; Tables IV, VIII, IX, lines 211–219 and 351–378.  
`cntvct_el0` produces integer counter ticks. With 2,000 iterations, a median of integer observations can be an integer or half-integer, yet Table VIII reports 98.7, 56.3, 132.4, 66.6, etc. These must be means, normalized batch values, or another statistic, contrary to the methodology. No variance, IQR, confidence interval, independent process/run count, input policy, or outlier rule is given. In addition, 99.6/17.4=5.72×, not 5.5×; 664/17.5=37.9×, not 39× (Table IV). The prose uses slightly different denominators, 17.3 and 17 ticks (lines 188–200), suggesting mixed runs/rounding.

**Minimum remedy:** Define the observation unit and estimator for every table, preserve raw integer counts, separate within-run iterations from independent runs, and report distributions/95% CIs. Correct ratios or give unrounded source values. Archive raw samples and analysis scripts.

### M2. CPU–GPU comparator, work, and resource budgets are not comparable
**Anchors:** Table XI, lines 364–372; Table XII, lines 421–432; Sec. VII-H, lines 406–416; platform has six CPU cores, lines 311–314.  
Table XII only labels a “CPU” comparator. Its per-operation values differ materially from Table XI: 20.2/256=78.9 µs KeyGen and 25.1/256=98.0 µs Encaps, neither clearly matching the hardened NEON 73/72 µs or reference 77/85 µs. GPU KeyGen accepts pre-generated coins (Algorithm 2), while it is unclear whether CPU timing includes `getrandom`; Encaps includes a hybrid CPU/GPU composition. GPU uses the whole GPU, whereas the comparator appears to use one of six CPU cores. Therefore “3.1× GPU speedup” is only meaningful, at best, against an unspecified sequential harness, not as a platform throughput advantage.

**Minimum remedy:** Identify exact CPU/GPU build, API, inputs, and included work. Compare equal semantic operations with identical pre-generated inputs and separately with end-to-end RNG. Report scalar, one-core NEON, six-core parallel NEON, GPU kernel-only, and GPU end-to-end throughput, plus CPU utilization.

### M3. Hardware/software controls needed for stable Jetson benchmarking are missing
**Anchors:** Sec. III-C, lines 109–117; Sec. VII-A, lines 309–320; Table XII caption, lines 421–432.  
There is no JetPack/L4T, kernel, CUDA driver/runtime, firmware, power mode, `nvpmodel`, `jetson_clocks`, CPU/GPU/EMC frequency policy, CPU affinity, scheduler priority, thermal state, cooling, temperature, throttling, memory state, or background-load control. Only the nominal GPU clock is stated. A single board/system is used.

**Minimum remedy:** Fully report and script the environment; lock/record CPU, GPU, and memory clocks; pin CPU threads; monitor temperature/throttling/power; repeat cold and steady-state runs across independent sessions and preferably multiple boards.

### M4. Managed-memory and occupancy/scaling explanations are technically unsupported
**Anchors:** Sec. VI-A/B, lines 267–275 and 306–313; Sec. VII-H, lines 447–452; Sec. IX-C/E, lines 589–637.  
Unified/managed memory does not automatically mean “no transfer overhead”; first-touch page migration and coherence can occur. No prefetch/residency counters are shown. The claimed 12,288-thread saturation analysis ignores the reported ~22 KB shared memory per block and the fact that only thread 0 performs most of the pipeline. With a 48 KB shared-memory limit, at most roughly two such blocks can reside per SM before considering registers/architectural block limits, so 9N total launched threads do not imply 9N concurrent/resident threads. Calling 2,304 SHAKE instances “concurrent” at N=256 is therefore misleading.

**Minimum remedy:** Report compiler resource usage (registers, static/dynamic shared memory), achieved occupancy, resident blocks/warps, profiler traces, managed-memory migrations, and kernel-by-kernel time. Replace capacity arithmetic with occupancy-calculator/profiler-supported analysis and distinguish launched parallel work from simultaneous residency.

### M5. KAT and differential-testing provenance is insufficient for a FIPS 203 compliance claim
**Anchors:** Abstract, lines 31–35; Introduction, lines 58–60, 87–88; Sec. VII-B, lines 323–346; references [4]/[7], lines 660–667.  
The manuscript calls the vectors “NIST KAT” but says outputs are compared with the pq-crystals reference, while the bibliography points to Kyber submission/specification material rather than an identified final FIPS 203/ACVP vector set and commit. Only deterministic KeyGen and Encaps APIs are named, although “all three KEM operations” is claimed. GPU testing is a separate 50-seed differential test, not clearly the 100 KATs. A derivative implementation and its reference ancestor can share defects. Counts across batch sizes/operations and handling of malformed ciphertext/implicit rejection are unclear.

**Minimum remedy:** Identify vector suite and provenance by URL/version/hash; identify oracle commit and ML-KEM parameterization; publish expected/actual digests and logs for KeyGen, Encaps, Decaps, and implicit rejection. Run final-FIPS/ACVP vectors where available, GPU KATs for supported operations, malformed-ciphertext negative tests, cross-implementation differential tests against at least one independent implementation, sanitizers, and randomized/property testing.

### M6. The optimization evidence is confounded and incomplete
**Anchors:** Table IV, lines 211–219; Table VIII, lines 351–362; Table X, lines 351–361; Table XVII, lines 521–540; Sec. IX-E, lines 633–637.  
There is no isolated measurement of lazy reduction, division-free Compress1, Karatsuba, NEON layers, Keccak replacement, RNG replacement, or their interactions from a common baseline. Table X mixes architecture and security changes; Table IV reports a historical “before/after” without a controlled commit/configuration protocol. Karatsuba is advertised but has no benchmark and basemul overall regresses. Causal statements such as which optimization “accounts” for speedup are therefore unsupported.

**Minimum remedy:** Provide a controlled ablation matrix with one commit, common compiler/environment, feature toggles, per-operation and end-to-end effects, and interaction results. Benchmark Karatsuba on/off and explain whether it is used in headline configurations.

### M7. Cross-implementation and classical comparisons are not fair baselines
**Anchors:** Sec. VIII-A/Table XIV, lines 463–498; Table XXI, lines 566–575; conclusion, lines 611–615.  
Table XIV combines A78AE, A72, unspecified ARM, and x86 Skylake measurements, approximate values, different libraries, likely different versions/compiler flags, and security-feature sets. No direct same-device reruns or source citations for individual numbers are provided. Consequently “3.4–5.6×,” “highest performance,” and comparisons to RSA/X25519 cannot establish implementation superiority. The TLS discussion also adds standalone operation times rather than an instrumented handshake.

**Minimum remedy:** Build current pq-crystals/FIPS-203, liboqs, and wolfSSL revisions on the same Jetson using documented equivalent flags/APIs/RNG and benchmark with the same harness. Label cross-platform literature values as contextual only. Measure an actual TLS hybrid handshake if retaining deployment-latency claims.

### M8. Scaling/generalization claims exceed measured evidence
**Anchors:** Table XII, lines 421–452; Sec. IX-A/Table XXII, lines 478–483 and 578–586; lines 544–548; future-work claims lines 623–637.  
Only ML-KEM-768 on one 8-SM device is measured. ML-KEM-512/1024 values and claims of similar GPU speedup are projections, not results; no uncertainty or model validation is supplied. The 512 Encaps entry is absent without explanation. Claims about discrete-GPU crossover (~1,000), 32-thread blocks yielding ~2×, and NEON Keccak yielding 1.5–2× are speculative.

**Minimum remedy:** Clearly segregate projections from findings; validate the operation-count model against implemented 512/1024 builds or remove numeric projections. Explain missing N=512 Encaps and test a wider range. Either benchmark a discrete GPU or qualify the crossover as an analytical scenario with a complete transfer/compute model and sensitivity analysis.

### M9. Reproducibility/artifact availability is below the standard needed to audit the claims
**Anchor:** “Availability of Source Code,” p. 10, lines 642–644.  
“Available from the corresponding author upon reasonable request” does not permit reviewers/readers to inspect code, reproduce tables, verify flags, or audit KAT/security behavior. No repository, commit, license, build container, harness, raw data, analysis script, KAT files/logs, or artifact manifest is supplied.

**Minimum remedy:** Provide an archival, anonymous review artifact and later a public persistent release containing exact source commit/submodules, license, build and run scripts, environment manifest, raw timing data, analysis code, expected table regeneration, KAT/differential logs, and SHA-256 hashes.

## Minor findings
1. **Terminology/units:** “ticks” and “cycles” are used interchangeably even though `cntvct_el0` is a 31.25 MHz timer, not CPU core cycles (Tables IV, VIII, IX; lines 211–219, 351–378). Rename to timer counts or convert to time.
2. **Warm-up wording:** “a warmup of 100-iterations” is grammatically and methodologically vague (lines 317–318); say whether warm-up is per operation, configuration, batch size, and process.
3. **Missing N=512 Encaps:** Table XII uses em dashes without explanation (lines 425–432). State memory/resource/error limitation or provide data.
4. **Projection precision:** Table XXII gives seemingly precise integer-microsecond projections without model error (lines 578–586). Add uncertainty/ranges and model assumptions.
5. **Cycle-breakdown residual:** The ~400-tick unexplained gap is ~18% of measured total, too large to confidently assign to generic function calls/cache/stalls without profiling (lines 397–405). Use PMU/profiler evidence.
6. **Security monitor reporting:** SP 800-90B tests are described on `getrandom()` outputs rather than the raw entropy source, and state/window handling across short calls is not given (lines 253–271). Clarify applicability, buffering, startup/continuous-test semantics, error behavior, and empirical false alarms.

## Questions for the authors
1. Is there an explicit CUDA synchronization inside every Table XII timed interval? Exactly where?
2. Does batch allocation and first-touch managed-memory migration count in Table XII? Are pages prefetched, and which processor initializes them?
3. Why does Algorithm 2 output a 1,152-byte secret key when ML-KEM-768 requires 2,400 bytes? What exact API is timed?
4. Which CPU implementation/configuration produces Table XII’s CPU column, and does it include RNG? Why do its per-operation values disagree with Table XI?
5. How were decimal timer counts derived if the reported statistic is the median of integer `cntvct_el0` differences?
6. How many independent program executions/board reboots were run, and what are the IQRs/CIs?
7. What exact FIPS 203 KAT/ACVP files, pq-crystals commit, and output hashes were used? Was GPU KeyGen/Encaps run on every KAT?
8. What mathematical invariant is checked around the NTT? Please derive it for one butterfly and state check placement.
9. Can the same polynomial/input recur, and if so does it generate the same shuffle? What evidence establishes trace decorrelation or attack failure?
10. Which hardening features are included in “six” and which in “nine”? What does “no sec.” actually disable?
11. What are CUDA register/shared-memory usage, achieved occupancy, page-migration counts, and per-kernel times?
12. Why is N=512 Encaps absent?

## Recommendation
**Major Revision (methodology; close to reject-and-resubmit if new experiments/artifact cannot be supplied).** The implementation idea and initial measurements are promising, but the paper’s central KEM-level GPU speedup, zero-overhead hardening, SPA/fault resistance, FIPS-compliance, scaling, and comparative-superiority claims are not presently supported by reproducible, statistically controlled, semantically comparable evidence. C1–C4 must be resolved before those headline claims are publishable.
