## Cross-Disciplinary Perspective Review — heterogeneous embedded/HPC deployment

**Manuscript:** “SHARANG: A Heterogeneous CPU–GPU Accelerated, Security-Hardened ML-KEM-768 Implementation for ARM–CUDA Platforms”  
**Target named by caller:** *The Journal of Supercomputing*  
**Disclosure:** `criteria_binding_unavailable`. No resolved ReviewCriteriaBindingManifest or Target Criteria Brief was supplied; therefore I make **no formal venue-alignment claim**. The recommendation below concerns scientific/deployment readiness, not criterion-bound journal fit. I read the complete 682-line manuscript independently and did not consult peer outputs.

### Summary
SHARANG combines a portable scalar implementation, ARM NEON acceleration, and CUDA batching for ML-KEM-768 on a Jetson Orin Nano. The manuscript reports good single-operation CPU latency and up to 3.1× GPU batch throughput relative to a sequential CPU baseline, while proposing lazy NTT reduction and several hardening mechanisms. The heterogeneous premise is relevant, but the current evidence is principally implementation microbenchmarking on one board. The paper does not yet establish a deployable CPU–GPU service: it lacks a realistic concurrent TLS/server experiment, multicore CPU baselines, queueing/latency analysis, simultaneous CPU/GPU operation, energy/thermal measurements, managed-memory migration accounting, and hardware-utilization evidence. More seriously, it calls CUDA KeyGen and Encaps “public-key operations” even though both manipulate sensitive material, and its deterministic 32-bit xorshift shuffle cannot support the claimed >1000 bits of entropy or demonstrated SPA resistance.

### Strengths
1. **Clear heterogeneous intent.** The division between latency-oriented NEON and throughput-oriented CUDA is stated explicitly (Section IX.B, lines 553–561), and batch results span N=32–512 (Table XII, lines 421–432).
2. **End-to-end CPU KEM timings, not only NTT kernels.** Table XI reports KeyGen, Encaps, and Decaps (lines 364–372), and Table IX attempts an Encaps component breakdown (lines 365–405).
3. **Useful systems profiling lesson.** Replacing per-call `/dev/urandom` open/read/close and adopting unrolled Keccak materially improve end-to-end latency (Section IV.E, lines 177–206; Table IV, lines 211–220).
4. **GPU limitation is partly acknowledged.** The paper notes non-constant-time GPU execution, absence of GPU Decaps, low thread utilization, and CPU-side hashing in Encaps (lines 335–339, 447–456, 608–630).
5. **Correctness checks cover several paths and batch sizes.** KAT and CPU/GPU byte comparisons are described (Section VII.B, lines 323–346).

## Critical findings

### C1. The GPU threat model incorrectly classifies KeyGen and Encaps as non-secret/public-only
**Anchor:** Section VI.D states that CUDA is restricted to “KeyGen and Encaps (public-key operations)” and that only Decaps handles secret keys (lines 335–339). Yet Algorithm 2 samples secret/noise polynomials `s,e`, forms `ŝ`, and writes `sk` (lines 284–305). Encaps also generates secret randomness and a shared secret; Section IX.D acknowledges CPU/GPU partitioning of Encaps hashing (lines 608–620). Managed buffers are accessible by CPU and GPU (lines 306–314).

**Why critical:** The security boundary underlying the GPU deployment is false. KeyGen puts long-lived secret-key material and coins/intermediates on the GPU and in unified memory; Encaps handles ephemeral secret material/shared-secret derivation. GPU cache/register residue, managed-memory lifetime, concurrent-process isolation, DMA/peripheral access, debugger/profiler exposure, and zeroization of device/global/managed buffers are not assessed. CPU stack wiping (Table V, lines 211–220) does not establish GPU-side erasure.

**Minimum remedy:** Redraw the threat model and dataflow for each operation, classifying every sensitive value and its CPU/GPU/managed-memory residency and lifetime. Add device/managed-buffer zeroization and verify it against compiler optimization; specify CUDA context/process isolation and error-path cleanup. Evaluate or explicitly exclude GPU side-channel, co-residency, remanence, DMA, and privileged-attacker threats. Remove the “public-key operations” rationale unless a redesigned GPU path demonstrably never handles sensitive material.

### C2. The central shuffled-NTT security and entropy claims are unsupported and internally impossible
**Anchor:** The shuffle uses a polynomial-derived seed and `xorshift32` (Section V.A, lines 234–242); Section VIII.D claims `sum log2(l!) > 1000 bits of entropy` and infeasible SPA correlation (lines 433–436); Section IX.C says deriving the seed from coefficients retains the unpredictability required for SPA resistance (lines 589–597). The abstract/conclusion call this “zero-cost SPA resistance” (lines 24–30; 608–615).

**Why critical:** A deterministic 32-bit PRNG has at most 32 bits of seed entropy, regardless of the size of the permutation space. Data already known or chosen by an attacker yields a predictable schedule; data depending on secrets may instead make schedule observations a leakage channel. No leakage model, trace experiment, TVLA, mutual-information/test-vector leakage assessment, or attack reproduction is provided. Shuffling alone generally misaligns traces; it does not prove SPA resistance.

**Minimum remedy:** Withdraw the entropy and resistance claims or supply a formal leakage argument plus physical measurements on the target. State whether seed inputs are public, attacker-controlled, or secret for every NTT call. Use an approved independent per-operation random source/DRBG if unpredictability is required, account for its cost, and quantify security with enough traces and a stated attacker model. Report only the actual seed entropy (at most 32 bits for the present generator).

## Major findings

### M1. The GPU speedup and crossover use an inadequate CPU baseline
**Anchor:** Table XII compares CUDA against sequential CPU batch times (lines 421–432), while the platform has six Cortex-A78AE cores (lines 310–320). The paper then declares a crossover near N≈32 and 38,800 KeyGen/s versus 12,600 CPU/s (lines 406–416), and uses that result for server deployment claims (lines 376–380, 553–561).

**Concern:** An embarrassingly parallel batch should be compared with a tuned multicore CPU implementation (1–6 cores, affinity-controlled), not one sequential core. At the reported 73 µs CPU KeyGen, ideal six-core throughput is already approximately 82k/s before scaling losses, potentially exceeding the GPU result. The chosen baseline can reverse both the speedup and crossover conclusions.

**Minimum remedy:** Benchmark optimized thread-pool CPU batches at 1, 2, 4, and 6 cores, with affinity and scheduling documented; compare throughput, p50/p95/p99 latency, and energy. Recompute the crossover against the best CPU configuration and against concurrent CPU+GPU execution.

### M2. “Unified memory eliminates transfer overhead entirely” is not measured
**Anchor:** The claim appears in the introduction/background (lines 36–40, 109–117) and Section VI.B (lines 277–314). The paper notes ~500 µs `cudaMallocManaged` cost and persistent/batch allocation but does not define whether allocation, first-touch page migration, synchronization, CPU preprocessing, output consumption, or cache-coherence costs are included (lines 306–318).

**Concern:** Shared physical DRAM avoids PCIe copies but does not eliminate CPU↔GPU ownership transitions, managed-memory page faults/migrations, cache maintenance, or synchronization. `CLOCK_MONOTONIC` host timing alone does not reveal the timed region.

**Minimum remedy:** Define end-to-end timing boundaries with pseudocode; report cold and warm runs, allocation included/excluded, CUDA events plus host wall time, all synchronizations, prefetch/advice policy, page-fault/migration counters, and CPU preprocessing/postprocessing. Replace “eliminates entirely” with a measured, qualified claim.

### M3. No realistic TLS/server workload validates the proposed CPU–GPU partition
**Anchor:** TLS deployment is inferred from arithmetic sums and byte sizes (Section VII.E, lines 408–416 and 376–385); the proposed use cases are “server key rotation” and “certificate pre-computation” (lines 553–561). No TLS stack is integrated.

**Concern:** There is no OpenSSL/BoringSSL/wolfSSL integration, network I/O, certificate processing, hybrid negotiation, batching queue, request-arrival distribution, timeout policy, or tail latency. Batch formation can add more latency than the 5–21% CPU gains, and realistic servers require Decaps, which remains CPU-only. It is unclear whether per-connection KeyGen batches match the targeted TLS protocol flow.

**Minimum remedy:** Integrate SHARANG into a real TLS 1.3 server/client path and specify protocol roles. Benchmark closed-loop and open-loop workloads over realistic concurrency and arrival rates; report handshakes/s, p50/p95/p99 latency, batch-wait time, CPU utilization, and response under burst/low-load conditions. Compare CPU-only, GPU-only where applicable, and adaptive heterogeneous scheduling.

### M4. The paper does not evaluate simultaneous heterogeneous operation or resource contention
**Anchor:** The architecture says CPU serves latency-sensitive work while GPU serves batches (lines 31–38, 553–561), but tables report paths separately. Encaps already mixes CPU-side hashing with GPU work (lines 410–414, 608–620).

**Concern:** On an SoC, CPU and GPU contend for unified DRAM, memory controller bandwidth, power/thermal budget, and possibly caches. The manuscript never runs CPU Decaps/TLS work concurrently with GPU batches or measures overlap and interference. Thus the defining “heterogeneous” system contribution is untested.

**Minimum remedy:** Run mixed workloads with CPU Decaps and GPU KeyGen/Encaps concurrently; sweep CPU/GPU load ratios and batch sizes. Report achieved overlap, memory bandwidth, CPU/GPU utilization, interference, latency tails, throughput, and an explicit routing/batching policy.

### M5. Resource-utilization and saturation explanations are not credible without profiler evidence
**Anchor:** Each block uses only 9 active threads while thread 0 executes most of the sequential KEM pipeline, with ~22 KB shared memory (lines 262–275). The paper attributes scaling regimes to launch/allocation overhead and a nominal 12,288-thread capacity, and says the 8-SM GPU approaches saturation above N=128 (lines 447–456).

**Concern:** Occupancy is governed by blocks/SM, shared memory, registers, warp allocation, and spills—not simply 9N versus a maximum thread count. Nine-thread blocks consume at least one 32-thread warp, while 22 KB shared memory may restrict resident blocks. The asserted saturation mechanism conflicts with the nominal N=1,365 thread-capacity calculation and lacks achieved-occupancy/SM data.

**Minimum remedy:** Provide Nsight Compute/Systems results: registers/thread, spills/local memory, shared memory/block, resident blocks/SM, achieved occupancy, active warps, SM utilization, memory bandwidth, cache hit rates, kernel timeline, and launch counts. Correct the saturation model and compare 9-thread design with at least one warp-cooperative variant or explain why not.

### M6. Energy, thermal behavior, and clocks are absent despite an embedded-deployment framing
**Anchor:** Methodology fixes GPU clock at 1020 MHz but reports no CPU frequency, nvpmodel/power mode, cooling, temperature, throttling, or power (lines 310–320). Embedded/edge/vehicle motivation is central (lines 14–23, 109–117).

**Concern:** Throughput on Jetson is strongly power-mode and thermal-state dependent. GPU acceleration may reduce latency yet consume more joules, and sustained batches may throttle or steal power budget from CPU/network workloads.

**Minimum remedy:** Report board power mode, CPU/GPU/EMC frequencies, governor, fan/cooling, ambient and steady-state temperatures. Measure idle-subtracted energy per operation and sustained throughput/W for CPU, multicore CPU, GPU, and mixed operation over sufficiently long runs, including throttling behavior.

### M7. Memory reporting is insufficient for an integrated-memory system
**Anchor:** The manuscript reports 7.6 GB DRAM, ~22 KB shared memory/block, constant tables, and text size (lines 273–275, 309–329; Table XIII, lines 434–444), but no end-to-end memory footprint.

**Concern:** There is no peak host/device/managed allocation by batch size, bytes/op, pinned or pageable storage, page residency, device-stack/local-memory use, register spills, memory-bandwidth use, fragmentation, or coexistence cost with a TLS server. Secret-buffer lifetime is also omitted.

**Minimum remedy:** Add a memory-accounting table for N=1–512 and each pipeline stage, including peak managed/global/shared/local/register usage, allocation lifetime, page residency/migration, and security-sensitive buffers. Report feasible batch sizes under realistic co-resident application memory pressure.

### M8. Generalizability and reproducibility are overclaimed from one board and projected data
**Anchor:** All measurements use one Jetson Orin Nano configuration (lines 310–320); ML-KEM-512/1024 results are projections (lines 478–483, 579–586); discrete-GPU behavior is analytically asserted (lines 277–308, 555–561); code is only “available … upon reasonable request” (lines 642–644).

**Concern:** “ARM–CUDA platforms” spans materially different CPU cores, SM counts, memory systems, JetPack/CUDA versions, power envelopes, and discrete versus integrated memory. Operation-count scaling does not capture occupancy, memory, or parameter-dependent effects. The absence of an artifact blocks reproduction of unusual security and performance claims.

**Minimum remedy:** Evaluate at least one additional Jetson generation/power envelope and, if discussing discrete GPUs, measure one. Clearly bound claims to Orin Nano where evidence is unavailable. Measure rather than project other ML-KEM parameter sets. Release buildable source, benchmark scripts, flags/commits, raw timings, and profiler traces, subject to journal artifact policy.

### M9. End-to-end practical value is not separated from borrowed/system fixes and kernel gains
**Anchor:** KeyGen falls from 240 to 73 µs largely after adopting unrolled public-domain Keccak and replacing `fopen/fread/fclose` with `getrandom` (Table IV, lines 177–220). Against pq-crystals, the final NEON end-to-end advantage is only 5–21% (Table XI, lines 364–372), while several primitive speedups do not dominate end-to-end time and basemul regresses (lines 351–405).

**Concern:** The manuscript blends novel arithmetic, NEON work, borrowed Keccak, removal of an avoidable RNG implementation pathology, and security flags into a single system narrative. The practical incremental value of each novel contribution is therefore unclear.

**Minimum remedy:** Provide a controlled ablation from the same well-optimized baseline: reference+`getrandom`+same Keccak, then lazy reduction, NEON components, compression, and each hardening feature. Report end-to-end latency/throughput and confidence intervals for every step, not only primitive ratios.

## Minor findings

1. **Statistical reporting:** Only medians of 2,000 iterations are given (lines 310–320). Report distributions/CI, run-to-run variation, outliers, and independent process/boot repetitions; 31.25 MHz timer resolution should be discussed for short primitives.
2. **Crossover evidence:** Table XII begins at N=32 although the text discusses N<8 and claims N≈32 (lines 406–416, 421–452). Add N=1,2,4,8,16,24 and identify cold/warm crossover separately.
3. **Configuration accounting:** The abstract says six hardening features (lines 23–30), the contribution list and conclusion say nine (lines 84–86, 603–607), while Section V again says six (lines 222–230). Define feature counting consistently and distinguish defenses, baseline coding practices, monitoring, and compliance tests.
4. **Cross-platform comparison:** Table XIV compares timings across A78AE, A72, generic ARM, and x86 Skylake (lines 488–498) without controlling compilers, clocks, versions, or measurement methods. Label these contextual, not direct performance comparisons.
5. **Projected future gains:** Claims of ~2× from 32-thread blocks and 1.5–2× NEON Keccak (lines 627–635) are speculative; mark them as hypotheses or support them with prototypes/modeling.

## Questions for the authors
1. Exactly which KeyGen and Encaps buffers reside in registers, shared, global, and managed memory, and how are coins, secret polynomials, secret keys, and shared secrets erased on success and every error path?
2. Why is KeyGen called a “public-key operation” when Algorithm 2 creates and stores `sk`, `s`, and `e` on the GPU?
3. For each shuffled NTT invocation, are the seed coefficients public, attacker-controlled, ephemeral-secret, or long-term-secret dependent? What empirical evidence shows reduced exploitable leakage rather than trace misalignment only?
4. What is included in every Table XII GPU timing: allocation, randomness generation, host hashes, first touch/page migration, kernel launch, synchronization, result copy/access, and cleanup?
5. How does a six-core CPU thread-pool compare at N=32–512, and what is the crossover against that baseline?
6. Can CPU Decaps execute concurrently with GPU KeyGen/Encaps without shared-memory-bandwidth or thermal interference? What routing policy chooses CPU versus GPU under low load and bursts?
7. What real TLS 1.3 message flow requires the claimed KeyGen batches, and what batching delay is acceptable before tail handshake latency outweighs throughput gains?
8. What are the board power mode, CPU/GPU/EMC clocks, cooling setup, energy/op, and sustained (not short-run) throughput?
9. What profiler evidence supports the claimed saturation regime given 9-thread blocks, ~22 KB shared memory/block, and potentially high Keccak register pressure?
10. Will source, raw data, benchmark harness, and Nsight traces be released for reproducibility?

## Recommendation
**Major Revision** (scientific/deployment-readiness recommendation; no formal venue-fit judgment because `criteria_binding_unavailable`). The implementation may become a useful heterogeneous ML-KEM case study, but the central deployment claims require multicore and mixed-workload baselines, measured managed-memory behavior, energy/memory/resource reporting, and a real server/TLS evaluation. The security claims cannot stand without correcting the GPU secret-data threat model and withdrawing or rigorously validating the deterministic-shuffle “entropy” and SPA-resistance claims.
