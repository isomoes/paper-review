#import "@preview/basic-document-props:0.1.0": simple-page

#let document-author = "isomoes"
#let paper-title = "Design and FPGA Implementation of a Low-Latency Binary Ring-LWE Cryptoprocessor for Post-Quantum Cryptography"
#let manuscript-id = "Not provided in the submitted manuscript"
#let venue = "The Journal of Supercomputing"
#let recommendation = "Reject"

#set document(
  title: paper-title,
  author: document-author,
  date: datetime.today(),
)

#set page(
  numbering: "1",
  number-align: center,
  margin: (x: 2.2cm, y: 1.7cm),
)
#set text(size: 10.5pt)
#set par(justify: true, leading: 0.68em)
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 13pt, weight: "bold")

#let comment-box(title, body) = rect(
  width: 100%,
  stroke: 0.8pt,
  radius: 2pt,
  inset: 9pt,
  [
    #text(weight: "bold", size: 11pt)[#title]
    #v(0.35em)
    #body
  ],
)

#align(center)[
  #text(size: 18pt, weight: "bold")[Academic Paper Review Report]
  #v(0.5em)
  #text(size: 11pt)[
    Reviewer: #document-author \
    Review Date: #datetime.today().display("[year]-[month]-[day]")
  ]
]

#v(0.8em)

#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]
  #v(0.5em)
  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    row-gutter: 0.35em,
    [*Paper Title:*], [#paper-title],
    [*Manuscript ID:*], [#manuscript-id],
    [*Venue:*], [#venue],
    [*Review Round:*], [Round 1],
    [*Date:*], [#datetime.today().display("[year]-[month]-[day]")],
    [*Recommendation:*], [#text(weight: "bold")[#recommendation]],
  )
])

= Review Summary

The manuscript proposes a Binary Ring-LWE FPGA architecture using two parallel G circular shift registers and two computation paths. It claims to produce two coefficients per clock, reducing standalone kernel latency from 257 to 129 cycles for $N = 256$, and maps key generation, two ciphertext computations, and decryption onto a shared datapath. The implementation is reported on a Xilinx Artix-7 XC7A100T, where the four-stage benchmark latency decreases from 2068 to 1556 cycles with increased LUT and flip-flop use and unchanged BRAM use.

The shared-kernel decomposition and same-device comparison are useful engineering foundations. Nevertheless, the paper does not yet establish that the stated coefficient ordering computes the required negacyclic convolution; its principal two-lane novelty substantially overlaps directly relevant prior work; and its broad post-quantum security framing is unsupported for the exact sparse parameters. Validation, FPGA reproducibility, performance arithmetic, and system boundaries also require fundamental reconstruction. I therefore recommend *Reject*. A substantially redeveloped manuscript could be considered as a fresh submission after the arithmetic, novelty, and security foundations are positively established.

= Strengths

+ *Clear engineering objective.* The manuscript makes the latency--area tradeoff explicit and reports the added logic cost of parallelism rather than presenting latency alone.
+ *Useful shared-datapath mapping.* Table VII maps key generation, both encryption components, and decryption onto the common $W = G dot B + D + T$ kernel in an intelligible way.
+ *Appropriate same-device starting point.* The main baseline and proposed designs are implemented on the same XC7A100T, and the manuscript correctly notes that ALMs and LUTs should not be directly equated across FPGA families.
+ *Visible latency decomposition.* Equations (32)--(39) and Table VIII distinguish kernel, phase, and four-stage cycle counts, which makes the claimed bottleneck inspectable.
+ *Plausible two-lane scheduling result.* A reduction from 257 to 129 kernel cycles is consistent with ideal two-lane processing, provided that coefficient mapping and RTL equivalence are demonstrated.

= Major Comments

#comment-box("1. Negacyclic coefficient mapping and dual-CSR correctness are not established", [

*Location/evidence:* Sections III--IV; Equations (3), (13)--(15), and (21)--(29); Figure 2.

With the stated natural-order initialization $G^(0) = [g_0, dots, g_(N-1)]$, Equation (25) gives $u_0 = sum_i b_i g_i$. Equation (3), however, requires the constant coefficient $b_0 g_0 - sum_(i > 0) b_i g_(N-i)$. The manuscript does not state a reversal or permutation of $B$ that would reconcile these expressions. In addition, the text claims that each CSR performs a double negacyclic rotation, while Equations (23)--(24) define only a one-position update; CSR1 initialization and the signs of both wrapped coefficients are absent. The baseline narrative also describes an outer-product accumulation, whereas the proposed narrative describes two complete dot products per cycle.

This issue matters because it affects the correctness of the central arithmetic operation and therefore every reported cryptographic phase and performance result.

*Minimum remedy:* Specify the exact coefficient-to-register ordering for $G$ and $B$; provide explicit two-position recurrences, including both wrapped signs and CSR1 initialization; give a cycle-accurate schedule and output-valid timing; include a complete $N = 4$ hand trace; and publish bit-exact RTL/reference equivalence evidence. If the mapping changes, re-synthesize and regenerate all results.

])

#v(0.6em)
#comment-box("2. The principal novelty claim overlaps directly relevant prior work", [

*Location/evidence:* Introduction contribution 1; Section IV-A; Equations (21)--(29); Tables III and VI; References.

The 2024 article #link("https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/qtc2.12110")[“x²DL: A high throughput architecture for binary-ring-learning-with-error-based post quantum cryptography schemes”] reports dual parallel LFSR structures, even/odd coefficient grouping, two output coefficients per clock, $N/2$-cycle BRLWE multiplication, and evaluation at $(n, q) = (256, 256)$. These features closely overlap the manuscript's stated novelty. The 2025 IEEE TETC area-time study (DOI 10.1109/TETC.2024.3482324) is also absent from the comparison.

This omission prevents assessment of originality and state-of-the-art significance. A G-CSR/LFSR implementation distinction or shared full-protocol integration might remain contributory, but the paper does not currently establish that boundary.

*Minimum remedy:* Cite and analyze the 2024 and 2025 work; provide a feature-by-feature claim chart covering register organization, rotation network, loading, output schedule, clock-edge use, protocol scope, resources, and latency; add controlled or resource-matched comparisons where feasible; and retain only demonstrably distinct novelty claims.

])

#v(0.6em)
#comment-box("3. The post-quantum security framing is unsupported for the implemented parameters", [

*Location/evidence:* Abstract; Sections II-A--B; Sections VII--VIII; Conclusion.

The manuscript uses $N = 256$, $q = 256$, and sparse binary secret/error polynomials of approximate Hamming weight 12, but gives no exact sampler, classical or quantum attack-cost estimate, decryption-failure rate, or mapping to a standardized scheme. If the private key $r_2$ has fixed weight 12, its support contains $binom(256, 12)$ possibilities, whose base-2 logarithm is approximately 66.79 bits, before specialized sparse-secret or ring attacks. The manuscript also calls $q$ prime even though 256 is composite. NIST's standardization of lattice-based schemes does not validate this exact Binary Ring-LWE instance.

This matters because functional arithmetic equality does not demonstrate a modern security level, and the title and abstract make broad security claims.

*Minimum remedy:* Define the exact distributions and generation algorithms; correct the algebraic domain to $(ZZ/256ZZ)[x] / (x^256 + 1)$; provide current concrete classical and quantum estimates covering relevant sparse-secret and ring attacks; define the target security level and decryption-failure behavior; and re-evaluate hardware if parameters change. Alternatively, remove security-strength and standardization implications and consistently frame the work as a non-security-parameterized arithmetic prototype.

])

#v(0.6em)
#comment-box("4. Functional validation is not auditable", [

*Location/evidence:* Sections VII-C and VIII-A, especially “all evaluated test cases.”

The manuscript does not report the number or generation of test vectors, random seeds, oracle implementation, comparison granularity, mismatch count, assertions, functional/code coverage, or hardware-capture procedure. Comparing FPGA outputs with post-synthesis simulation is not equivalent to checking both against an independent bit-accurate oracle. Sparse or symmetric vectors may also fail to expose coefficient-order and wrap-sign errors.

*Minimum remedy:* Report deterministic and random test counts, seeds, oracle source/version, pass criteria, and failures. Include all-zero/all-one operands, sparse-weight extremes, both negacyclic wrap signs, coefficients 0/1/255, accumulator extremes, decoder boundaries 63/64/192/193, back-to-back FSM operation, and BRAM hazards. Add exhaustive small-ring tests, seeded $N = 256$ campaigns, assertions/coverage, known-answer tests, and reproducible RTL/software artifacts.

])

#v(0.6em)
#comment-box("5. FPGA implementation and baseline comparison are not reproducible", [

*Location/evidence:* Section VII-A; Tables I, II, IV--VI, and IX.

“The standard Vivado design flow” does not identify the Vivado release, complete FPGA part/package/speed grade, XDC constraints, clock uncertainty, implementation directives, PVT corner, WNS/TNS, critical path, Fmax derivation, or seed policy. The provenance of the Artix-7 baseline is unclear: it may be original RTL, a port, or a reimplementation. Resource totals do not specify whether LUTRAM, DSPs, wrappers, clocking, VIO/ILA, BRAM controllers, or debug logic are included.

*Minimum remedy:* Disclose the complete tool and constraint flow, timing reports, limiting path, seeds or multi-seed distribution, hierarchical utilization, and inclusion rules. State baseline provenance and modifications. Run both designs with identical flows and report separately an iso-frequency comparison and independently maximized-Fmax results.

])

#v(0.6em)
#comment-box("6. Performance, delay, throughput, and ADP values are inconsistent", [

*Location/evidence:* Abstract; Equation (30); Tables V, VIII, and IX; Section VIII-B; Conclusion.

Using Table IX's stated formula, $55.278 "MHz" / 2068$ gives approximately 26,730.17 operations/s, not 26,370, and $55.586 "MHz" / 1556$ gives approximately 35,723.65 operations/s, not 35,816. The corresponding gain is about 33.65%, not 35.8%. The printed delays 9.352 and 6.998 microseconds are phase delays because they use 517 and 389 cycles; total delays are approximately 37.4109 and 27.9927 microseconds. The reported ADP values are close to FF count multiplied by phase delay despite being labeled `LUT-cycles`. LUT count multiplied by total cycles gives 34,647,272 and 31,831,092 LUT-cycles, an improvement of approximately 8.13%, not 17.8%. Tables V and VI additionally conflate area-cycle and area-time products.

*Minimum remedy:* Define kernel, phase, and total boundaries; report area-cycle and area-time products separately; regenerate every derived value from one auditable specification; and propagate corrected numbers consistently through the abstract, tables, discussion, and conclusion.

])

#v(0.6em)
#comment-box("7. “Complete cryptoprocessor” exceeds the demonstrated system boundary", [

*Location/evidence:* Abstract; Sections VI--VIII; Table IX; Conclusion.

The hardware consumes pre-existing $r_1$, $r_2$, and $e_1$--$e_3$ values from BRAM. It does not implement or time an entropy source, DRBG, sparse sampler, key provisioning, zeroization, deployment host interface, input/output transfer, or failure/retry behavior. VIO/ILA and one reported I/O do not define a deployable interface. Side-channel leakage, fault behavior, and energy are not evaluated.

*Minimum remedy:* Either rename and consistently delimit the artifact as a BRLWE arithmetic accelerator with a protocol-flow controller, or integrate and account for secure randomness, sampling, interfaces, transfers, lifecycle operations, and the claimed implementation-security boundary. Report kernel, preloaded four-stage, and deployable end-to-end performance separately.

])

#v(0.6em)
#comment-box("8. Correctness, scaling, memory scheduling, and deployment scope need further evidence", [

*Location/evidence:* Section II-B; Figure 3; Equations (10)--(11) and (32)--(39); Sections VI--VIII.

“Approximate Hamming weight” defines neither a deterministic noise cap nor a probability distribution, so it does not by itself ensure decoding. Only one parameter/device point is evaluated, although dual-lane routing, adder depth, fanout, and BRAM bandwidth may scale nonlinearly. No BRAM port/address schedule or annotated waveform proves the fixed PREBRAM, LOAD, LOADCSR, COMPUTE, POSTPROC, and STORE cycle costs. Key retention, reset/zeroization, debug exposure, side-channel leakage, and faults are outside the stated evidence.

*Minimum remedy:* Define the exact samplers and decoder endpoints; derive a deterministic bound or quantified decryption-failure rate; state supported $N/q$ ranges and even-$N$ assumptions; add scaling points or limit claims; provide a state-by-state memory schedule and waveform; and clearly define or narrow the deployment threat boundary.
])

= Minor Comments

+ *Abstract and conclusion:* Correct the malformed transition from $N + 1$ to $N/2 + 1$ and remove the stray “2improvement” artifact.
+ *Introduction contribution 3:* Reconcile the isolated 1552-cycle value with Equations (37)--(39), Tables VIII--IX, and the dominant 1556-cycle result.
+ *Section II-A:* Remove the false statement that $q$ is prime when the implementation uses $q = 256$; state the actual modulus assumptions.
+ *Section II-D and Figure 1:* Correct party roles. The party generating the public key, retaining $r_2$, receiving ciphertext, and decrypting is the receiver/key owner; the encrypting party is the sender.
+ *Equation (8):* Repair the visibly malformed message-encoding equation and define all symbols and rounding/floor operations.
+ *Equations (5)--(9):* State coefficient reduction modulo $q$ consistently, not only polynomial reduction modulo $x^N + 1$.
+ *Sections III and VI:* Remove duplicated sentences and repeated operand-mapping explanations.
+ *Terminology:* Use one consistent form for Binary Ring-LWE/BRLWE, G-CSR, high-speed, low-latency, computation latency, phase latency, and total latency.
+ *Tables:* Define whether BRAM is reported in RAMB18 equivalents, whether LUT counts include LUTRAM, and list omitted zero-count resource categories such as DSPs.
+ *Figures 2--3:* Add signal widths, memory ports, pipeline/valid timing, and state-cycle annotations sufficient to relate the diagrams to the equations.
+ *Writing quality:* Correct pervasive grammar, spacing, capitalization, duplicated words, broken hyphenation, and artifacts such as “Heer,” “is becomes,” and `textitLasya`.
+ *Related work:* Update the literature beyond the eight references and distinguish standardized Module-LWE schemes from this nonstandard BRLWE construction.

= Questions for Authors

+ What exact $G$ and $B$ register contents and partial sums occur for every cycle at $N = 4$, and how do they reproduce Equation (3)?
+ Is the Hamming weight of each of $r_1$, $r_2$, and $e_1$--$e_3$ fixed, capped, or an average? Which concrete classical and quantum estimates follow from that exact sampler?
+ How does the proposed dual-G-CSR architecture differ technically and chronologically from the 2024 x²DL dual-LFSR architecture?
+ Were the Artix-7 baseline results obtained from original RTL or a reimplementation, and were both designs run under identical constraints, directives, and seeds?
+ What formula and resource quantity produced the Table IX ADP values 188,594 and 154,980?
+ How many independent vectors were executed in simulation and on hardware, and what coverage, mismatch count, and observed decryption-failure result were obtained?
+ Are random polynomials generated on-chip? If not, why are sampling and transfer costs excluded while the artifact is called a complete cryptoprocessor?

= Confidential Comments to Editor

The Journal of Supercomputing identifies its scope as high-performance computer design, analysis, and use, including computer architecture, systems, and performance methods (#link("https://link.springer.com/journal/11227")[journal page]). The FPGA-accelerator topic is therefore plausibly relevant. Fit is nevertheless only partial in the present form because the paper does not establish an advanced new architecture, scalability beyond one parameter/device point, or system-level high-performance significance. The rejection recommendation is driven primarily by technical readiness rather than scope. Two critical challenges are validated: the manuscript does not establish the coefficient/register mapping of its central negacyclic computation, and it does not substantiate security for its exact sparse parameter set. A third critical issue is the close overlap between the main novelty claim and the 2024 x²DL architecture. No critical concern was resolved by the submitted evidence.

A normal Major Revision would assume a stable contribution that can be validated through bounded additions. Here, addressing the concerns may change the RTL, require complete re-verification and synthesis, replace or narrow the security framing, and reconstruct the novelty claim against direct prior art. I therefore recommend *Reject*, while encouraging a fresh submission if the authors provide a corrected cycle-level derivation, auditable artifacts and FPGA flow, current comparisons, defensible security scope, and internally consistent performance results.
