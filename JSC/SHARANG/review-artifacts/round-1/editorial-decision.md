# Editorial Decision Package

## Manuscript

**Title:** *SHARANG: A Heterogeneous CPU–GPU Accelerated, Security-Hardened ML-KEM-768 Implementation for ARM–CUDA Platforms*  
**Target venue:** *The Journal of Supercomputing*  
**Review round:** Initial review  
**Decision:** **Major Revision — re-review required**

## Scope and criteria disclosure

`criteria_binding_unavailable`: no formal `ReviewCriteriaBindingManifest` or Target Criteria Brief was supplied. The manuscript is provisionally relevant to the journal's broad high-performance computing, heterogeneous architecture, systems, and performance-evaluation remit, but this package makes no contract-bound venue-alignment claim.

## Review-panel provenance

The reports were produced by role-separated AI subagent contexts. Each seat was instructed to read the manuscript independently and not consult peer outputs. Role and context separation do **not** establish independent error processes.

| Seat | Role ID | Actor type | Context ID | Peer outputs visible | Model family | Provider | Human reviewer ID |
|---|---|---|---|---|---|---|---|
| Journal-Fit Reviewer | EIC | AI subagent | `012a25c8-25c1-45ef-8b05-282f600eefae` | No | unknown | unknown | none |
| Methodology Reviewer | R1 | AI subagent | `8e6c7a69-5b0b-4f20-ab58-a5f7a2e6426d` | No | unknown | unknown | none |
| Domain Reviewer | R2 | AI subagent | `4b52c28b-9308-4331-815b-45628144b91c` | No | unknown | unknown | none |
| Perspective Reviewer | R3 | AI subagent | `8eff6c0e-3eda-414f-b637-2f0f891260d2` | No | unknown | unknown | none |
| Devil's Advocate | DA | AI subagent | `1c819a9f-af81-40d5-956a-793728cca047` | No | unknown | unknown | none |

| Provenance axis | Status |
|---|---|
| Role-separated | true |
| Within-panel invocation-context separation | true |
| Blind to peer outputs | true |
| Model-family distinct | unknown |
| Provider distinct | unknown |
| Human-reviewer distinct | false / not applicable |

**Binary independence claim:** Not computed and not asserted.  
**Correlated-error disclosure:** The model families and providers were not exposed. The five reports may therefore share model-, provider-, prompt-, or training-induced errors despite role and context separation. Corroboration across seats increases traceability but is not statistical independence.

## Reviewer summary

| Reviewer | Focus | Recommendation |
|---|---|---|
| Journal-Fit Reviewer | Venue relevance, contribution, positioning, submission maturity | Major Revision |
| Methodology Reviewer | Experimental design, benchmarking, statistics, comparability, reproducibility | Major Revision |
| Domain Reviewer | ML-KEM/FIPS fidelity, arithmetic, side channels, fault security | Reject in present form / rebuilt resubmission invited |
| Perspective Reviewer | Heterogeneous deployment, GPU boundary, workloads and resource accounting | Major Revision |
| Devil's Advocate | Adversarial challenge to core security and performance claims | Reject in present form / resubmission encouraged |

The decision is not a mechanical vote. The severe findings are potentially repairable through corrected implementation/proofs, new controlled evaluation, and substantial claim narrowing; therefore **Major Revision** is preferred over outright rejection, with the explicit warning that failure to resolve the three blockers would justify rejection at re-review.

## Blocking issues

| Ref | Blocking issue | Source reviewers | Manuscript anchor | Resolving item |
|---|---|---|---|---|
| B1 | The reported CUDA “KeyGen” may implement only K-PKE key generation: Algorithm 2 outputs a 1,152-byte secret while the paper states a 2,400-byte ML-KEM-768 decapsulation key. This can invalidate the headline 3.1× comparison. | R2, DA | Table I, lines 73–83; Algorithm 2, lines 284–305; §VII.B/H, lines 323–346 and 406–432 | REV-1 |
| B2 | The deterministic polynomial-derived `xorshift32` shuffle cannot realize the claimed >1,000 bits of entropy, and no leakage evidence establishes “SPA resistance” or “zero-cost security.” | EIC, R2, R3, DA | Abstract, lines 24–30; §V.A, lines 234–242; §VIII.D, lines 433–436; §IX.C, lines 589–597; Conclusion, lines 608–615 | REV-2 |
| B3 | The security/correctness foundation contains an unproven or false ordinary-sum NTT checksum and incomplete lazy-NTT bounds. These affect core fault-resistance and correctness claims. | R2, DA; methodology implications noted by R1 | §IV.A, lines 121–137 and 152–158; §V.B, lines 245–251; §VIII.D/E, lines 433–451 | REV-3 and REV-4 |

## Consensus analysis

### Points of agreement

1. **Promising engineering premise, insufficient present evidence.** The panel recognizes a plausible latency-oriented NEON / throughput-oriented CUDA design and useful implementation decomposition. Nevertheless, all scoring reviewers require substantial revision or stronger, and both security-focused assessments find the current headline security claims unacceptable.
2. **The shuffle claims are materially overstated.** EIC, R2, R3, and DA independently identify the 32-bit deterministic seed, unsupported entropy calculation, and absence of physical leakage evaluation. This is a four-seat corroborated blocker.
3. **Performance comparisons are not yet fair or reproducible.** EIC, R1, R2, R3, and DA identify undefined timing boundaries, single-platform evidence, absent variability, weak same-hardware controls, sequential rather than multicore CPU batch comparison, and unavailable artifacts.
4. **Security feature counts do not constitute validation.** EIC, R2, R3, and DA reject the use of checkmarks/counts as evidence for “comprehensive security hardening.” Functional KAT agreement does not demonstrate side-channel or fault resistance.
5. **The deployment argument needs system-level evidence.** EIC and R3, supported by DA, request a real or trace-driven workload, mixed CPU–GPU operation, queueing/tail latency, and resource accounting rather than projection from microbenchmarks.

### Points of disagreement and editorial resolution

**Decision category.** R2 and DA recommend rejection/resubmission, whereas EIC, R1, and R3 recommend Major Revision. This is mainly a repair-scope disagreement, not disagreement that the defects exist. The editor resolves it as **Major Revision** because the manuscript could remain publishable if the authors (i) establish complete ML-KEM operation parity, (ii) correct the mathematical/security errors, (iii) withdraw unsupported resistance/superlative claims or add credible evidence, and (iv) rebuild the evaluation. Re-review is mandatory; this is not an invitation for cosmetic revision.

**Venue fit.** EIC views the topic as provisionally in scope but notes that the current paper resembles a platform-specific cryptographic implementation report more than a mature heterogeneous-supercomputing study. R3 similarly finds the heterogeneous premise relevant but untested under simultaneous workloads. The editor finds provisional topical fit but no criteria-bound venue-alignment conclusion.

## Devil's Advocate CRITICAL adjudication

Every DA CRITICAL finding is addressed explicitly:

1. **Data-derived shuffle / SPA resistance — VALIDATED.** R2 and R3 independently corroborate that a deterministic 32-bit PRNG cannot yield >1,000 bits of realized entropy, may be predictable for public/chosen/repeated inputs, and can introduce data-dependent leakage for secret-derived inputs. No trace-based evaluation is reported. This blocks acceptance and is carried into REV-2.
2. **Ordinary-sum NTT fault invariant — VALIDATED as technically unsupported and apparently false as written.** R2 independently notes that for a butterfly `(a,b) → (a+ζb, a−ζb)`, the output sum is `2a`, not generally `a+b`. The manuscript supplies no transform-specific weighted invariant or injection model. This blocks the fault-detection claim and is carried into REV-3.
3. **“Comprehensive security hardening” unsupported — VALIDATED.** EIC, R2, and R3 corroborate that KATs, coding idioms, checkmarks, and feature counts do not validate side-channel, fault, constant-time, zeroization, or GPU-memory security. DPA/EM and coordinated faults are explicitly uncovered. This is carried into REV-2, REV-3, REV-5, and REV-7.

No DA CRITICAL finding is rejected or silently bypassed.

## Decision rationale

SHARANG addresses a relevant and potentially useful problem: combining ARM NEON latency optimization with GPU batch throughput for ML-KEM-768 on an integrated Jetson platform. The manuscript offers implementation detail, primitive and end-to-end measurements, KAT/differential tests, and candid acknowledgment of several limitations. These merits justify an opportunity to revise.

Acceptance is nevertheless impossible in the current form. First, the CUDA KeyGen pseudocode and key sizes suggest that the central GPU speedup may compare incomplete K-PKE work against complete ML-KEM KeyGen. Second, the claimed security novelty relies on a deterministic 32-bit, data-derived shuffle while asserting over 1,000 bits of entropy and SPA resistance without leakage evidence. Third, the claimed ordinary-sum NTT invariant appears invalid, while the lazy-reduction proofs do not bound all branches and backend semantics. Fourth, the GPU path handles secret-bearing KeyGen and ephemeral Encaps state despite being justified as “public-key operations.” Finally, benchmark timing boundaries, multicore controls, variability, managed-memory behavior, FIPS/ACVP evidence, and artifacts are insufficient for verification.

These problems are severe but not necessarily unrepairable. A corrected full-operation implementation, executable bounds and checksum analysis, defensible threat model, controlled evaluation, public artifact, and disciplined claim ledger could produce a materially different manuscript. The appropriate decision is therefore **Major Revision with full re-review**. If operation parity or arithmetic/security validity cannot be demonstrated, the revised manuscript should be rejected or reframed as a narrower systems prototype without security-resistance claims.

## Required revisions

### REV-1 — Establish complete and equivalent ML-KEM GPU operations
- **Sources:** R2; DA.
- **Anchor:** Table I, lines 73–83; Algorithm 2, lines 284–305; §VII.B/H, lines 323–346 and 406–432.
- **Problem:** Algorithm 2 emits `sk[N][1152]` and appears to omit complete ML-KEM decapsulation-key construction (`dkPKE || ek || H(ek) || z`), while the paper reports full ML-KEM KeyGen speedup.
- **Minimum remedy:** Publish the exact call graph and code; implement and time complete FIPS 203 ML-KEM KeyGen with independent required randomness, full 2,400-byte key construction, hashes, synchronization, memory movement, and cleanup. If the existing kernel is K-PKE-only, relabel every result and remove full-KeyGen comparisons.
- **Acceptance criteria:** Each CPU/GPU timing maps to the same algorithmic operation, inputs, outputs, security configuration, and timing boundary; complete output lengths and byte-level equivalence are documented and reproducible.

### REV-2 — Correct or withdraw shuffle entropy and SPA-resistance claims
- **Sources:** EIC, R2, R3, DA.
- **Anchor:** Abstract, lines 24–30; §V.A, lines 234–242; §VIII.D, lines 433–436; §IX.C, lines 589–597; Conclusion, lines 608–615.
- **Problem:** The seed has at most 32 bits of state and zero fresh entropy conditioned on the polynomial; the >1,000-bit calculation counts a theoretical permutation space rather than realized entropy. No attacker model or leakage experiment demonstrates SPA resistance.
- **Minimum remedy:** Remove “>1,000 bits,” “SPA resistance,” “unpredictability,” and “zero-cost security” unless supported. Specify the secrecy/control of inputs to every shuffled NTT, seed-to-permutation mapping, bias/collisions, and repeated/chosen-input behavior. Use independent cryptographic randomness if unpredictability is required and measure its cost. Add a reproducible physical leakage evaluation with explicit attacker model, appropriate fixed-versus-random testing, and attack-success comparison.
- **Acceptance criteria:** Claims are bounded to evidence; actual seed entropy is correctly stated; test data and procedures are available; no unvalidated resistance claim remains.

### REV-3 — Replace or prove the NTT fault-detection invariant
- **Sources:** R2, DA.
- **Anchor:** §V.B, lines 245–251; §VIII.D/E, lines 433–451; Table XVIII, lines 503–520.
- **Problem:** The ordinary coefficient sum is not generally invariant under the stated twiddled butterfly, and the `1−1/q` coverage claim lacks a defined fault distribution and protected check computation.
- **Minimum remedy:** Provide exact pre/post checksum equations tied to each transform and prove them, or replace the mechanism with a valid weighted checksum, residue code, redundant computation, or other justified scheme. Define fault timing/location/value/control-flow assumptions, checker protection, false-positive/negative behavior, response semantics, and experimental injection coverage.
- **Acceptance criteria:** The check is mathematically valid for the compiled algorithm, and claimed coverage is supported under an explicit fault model by reproducible tests.

### REV-4 — Rebuild the lazy-NTT range proofs for all backends
- **Sources:** R2; DA flagged the correctness foundation.
- **Anchor:** §IV.A, lines 121–137 and 152–158; Algorithms/equations around lines 165–200.
- **Problem:** The proofs treat Montgomery outputs as bounded independently of growing multiplicands and do not fully bound the unreduced GS addition branch, narrowing, signedness, or scalar/NEON/CUDA semantics.
- **Minimum remedy:** Supply per-layer interval bounds for every branch, twiddle extremum, multiplication, cast, narrowing, inverse scaling, and backend width under exact C/CUDA/intrinsic semantics. Add machine-checkable or exhaustive bounded verification, sanitizer runs, and edge-case differential tests.
- **Acceptance criteria:** No signed overflow, narrowing loss, undefined behavior, or backend-specific bound gap remains; the proof and executable checks reproduce the stated bounds.

### REV-5 — Correct the GPU threat model and secret-data lifecycle
- **Sources:** R2, R3, DA.
- **Anchor:** §VI.D, lines 335–340; Algorithm 2, lines 284–305; §VIII.E, lines 445–451; Table V, lines 211–220.
- **Problem:** GPU KeyGen and Encaps are described as public-only although they handle secret noise, key material, randomness, and shared-secret-related state. CPU stack wiping does not cover managed/device/global/shared/register state.
- **Minimum remedy:** Add operation-level dataflow and lifetime diagrams; classify each sensitive value and memory location; define co-tenancy, driver, DMA, debugger/profiler, cache/register remanence, physical-observer, and privileged-attacker assumptions. Implement and verify cleanup on success/error paths or narrow the supported security environment and claims.
- **Acceptance criteria:** The threat model no longer relies on the false public-only classification, and every sensitive CPU/GPU buffer has documented ownership, lifetime, cleanup, and residual-risk treatment.

### REV-6 — Rebuild the performance methodology and heterogeneous baselines
- **Sources:** EIC, R1, R2, R3, DA.
- **Anchor:** §VII.A, lines 309–320; Tables VIII–XII, lines 351–432; §VI.B, lines 306–318; §IX.B, lines 553–561.
- **Problem:** GPU timings lack fully defined host/device boundaries; the batch baseline is sequential despite six CPU cores; only medians from one device are given; managed-memory migrations, synchronization, allocation, thermals, power, and simultaneous CPU/GPU contention are not measured.
- **Minimum remedy:** Define timed regions in pseudocode and report host wall time plus CUDA-event components, cold/warm allocation and migration behavior, synchronization, randomness, CPU preprocessing/postprocessing, and cleanup. Compare optimized 1/2/4/6-core NEON batches, GPU, and concurrent CPU+GPU operation. Report independent runs, distributions/confidence intervals, p50/p95/p99, affinity, clocks, power mode, temperatures, sustained throughput, energy/operation, and profiler evidence.
- **Acceptance criteria:** All headline speedups use complete equivalent operations and the strongest relevant same-platform baseline; raw samples and scripts reproduce reported statistics and crossover points.

### REV-7 — Establish FIPS 203 fidelity and delimit KAT evidence
- **Sources:** R2; R1 methodology concerns; DA.
- **Anchor:** Abstract, lines 14–35; §III.A, lines 87–96; §VII.B, lines 323–346; Conclusion, lines 608–613.
- **Problem:** Equality to an unspecified pq-crystals revision and 100 AES-CTR-DRBG-generated vectors is not by itself FIPS 203 or ACVP validation and cannot cover “all code paths.” Required input checks, implicit rejection, domain separation, error handling, configurations, and negative cases are not mapped.
- **Minimum remedy:** Pin all source revisions; map every implemented API and step to FIPS 203; identify vector provenance and distinguish legacy KAT compatibility from formal validation. Add malformed/noncanonical key and ciphertext cases, implicit rejection, dk-hash consistency, randomness/error behavior, and a coverage matrix for every backend and compile-time option.
- **Acceptance criteria:** Compliance wording exactly matches the evidence, and published vector files, hashes, logs, and negative tests reproduce each stated result.

### REV-8 — Supply a reviewable and reproducible artifact
- **Sources:** EIC, R1, R2, R3, DA.
- **Anchor:** §VII.A/B, lines 309–346; Source Code Availability, lines 642–644.
- **Problem:** “Available upon reasonable request” prevents verification of security-sensitive code, proofs, configurations, and measurements.
- **Minimum remedy:** Archive source, license, immutable commit/tag, dependency revisions, build environment, scripts, raw timings, profiler outputs, test vectors, logs, proof/checking tools, and table-to-command mapping.
- **Acceptance criteria:** A third party can build each backend and reproduce correctness tests, key measurements, range checks, and all revised tables from the documented artifact.

## Suggested revisions

### REV-9 — Rebuild prior work and narrow novelty/superlative claims
- **Sources:** EIC, R2, DA.
- **Anchor:** §II, lines 99–137; Table XIV, lines 488–498; References, lines 653–681.
- Correct the FPGA paper used to support a GPU statement; cover current GPU/CUDA ML-KEM, ARM optimization, masking/shuffling/fault work, and relevant vendor GPU implementations. Bound “first,” “highest performance,” and “most comprehensive” to a documented search and controlled comparisons, or remove them.

### REV-10 — Validate deployment significance
- **Sources:** EIC, R3, DA.
- **Anchor:** §VII.E/H, lines 376–416 and 406–452; §IX.B, lines 553–561.
- Integrate with a real or trace-driven TLS/server workload. Report batch formation, queueing, p95/p99 latency, realistic arrival patterns, concurrent CPU Decaps, routing policy, throughput, and resource contention. Otherwise present deployment examples as hypotheses.

### REV-11 — Correct managed-memory and resource-utilization claims
- **Sources:** EIC, R3, DA.
- **Anchor:** §VI.A–C, lines 253–329; CUDA scaling discussion, lines 447–456.
- Replace “eliminates transfer overhead entirely” with measured wording. Report page faults/migrations, prefetch/advice, cache ownership transitions, registers, spills, shared memory, resident blocks/SM, occupancy, utilization, bandwidth, and end-to-end memory footprint.

### REV-12 — Normalize claim accounting and presentation
- **Sources:** EIC, R2, R3, DA.
- **Anchor:** Abstract and contribution list, lines 14–35 and 70–87; Tables VI/XIX, lines 222–242 and 524–539; Conclusion, lines 599–615.
- Use one security-feature taxonomy; reconcile six versus nine features and “zero cost” versus measured overhead. Separate mitigation, tested resistance, functional conformance, and monitoring. Remove `TEMPLATE` residue, correct typographic errors such as “P6FIPS 203,” and improve dense tables.

## Source-ordered revision roadmap

The immutable checklist is saved separately as `07_revision_roadmap.md`. Its numbering is for source traceability only and does not prescribe a work order.

- [ ] REV-1 — Complete/equivalent ML-KEM GPU operation validation (`must_fix`)
- [ ] REV-2 — Shuffle entropy and SPA-claim correction/evaluation (`must_fix`)
- [ ] REV-3 — Valid NTT fault-check construction and evidence (`must_fix`)
- [ ] REV-4 — Complete lazy-NTT range proofs (`must_fix`)
- [ ] REV-5 — GPU secret-data threat model and cleanup (`must_fix`)
- [ ] REV-6 — Controlled timing, multicore baseline, and statistics (`must_fix`)
- [ ] REV-7 — FIPS/KAT claim and test reconstruction (`must_fix`)
- [ ] REV-8 — Reproducible artifact (`must_fix`)
- [ ] REV-9 — Prior work and novelty framing (`should_fix`)
- [ ] REV-10 — Deployment workload validation (`should_fix`)
- [ ] REV-11 — Managed-memory/resource evidence (`should_fix`)
- [ ] REV-12 — Claim consistency and presentation (`should_fix`)

## Deadline

**Journal-supplied deadline:** NOT PROVIDED. No deadline or duration is inferred.

## Closing

The manuscript contains a potentially publishable heterogeneous cryptographic-engineering contribution, but the revision must be fundamental rather than editorial. Please submit a point-by-point response mapping every REV item to exact revised locations and evidence. The revised manuscript should undergo full technical re-review, especially for operation parity, arithmetic correctness, security claims, and reproducibility.
