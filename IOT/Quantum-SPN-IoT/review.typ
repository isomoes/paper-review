#import "@preview/basic-document-props:0.1.0": simple-page

// Document configuration
#let document-author = "isomoes"
#let ai-model = "GPT-5.6-sol"
#let paper-title = "A Depth-Oriented Quantum Resource Estimation Framework for Lightweight SPN Block Ciphers Toward Quantum-Resource-Aware IoT Security"
#let manuscript-id = "IOT-D-26-02530"

#set document(
  title: paper-title,
  author: document-author + " / " + ai-model,
  date: datetime.today(),
)

#set page(
  numbering: "1",
  number-align: center,
  margin: (x: 2.2cm, y: 1.6cm),
)

#set text(size: 10.5pt)
#set par(justify: true, leading: 0.68em)
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")
#show cite: set text(fill: blue)
#show figure.where(kind: table): it => [
  #it.caption
  #it.body
]

// Color shorthand functions
#let redt(content) = text(fill: red, content)
#let bluet(content) = text(fill: blue, content)
#let greent(content) = text(fill: green, content)
#let yellowt(content) = text(fill: yellow, content)
#let oranget(content) = text(fill: orange, content)
#let purplet(content) = text(fill: purple, content)
#let greyt(content) = text(fill: gray, content)
#let grayt(content) = text(fill: gray, content)

// Review scoring function
#let score-box(title, score, max-score: 10) = rect(
  width: 100%,
  stroke: 1pt,
  inset: 8pt,
  fill: luma(250),
  [#text(weight: "bold")[#title: ] #text(fill: blue, weight: "bold")[#score/#max-score]],
)

// Comment box function
#let comment-box(title, content) = rect(
  width: 100%,
  stroke: 1pt,
  inset: 10pt,
  [
    #text(weight: "bold", size: 11pt)[#title]
    #v(0.5em)
    #content
  ],
)

#align(center)[
  #text(size: 18pt, weight: "bold")[Academic Paper Re-Review Report]
  #v(0.5em)
  #text(size: 12pt)[
    Reviewer: #document-author \
    AI Model: #ai-model \
    Review Date: #datetime.today().display("[year]-[month]-[day]")
  ]
]

#v(1em)

#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]
  #v(0.5em)
  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    row-gutter: 0.35em,
    [*Paper Title:*], [#paper-title],
    [*Manuscript ID:*], [#manuscript-id],
    [*Journal:*], [Internet of Things],
    [*Review Round:*], [Revised manuscript verification],
    [*AI Model:*], [#ai-model],
    [*Recommendation:*], [#redt[*Major Revision*]],
  )
])

#v(0.8em)
#rect(width: 100%, stroke: red + 0.8pt, inset: 8pt, fill: rgb("fff5f5"), [
  *Review-scope notice.* This is a legacy, non-contract re-review because the original manuscript, immutable revision roadmap, author-adjudication sidecar, and revision-evidence bundle were not supplied. The prior reviews, response letter, marked revised manuscript, and public verification repository were examined. The submitted manuscript was not modified.
])

= Review Summary

The manuscript presents a depth-oriented logical quantum-resource estimation workflow for lightweight SPN block ciphers and a complete uLBC case study. The revision makes substantial and verifiable progress: it removes the former nonstandard count-times-depth indicator, separates gate-count and depth--width costs, normalizes cross-cipher cost models, makes pair-parallel and pair-serial scheduling consistent, reports scheduling extremes and encryption full depth, improves prior-art attribution, moderates IoT deployment claims, and provides a functioning public verification artifact. The displayed arithmetic in Tables 7, 12, 13, and 14 is internally consistent. Nevertheless, central methodological issues remain in the key-identification assumption, the formal treatment of measurement-assisted uncomputation, and the auditability of complete-oracle resource totals. I therefore recommend *Major Revision*.

The main required revisions are:

+ Correct the plaintext--ciphertext pair model. The present choice $r = ceil(k/n)$ does not imply overwhelming-probability key uniqueness when $r n = k$.
+ Separate the measurement-assisted 4T dynamic-circuit semantics from the exact-unitary 7T construction; the former cannot be written simply as $U_("unc") = U_("fwd")^dagger$ on the stated Hilbert space.
+ Add a paper-visible component ledger for comparator, phase marking, reversal, diffusion, coherent key fanout, single-qubit operations, measurements, depth, and width.
+ Either propagate the exact-unitary sensitivity through full-depth, width, $D W$, and search costs or explicitly limit it to T resources.
+ Version the public artifact and state clearly that it supports verification but does not reproduce the complete production QuSAT and CNOT-optimization pipeline.

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  row-gutter: 0.5em,
  score-box("Innovation", 7),
  score-box("Technical Quality", 5),
  score-box("Validation", 6),
  score-box("Reproducibility", 6),
  score-box("Writing Quality", 8),
  score-box("Overall", 6),
)

= Detailed Review

== Innovation Assessment

#score-box("Innovation Assessment", 7)

The paper's strongest contribution is not a new S-box synthesis principle in isolation, but the integration of bounded AND-depth search, clean reversible mapping, liveness-based reuse, CNOT scheduling, complete-oracle accounting, and deployment-oriented interpretation. The revision correctly acknowledges that SAT-based S-box optimization and low multiplicative-complexity results predate this work. It also narrows the novelty claim from universal superiority to a verified depth-oriented trade-off.

#comment-box("Assessment", [
  The integrated workflow is potentially publishable and relevant to logical quantum-resource analysis. The paper should continue to avoid presenting the bounded QuSAT search, the simple deployment threshold, or the 4T model itself as independently novel. The contribution is strongest when framed as a transparent, metric-consistent integration and uLBC case study.
])

== Technical Quality Assessment

#score-box("Technical Quality Assessment", 5)

#comment-box("Major Comment 1 — Key uniqueness and Grover iterations", [
  Section 2.5 defines $r = ceil(k/n)$ and states that this supplies enough plaintext--ciphertext pairs to identify the key; Section 4.4 describes this as an overwhelming-probability convention. For the three evaluated variants, $r n = k$. Under an ideal-cipher/random-function approximation, the expected number of false keys matching all pairs is approximately $lambda = 2^(k-r n) = 1$. The probability of no false key is therefore approximately $e^(-1)$, not overwhelming. Multiple marked keys also alter the optimal Grover iteration count and do not guarantee recovery of the original key.

  *Required action:* define a target failure probability $epsilon$ and choose enough pairs to satisfy a justified bound such as $r n - k >= log_2(1/epsilon)$, or explicitly analyze the multiple-solution case. Recompute comparator, fanout, depth, width, $G_("iter")$, $D W$, and all affected search-cost tables.
])

#v(0.6em)
#comment-box("Major Comment 2 — Measurement-assisted versus unitary semantics", [
  Section 3.1.2 adopts Gidney-style measurement, reset, and classical feed-forward for zero-T uncomputation, but the formal development calls the mapping a three-phase unitary and writes $U_("unc") = U_("fwd")^dagger$. Measurement-assisted erasure is not that unitary inverse on the displayed Hilbert space. It may implement the intended coherent map as a dynamic circuit or quantum channel with conditional corrections, but this must be formulated separately from the exact-unitary 7T realization.

  *Required action:* revise Eqs. (5)--(11), the state-evolution notation, Proposition 1, and associated proofs to distinguish the measurement-assisted channel/isometry from the exact-unitary construction.
])

#v(0.6em)
#comment-box("Major Comment 3 — Complete-oracle accounting", [
  The revision now states that comparison, phase marking, comparator reversal, encryption uncomputation, and diffusion are included. However, Tables 12 and 13 provide only aggregate totals. The manuscript does not give comparator and diffusion circuits, AND-tree formulas, coherent key-fanout costs, phase-kickback ancilla preparation, separate $N_("1q")$ and $N_M$ values, or dependency schedules supporting the non-encryption full-depth terms. Consequently, the exact CNOT totals and $G_("iter")$ values cannot be reconstructed from the paper.

  *Required action:* add a component-by-component complete-iteration table and explicit formulas. Every reported T, CNOT, one-qubit, measurement, depth, and width total should be derivable from paper-visible quantities.
])

#v(0.6em)
#comment-box("Moderate Comment — Sensitivity scope and operation weighting", [
  The 7T sensitivity is propagated to T-count and T-depth but not to full depth, width, $D W$, or headline search costs. In addition, $G_("iter") = N_T + N_("CNOT") + N_("1q") + N_M$ assigns unit weight to heterogeneous operations while measurement latency and physical fault-tolerant overhead are excluded. This is acceptable as a counted logical-operation upper bound, but not as a technology-neutral fault-tolerant cost. Rename and position it accordingly, report its components, and label all headline values by model.
])

== Experimental Assessment

#score-box("Experimental and Validation Assessment", 6)

The revised Table 11 adds LIGHTER-R and DORCIS comparisons and expands the S-box set with RECTANGLE and KLEIN. The public repository was reachable at commit `1525eba77422cb7116990d0d6076780249bab676`. Six fixed SMT instances passed under Z3 4.15.4, and all 13 released tests passed. The released S-box, MixColumn, uLBC known-answer, complete-oracle, Table 10, and external-validation checks were reproducible.

#comment-box("Validation boundary", [
  These checks establish internal consistency of the released witnesses, formulas, and frozen outputs. They do not independently validate the complete scientific model. The LIGHTER-R/DORCIS comparison is primarily S-box-level and uses different in-place/clean objectives; it is not a full-cipher or complete-oracle cross-tool validation. The manuscript or supplement should document tool versions, settings, clean-wrapper conversion, seeds, exhaustive checks, and this scope boundary.
])

#v(0.6em)
#comment-box("Reproducibility boundary", [
  The repository contains fixed SMT2 instances, witnesses, netlists, reference encoding, table-recomputation scripts, and verification tests. Its own scope states that the production QuSAT generator, search-order and symmetry-breaking refinements, model ranking, automated CNOT-provenance tooling, cluster launchers, and one-click pipeline are withheld. The artifact therefore supports verification but not end-to-end regeneration of the complete optimization workflow. Cite a durable release or commit in the paper, provide a file-to-claim manifest, and state this limitation explicitly.
])

== Writing Quality Assessment

#score-box("Writing Quality Assessment", 8)

The revision is considerably clearer than the version described by the original reviewers. Terminology is better controlled, prior work is properly acknowledged, scheduling assumptions are explicit, and deployment claims are appropriately qualified. The energy and protocol-integration paragraph is useful for an IoT readership.

Remaining presentation issues are technical rather than stylistic:

- Replace the phrase “enough block-cipher evaluations to identify the key” with a quantified statement tied to a false-key probability.
- Avoid describing the measurement-assisted construction as a unitary inverse.
- Label Table 12's search values explicitly as 4T logical-model results.
- State directly in the Data and Code Availability section what is released, what is withheld, and which commit or archival DOI corresponds to the reviewed manuscript.
- Add a concise notation table for encryption-, oracle-, and Grover-level quantities.

== Verification of the Original Review Comments

#figure(
  kind: table,
  caption: [Disposition of the sixteen original reviewer comments.],
  table(
    columns: (0.8fr, 2.6fr, 1.2fr),
    inset: 5pt,
    stroke: 0.5pt,
    align: (left, left, center),
    table.header([*Ref.*], [*Concern*], [*Verified status*]),
    [R2-1], [Nonstandard Grover metric], [#greent[*Fully*]],
    [R2-2], [Incomplete oracle accounting], [#oranget[*Partially*]],
    [R2-3], [Fault-tolerant sensitivity], [#oranget[*Partially*]],
    [R2-4], [Limited external validation], [#oranget[*Partially*]],
    [R2-5], [Overstated IoT deployment], [#greent[*Fully*]],
    [R2-6], [Public reproducibility materials], [#oranget[*Partially*]],
    [R2-7], [Overstated resilience/suitability], [#greent[*Fully*]],
    [R3-1], [Mixed comparison models], [#greent[*Fully*]],
    [R3-2], [Parallel depth/width inconsistency], [#greent[*Fully*]],
    [R3-3], [Nonstandard indicator/AES comparison], [#greent[*Fully*]],
    [R3-4], [Prior-art attribution], [#greent[*Fully*]],
    [R3-5], [Solver and artifact details], [#oranget[*Partially*]],
    [R3-6], [Scheduling extremes], [#greent[*Fully*]],
    [R3-7], [Encryption full depth], [#greent[*Fully*]],
    [R3-8], [Screening terminology], [#greent[*Fully*]],
    [R3-9], [Energy/protocol discussion], [#greent[*Fully*]],
  ),
)

Overall, 11 comments are fully addressed and 5 are partially addressed. None is wholly unaddressed. The recommendation remains Major Revision because the residual issues affect the central resource and security model rather than only exposition.

= Final Recommendation

#rect(width: 100%, stroke: 1.2pt + red, inset: 12pt, fill: rgb("fff5f5"), [
  #align(center)[#text(size: 15pt, weight: "bold", fill: red)[MAJOR REVISION]]
  #v(0.5em)
  The revised paper is substantially stronger and its displayed arithmetic is internally consistent. Acceptance remains premature until the key-identification assumption is corrected, the measurement-assisted formalism is repaired, and complete-oracle totals become auditable from the manuscript.
])
