#import "@preview/basic-document-props:0.1.0": simple-page

// Chinese font configuration
// #set text(
//   font: (
//     "Source Han Serif SC",
//     "Source Han Sans SC",
//   ),
//   lang: "zh",
//   region: "cn",
// )

// Document configuration
#let document-author = "isomo"

// Document setup
#set document(
  title: "High-Efficiency Hardware Architectures for the Areion Permutation Family",
  author: document-author,
  date: datetime.today(),
)

// Page setup
#set page(
  numbering: "1",
  number-align: center,
)

// Heading styles
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")

// Citation styling - make citations blue and clickable-looking
#show cite: set text(fill: blue)

// Table caption positioning - put captions above tables
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
#let score-box(title, score, max-score: 10) = rect(width: 100%, stroke: 1pt, inset: 8pt, fill: luma(250), [
  #text(weight: "bold")[#title: ] #text(fill: blue, weight: "bold")[#score/#max-score]
])

// Comment box function
#let comment-box(title, content) = rect(width: 100%, stroke: 1pt, inset: 10pt, [
  #text(weight: "bold", size: 11pt)[#title]
  #v(0.5em)
  #content
])

// Title page
#align(center)[
  #text(size: 18pt, weight: "bold")[
    Academic Paper Review Report
  ]
  #v(0.5em)
  #text(size: 12pt)[
    Reviewer: #document-author
    Review Date: #datetime.today().display("[year]-[month]-[day]")
  ]
]

#v(1em)

// Paper information section
#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]

  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    [*Paper Title:*], [High-Efficiency Hardware Architectures for the Areion Permutation Family],
    [*Manuscript ID:*], [TCAS-II-27474-2026],
    [*Submission ID:*], [71376c25-ea5e-46f3-8573-de33a3df5343],
    [*Journal/Conference:*], [IEEE Transactions on Circuits and Systems II: Express Briefs],
  )
])

#v(1em)

= Review Summary

This manuscript presents hardware architectures for the Areion permutation family, including a lightweight datapath for Areion-256, a high-throughput datapath for Areion-512, and a sponge-based hash extension named AreionS. The topic is relevant to TCAS-II, but the main technical contribution is not strong enough for publication in its current form. The key datapath optimizations in Section III are essentially simple datapath splitting and operation reordering: the Areion-256 design shortens a long combinational path and reuses hardware, while the Areion-512 design similarly shortens the critical path to increase the achievable clock frequency. These transformations are technically plausible, but they are too straightforward to establish a sufficiently novel architecture. More importantly, the claimed throughput advantage is not convincingly demonstrated because the cycle count is also increased, so a shorter critical path alone does not prove a better overall architecture. The performance comparison is also unfair because the baselines are not evaluated under the same configuration, process, synthesis flow, or experimental environment. #purplet([My recommendation is reject.])

The main issues are as follows: (1) the main architectural idea is too simple and resembles standard critical-path splitting, resource sharing, and operation reordering rather than a substantive new datapath design; (2) the Areion-256 result is largely expected because using fewer SubBytes resources and splitting the long path naturally reduces area and delay while increasing cycle count; (3) the Areion-512 result is not a clear throughput contribution because the design trades a shorter critical path for an additional cycle, and the paper does not convincingly analyze the frequency-cycle trade-off; (4) the comparison against SHA-256, Ascon-Hash, and HarakaS is not fair because it relies on different technologies, libraries, constraints, and reported data; and (5) several security and performance claims, especially around AreionS and hardware superiority over existing hash functions, are stronger than the evidence supports.


= Detailed Review

== Innovation Assessment

#score-box("Innovation Score", "3", max-score: 10)

The manuscript addresses a relevant problem: hardware implementation of the Areion permutation family and its use for short-input hashing. However, #oranget([the proposed architectural contribution is weak.]) The main datapath optimizations in Section III are mostly straightforward transformations of AES-like round logic rather than clearly novel circuit architectures.

For Areion-256, the design splits a long datapath and reuses a single SubBytes block. #purplet([The resulting area reduction is largely expected because fewer nonlinear hardware resources are instantiated, and the shorter critical path is also a direct consequence of cutting the original long combinational path.]) This is a conventional area-cycle trade-off rather than a sufficiently original architecture.

For Areion-512, the paper uses a similar idea: reorder the operations so that the critical path contains fewer SubBytes stages and the clock frequency can increase. However, this also increases the number of cycles from 15 to 16. #oranget([Therefore, the claimed high-throughput contribution is not compelling unless the authors show a rigorous frequency-cycle trade-off and demonstrate that the throughput gain is robust under fair constraints.]) A shorter critical path by itself is not enough to establish a meaningful throughput innovation.

The AreionS extension also appears to be a direct application of a known sponge mode to an existing permutation. #purplet([Taken together, the paper does not provide enough novelty for acceptance: the main contribution is a set of predictable datapath trade-offs rather than a new or deep circuit-architecture technique.])


== Technical Quality Assessment

#score-box("Technical Quality Score", "4", max-score: 10)

The proposed datapath transformations are generally understandable, but their technical depth is limited. #bluet([For Areion-256, reusing a single SubBytes block can reduce area and shorten the combinational path, but this comes at the cost of doubling the cycle count. For Areion-512, moving one SubBytes stage across the round boundary can reduce the critical path, but it also increases the number of cycles.]) These are basic hardware trade-offs that should be analyzed more carefully rather than presented as strong architectural contributions.

The central technical problem is that the paper does not convincingly show that these trade-offs lead to a superior design under realistic criteria. #purplet([For Areion-512, the authors emphasize the shorter critical path and higher frequency, but the design loses the lower cycle count of the reference architecture.]) Throughput depends on both frequency and cycle count, so the contribution should be judged by the full latency-throughput-area-power trade-off, not by critical path reduction alone.

The paper also lacks a sufficiently rigorous equivalence and transformation analysis. Figures 2 and 4 illustrate the modified datapaths, but the manuscript should explain exactly which operations are reordered, which state values are delayed, and why the transformed design is functionally identical to the original Areion permutation.

The security discussion around AreionS is also weak. The statement that sponge use is cryptographically secure because the original proposal shows resistance to linear, differential, and zero-sum distinguishers is too strong. #oranget([Absence of several known distinguishers is not by itself a proof that the resulting sponge construction achieves the stated security level.]) The authors should clarify the security model and state the exact assumptions behind the claimed security level.

Finally, the implementation details are not sufficiently reproducible. The paper does not report enough about synthesis constraints, timing corners, clock uncertainty, switching activity for power, or whether all designs include comparable control logic and padding/hash wrapper overhead. #purplet([For a paper whose main claim is hardware efficiency, these omissions substantially weaken the technical quality.])


== Experimental Assessment

#score-box("Experimental Score", "3", max-score: 10)

The intra-paper comparison between Areion-256-ref and Areion-256-com, and between Areion-512-ref and Areion-512-hth, is useful but not sufficient. #oranget([The results mostly confirm expected trade-offs: splitting a long datapath and reusing hardware reduces area or delay but increases cycle count; shortening the critical path can increase frequency but may lose cycle efficiency.]) These results do not by themselves establish a strong architectural contribution.

The larger experimental weakness is the unfair comparison against SHA-256, Ascon-Hash, and HarakaS. #purplet([The paper relies on cross-paper and cross-technology comparisons, including ROHM 180 nm, SkyWater 130 nm, OCL 45 nm, STM 130 nm, and TSMC 28 nm.]) These results are not obtained under the same configuration, standard-cell library, synthesis constraints, voltage, timing corner, area definition, or optimization goal. Therefore, they cannot support the strong conclusion that Areion-based hash functions outperform established standards.

The SHA-256 comparison is especially weak because the compared implementations use different process nodes and appear to include different design boundaries. Similarly, the Ascon-Hash comparison is incomplete because the exact throughput of the referenced Ascon implementation is not reported, yet the manuscript infers that AreionS likely has higher throughput. #oranget([A claim based on inference rather than measured or same-flow experimental data should not be presented as an experimental conclusion.])

The HarakaS comparison is also problematic. AreionS is synthesized in OCL 45 nm while HarakaS is reported in TSMC 28 nm. The manuscript states that implementing AreionS in 28 nm would reduce delay and boost throughput, but this is speculative. #purplet([Without same-node synthesis or a validated scaling methodology, this comparison should not be used to claim superiority.])

The evaluation also lacks the metrics needed to judge the claimed efficiency. Power and energy are not consistently reported for the hash comparisons, and there is no energy-per-bit, throughput-per-watt, matched-frequency power, or module-level breakdown. #purplet([Because the proposed designs trade area, frequency, and cycle count, these missing metrics are central rather than optional.])

Overall, #oranget([the experimental section does not provide a fair or convincing basis for the paper's main performance claims.]) This is a major reason for rejection.


== Writing Quality Assessment

#score-box("Writing Quality Score", "5", max-score: 10)

The manuscript is mostly readable and the structure is suitable for an Express Brief: introduction, preliminaries, proposed datapaths, hash-function application, and conclusion. The figures are useful for understanding the high-level datapaths, and the tables summarize the main results compactly. #bluet([The paper is generally understandable to readers familiar with AES-based cryptographic hardware.])

However, several parts of the writing should be revised for precision. #oranget([Some claims are overstated relative to the evidence.]) Examples include the assertion that AreionS is cryptographically secure, the conclusion that Areion-based hash functions significantly outperform established standards, and the speculation that 28 nm implementation would substantially narrow the throughput gap with HarakaS. These claims are particularly problematic because the core experiments are not conducted in a fair same-flow environment.

The notation and algorithm description also need improvement. Algorithm 1 should define `pad`, `Trunc256`, state size, block order, output length handling, and any domain-separation bits more precisely. The manuscript should also use consistent terminology for rounds, cycles, and clock cycles, especially where Areion-512-hth is described as requiring 16 rounds while the original algorithm has 15 rounds.

There are also presentation issues. The manuscript appears to retain template artifacts such as `JOURNAL OF LATEX CLASS FILES, VOL. 14, NO. 8, AUGUST 2021`, placeholder copyright text, and a manuscript received/revised line from 2021. #purplet([These should be removed before publication.]) Some line-break artifacts and hyphenation issues are visible in the converted manuscript and should be checked carefully.


= Specific Revision Suggestions

== Major Issues

+ *Insufficient architectural novelty:* The datapath optimizations in Section III are too simple. Areion-256 mainly splits a long path and reuses SubBytes hardware, while Areion-512 mainly shortens the critical path by reordering operations. These are standard hardware trade-offs rather than strong new architectural contributions.

+ *Unconvincing throughput claim:* For Areion-512, the shorter critical path comes with an increased cycle count. Since throughput depends on both clock frequency and cycle number, the paper does not sufficiently prove that the proposed design is fundamentally high-throughput rather than simply trading cycles for frequency.

+ *Unfair performance comparison:* The comparisons with SHA-256, Ascon-Hash, and HarakaS are not conducted under the same experimental configuration, process node, standard-cell library, synthesis constraints, or implementation boundary. Therefore, the claimed performance superiority is not convincing.

+ *Weak support for AreionS:* The sponge-based AreionS construction is not specified or justified rigorously enough, and its security and performance claims are not sufficiently supported.

+ *Insufficient reproducibility:* The manuscript lacks key synthesis and implementation details, including timing corners, voltage, switching activity, exact constraints, and whether wrapper/control logic is included consistently.


== Minor Issues

+ *Remove template artifacts:* The manuscript still shows `JOURNAL OF LATEX CLASS FILES`, placeholder copyright text, and old received/revised dates.

+ *Define all algorithmic primitives:* In Algorithm 1, define the exact padding rule, `Trunc256`, message block ordering, output length handling, and state initialization.

+ *Clarify terminology:* Distinguish algorithmic rounds from hardware cycles, especially for Areion-512-hth and the final additional processing step.

+ *Moderate speculative statements:* Avoid statements such as expected 28 nm improvements unless a scaling model or same-node synthesis result is provided.

+ *Add module-level breakdowns:* A small table separating SubBytes, linear layers, registers, controller, and wrapper logic would make the area and timing claims easier to evaluate.

+ *Improve table captions and comparison notes:* Each comparison table should state technology node, voltage, timing corner, whether area is pre-layout or post-layout, and whether control and padding logic are included.


= Review Comments

== Comments to Authors

This paper studies hardware architectures for the Areion permutation family and proposes a lightweight Areion-256 datapath, a high-throughput Areion-512 datapath, and a sponge-based hash extension named AreionS. #bluet([The topic is relevant to cryptographic hardware design.]) However, the current manuscript does not provide a sufficiently strong technical contribution for publication.

#purplet([My main concern is that the key datapath contribution is too simple.]) The Areion-256 architecture mainly splits a long datapath and reuses SubBytes hardware. This naturally reduces area and critical-path delay, but it also increases the number of cycles. The Areion-512 architecture follows a similar idea: it shortens the critical path and increases the possible clock frequency, but it loses the lower cycle count of the reference design. These are standard hardware trade-offs and do not establish a strong new architecture.

The throughput claim is therefore not convincing. A shorter critical path alone does not prove higher throughput when the cycle count also changes. The paper should analyze the full relationship among frequency, cycles, area, power, and latency, but the current evaluation mainly emphasizes favorable metrics.

The performance comparison is also unfair. The comparisons against SHA-256, Ascon-Hash, and HarakaS are largely cross-process and cross-paper comparisons, not experiments under the same configuration or environment. Since process node, library, voltage, timing constraints, synthesis strategy, and implementation boundary can significantly affect area, delay, power, and throughput, these comparisons cannot support the claimed superiority.

In addition, the AreionS construction and its security discussion are too brief. The paper should specify the sponge padding, domain separation, state handling, output-length rules, and the assumptions behind the security claim. The manuscript also contains presentation issues such as template artifacts and speculative process-scaling statements.

#purplet([Overall, I recommend rejection.]) The work studies a relevant primitive, but the main datapath optimization is too straightforward, the throughput advantage is not convincingly proven, and the performance comparison is not fair enough to support the paper's central claims.


== Confidential Comments to Editor

#oranget([The manuscript is relevant to TCAS-II, but I recommend rejection.]) The basic datapath ideas are not wrong, but they are too simple for the claimed contribution. The Areion-256 and Areion-512 optimizations mainly split or reorder the datapath, trading cycle count against area or frequency.

The most serious issue is that the paper's key performance claims are not supported by a fair experimental methodology. The comparisons with SHA-256, Ascon-Hash, and HarakaS use different processes and reported environments, so they cannot establish the claimed superiority. In my view, the combination of weak novelty and unfair evaluation makes the manuscript unsuitable for acceptance.

// Bibliography section
// #bibliography("../references.bib", style: "apa")
