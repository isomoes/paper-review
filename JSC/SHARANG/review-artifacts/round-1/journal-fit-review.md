# Journal-Fit Reviewer Report

**Target:** *The Journal of Supercomputing*  
**Assessment status:** `criteria_binding_unavailable`. No formal ReviewCriteriaBindingManifest was supplied. Accordingly, this is a **provisional venue-fit assessment**, not a contract-bound claim that the manuscript satisfies the journal’s criteria. I reviewed the complete 682-line extracted manuscript independently and did not consult other panel reports.

## Summary and provisional venue fit

SHARANG presents an ML-KEM-768 implementation for an NVIDIA Jetson Orin ARM–CUDA platform with three paths: portable scalar C, ARM NEON for latency-sensitive operations, and CUDA batching for throughput. It combines arithmetic and SIMD optimizations with security-hardening mechanisms and reports NIST KAT agreement, primitive timings, KEM timings, and CUDA batch throughput.

The subject is **clearly within the journal’s broad scope**: it addresses heterogeneous architecture, algorithms/programs, performance measurement, and an application of supercomputing techniques to post-quantum cryptography. The strongest journal-facing angle is not simply “an optimized ML-KEM implementation,” but the latency/throughput division between ARM CPU and integrated GPU under unified memory.

Fit is nevertheless only **moderate in the manuscript’s current form**. The paper presently reads more like a platform-specific cryptographic implementation report than a mature supercomputing systems study. Its system-level analysis is limited to one device, the GPU design is largely independent-operation batching with substantial sequential work, comparisons are not controlled, and the literature review does not establish the claimed novelty. The central security wording also exceeds the evidence presented. These issues prevent submission readiness despite good topical fit.

## Genuine strengths

1. **A coherent heterogeneous-use case.** The manuscript clearly distinguishes low-latency CPU work from throughput-oriented GPU work (Introduction, p. 1, lines 31–40 and 47–57; Discussion §IX.B, p. 8, lines 553–561). This is relevant to the journal’s readership.
2. **Concrete implementation detail.** The paper identifies compiler flags, clocks, timing sources, iteration counts, and warm-up procedure (Experimental Evaluation §VII.A, p. 5, lines 309–320), and supplies algorithmic/pseudocode detail rather than reporting only headline numbers.
3. **Multiple correctness checks.** Internal tests, NIST KAT comparisons, and CPU/GPU byte-level comparisons are described (Experimental Evaluation §VII.B, pp. 5–6, lines 323–346).
4. **Useful performance decomposition.** Primitive timings, cycle breakdown, configuration impact, end-to-end KEM timings, batch scaling, and code size are separated in Tables VIII–XIII (pp. 6–7, lines 351–416 and 421–461). This is a sound basis for a stronger systems paper.
5. **Some limitations are candidly acknowledged.** The manuscript notes non-constant-time GPU execution, lack of GPU Decaps, fault-detection limitations, NEON basemul regression, and CUDA utilization limits (pp. 7 and 9, lines 445–456 and 606–630).

## Critical findings

### C1. The novelty claim is not established, and the cited prior-work support is internally incorrect

**Anchor:** Related Work §II.C, p. 2, lines 127–137; Reference [13], p. 10, lines 678–679; cross-implementation discussion, pp. 7–8, lines 463–498.

The paper claims that GPU acceleration of lattice cryptography has been explored mainly on discrete GPUs and that SHARANG is the first heterogeneous CPU–GPU ML-KEM implementation on an integrated SoC. Yet the sole citation attached to this discussion, [13], is titled “NewHope-Simple key exchange on low-cost FPGAs,” not a GPU study. The related-work section contains no adequate survey of GPU Kyber/ML-KEM, CUDA PQC, integrated-GPU cryptography, or heterogeneous CPU–GPU scheduling. Thus the paper’s principal originality claim is presently unsupported and may be incorrectly scoped.

**Minimum remedy:** Replace the current related-work treatment with a current, systematic comparison of GPU/CUDA ML-KEM or Kyber implementations, integrated-memory cryptography, ARM SIMD implementations, and relevant heterogeneous designs. Correct the miscitation. State a narrowly falsifiable novelty claim (platform, operation, batching model, security configuration, and date of search), and add a comparison table separating algorithmic novelty, architecture novelty, security features, hardware, and evaluation conditions. If priority cannot be established, change “first” to a non-priority contribution statement.

### C2. Security-resistance claims materially exceed the evidence presented and dominate the paper’s positioning

**Anchor:** Abstract, p. 1, lines 24–35; contribution list, p. 2, lines 81–86; Security Hardening §V.A, p. 4, lines 222–242; Security Analysis §VIII.D–E, p. 7, lines 426–451; Discussion §IX.C, p. 9, lines 589–597; Conclusion, p. 9, lines 605–615.

“SPA resistance,” “comprehensive security hardening,” and “maintaining the unpredictability property required for SPA resistance” are asserted without trace-based leakage experiments, an adversarial evaluation, or a cited argument showing that a seed deterministically derived from the processed polynomial provides the claimed unpredictability to the relevant attacker. The manuscript itself concedes that shuffling does not resist DPA. KAT equality establishes functional correctness, not side-channel resistance. This is not a request for a full methodology audit; it is a claim/evidence and positioning problem because security hardening is one of the paper’s headline contributions.

There is also a visible accounting inconsistency: the abstract and §V say **six** features (lines 24 and 222), while the contribution list, Table VI, and conclusion say **nine** (lines 84–86, 232–242, and 605).

**Minimum remedy:** Either (a) add an appropriate empirical side-channel/fault evaluation and a defensible attacker model supporting each resistance claim, or (b) consistently reframe the mechanisms as “countermeasures intended to impede SPA/fault attacks,” without claiming demonstrated resistance. Separate functional tests, constant-time coding measures, health monitoring, and experimentally validated attack resistance. Define one stable feature taxonomy and count it consistently throughout.

## Major findings

### M1. The paper does not yet demonstrate enough heterogeneous-systems novelty for this venue

**Anchor:** CUDA Architecture §VI.A, p. 4, lines 253–275; Algorithm 2, p. 5, lines 284–306; CUDA scaling discussion, p. 7, lines 447–456; Discussion §IX.B, p. 8, lines 553–561.

The batch kernel assigns nine threads to matrix generation, after which thread 0 executes the sequential arithmetic pipeline. This appears closer to coarse batching of independent KEM instances than to a deeply heterogeneous or GPU-parallel KEM architecture. CPU and GPU paths are presented as separate modes; there is little evidence of scheduling, overlap, load balancing, CPU/GPU co-execution, memory-coherence behavior, or a runtime policy beyond a measured crossover point.

**Minimum remedy:** Clarify precisely what is heterogeneous about the execution model. Add an architecture diagram and a timeline/dataflow identifying CPU work, GPU work, synchronization, managed-memory migrations, and serialization. Compare against at least (i) optimized CPU batch execution using all six cores and NEON and (ii) a straightforward CUDA one-block-per-operation baseline. Quantify where SHARANG’s design, rather than generic batching, provides gain.

### M2. The performance evidence is too narrow and the headline comparisons are not controlled

**Anchor:** Experimental Methodology §VII.A, p. 5, lines 309–320; Tables XI–XIV, pp. 6–8, lines 364–416, 421–461, and 488–498.

All primary results come from one Jetson device. Only medians are reported, without dispersion. Table XIV mixes measurements from different ARM generations and x86 with approximate values and then draws broad comparative conclusions. The CPU comparator for GPU throughput appears sequential, while the platform has six CPU cores. No power/energy, utilization, memory-bandwidth, thermal-state, or sustained-load data are reported—important measures for an embedded heterogeneous platform. The TLS and server statements are projections from microbenchmarks, not integrated application measurements.

**Minimum remedy:** Report distributions or robust variability measures, benchmark controls, frequency/power mode, thermal management, and reproducible command/configuration details. Add multicore CPU batch baselines and normalize comparisons to identical hardware wherever possible. Ideally include a second Jetson-class configuration or explain the single-platform limitation explicitly. Measure energy per operation and sustained throughput, or narrow the systems-efficiency claims. Label cross-platform numbers as contextual rather than direct evidence of superiority.

### M3. Application significance is asserted rather than demonstrated

**Anchor:** Throughput and Deployment Analysis §VII.E, p. 6, lines 408–416; CUDA throughput §VII.H, pp. 6–7, lines 406–416 and 421–452; Discussion §IX.B, p. 8, lines 553–561.

The manuscript invokes TLS handshakes, concurrent connections, server key rotation, and certificate pre-computation, but does not integrate SHARANG into TLS or evaluate arrival patterns, queueing latency, batching delay, concurrent CPU Decaps, or end-to-end server throughput. A batch crossover at N≈32 does not by itself show benefit under realistic latency constraints.

**Minimum remedy:** Add at least one end-to-end or trace-driven workload evaluation. Report throughput and tail latency as batch size/timeout changes, and demonstrate how requests are accumulated and dispatched. If this is outside scope, remove application-level performance conclusions and present them explicitly as prospective use cases.

### M4. Reproducibility and artifact availability are below current systems-paper expectations

**Anchor:** Source Code Availability, p. 10, lines 642–644; build description, pp. 7–8, lines 457–465; correctness claims, p. 5, lines 323–346.

“Available from the corresponding author upon reasonable request” does not permit reviewers or readers to reproduce the many implementation, performance, and security-feature claims. The paper also lacks a commit identifier, scripts, raw measurements, test vectors/output logs, and exact build configurations for each table.

**Minimum remedy:** Provide an anonymized archival artifact or public repository at review time, with a commit/tag, license, build instructions, benchmark scripts, KAT procedure, raw timing data, and mapping from each table to a command/configuration. If release is impossible, explain the concrete restriction and substantially narrow reproducibility claims.

### M5. Contribution accounting and headline statements are inconsistent

**Anchor:** Abstract, p. 1, lines 18–35; contribution list, p. 2, lines 70–87; Table XIX, p. 8, lines 524–540; Conclusion, p. 9, lines 599–615.

Examples include “six security hardening features” versus nine; “zero measurable runtime cost” versus total overhead “<5 µs”; “10–22%” versus “5–21%” end-to-end speedup descriptions; and “highest performance with the most comprehensive security hardening” despite uncontrolled comparisons. These discrepancies make it difficult to determine the actual contribution and weaken editorial confidence.

**Minimum remedy:** Create a single claim ledger before resubmission: each abstract/conclusion claim should map to one table/experiment, configuration, comparator, and scope limitation. Use one feature taxonomy and distinguish primitive speedup, end-to-end speedup, throughput speedup, and overhead.

## Minor findings

1. **Submission formatting is visibly unfinished.** Every extracted page begins with “TEMPLATE” (e.g., pp. 1–10, lines 1, 66, 138, 207, 280, 347, 417, 484, 562, 638), and the paper uses an IEEE-like layout rather than an obviously journal-ready Springer format. Remove template residue and conform to the target venue’s current instructions.
2. **Several projections are presented too prominently.** Table XXII extrapolates ML-KEM-512/1024 from operation counts rather than measurements (Discussion §IX.A, pp. 7–9, lines 478–483 and 578–586). Keep these explicitly labeled as modeled estimates and avoid performance conclusions until measured.
3. **Copyediting is required.** Examples include “speedup of 1.75× speedup” (§VII.C, p. 6, lines 384–388) and “P6FIPS 203” (§VIII.D, p. 7, lines 429–432). Several tables are visually dense or corrupted in extraction, especially Tables VI, XVII, and XVIII (pp. 4, 7–8, lines 225–242 and 502–540); check final rendering and accessibility.
4. **Bibliographic depth and quality are insufficient.** Fourteen references are too few for claims spanning ML-KEM optimization, ARM SIMD, CUDA, side channels, fault attacks, entropy monitoring, and TLS deployment. Several entries are bare project URLs rather than versioned releases or archival sources (References, p. 10, lines 653–681).
5. **Some broad contextual comparisons distract from the core contribution.** Tables XV, XVI, and XXI compare unrelated signature/KEM categories or projected protocol costs (pp. 8–9, lines 502–520 and 566–575). Space would be better used for direct ML-KEM GPU/system competitors and controlled baselines.

## Questions to the authors

1. What exact literature search supports the “first” integrated-SoC heterogeneous ML-KEM claim, and why is an FPGA NewHope paper cited as the GPU prior-art source?
2. What attacker knowledge and observation model makes the polynomial-derived shuffle seed unpredictable, and what measured evidence supports “SPA resistance” rather than merely shuffled execution?
3. Are CPU batch figures single-core or multicore? How does CUDA compare with six-core NEON batch processing under equal power and latency constraints?
4. Does managed memory incur page migrations during measured kernels, and were buffers prefetched or resident? Please provide a CPU/GPU execution and memory timeline.
5. How would a server form batches of 32–512 requests without introducing unacceptable queueing/tail latency, and can this be demonstrated in an actual or trace-driven TLS workload?
6. Which six versus nine mechanisms are intended to count as distinct “security features,” and which are always enabled in every number reported?
7. Will the full source, scripts, raw benchmark data, and exact tested revision be made available for review and publication?

## Recommendation: **Major Revision**

The manuscript is topically suitable for *The Journal of Supercomputing* and contains a potentially publishable ARM–CUDA implementation with useful measured results. It is not submission-ready, however. The minimum publishable revision must repair the prior-art/novelty foundation, bring security language into line with evidence, strengthen the heterogeneous-systems analysis and controlled baselines, validate or narrow the application claims, and provide a reproducible artifact. If the claimed priority or security-resistance claims cannot be substantiated, substantial reframing—not merely copyediting—will be required.
