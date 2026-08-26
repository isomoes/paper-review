# Reviewer 1 — Round-2 Methodology Re-review

**Role:** CUDA/HPC benchmarking and reproducibility specialist  
**Venue standard applied:** Scientific Reports; methods and reported measurements must be sufficiently specified to reproduce and audit the principal claims.  
**Recommendation:** **Major Revision**  
**Confidence:** 5/5

## Overall assessment

The revision adds useful performance tables, identifies the GPU timing scope as kernel-only, includes two CUDA devices, adds AES-256-CTR and ASCON-128a GPU baselines, and provides a public code URL. These are genuine improvements. Several reported throughput and Salsa20 speedup values can also be reconstructed from the tabulated payload size and timings.

However, the central benchmarking claims remain methodologically unsupported. CPU and GPU pseudocode do not process the same stated byte count for RGB data, the reported Salsa20 speedups compare a CPU Salsa20-128 implementation with GPU Salsa20-256, baseline CPU timings for two of the three Table 11 speedups are absent, and there is no replication or uncertainty analysis. The occupancy/register-spilling explanation is asserted without profiler evidence and is especially questionable for an 8-thread block. Energy and memory values have no measurement protocol, while the energy arithmetic implies a different payload from the throughput arithmetic. Only two images are mentioned, without a controlled size sweep. These deficiencies require new measurements and fuller methods rather than editorial clarification alone.

## Genuine strengths in the revision

1. **GPU timing scope is now identifiable.** CUDA events and kernel-execution timing are stated at revised lines 605–607 and 786–789, and PCIe transfers are explicitly excluded from the headline speedups at lines 1184–1192. This is substantially clearer than the previous version.
2. **The performance surface is broader.** Tables 2–5 report the Salsa20 kernel across ten launch configurations and two GPUs (lines 802–873); Tables 6–7 add AES-256-CTR and ASCON-128a on the A4000 (lines 917–946); Table 11 collates throughput, energy, memory, and speedup (lines 1086–1094).
3. **Some arithmetic is internally reconstructable.** Interpreting the manuscript’s ambiguous “1.34 Mb” (line 764) as 1.34 MB, `1.34 MB / 0.168 ms = 7,976 MB/s` and `1.34 MB / 0.172 ms = 7,791 MB/s`, consistent with the rounded Salsa20 values 7,980 and 7,790 MB/s in Table 11. Likewise, `91.337/0.344 = 265.51` and `232.03/0.168 = 1381.13`, numerically explaining the two headline Salsa ratios (CPU times at lines 762–767; GPU times at lines 802–807 and 840–846).
4. **A reproducibility starting point is present.** A source-code repository is cited at revised lines 1227–1229. This is helpful, although it does not replace a complete experimental protocol or a version-pinned artifact.

## Verification of relevant prior comments

Status meanings: **Addressed** = the requested item is adequately resolved in the revised text; **Partial** = material was added but the concern is not yet resolved; **Unaddressed** = the requested evidence or analysis remains absent.

| Prior item | Round-2 status | Verification against revised manuscript |
|---|---|---|
| Reviewer 1, item 1: recent comparable methods under identical data/conditions (Review lines 3–16) | **Partial** | AES-256-CTR and ASCON-128a tables were added (revised lines 917–946, 1086–1094), but their implementation, byte mapping, optimization level, and timing protocol are not described. The requested recent image-encryption comparisons are not established under demonstrably identical conditions. |
| Reviewer 1, item 3: time, speedup, throughput, memory, complexity, scaling (Review lines 36–47) | **Partial** | Values are now listed, but timing equivalence, baseline speedup denominators, memory/energy methods, replication, and controlled size scaling remain missing (revised lines 605–607, 758–760, 762–789, 1086–1094). |
| Reviewer 1, item 5: multiple datasets and averaged independent experiments (Review lines 59–67) | **Unaddressed** | Only an airport image and one Lenna image are mentioned (revised lines 762–768, 911–915). No number of repetitions, mean, dispersion, confidence interval, or independent-run protocol is reported anywhere in the methods/results tables. |
| Reviewer 1, item 6: explain performance and limitations (Review lines 68–78) | **Partial** | Limitations were expanded (revised lines 1052–1056, 1163–1182, 1221–1222), but the performance explanation relies on unverified occupancy/spilling assertions and a non-comparable “rounds per byte” argument (lines 993–1000, 1102–1109). |
| Reviewer 2, item 2 and minor optimization/configuration comments: optimization novelty and 8192×8 explanation (Review lines 94–109, 205–211) | **Partial** | The claim is now explicit at revised lines 993–1000, but no occupancy percentage, registers/thread, resident blocks/warps, spill loads/stores, or compiler evidence is supplied. |
| Reviewer 2, item 4: throughput, kernel time, PCIe scope (Review lines 121–129) | **Partial** | Kernel-only scope and PCIe exclusion are stated (revised lines 605–607, 786–789, 1184–1192), and throughput is listed. End-to-end latency is still absent, CPU timer boundaries are unspecified, and workload inequivalence prevents the speedups from being accepted. |
| Reviewer 2, item 6: memory, complexity, power, lightweight comparison (Review lines 175–199) | **Partial** | Table 11 provides values (revised lines 1086–1094), but there is no energy or memory measurement method, and “rounds per byte” does not normalize unlike cipher rounds into comparable work (lines 1102–1106). |
| Reviewer 2, item 7: ChaCha20/AES-GCM/ASCON comparison (Review lines 200–201) | **Partial** | AES-256-CTR and ASCON-128a were added, but ChaCha20 and AES-GCM were not benchmarked; moreover, baseline implementations are insufficiently documented for comparability. |
| Reviewer 3, item 1: comparison with prior CUDA Salsa20 and architectural novelty (Review lines 215–248) | **Partial** | Khalid et al. is discussed and cited, but no controlled reproduction or normalized comparison is provided; “more efficient” is asserted at revised lines 1102–1109 without comparable hardware, payload, timing scope, or measurement data. |
| Reviewer 3, item 4: OpenMP/OpenCL/ChaCha20/AES-GPU and optimal configuration (Review lines 302–326) | **Partial** | An AES CUDA baseline is present, but OpenMP, OpenCL, and ChaCha20 are deferred. The AES/ASCON kernel methods are absent, and the optimal-configuration explanation lacks profiler evidence. |
| Reviewer 3, item 5: occupancy, latency, cache, architecture support (Review lines 327–338) | **Unaddressed** | Revised lines 993–1000 merely state that occupancy is maximized and registers do not spill. No occupancy, memory-latency, cache, achieved-bandwidth, stall, or register data are reported. |
| Reviewer 3, item 7: resolutions, grayscale/RGB, multiple benchmark datasets (Review lines 367–385) | **Partial** | Two images and two color modes are mentioned (revised lines 762–768, 911–915), but no controlled resolution series or per-image comparative timing table is shown. The GPU pseudocode’s omission of channels also undermines the RGB validation (lines 648–655 versus CPU lines 412–415). |

## Major and Critical methodology problems

### 1. Critical — CPU/GPU workloads are not demonstrably equivalent

**Problem.** The CPU pseudocode defines `L = W × H × C` (revised lines 409–420), whereas the GPU description and pseudocode define `data_len = width × height`, despite reading the channel count (lines 530–545 and 637–655). Thus, for RGB input, the written GPU method processes one-third of the byte count processed by the CPU method. In addition, the only reported CPU timings are explicitly for Salsa20-128 (lines 359–360 and 762–767), while the headline GPU ratios use the Salsa20-256 timings from Tables 2 and 4 (lines 802–807, 840–846). The unsupported statement that Salsa20-256 “will have the same computation time” (lines 784–785) is not a substitute for measurement.

**Consequence.** The central CPU/GPU speedup and RGB/scaling claims are not based on a controlled like-for-like workload. For RGB images, the pseudocode also raises a correctness concern: either only part of the decoded buffer is transformed, or the manuscript does not describe the executed code. This defect directly compromises the main acceleration claim.

**Minimum remedy.** Correct and reconcile the implementation and pseudocode so both paths process the identical decoded byte buffer (`W × H × C`, including any row pitch). Re-run CPU and GPU Salsa20-256 on the same input bytes, key/nonce policy, compiler optimization level, and transform boundaries. Report bytes processed and verify every byte after encrypt–decrypt. Provide per-image checksums and derive speedup only from matched CPU/GPU trials.

### 2. Major — Timing, speedup, and throughput are insufficiently defined despite partially correct arithmetic

**Problem.** CUDA events are mentioned (lines 605–607), but event placement, stream, synchronization, warm-up, repeat count, and aggregation are not specified. CPU timer type and boundaries are absent. PCIe transfers are excluded only in the conclusion (lines 1184–1192), yet the abstract and deployment discussion use the kernel-only speedups without an end-to-end companion result (lines 20–32, 1178–1182). Table 11 lists AES and ASCON GPU speedups of 26.86× and 71.31× (lines 1086–1094), but no corresponding CPU AES or ASCON times appear in the manuscript. The throughput arithmetic is reconstructable only by interpreting the manuscript’s “1.34 Mb” as 1.34 MB and inferring that every Table 11 rate uses that payload; the tables do not state this basis or whether MB means 10^6 or 2^20 bytes.

**Consequence.** Readers cannot reproduce the timing or determine whether the reported differences exceed run-to-run noise. The AES/ASCON speedups are unauditable, and kernel-only numbers may materially overstate application-level benefit for social-media-sized inputs.

**Minimum remedy.** Define a timing protocol with exact event/timer boundaries, synchronization, stream, warm-ups, repetitions, and summary statistics. Report both kernel-only and end-to-end host latency (allocation policy stated; H2D + kernel + D2H) for each payload. Add the CPU AES/ASCON measurements or remove their speedups. State the exact byte count and MB convention and give formulas for throughput and speedup.

### 3. Major — No replication, variability, or statistical treatment

**Problem.** Tables 2–7 present single three-decimal timing values (lines 802–946), but the manuscript provides no trial count, warm-up policy, mean/median, standard deviation, confidence interval, or outlier policy. This leaves Reviewer 1’s explicit request for averaged independent experiments (Review lines 59–67) unaddressed.

**Consequence.** The claimed optimum and small differences between configurations may be measurement noise or dynamic-clock effects. For example, several ASCON configurations differ by only 0.001 ms (lines 940–944), far below what can be interpreted from an undocumented single-value procedure.

**Minimum remedy.** Re-run each principal configuration over a predeclared number of process-level repetitions, with adequate in-process iterations after warm-up. Report at least median and interquartile range or mean, SD, and 95% CI; show all raw trial values in a repository artifact. Control or record clock state, temperature, and power mode. Use uncertainty-aware comparisons before declaring an optimum.

### 4. Major — Occupancy and register-spilling claims have no supporting measurements

**Problem.** The manuscript states that 8192 blocks × 8 threads “maximizes SM occupancy without spilling registers” and that higher thread counts reduce occupancy (lines 993–1000). No numerical achieved/theoretical occupancy, registers per thread, shared/local memory, resident blocks/warps, spill stores/loads, or profiler command/output is supplied. An 8-thread CUDA block activates only eight lanes of at least one 32-thread warp, making the claimed occupancy mechanism non-obvious and requiring direct evidence. The discussion does not address cache behavior or memory stalls requested previously.

**Consequence.** The architectural explanation for the selected launch shape—and a stated novelty claim—cannot be verified and may confuse lowest measured latency with maximum occupancy. It also does not establish causation between occupancy and runtime.

**Minimum remedy.** For each tested block size on each GPU, report compute capability, compiled registers/thread (`ptxas -v`), static/dynamic shared memory, theoretical and achieved occupancy, active warps/SM, local-memory spill transactions, achieved memory bandwidth, and principal stall/cache metrics from a named Nsight Compute version and command. Explain the sub-warp 8-thread choice, include error bars, and describe it as the fastest tested configuration unless profiler evidence supports a stronger architectural claim.

### 5. Major — Energy and memory results are neither measured reproducibly nor arithmetically aligned with throughput

**Problem.** Table 11 reports energy, efficiency, and identical 6.29 MB memory usage (lines 1086–1094), but no tool, API, sampling rate, baseline subtraction, integration interval, repetition, or definition of “memory usage” is provided. Moreover, `energy efficiency × energy per encryption` implies a payload of approximately 4.19 MB for all ciphers: Salsa20 `780.38 MB/J × 0.00537 J = 4.1906 MB`; AES `176 × 0.02383 = 4.1941 MB`; ASCON `841.02 × 0.00498 = 4.1883 MB`. By contrast, Table 11 throughput reconstructs from Tables 4, 6, and 7 only if the manuscript’s ambiguous “1.34 Mb” is treated as 1.34 MB. The payload bases therefore appear inconsistent or are at least undisclosed.

**Consequence.** The energy-efficiency comparison cannot be audited, and the identical memory values may merely reflect a common input allocation rather than algorithm-specific peak memory. These data do not currently support lightweight/energy claims.

**Minimum remedy.** State the exact payload for every energy and memory result and correct the table/formulas. Describe the power instrument/API, sample interval, idle baseline, integration window, repetitions, and uncertainty. Measure full-operation energy or clearly label kernel-only energy. Define memory as allocated bytes or measured peak device memory, itemize buffers/context overhead, and report algorithm-specific values with measurement precision.

### 6. Major — Baseline implementations and work units are not comparable or reproducible

**Problem.** Salsa20’s GPU method is described, but equivalent methods for AES-256-CTR and ASCON-128a are absent. Their work assignment, library/custom-code status, authentication/tag handling, compiler flags, and correctness validation are unknown (Tables 6–7, lines 917–946). Launch sweeps also use 65,536 total threads for Salsa20 (lines 790–794) but 262,144 for AES/ASCON (Tables 6–7), with no mapping from a thread to bytes for those baselines. “Rounds per byte” is then treated as a cipher-independent complexity measure (lines 1102–1106), although a round in these three primitives performs materially different operations and cannot normalize computational work by simple count.

**Consequence.** Performance differences may arise from implementation maturity, unequal functionality, or unequal work decomposition rather than cipher structure. The claim of identical GPU conditions and superiority over prior work is not reproducible.

**Minimum remedy.** Add complete baseline implementation descriptions and version-pinned source, including mode/functionality, bytes/thread, tail handling, key setup, nonce/counter handling, tag generation/verification if applicable, compiler flags, and correctness test vectors. Tune each implementation under one declared, fair policy and report both its best configuration and the full sweep. Remove the cross-cipher “rounds per byte” efficiency inference or replace it with measured instruction/resource/profiler evidence and appropriately limited interpretation.

### 7. Major — Dataset/scaling evidence remains inadequate

**Problem.** The paper mentions one 1.34 MB grayscale airport image and one 512 KB color Lenna image (lines 762–768, 911–915), but gives neither exact dimensions/source/hash nor a systematic size series. There is no clear per-image table showing Salsa20, AES, and ASCON times at both sizes. The response’s claim of scalability is therefore not verifiable from the revised results, and the RGB byte-count discrepancy intensifies this concern.

**Consequence.** Fixed launch overhead, throughput saturation, tail effects, and color-channel handling cannot be assessed. Results from two isolated files do not demonstrate scaling or generalization across image resolutions/content types.

**Minimum remedy.** Use a documented benchmark set with exact dimensions, channels, decoded byte counts, source URLs/licenses, and checksums. Run a controlled payload sweep from small social-media images through sizes that saturate the GPU, using identical byte buffers across ciphers and CPU/GPU paths. Plot latency and throughput with uncertainty versus bytes and provide per-image correctness hashes.

### 8. Major — The experimental environment is not reproducible to Scientific Reports standards

**Problem.** Hardware is only partially identified in the conclusion (lines 1184–1188), and the repository is linked (lines 1227–1229). Missing are OS, CUDA toolkit, driver, compiler and optimization flags, exact GPU model properties/compute capability, CPU core/thread use and affinity, memory configuration, application/library versions, GPU persistence/power/clock settings, repository commit/tag, execution commands, and raw result files.

**Consequence.** Another laboratory cannot reconstruct the binaries, execution conditions, or tables, and dynamic GPU/CPU behavior cannot be separated from the proposed optimization.

**Minimum remedy.** Add a dedicated reproducibility subsection and a versioned archival artifact. Record all software/hardware versions and settings above, exact build/run commands, fixed inputs and hashes, profiler commands, raw timings/power traces, and scripts that regenerate Tables 2–7 and 11. Cite an immutable commit or release rather than only a mutable repository root.

## Recommendation rationale

**Major Revision.** The revision has made visible progress and the core idea remains testable, so rejection is not necessary on methodology grounds at this stage. Nevertheless, the principal speedup, optimization, energy, memory, and scaling claims are not presently reproducible or based on demonstrably equivalent workloads. Acceptance would require corrected byte handling, matched CPU/GPU and cross-cipher experiments, replicated uncertainty-aware measurements, profiler evidence for the architectural claims, and a version-pinned reproducibility package.