# Editorial Decision — Round-2 Re-Review

## Final recommendation: **Reject**

The manuscript is within the broad engineering and applied-science scope of *Scientific Reports*. That scope fit is distinct from scientific validity: a topic can suit the journal while the reported study remains technically unsound or insufficiently reproducible. Here, the field analysis and Journal-Fit Reviewer support venue fit, but the five role-separated reports converge on unresolved defects affecting the identity and correctness of the evaluated implementation, the equivalence and reproducibility of the experiments, and the alignment of security, performance, novelty, and deployment claims with the reported evidence.

This recommendation is therefore **not a rejection for journal mismatch or insufficient perceived impact**. It is a rejection on scientific-validity and submission-readiness grounds. The necessary work includes specification-faithful implementation documentation, standard conformance testing, correction of byte coverage, matched and repeated experiments, and re-analysis of the resulting evidence. Because those steps may change the central tables and conclusions, they amount to a newly validated experimental study rather than a bounded Round-2 correction.

## Consensus across the reports

1. **The manuscript has improved in useful ways.** Reviewers acknowledge the added AES-256-CTR and ASCON-128a comparisons, expanded threat-model and limitations discussion, disclosure that headline GPU timings exclude PCIe transfer, additional pseudocode and hardware information, a second image example, and a public code link.
2. **The evaluated Salsa20 object is not reproducibly identified or validated.** The title, abstract, principal results, and conclusion emphasize Salsa20-256, while the detailed CPU/GPU methods repeatedly describe Salsa20-128; the documented nonce/counter word placement is also inconsistent with the manuscript’s own standard state layout. No known-answer test establishes conformance.
3. **RGB correctness and workload equivalence are unresolved.** The CPU path uses `W × H × C`, while the GPU path uses `width × height`. This may leave colour-image bytes unencrypted and invalidates like-for-like CPU/GPU comparison unless the executed representation is shown to differ from the pseudocode.
4. **The performance evidence is not yet auditable.** The manuscript lacks repeated trials, uncertainty, complete timing boundaries, CPU baseline details for all reported speedups, end-to-end measurements, profiler evidence for the occupancy/no-spill explanation, and reproducible energy and memory methods.
5. **Several conclusions do not follow from the manuscript’s own tables.** In particular, reported ASCON-128a latency, throughput, and energy values conflict with the prose claim that Salsa20 has minimal latency and that the alternatives cost more.
6. **Security claims exceed the demonstrated evidence.** Image histograms, entropy, correlation, NPCR/UACI, and corruption PSNR do not establish Salsa20 conformance or cryptographic attack resistance. The generic Grover-search argument is presented too broadly, and the ASCON-128a post-quantum comparison is internally inconsistent.
7. **The proposed deployment is not established.** Nonce lifecycle, authentication, replay protection, key management, platform transformation, mobile implementation, and end-to-end operation are absent or acknowledged only as limitations. The evidence supports, at most, a CUDA kernel study unless those system claims are removed or directly evaluated.
8. **Reproducibility and originality remain insufficiently demonstrated.** A mutable repository URL and in-paper summary tables do not supply version-pinned code, raw measurements, profiler outputs, environment details, or scripts. The claimed advantage over prior GPU work is not normalized or experimentally controlled.

## Disagreements and evidence-based arbitration

### Major Revision versus Reject

The Journal-Fit, Methodology, and Perspective Reviewers recommend **Major Revision**, reasoning that the engineering idea remains testable and the deficiencies are potentially remediable. The Domain Reviewer and Devil’s Advocate recommend **Reject**, reasoning that the documented cipher may be nonconformant, RGB coverage may be incomplete, and the principal experimental campaign would have to be rerun after foundational corrections.

The latter position is more persuasive for this Round-2 decision. The disputed issues do not concern presentation alone: the manuscript does not establish which Salsa20 variant produced the headline evidence; its state and byte-length descriptions raise direct correctness concerns; no independent conformance test resolves those concerns; and its own comparative table contradicts a central claimed advantage. Correcting these defects would require establishing the experimental object first and then regenerating performance and security evidence. That scope exceeds a bounded revision of the present evidentiary record.

### Authentication and deployment scope

The Domain and Perspective Reviewers call for authenticated encryption, nonce lifecycle, replay handling, and deployable protocol evidence. Other reports allow a narrower alternative: retain a confidentiality-only kernel prototype under a passive-adversary model and remove secure social-media, mobile, and end-to-end deployment claims. These positions are compatible rather than contradictory. Authentication and full deployment evaluation are necessary only if the manuscript retains practical secure-system claims; otherwise, strict claim narrowing is the minimum defensible route. Neither route cures the prior implementation-conformance and benchmarking defects.

### Novelty threshold

The Journal-Fit Reviewer treats the work as a potentially publishable benchmark if rigorously validated, while the Devil’s Advocate questions whether a launch-configuration sweep is itself a scientific contribution. The evidence does not justify a categorical finding that no publishable contribution is possible. It does, however, show that present novelty claims are unsubstantiated. A future submission would need either a normalized state-of-the-art comparison identifying a specific new optimization or an explicitly narrower contribution as a reproducible comparative characterization study.

## Explicit adjudication of every Devil’s Advocate CRITICAL issue

### DA-C1 — Experimental object is not identifiable

**Adjudication: VALIDATED.** The Devil’s Advocate anchors the conflict to lines 1–32, 359–515, 527–545, 639–700, 802–835, and 1184–1222. This finding is independently corroborated by the Journal-Fit Reviewer (Major 1), Methodology Reviewer (Critical 1), Domain Reviewer (Critical 1 and Major 2), and Perspective Reviewer (C2). The reports consistently identify a Salsa20-256 headline paired with Salsa20-128 methods, incomplete variant-specific state initialization, and absent known-answer testing. The Domain and Perspective reports additionally identify reversal of nonce and counter positions in Algorithm 7 relative to the manuscript’s own state matrix. No report supplies contrary evidence. This foundation-level uncertainty invalidates silent acceptance and materially supports rejection.

### DA-C2 — Reported data contradict the central superiority claim

**Adjudication: VALIDATED.** The Devil’s Advocate anchors the conflict to lines 934–946, 1052–1100, and Table 11 at lines 1086–1094. The Journal-Fit Reviewer (Major 3) and Domain Reviewer (Major 5) independently observe that ASCON-128a is reported with lower best kernel time, higher encryption/decryption throughput, and lower energy per encryption than Salsa20, contrary to the prose claim that Salsa20 has minimal latency and that both alternatives cost more. The Methodology Reviewer also finds the baseline implementations and work units insufficiently defined for a valid ranking. No reviewer reconciles the contradiction. The superiority conclusion must therefore be withdrawn or recomputed after a functionality-equivalent, reproducible comparison; as presented, it cannot support acceptance.

**DA-CRITICAL terminal status:** **2 validated; 0 rejected; 0 unresolved.** Both block acceptance. Together with the implementation-correctness defects and required experimental re-execution, they support the final recommendation of **Reject**.

## Re-review limitation

The synthesis was prepared from the supplied field analysis and five Round-2 role-separated reports. The **original pre-revision manuscript was not available** to the editorial synthesizer. Consequently, this package cannot independently determine the exact extent of change from the original submission or verify every claimed Round-1 correction against the original text. The decision therefore rests on the reviewers’ anchored assessment of the revised manuscript and their reported verification statuses. This limitation does not resolve the current internal contradictions documented consistently across the reports.

## Conditions for a scientifically credible future submission

A future submission would need to establish specification-faithful cipher identity and full byte coverage before regenerating all affected results; provide independent known-answer and cross-implementation tests; implement an enforceable nonce protocol and either authenticated deployment functionality or strict confidentiality-only claim narrowing; repeat matched benchmarks with uncertainty, end-to-end boundaries, profiler evidence, and auditable energy/memory methods; reconcile every conclusion with corrected tables; and release an immutable reproducibility package. The accompanying roadmap records these decision-driving items without ranking them.