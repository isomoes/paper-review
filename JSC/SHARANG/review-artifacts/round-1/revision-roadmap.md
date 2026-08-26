# SHARANG Revision Roadmap

**Artifact:** Standalone immutable source-traceability checklist  
**Decision:** Major Revision — full re-review required  
**Target:** *The Journal of Supercomputing* (provisional fit only)  
**Criteria status:** `criteria_binding_unavailable`  
**Deadline:** NOT PROVIDED

> The order below is immutable source-traceability order, not a ranking or prescribed work order. `must_fix` and `should_fix` are editorial obligation classes, not estimates of effort. The manuscript itself must remain separate from this review artifact.

## Required revisions (`must_fix`)

### REV-1 — Demonstrate complete and equivalent ML-KEM GPU operations

- **Source reviewers:** Domain (R2); Devil's Advocate (DA).
- **Evidence anchor:** Table I, lines 73–83; Algorithm 2, lines 284–305; §VII.B/H, lines 323–346 and 406–432.
- **Finding:** Algorithm 2 outputs a 1,152-byte secret-key object, while the paper states that ML-KEM-768 uses a 2,400-byte decapsulation key. The described GPU flow appears to construct K-PKE keys rather than complete ML-KEM KeyGen, potentially invalidating the 6.6 ms / 3.1× headline comparison.
- **Minimum remedy:** Publish the exact call graph and code. Implement and time complete FIPS 203 KeyGen, including all required randomness, full decapsulation-key construction, hashes, host/device work, synchronization, memory movement, and cleanup. If the current result is K-PKE-only, relabel it and remove comparisons against full ML-KEM KeyGen.
- **Acceptance criteria:** CPU and GPU results use identical complete operations, inputs, outputs, security configurations, and timing boundaries; expected key lengths and byte-level equivalence are documented and reproducible.
- **Author triage:** unassigned (`will_address` / `wont_address` / `not_on_point`).

### REV-2 — Correct or substantiate the shuffle entropy and SPA claims

- **Source reviewers:** Journal-Fit (EIC), Domain (R2), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** Abstract, lines 24–30; §V.A, lines 234–242; §VIII.D, lines 433–436; §IX.C, lines 589–597; Conclusion, lines 608–615.
- **Finding:** A deterministic polynomial-derived `xorshift32` seed has at most 32 bits of state and zero fresh entropy conditioned on its input. Counting the theoretical permutation space does not establish >1,000 bits of realized entropy. Public/chosen/repeated inputs may make schedules predictable, while secret-derived scheduling may add leakage. No physical experiment demonstrates SPA resistance.
- **Minimum remedy:** Remove the >1,000-bit, unpredictability, SPA-resistance, and zero-cost-security claims unless supported. State the status of every seed input, the mapping and bias/collision behavior, and repeated/chosen-input effects. Use independent cryptographic randomness if required and account for its cost. Add reproducible leakage evaluation under an explicit attacker model.
- **Acceptance criteria:** Entropy is correctly bounded; every security claim maps to evidence; trace data, test procedures, and baselines are available; no unvalidated resistance claim remains.
- **DA adjudication:** VALIDATED.
- **Author triage:** unassigned.

### REV-3 — Prove or replace the NTT fault-detection checksum

- **Source reviewers:** Domain (R2), Devil's Advocate (DA).
- **Evidence anchor:** §V.B, lines 245–251; §VIII.D/E, lines 433–451; Table XVIII, lines 503–520.
- **Finding:** The ordinary coefficient sum is not generally invariant under the stated butterfly: `(a+ζb)+(a−ζb)=2a`, not normally `a+b`. The claimed `1−1/q` detection rate also lacks a defined fault event space and checker-protection model.
- **Minimum remedy:** Give exact transform-specific checksum equations and a proof, or replace the mechanism with a valid weighted checksum, residue code, redundant computation, or another justified construction. Define injection timing/location/value assumptions, checker protection, failure response, false positives/negatives, and experimental coverage.
- **Acceptance criteria:** The construction is mathematically valid for the actual implementation, and reproducible fault tests support only the stated coverage under an explicit model.
- **DA adjudication:** VALIDATED.
- **Author triage:** unassigned.

### REV-4 — Reconstruct the lazy-NTT bounds across scalar, NEON, and CUDA code

- **Source reviewers:** Domain (R2); Devil's Advocate (DA) identifies the affected correctness foundation.
- **Evidence anchor:** §IV.A, lines 121–137 and 152–158; arithmetic implementation, lines 165–200.
- **Finding:** The existing arguments do not include the multiplicand-dependent Montgomery bound, do not fully bound unreduced GS additions, and do not state exact centered-input, twiddle, narrowing, signedness, inverse-scaling, or backend semantics.
- **Minimum remedy:** Produce per-layer interval bounds for every branch and backend under exact language/intrinsic semantics. Add machine-checkable or exhaustive bounded verification, sanitizer runs, and edge-case differential tests.
- **Acceptance criteria:** The proof and executable checks establish absence of signed overflow, narrowing loss, undefined behavior, and backend-specific range gaps.
- **Author triage:** unassigned.

### REV-5 — Correct the GPU threat model and secret-data lifecycle

- **Source reviewers:** Domain (R2), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** Algorithm 2, lines 284–305; §VI.D, lines 335–340; §VIII.E, lines 445–451; Table V, lines 211–220.
- **Finding:** KeyGen and Encaps are called public-key operations even though GPU/managed memory handles secret noise, long-lived key material, ephemeral randomness, and shared-secret-related state. CPU stack wiping does not cover device memory, registers, caches, shared memory, managed pages, or error paths.
- **Minimum remedy:** Provide dataflow and lifetime diagrams, classify all values and memory locations, and define co-tenancy, driver, DMA, debugger, cache/remanence, physical, and privileged-attacker assumptions. Implement and verify cleanup or narrow the supported environment and claims.
- **Acceptance criteria:** No public-only rationale remains for secret-bearing operations; each sensitive object has documented residency, ownership, lifetime, cleanup, and residual risk.
- **Author triage:** unassigned.

### REV-6 — Rebuild the benchmark design, timing boundaries, and baselines

- **Source reviewers:** Journal-Fit (EIC), Methodology (R1), Domain (R2), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** §VI.B, lines 306–318; §VII.A, lines 309–320; Tables VIII–XII, lines 351–432; §IX.B, lines 553–561.
- **Finding:** GPU timing boundaries are unclear; the comparator is sequential despite a six-core CPU; allocation, page migration, synchronization, random generation, host work, and cleanup are not consistently scoped; only medians on one board are given; clocks, thermals, energy, contention, and variability are insufficiently reported.
- **Minimum remedy:** Define timed regions with pseudocode. Report host wall time and CUDA-event components, cold/warm behavior, allocation, migration, synchronization, preprocessing/postprocessing, and cleanup. Compare tuned 1/2/4/6-core NEON, GPU, and concurrent CPU+GPU paths. Report independent-run distributions/CIs, p50/p95/p99, affinity, power mode, clocks, thermals, sustained throughput, energy/op, and profiler evidence.
- **Acceptance criteria:** Complete equivalent operations are compared against the strongest relevant same-platform baseline; raw data and scripts reproduce every headline statistic and crossover.
- **Author triage:** unassigned.

### REV-7 — Establish FIPS 203 fidelity and accurately delimit KAT evidence

- **Source reviewers:** Domain (R2), Methodology (R1), Devil's Advocate (DA).
- **Evidence anchor:** Abstract, lines 14–35; §III.A, lines 87–96; §VII.B, lines 323–346; Conclusion, lines 608–613.
- **Finding:** Equality with an unspecified pq-crystals revision and 100 generated vectors is not equivalent to complete FIPS 203 or ACVP validation and cannot demonstrate all code paths. Required API checks, malformed-input handling, implicit rejection, randomness failures, configurations, and backend coverage are not mapped.
- **Minimum remedy:** Pin revisions; map implementation steps and APIs to FIPS 203; document vector provenance; distinguish compatibility testing from formal validation. Add malformed/noncanonical key/ciphertext cases, dk consistency, implicit rejection, failure behavior, and a configuration/backend coverage matrix.
- **Acceptance criteria:** Compliance wording matches the exact evidence; published vectors, hashes, logs, and negative tests reproduce every stated result.
- **Author triage:** unassigned.

### REV-8 — Release a complete, reviewable reproducibility artifact

- **Source reviewers:** Journal-Fit (EIC), Methodology (R1), Domain (R2), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** §VII.A/B, lines 309–346; Source Code Availability, lines 642–644.
- **Finding:** Availability only upon reasonable request prevents verification of security-sensitive code, arithmetic claims, configuration parity, tests, and measurements.
- **Minimum remedy:** Archive source and license, immutable commit/tag, dependency revisions, build environment, scripts, raw timings, profiler outputs, test vectors, logs, proofs/checkers, and a table-to-command map.
- **Acceptance criteria:** A third party can build every backend and reproduce correctness tests, key measurements, range verification, and revised tables.
- **Author triage:** unassigned.

## Suggested revisions (`should_fix`)

### REV-9 — Correct prior work and bound novelty/superlative claims

- **Source reviewers:** Journal-Fit (EIC), Domain (R2), Devil's Advocate (DA).
- **Evidence anchor:** §II, lines 99–137; Table XIV, lines 488–498; References, lines 653–681.
- **Task:** Correct the FPGA reference used for a GPU claim; cover current GPU/CUDA ML-KEM, ARM optimization, shuffling/masking/fault evaluation, and GPU-security literature. Bound or remove “first,” “highest performance,” and “most comprehensive” unless a documented search and controlled comparisons support them.
- **Acceptance criteria:** Every novelty/comparison claim has an accurate citation, explicit scope, and fair evidence.
- **Author triage:** unassigned.

### REV-10 — Validate the proposed TLS/server deployment

- **Source reviewers:** Journal-Fit (EIC), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** §VII.E/H, lines 376–416 and 406–452; §IX.B, lines 553–561.
- **Task:** Add a real or trace-driven workload with batching, request arrivals, queueing, p95/p99 latency, concurrent CPU Decaps, routing policy, and resource contention. Otherwise label deployment examples as prospective hypotheses.
- **Acceptance criteria:** Application-level claims follow from measured end-to-end behavior rather than arithmetic extrapolation from kernels.
- **Author triage:** unassigned.

### REV-11 — Measure managed-memory and GPU resource behavior

- **Source reviewers:** Journal-Fit (EIC), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** §VI.A–C, lines 253–329; scaling discussion, lines 447–456.
- **Task:** Qualify the claim that unified memory eliminates transfer overhead. Report cold/warm migrations, prefetch/advice, page faults, cache ownership, registers, spills, shared memory, occupancy, blocks/SM, utilization, bandwidth, synchronization, and peak memory footprint by batch size.
- **Acceptance criteria:** Transfer, saturation, and crossover explanations are supported by profiler and end-to-end measurements.
- **Author triage:** unassigned.

### REV-12 — Normalize claims, feature accounting, and presentation

- **Source reviewers:** Journal-Fit (EIC), Domain (R2), Perspective (R3), Devil's Advocate (DA).
- **Evidence anchor:** Abstract and contributions, lines 14–35 and 70–87; Tables VI/XIX, lines 222–242 and 524–539; Conclusion, lines 599–615.
- **Task:** Reconcile six versus nine features and “zero cost” versus measured overhead; separate coding practices, monitoring, functional testing, candidate mitigations, and validated resistance. Remove `TEMPLATE` residue, correct “P6FIPS 203” and duplicated wording, and improve dense tables.
- **Acceptance criteria:** A claim ledger maps each abstract/conclusion statement to one configuration, comparator, experiment, and limitation; terminology and counts are consistent.
- **Author triage:** unassigned.

## Re-review evidence bundle

A revised submission should include:

1. Revised manuscript with exact change locations.
2. Point-by-point response covering REV-1 through REV-12.
3. Immutable source revision and build environment.
4. Complete benchmark raw data and analysis scripts.
5. Complete FIPS/KAT/negative-test artifacts and coverage matrix.
6. Lazy-NTT bound proof/checker and fault-check derivation/tests.
7. Side-channel evidence or explicit withdrawal/narrowing of resistance claims.
8. GPU data-lifetime, zeroization, and threat-model evidence.

Re-review should verify each acceptance criterion against the revised manuscript and artifacts rather than relying solely on the response letter.
