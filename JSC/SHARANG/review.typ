#import "@preview/basic-document-props:0.1.0": simple-page

// Document configuration
#let document-author = "isomoes"
#let paper-title = "SHARANG: A Heterogeneous CPU–GPU Accelerated, Security-Hardened ML-KEM-768 Implementation for ARM–CUDA Platforms"
#let manuscript-id = "Not provided"

#set document(title: paper-title, author: document-author, date: datetime.today())
#set page(numbering: "1", number-align: center, margin: (x: 2.2cm, y: 1.6cm))
#set text(size: 10.5pt)
#set par(justify: true, leading: 0.68em)
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")
#show cite: set text(fill: blue)
#show figure.where(kind: table): it => [#it.caption #it.body]

#let redt(content) = text(fill: red, content)
#let bluet(content) = text(fill: blue, content)
#let greent(content) = text(fill: green, content)
#let oranget(content) = text(fill: orange, content)
#let grayt(content) = text(fill: gray, content)

#let score-box(title, score, max-score: 10) = rect(
  width: 100%, stroke: 1pt, inset: 8pt, fill: luma(250),
  [#text(weight: "bold")[#title: ] #text(fill: blue, weight: "bold")[#score/#max-score]],
)

#let comment-box(title, content) = rect(
  width: 100%, stroke: 1pt, inset: 10pt,
  [#text(weight: "bold", size: 11pt)[#title] #v(0.5em) #content],
)

#align(center)[
  #text(size: 18pt, weight: "bold")[Academic Paper Review Report]
  #v(0.5em)
  #text(size: 12pt)[Reviewer: #document-author \
  Review Date: #datetime.today().display("[year]-[month]-[day]")]
]

#v(1em)
#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]
  #v(0.5em)
  #grid(
    columns: (auto, 1fr), gutter: 1em, row-gutter: 0.35em,
    [*Paper Title:*], [#paper-title],
    [*Manuscript ID:*], [#manuscript-id],
    [*Journal:*], [The Journal of Supercomputing],
    [*Review Round:*], [Initial full review],
    [*Recommendation:*], [#redt[*Major Revision*]],
  )
])

= Review Summary

The manuscript presents SHARANG, a three-tier ML-KEM-768 implementation for NVIDIA Jetson Orin: portable scalar C, ARM NEON for low-latency execution, and CUDA for batched throughput. It combines lazy-reduction NTT arithmetic, SIMD kernels, system-level optimization, functional testing, and proposed side-channel and fault countermeasures. The latency-oriented CPU and throughput-oriented GPU split is relevant to heterogeneous high-performance computing, and the manuscript contains useful implementation and timing detail.

The current evidence does not support several headline claims. The CUDA “KeyGen” pseudocode appears to output a 1,152-byte K-PKE secret object rather than the complete 2,400-byte ML-KEM-768 decapsulation key. The deterministic 32-bit shuffle cannot realize the claimed more-than-1,000-bit entropy, and no leakage experiment establishes SPA resistance. The ordinary-sum NTT fault invariant appears false as written, while the lazy-NTT range proof does not cover all operations and backend semantics. The GPU threat model also treats secret-bearing KeyGen and Encaps as public-only operations. Undefined CUDA timing boundaries, an inadequate sequential CPU baseline, absent statistical uncertainty, and unavailable artifacts further prevent verification. I therefore recommend *Major Revision with full technical re-review*.

The main required revisions are:

+ Demonstrate complete and semantically equivalent CPU/GPU ML-KEM operations, including full KeyGen output construction and all host/device work.
+ Correct or withdraw the shuffle-entropy, unpredictability, zero-cost-security, and SPA-resistance claims; add a defensible attacker model and leakage evidence if resistance is retained.
+ Prove or replace the NTT fault-detection checksum and reconstruct executable lazy-NTT range bounds for scalar, NEON, and CUDA code.
+ Correct the GPU secret-data threat model and document sensitive-data residency, lifetime, cleanup, and residual risks.
+ Rebuild the benchmark methodology with synchronized timing, tuned multicore CPU baselines, statistical distributions, managed-memory accounting, energy/thermal controls, and mixed CPU/GPU workloads.
+ Establish the precise scope of FIPS 203/KAT evidence and release a complete reproducibility artifact.

#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.6em, row-gutter: 0.5em,
  score-box("Innovation", 6), score-box("Technical Quality", 3),
  score-box("Validation", 3), score-box("Reproducibility", 2),
  score-box("Writing Quality", 5), score-box("Overall", 4),
)

= Detailed Review

== Innovation Assessment

#score-box("Innovation Assessment", 6)

The strongest contribution is the proposed division between latency-sensitive NEON execution and throughput-oriented GPU batching on an integrated ARM–CUDA SoC. The paper also offers a potentially useful combination of lazy reduction, SIMD arithmetic, system-level profiling, and security-oriented implementation mechanisms. Primitive, end-to-end, configuration, batch-scaling, and code-size results provide a substantive starting point.

#comment-box("Assessment", [
  The contribution is potentially publishable as a heterogeneous cryptographic-systems study, but the present novelty case is not established. Section II.C cites an FPGA NewHope paper as evidence about prior GPU lattice cryptography, and the survey does not adequately cover current GPU/CUDA ML-KEM, integrated-memory cryptography, or optimized ARM implementations. The claims “first,” “highest performance,” and “most comprehensive” require a dated systematic search and controlled comparisons; otherwise they should be removed or narrowly bounded.
])

== Technical Quality Assessment

#score-box("Technical Quality Assessment", 3)

#comment-box("Major Comment 1 — Complete ML-KEM GPU KeyGen", [
  Table I states that ML-KEM-768 has a 2,400-byte secret/decapsulation key, while Algorithm 2 outputs `sk[N][1152]` and describes only PKE-style secret/public-key generation. It does not show complete decapsulation-key construction, including all required randomness and stored fields.

  *Consequence:* the reported 6.6 ms and 3.1× CUDA “KeyGen” result may compare incomplete K-PKE work against complete CPU ML-KEM KeyGen, invalidating the central performance claim.

  *Required action:* publish the exact call graph and code; implement and time complete FIPS 203 KeyGen, including full output construction, hashes, synchronization, memory movement, and cleanup. If the existing kernel is K-PKE-only, relabel all affected results and remove comparisons with full ML-KEM KeyGen.
])

#v(0.6em)
#comment-box("Major Comment 2 — Shuffle entropy and SPA resistance", [
  The abstract, Section V.A, Section VIII.D, Section IX.C, and the conclusion claim that a polynomial-derived `xorshift32` schedule provides more than 1,000 bits of entropy and zero-cost SPA resistance. A deterministic 32-bit generator has at most 32 bits of state and no fresh entropy once its polynomial input is fixed. Public, chosen, repeated, or recoverable inputs may make the schedule predictable; secret-derived scheduling may itself leak through control flow or memory behavior. No physical leakage experiment is reported.

  *Required action:* remove the more-than-1,000-bit, unpredictability, SPA-resistance, and zero-cost-security claims unless supported. Specify the secrecy/control of every seed input, the seed-to-permutation mapping, bias and collisions, and repeated/chosen-input behavior. If unpredictability is required, use independent cryptographic randomness and measure its cost. Add reproducible power/EM evaluation under an explicit attacker model.
])

#v(0.6em)
#comment-box("Major Comment 3 — NTT fault-detection invariant", [
  Section V.B asserts that the ordinary coefficient sum is invariant under the NTT. For the stated butterfly, $(a + zeta b) + (a - zeta b) = 2a$, not generally $a+b$. The claimed $1 - 1/q$ detection probability also lacks a defined fault distribution, injection point, protected checker, and response model.

  *Required action:* provide exact transform-specific checksum equations and a proof tied to the implementation, or replace the mechanism with a valid weighted checksum, residue code, or redundant computation. Define the fault model and report reproducible injection coverage, false positives, false negatives, and failure handling.
])

#v(0.6em)
#comment-box("Major Comment 4 — Lazy-NTT range proof", [
  Theorems 1–2 do not fully incorporate multiplicand-dependent Montgomery bounds, unreduced Gentleman–Sande additions, centered twiddle/input ranges, narrowing, signedness, inverse scaling, or scalar/NEON/CUDA language semantics.

  *Consequence:* signed overflow, narrowing loss, undefined behavior, or backend-specific correctness gaps remain unresolved despite the “formal proof” wording.

  *Required action:* provide per-layer interval bounds for every branch, multiplication, cast, narrowing step, and backend. Supply a machine-checkable or exhaustive bounded verification, sanitizer results, and edge-case differential tests.
])

#v(0.6em)
#comment-box("Major Comment 5 — GPU threat model and secret-data lifecycle", [
  Section VI.D calls GPU KeyGen and Encaps “public-key operations.” KeyGen handles secret noise and creates a long-lived decapsulation key; Encaps handles ephemeral secret material and shared-secret-related state. CPU stack wiping does not cover managed/device memory, registers, shared memory, caches, driver state, co-residency, DMA, remanence, or error paths.

  *Required action:* add operation-level dataflow and lifetime diagrams, classify every sensitive value and memory location, and define co-tenancy, privileged-software, physical-observer, and remanence assumptions. Implement and verify cleanup on all success/error paths, or narrow the supported environment and claims.
])

== Experimental and Validation Assessment

#score-box("Experimental and Validation Assessment", 3)

The manuscript usefully reports primitive timings, end-to-end KEM timings, a component breakdown, configuration effects, batch scaling, and code size. It also reports internal tests, 100 deterministic vectors, and CPU/GPU bytewise comparisons. Several percentage calculations are internally consistent, and negative results such as the NEON basemul regression are disclosed. These are useful foundations, but the current benchmark and validation boundaries are not auditable.

#comment-box("Major Comment 6 — Timing boundaries and fair baselines", [
  Section VII.A names `CLOCK_MONOTONIC` for GPU benchmarks but does not state where CUDA synchronization occurs or whether allocation, managed-memory migration, RNG, CPU-side Encaps hashing, result access, verification, and cleanup are included. CUDA launches are asynchronous. Table XII also appears to compare the whole GPU against one sequential CPU core on a six-core platform, and its CPU per-operation values do not clearly match Table XI.

  *Required action:* publish timed-region pseudocode. Report synchronized end-to-end host wall time and CUDA-event components, cold/warm allocation and migration behavior, all host work, and cleanup. Compare equivalent scalar, 1/2/4/6-core NEON, GPU, and concurrent CPU+GPU paths. Recompute every speedup and crossover against the strongest relevant same-platform baseline.
])

#v(0.6em)
#comment-box("Major Comment 7 — Statistical, resource, and deployment evidence", [
  Only medians from one board are reported, without run-level replication, distributions, confidence intervals, affinity, complete clock/power configuration, thermal state, energy, or sustained-load behavior. Decimal “median ticks” are also unexplained for an integer timer counter. Unified-memory and GPU-saturation explanations lack page-migration and occupancy evidence. TLS/server conclusions are arithmetic projections rather than application measurements.

  *Required action:* report independent-run distributions and confidence intervals, p50/p95/p99 latency, exact timer estimator, CPU/GPU/EMC clocks, power mode, affinity, thermals, sustained throughput, energy per operation, and Nsight resource/migration metrics. Add a real or trace-driven workload with batching delay, queueing, mixed CPU Decaps/GPU work, and tail latency, or label deployment claims as prospective.
])

#v(0.6em)
#comment-box("Major Comment 8 — FIPS/KAT scope and reproducibility", [
  Equality with an unspecified pq-crystals revision and 100 generated vectors does not by itself establish complete FIPS 203 or ACVP validation, nor can ordinary KATs cover all configurations, malformed inputs, and implicit-rejection paths. Source is available only upon request, so the implementation and timings cannot be audited.

  *Required action:* pin all revisions, map APIs and steps to FIPS 203, identify and hash the vector corpus, distinguish compatibility testing from formal validation, and add malformed/noncanonical input, implicit-rejection, consistency, randomness-failure, and backend/configuration coverage. Release an archival artifact containing source, license, dependencies, build/run scripts, raw data, analysis code, vectors/logs, proofs/checkers, profiler outputs, and a table-to-command map.
])

#v(0.6em)
#comment-box("Ablation boundary", [
  The reported end-to-end improvement combines replacement of an inefficient file-based RNG path, adoption of an unrolled Keccak implementation, lazy reduction, NEON kernels, compression changes, and security mechanisms. Table X does not isolate these contributions, and Karatsuba is advertised without a corresponding headline benchmark. Add a controlled ablation from one well-optimized baseline and report interactions and uncertainty for every claimed contribution.
])

== Writing Quality Assessment

#score-box("Writing Quality Assessment", 5)

The manuscript has a clear high-level organization and generally communicates the three implementation tiers effectively. However, several presentation and claim-consistency problems obscure the technical contribution:

- The abstract and Section V refer to six security features, whereas the contribution list, Table VI, and conclusion count nine. Use one taxonomy and separate coding practices, monitoring, candidate mitigations, functional tests, and validated resistance.
- “Zero measurable runtime cost” conflicts with Table X's 69 µs versus 73 µs NEON KeyGen values and Table XIX's nonzero wiping/total overhead. Use statistically bounded, configuration-specific wording.
- The Introduction incorrectly states that RFC 9794 standardized ML-KEM for TLS 1.3. RFC 9794 defines hybrid-scheme terminology; cite and describe the applicable TLS specification accurately.
- `cntvct_el0` values should be called timer counts, not CPU cycles. Explain how decimal medians arise from integer counter differences and correct inconsistent speedup ratios.
- Qualify the statement that unified memory eliminates transfer overhead; shared physical DRAM does not remove page migration, cache ownership, coherence, or synchronization costs.
- Clearly label ML-KEM-512/1024 timings, discrete-GPU crossover, 32-thread-kernel gains, and NEON Keccak gains as unvalidated projections.
- Remove all `TEMPLATE` headers, correct “speedup of 1.75× speedup” and “P6FIPS 203,” and redesign dense or malformed Tables VI, XVII, and XVIII.

== Questions for Authors

+ Does CUDA KeyGen return a 1,152-byte K-PKE secret object or the complete 2,400-byte ML-KEM decapsulation key? Where are the remaining fields generated and timed?
+ For each shuffled NTT invocation, are the seed coefficients public, attacker-controlled, ephemeral-secret, or long-term-secret dependent? Can identical inputs reproduce a schedule?
+ What exact checksum is compared before and after the NTT, and how is its invariance derived for one twiddled butterfly?
+ Is an explicit CUDA synchronization inside every Table XII timing interval? Which allocation, migration, RNG, host hashing, and cleanup operations are included?
+ Which CPU implementation produces Table XII's baseline, and how does a pinned six-core NEON thread pool compare over the same complete operations?
+ Which FIPS 203 revision, reference commit, vector files, and hashes were used, and which negative and implicit-rejection cases were tested?
+ Will the complete source, benchmark harness, raw measurements, proof/checking scripts, profiler traces, and security-test artifacts be archived for review?

= Final Recommendation

#rect(width: 100%, stroke: 1.2pt + red, inset: 12pt, fill: rgb("fff5f5"), [
  #align(center)[#text(size: 15pt, weight: "bold", fill: red)[MAJOR REVISION]]
  #v(0.5em)
  The heterogeneous implementation direction is potentially publishable, but acceptance is premature until complete ML-KEM operation parity is demonstrated, the arithmetic and fault constructions are corrected, security claims are either validated or withdrawn, and the performance evidence becomes fair and reproducible. The revised manuscript should undergo full technical re-review.
])

= Confidential Comments to Editor

The topic is provisionally relevant to _The Journal of Supercomputing_, particularly as a heterogeneous systems and performance-evaluation contribution. The present manuscript, however, overweights unvalidated security feature counts and may benchmark incomplete GPU KeyGen work. These issues are fundamental rather than editorial. Major Revision is justified only if the venue permits a substantially rebuilt implementation, proof, artifact, and evaluation; failure to establish operation equivalence or mathematical validity should lead to rejection or resubmission as a narrower systems prototype.
