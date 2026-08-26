#import "@preview/basic-document-props:0.1.0": simple-page

#let document-author = "isomoes"
#let paper-title = "GPU-Accelerated Quantum-resistant Image Encryption for Social Media using Lightweight Cryptographic Stream Cipher"
#let manuscript-id = "Not assigned in supplied package"
#let venue = "Scientific Reports"
#let review-round = "Round 2 re-review"
#let review-date = "2026-08-26"
#let recommendation = "Reject"

#set document(
  title: paper-title,
  author: document-author,
  date: datetime(year: 2026, month: 8, day: 26),
)

#set page(
  numbering: "1",
  number-align: center,
  margin: (x: 2.1cm, y: 1.7cm),
)
#set text(size: 10.5pt)
#set par(justify: true, leading: 0.68em)
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 13.5pt, weight: "bold")
#show heading.where(level: 3): set text(size: 11.5pt, weight: "bold")

#let redt(content) = text(fill: red.darken(15%), content)
#let oranget(content) = text(fill: rgb("b85c00"), content)
#let greent(content) = text(fill: rgb("177245"), content)
#let grayt(content) = text(fill: gray, content)

#let comment-box(title, content, severity: "major") = {
  let accent = if severity == "critical" { red.darken(10%) } else if severity == "minor" { gray } else { rgb("b85c00") }
  rect(
    width: 100%,
    stroke: 1pt + accent,
    inset: 10pt,
    radius: 2pt,
    fill: if severity == "critical" { rgb("fff4f4") } else { rgb("fffaf3") },
    [
      #text(weight: "bold", size: 11pt, fill: accent)[#title]
      #v(0.45em)
      #content
    ],
  )
}

#align(center)[
  #text(size: 18pt, weight: "bold")[Academic Paper Re-Review Report]
  #v(0.45em)
  #text(size: 11.5pt)[
    Reviewer: #document-author \
    Review Date: #review-date
  ]
]

#v(0.8em)
#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(246), [
  #text(weight: "bold", size: 14pt)[Paper Information]
  #v(0.45em)
  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    row-gutter: 0.32em,
    [*Paper Title:*], [#paper-title],
    [*Manuscript ID:*], [#manuscript-id],
    [*Journal:*], [#venue],
    [*Review Round:*], [#review-round],
    [*Review Date:*], [#review-date],
    [*Recommendation:*], [#redt[*#recommendation*]],
  )
])

#v(0.65em)
#rect(width: 100%, stroke: 0.8pt + gray, inset: 8pt, fill: luma(250), [
  *Verification scope.* The supplied package contains the revised manuscript, a highlighted manuscript, and the prior review/author-response table. It does not contain the original pre-revision manuscript or a formal change set. The highlighted and revised PDFs have substantively identical extracted text. Accordingly, this report verifies each response against the revised manuscript but cannot independently reconstruct the exact before/after change. The manuscript itself was not modified.
])

= Review Summary

The manuscript studies CUDA acceleration of Salsa20 for image encryption and reports CPU/GPU timing, security diagnostics, and comparisons with AES-256-CTR and ASCON-128a. The revision adds comparative tables, kernel-only throughput, security metrics, a threat-model discussion, deployment limitations, and a code link. These changes improve topical coverage and place the work within the broad engineering scope of _Scientific Reports_.

The revised paper nevertheless fails on scientific validity and reproducibility. Its title and conclusions concern Salsa20-256, while the detailed CPU and CUDA methods repeatedly specify Salsa20-128. The CUDA pseudocode reverses the standard nonce/counter state positions and computes the GPU buffer length as `width × height`, omitting image channels despite claiming RGB validation. No operational nonce-uniqueness protocol or authentication mechanism is implemented. The performance claims compare non-equivalent or insufficiently documented workloads, exclude transfer and application costs, omit repeated-trial statistics, and assert occupancy, register-spilling, energy, and memory conclusions without the required measurements. Several central claims are contradicted by the manuscript's own tables, including the claimed latency advantage over ASCON-128a and the asserted superiority over the cited 43.44 GB/s prior Salsa20 GPU implementation.

These are not presentation defects. Correcting them requires cryptographic reimplementation, conformance testing, and a complete experimental rerun. Because this is already a revised submission and the present results do not establish that the evaluated system is standard Salsa20-256, secure for the claimed application, or comparatively superior, my recommendation is *Reject*. A substantially rebuilt study could be considered as a new submission.

= Strengths

+ *Relevant engineering problem.* Efficient confidentiality protection for high-volume multimedia is a legitimate systems problem, and GPU cryptographic implementation is within the engineering scope of the target journal.

+ *Useful disclosure of timing scope.* The revision states that CUDA events measure kernel execution and that PCIe transfer is excluded from the headline speedup (Methods, extracted lines 605--607; Conclusion, lines 1184--1192).

+ *Additional same-GPU baselines.* AES-256-CTR and ASCON-128a timing tables were added (lines 917--946), which is preferable to relying solely on cross-paper timing.

+ *More candid deployment discussion.* The revision acknowledges lossy-recompression incompatibility, metadata leakage, external key management, and lack of authentication (lines 1115--1182).

+ *Code availability in principle.* A repository URL is supplied (lines 1227--1229), although a reviewed commit, build manifest, raw data, and complete reproduction instructions are still needed.

= Detailed Review

== Innovation Assessment

The manuscript's potentially useful contribution is a controlled characterization of Salsa20, AES-256-CTR, and ASCON-128a on common GPU hardware, together with a launch-configuration study. This topic is relevant to applied cryptographic engineering. However, the present evidence does not establish a new cipher construction, a new CUDA optimization principle, or state-of-the-art performance. The paper cites 43.44 GB/s for Khalid et al. (lines 194--197) but reports 7.98 GB/s for the current implementation (lines 1086--1090), while still claiming greater efficiency. The comparison is not normalized for hardware, workload, functionality, or timing scope.

#comment-box("Innovation assessment", [
  The work could become a useful reproducible implementation study if it identifies the exact new optimization or explicitly narrows its contribution to comparative characterization. The current novelty and superiority claims should not be retained without controlled comparisons to prior GPU Salsa20, ChaCha20, OpenCL/OpenMP, optimized CPU, and equivalent authenticated baselines.
], severity: "major")

== Technical Quality Assessment

The technical foundation is not yet sound. The title and principal claims concern Salsa20-256, while the serial and CUDA methods repeatedly specify Salsa20-128. Algorithm 7 reverses the manuscript's own nonce/counter word layout, and the GPU path uses `width × height` rather than `width × height × channels`. No authoritative known-answer test establishes Salsa20 conformance. The application also lacks a nonce lifecycle and authentication despite assuming untrusted intermediaries.

#comment-box("Technical-quality boundary", [
  These defects affect the identity and correctness of the evaluated primitive and the confidentiality coverage of RGB images. Successful self-decryption cannot detect a mutually cancelling implementation error. The implementation must be corrected and validated before any security or performance conclusion can be considered.
], severity: "critical")

== Experimental Assessment

The revision broadens the reported performance surface by adding two GPUs, launch-configuration sweeps, AES/ASCON baselines, throughput, energy, and memory values. Some headline ratios are arithmetically reproducible. Nevertheless, CPU and GPU variants and byte counts are not demonstrably equivalent; kernel-only GPU timing is used broadly; repetitions and uncertainty are absent; profiler evidence does not support the occupancy claim; and throughput and energy-efficiency arithmetic imply different payload sizes.

#comment-box("Experimental and reproducibility boundary", [
  The 265×/1381× speedups, 8192×8 occupancy optimum, energy efficiency, memory advantage, and scalability should be treated as unvalidated until the study is rerun with matched workloads, end-to-end boundaries, repeated trials, profiler measurements, auditable power methods, and an immutable reproduction package.
], severity: "critical")

== Writing Quality Assessment

The new threat-model, metadata, recompression, and limitations sections are useful and more candid than the original response implies. However, substantial language and technical-precision problems remain. The Introduction incorrectly explains public-key encryption for a symmetric cipher; the Salsa20 equations and round terminology are inconsistent; several superiority and quantum-security claims exceed the evidence; and figure/table presentation remains uneven.

#comment-box("Writing and presentation assessment", [
  A professional technical edit is required after the implementation and experiments are corrected. Editing should focus on precise cryptographic terminology, consistent Salsa20 variants and byte units, accurate claim-to-table alignment, concise relevant literature, journal-compliant references and end matter, and readable figures with quantitative captions.
], severity: "major")

= Major Comments

#comment-box("1. The paper does not specify a validated Salsa20-256 implementation", [
  *Location/evidence:* The title and abstract claim Salsa20-256 (lines 1--32), but the serial and parallel methods and pseudocode specify Salsa20-128 (lines 359--515 and 639--723), including repeated 128-bit key material at line 692. The manuscript merely asserts that 128- and 256-bit variants have the same execution time (lines 784--785).

  *Consequence:* The principal security, performance, and quantum-search claims cannot be tied to a reproducible 256-bit implementation. Round-trip decryption is insufficient because an erroneous transformation can invert itself.

  *Minimum remedy:* Implement and fully specify Salsa20-256; validate CPU and GPU code against authoritative Salsa20/20 256-bit known-answer vectors and byte-for-byte cross-checks; rerun every table using the validated variant and release the exact reviewed source revision.
], severity: "critical")

#v(0.55em)
#comment-box("2. The CUDA algorithm contains state-layout and RGB-length errors", [
  *Location/evidence:* The manuscript's state matrix places nonce words at positions 6--7 and counter words at 8--9 (lines 297--302), while Algorithm 7 reverses them (lines 693--697). The serial path uses `W × H × C` bytes (lines 412--415), but the CUDA path uses only `width × height` (lines 542--545 and 648) despite the RGB Lenna claim (lines 911--915).

  *Consequence:* The specified GPU primitive is not standard Salsa20, and for RGB input it appears to process only one-third of the decoded pixel bytes. Color-image confidentiality, timings, and security metrics are therefore invalid as documented.

  *Minimum remedy:* Correct the standard state layout and byte length; publish tests covering grayscale, RGB, RGBA, partial blocks, counter carries, and all processed bytes; then rerun correctness, security, and performance experiments.
], severity: "critical")

#v(0.55em)
#comment-box("3. Nonce reuse and missing authentication invalidate the advertised social-media system", [
  *Location/evidence:* The paper says a nonce must be unique (lines 269--295), but the algorithms only initialize it and reset the counter to zero (lines 374--375, 449--460, 545--547, and 649--670). No allocation, persistence, transmission, collision, or reuse policy is given. The threat model assumes untrusted intermediaries (lines 1117--1128), while the limitations admit unauthenticated, bit-flippable ciphertext (lines 1163--1178).

  *Consequence:* Reusing a key/nonce pair repeats the keystream; the construction also cannot detect modification, substitution, truncation, or replay. Acknowledging these failures does not support the abstract's claim of secure deployable image encryption.

  *Minimum remedy:* Either restrict the contribution to a confidentiality-only kernel microbenchmark or implement a standardized authenticated construction with an explicit nonce lifecycle, associated-data policy, tag verification, replay handling, and negative tamper tests. Rerun all application and baseline benchmarks with equivalent functionality.
], severity: "critical")

#v(0.55em)
#comment-box("4. The 265× and 1381× speedups are not valid comparative application results", [
  *Location/evidence:* CPU measurements are explicitly Salsa20-128 (lines 762--767), while the headline GPU/security claims concern Salsa20-256 (lines 784--852). The GPU buffer length differs from the serial definition. CUDA events time the kernel while H2D/D2H transfers remain outside the interval (lines 559--561 and 605--607). Compiler flags, exact Xeon model, SIMD use, affinity, warm-up, synchronization, and repeated trials are absent.

  *Consequence:* The ratios are arithmetically reproducible but compare unverified workloads and an uncharacterized serial baseline. They cannot establish end-to-end acceleration or superiority over optimized CPU cryptography.

  *Minimum remedy:* Use identical validated cipher variants, decoded bytes, and functionality; compare with a recognized optimized CPU implementation; and report both kernel-only and end-to-end latency with complete hardware/software settings, warm-ups, repetitions, distributions, and uncertainty.
], severity: "critical")

#v(0.55em)
#comment-box("5. Occupancy, energy, memory, and scalability conclusions lack measurement support", [
  *Location/evidence:* The paper asserts that 8192 blocks × 8 threads maximize occupancy without spilling (lines 993--1000 and 1197--1204), but reports no achieved occupancy, registers, spills, active warps, warp efficiency, memory stalls, or cache metrics. Eight threads occupy only part of a 32-lane warp. Table 11 reports 7,980 MB/s and 5.37 mJ with 780.38 MB/J (lines 1086--1095): throughput implies about 1.34 MB, while energy efficiency implies about 4.19 MB. The power method and meaning of identical 6.29 MB memory figures are unspecified. Only two images and no repeated trials are reported.

  *Consequence:* The proposed optimum, energy efficiency, memory advantage, and scalability are not reproducible scientific findings.

  *Minimum remedy:* Report Nsight Compute metrics for every launch configuration; define compressed size, decoded bytes, and launch coverage consistently; document power sampling, batching, integration, baseline subtraction, and uncertainty; and evaluate repeated trials across multiple resolutions, channel formats, and batch sizes.
], severity: "critical")

#v(0.55em)
#comment-box("6. The security and quantum-resistance argument remains overstated", [
  *Location/evidence:* The Introduction describes public-key encryption/private-key decryption for a symmetric stream cipher (lines 63--71). The text calls Grover's bound the only applicable quantum attack and a hard floor (lines 221--228), yet the detailed implementation is 128-bit and the paper also says 128-bit-key ASCON-128a meets the same 128-bit post-quantum margin (lines 1057--1100). NPCR/UACI, entropy, histograms, and pixel correlation are treated as security evidence (lines 952--1081), while NIST, chosen-plaintext, and known-plaintext analysis are deferred in the response.

  *Consequence:* Generic quantum key-search reasoning does not prove security of this concrete implementation or complete system. Image statistics do not establish cryptographic confidentiality, nonce safety, or integrity. A chi-square p-value is not a probability that the histogram is uniform.

  *Minimum remedy:* Correct the symmetric-encryption model; qualify the claim as a generic key-search estimate under explicit assumptions; align every key size; prioritize conformance, nonce, authentication, and adversarial security properties; and label image metrics only as descriptive diagnostics with complete protocols.
], severity: "critical")

#v(0.55em)
#comment-box("7. The novelty and comparative-efficiency claims are contradicted or incomplete", [
  *Location/evidence:* ASCON-128a is reported at approximately 0.144 ms encryption and 9,310 MB/s, versus Salsa20 at approximately 0.168 ms and 7,980 MB/s (lines 840--852, 934--946, and 1086--1095), contradicting the claimed Salsa20 minimum latency (lines 1052--1100). The paper cites 43.44 GB/s for Khalid et al. (lines 194--197) but reports 7.98 GB/s for this work while claiming greater efficiency (lines 1102--1109). Requested ChaCha20, AES-GCM, OpenMP, and OpenCL comparisons are deferred. “Rounds per byte” compares non-equivalent round functions.

  *Consequence:* The evidence does not establish a new GPU architecture, state-of-the-art performance, or the claimed unique security/performance combination.

  *Minimum remedy:* Reframe the contribution as an implementation study unless a genuinely new kernel method is demonstrated; add normalized same-functionality comparisons and profiler evidence; remove invalid rounds-per-byte reasoning; and correct every conclusion contradicted by the tables.
], severity: "critical")

#v(0.55em)
#comment-box("8. Scientific Reports reproducibility expectations are not met", [
  *Location/evidence:* The manuscript provides a mutable repository URL (lines 1227--1229), but omits a commit/tag, exact image dimensions and hashes, compiler/CUDA/driver versions and flags, benchmark commands, test vectors, raw repetitions, power logs, and analysis scripts. Tables 2--7 contain single values without trial counts or uncertainty (lines 802--946).

  *Consequence:* The methods and results cannot be independently reproduced or audited to the standard expected for an experimental engineering article.

  *Minimum remedy:* Archive the exact reviewed code and data; provide a file-to-claim manifest and one-command reproduction procedure; release raw measurements; and describe all hardware, software, controls, repetitions, and statistical summaries in the Methods.
], severity: "major")

= Verification of Prior Review Issues

The following table records each supplied issue, the response claim, the manuscript evidence checked, and the verified status. “Partial” means relevant material was added but the original acceptance requirement remains unmet.

#text(size: 8.2pt)[
#table(
  columns: (0.55fr, 1.45fr, 1.35fr, 2.05fr, 0.75fr),
  inset: 3.5pt,
  stroke: 0.45pt,
  align: (left, left, left, left, center),
  table.header([*Ref.*], [*Original issue*], [*Author response*], [*Verified revised-manuscript evidence*], [*Status*]),
  [R1.1], [Recent state-of-art comparison], [Added AES-CTR and ASCON on the same GPU], [Tables 6--11 add in-house baselines, but recent GPU image/stream methods and normalized prior work are absent; Khalid comparison is adverse (lines 194--197, 1086--1109).], [#oranget[*Partial*]],
  [R1.2], [Standard security metrics], [Added entropy, chi-square, correlation, NPCR/UACI, key tests and robustness], [Tables 8--10 exist (lines 1004--1081); NIST/CPA/KPA are deferred and several metrics are misinterpreted.], [#oranget[*Partial*]],
  [R1.3], [Comprehensive performance evaluation], [Added times, throughput, speedup, energy, memory, complexity and another image], [Metrics are present, but cipher/byte equivalence, end-to-end timing, repetitions, energy method, memory definition, and scaling are unresolved.], [#oranget[*Partial*]],
  [R1.4], [Improve figures], [Claims 400 dpi and reference checking], [Resolution change cannot be verified without the original; current figures remain inconsistently scaled and several occupy excessive page area.], [#grayt[*Cannot verify*]],
  [R1.5], [Multiple datasets and independent trials], [Added one 512 KB RGB Lenna image], [Only two images; no repeated trials or uncertainty; GPU length omits channels (lines 542--545, 911--915).], [#redt[*Not addressed*]],
  [R1.6], [Expanded discussion], [Added novelty, limitation and deployment sections], [Sections 6.1--6.4 exist (lines 992--1182), but central architectural and deployment explanations remain assertions or admissions of non-deployability.], [#oranget[*Partial*]],

  [R2.1], [Justify quantum-resistant claim], [Added Grover/Bennett/NIST discussion and threat model], [Theory added at lines 221--228, but 128/256 mismatch, ASCON inconsistency, and complete-system overclaim remain.], [#oranget[*Partial*]],
  [R2.2], [Explain novelty beyond CUDA Salsa20], [Claims comparative framework and 8192×8 occupancy optimum], [No validated new kernel method or occupancy/register evidence; prior 43.44 GB/s result exceeds reported 7.98 GB/s.], [#redt[*Not verified*]],
  [R2.3], [Expand security evaluation], [Added image metrics; left CPA/KPA and NIST as future work], [Metrics added, but nonce reuse, authentication, CPA/KPA, and NIST evaluation remain unresolved.], [#oranget[*Partial*]],
  [R2.4], [Throughput, kernel scope and PCIe], [Reports throughput and says timing is kernel-only], [Disclosure is present (lines 605--607, 1184--1192), but no end-to-end measurement and workload mismatch invalidates headline speedups.], [#oranget[*Partial*]],
  [R2.5], [Threat model, compression, metadata, deployment], [Added Sections 6.3--6.4], [Compression and metadata are discussed, but nonce, replay, active tampering, and deployable authentication remain absent.], [#oranget[*Partial*]],
  [R2.6], [Justify lightweight classification], [Added energy, memory and rounds-per-byte comparison], [Energy/memory lack methods and rounds-per-byte is not a cipher-independent complexity measure.], [#redt[*Not verified*]],
  [R2.7], [Compare ChaCha20, AES-GCM and ASCON], [Compared AES-CTR and ASCON; deferred ChaCha20], [ASCON and AES-CTR appear; ChaCha20 and AES-GCM do not. AES-CTR is not AES-GCM.], [#oranget[*Partial*]],
  [R2.m1], [Define LWC], [Expanded abbreviation], [Defined in abstract/introduction.], [#greent[*Full*]],
  [R2.m2], [Clarify CUDA optimization strategy], [Added configuration discussion], [A parameter sweep is described, but the architectural explanation lacks profiler evidence.], [#oranget[*Partial*]],
  [R2.m3], [Explain 8192×8 choice], [Claims maximum occupancy without spilling], [No occupancy, register, spill, cache, or warp measurements support the assertion.], [#redt[*Not addressed*]],
  [R2.m4], [Report throughput], [Added Table 11], [Throughput is present, but its payload denominator conflicts with energy efficiency.], [#oranget[*Partial*]],
  [R2.m5], [Improve abstract readability], [Claims necessary changes], [Current abstract remains overclaimed and does not disclose kernel-only scope, authentication, or implementation inconsistency.], [#oranget[*Partial*]],

  [R3.1], [Explain scientific novelty and superiority], [Reframed as comparative GPU characterization], [Contribution is reframed, but novelty and superiority are unsupported by normalized evidence.], [#oranget[*Partial*]],
  [R3.2], [Add post-quantum theory], [Added Grover analysis and Table 1], [Theory is present but materially overstated and inconsistent with key variants and ASCON strength.], [#oranget[*Partial*]],
  [R3.3], [Security/attack tests], [Added metrics; deferred CPA/KPA and NIST], [Several diagnostics appear, but requested adversarial/randomness work remains future work and metric interpretation is weak.], [#oranget[*Partial*]],
  [R3.4], [OpenMP/OpenCL/ChaCha/AES comparisons], [Added AES-CUDA; deferred others], [Only AES-CUDA is measured; expected similarity is not experimental evidence.], [#redt[*Mostly unaddressed*]],
  [R3.5], [Architectural support for optimum], [Claims occupancy/no spilling], [No profiler measurements establish the mechanism.], [#redt[*Not addressed*]],
  [R3.6], [Add three suggested references], [States all were added], [Requested works appear at lines 202--216 and 1340--1346.], [#greent[*Full*]],
  [R3.7], [Multiple resolutions, grayscale and RGB], [Added one RGB Lenna image], [No quantitative scaling study; documented GPU byte length omits channels.], [#redt[*Contradicted*]],
  [R3.8], [Reduce oversized Figures 3--6], [Explicitly retained them large], [The requested change was declined; present layout remains excessive.], [#redt[*Not addressed*]],
  [R3.9], [Professional English editing], [Claims correction], [Numerous grammatical and technical-language errors remain throughout.], [#redt[*Not satisfied*]],
  [R3.10], [Use variables consistently], [Claims correction], [Salsa20-128/256, `W×H×C`/`W×H`, MB/Mb/decoded bytes, and security labels remain inconsistent.], [#redt[*Not satisfied*]],
)
]

*Updated Round-2 recommendation:* *Reject.* The response package resolves only a small subset of the prior issues fully, while the remaining implementation-conformance, RGB coverage, authentication, and benchmark-validity defects require a new experimental campaign.

= Minor Comments

+ *Introduction, lines 63--71:* Replace the public-key/private-key diagram and explanation with a correct symmetric-encryption flow showing a shared secret, unique nonce, counter, ciphertext, and authentication tag.

+ *Salsa20 equations, lines 317--323:* Use rotate-left notation rather than a left shift. Align the equations with Algorithm 5 and the authoritative specification.

+ *Lines 337--342:* Correct the explanation of Salsa20 feed-forward; it should not be described merely as preventing an attacker from running the state backward.

+ *Lines 217--220:* Correct “AES-26-CTR” to “AES-256-CTR” and avoid describing reduced-round attack margins as direct full-round security percentages.

+ *Tables 8--10:* Separate plaintext-differential NPCR/UACI from key-sensitivity NPCR/UACI. Do not describe a chi-square p-value as the probability that a histogram is uniform.

+ *ASCON baseline:* State explicitly whether tag generation and verification are included. If corrupted ciphertext produces an image rather than rejection, the experiment is not full ASCON-128a authenticated encryption.

+ *Figures 3--6 and 13--15:* Reduce unused space, enlarge labels, standardize styles, and add quantitative profiler values rather than screenshots alone.

+ *Writing:* The manuscript requires professional English editing. Examples include sentence fragments, article/preposition errors, inconsistent capitalization, and imprecise phrases such as “massive speedup,” “hard to hack,” and “the sender identifies an unauthorized user.”

+ *Scientific Reports format:* Check title length and accuracy, use the journal's numerical Nature reference style, add a competing-interests statement and author-contributions statement, and ensure the Methods contain complete reproducibility information.

= Questions for Authors

1. Which exact source file and immutable commit generated every Salsa20-256 result, and does it pass published Salsa20/20 256-bit known-answer vectors?

2. Why does Algorithm 7 place the counter in state words 6--7 and nonce in 8--9, contrary to the manuscript's earlier state matrix and the standard Salsa20 layout?

3. For the RGB Lenna experiment, how many decoded bytes were encrypted, and how can `width × height` cover all color channels?

4. What payload definition and power-integration procedure yield both 5.37 mJ and 780.38 MB/J when throughput is calculated from a 1.34 MB payload?

5. Were ASCON-128a authentication tags generated and verified in timing and corruption tests? If so, why were modified ciphertexts decoded instead of rejected?

= Confidential Comments to Editor

The topic is within the broad engineering scope of _Scientific Reports_, but scope fit should not be confused with scientific validity. The revision addresses many requested topics at the level of added prose and tables, yet the central implementation remains internally inconsistent and lacks conformance evidence. The documented CUDA primitive reverses nonce/counter positions, appears to omit RGB channels, and does not establish the claimed Salsa20-256 implementation. The security construction lacks nonce management and authentication, while the experimental conclusions depend on unmatched workloads and unsupported profiler/energy assertions.

These defects invalidate the principal correctness, security, and performance claims. They also persisted through a major response round in which several requested evaluations were deferred or answered by assertion. Repair would require a new implementation, formal test-vector validation, a complete benchmark rerun, and substantial reframing. I therefore recommend *Reject* rather than another ordinary revision. A new submission could be considered if it provides a conforming authenticated construction, reproducible evidence, and a contribution that remains meaningful after comparison with prior GPU Salsa20 and optimized baselines.

= Final Recommendation

#v(0.3em)
#rect(width: 100%, stroke: 1.2pt + red.darken(10%), inset: 12pt, fill: rgb("fff4f4"), [
  #align(center)[#text(size: 15pt, weight: "bold", fill: red.darken(15%))[REJECT]]
  #v(0.45em)
  The revised manuscript remains unsuitable for publication because its central cipher implementation, RGB coverage, nonce/authentication model, benchmark comparability, and comparative conclusions are not scientifically validated.
])
