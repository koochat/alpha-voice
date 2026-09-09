# PRD: AlphaVoice
> Source: `docs/00-brief.md` | Version: 1.0 | Status: validated | Validated: 2026-08-31

## 1. Product Objective

Build a responsive web-based application for US stock investors that tracks **Public Appearances of CEOs and CFOs for stocks in the user's Watchlist** and brings them together into a unified Feed and historical Timeline.

Product priority:

**Precision > Coverage > Speed**

AlphaVoice is not a general news aggregator. News that merely mentions an executive must not be mixed with content where the CEO/CFO actually speaks or participates directly.

The system is **Watchlist-driven**. The Stock Search Universe covers eligible companies listed or traded as:

- NYSE
- Nasdaq
- NYSE American
- ADRs traded on the supported US exchanges above

Excluded from the selectable universe:

- ETFs
- Funds
- Instruments that do not have a normal company/executive structure suitable for CEO/CFO tracking

A stock being present in the Stock Universe does not mean the system proactively monitors it. Discovery and backfill are driven by stocks followed by at least one user.

---

## 2. Functional Requirements

| ID | Requirement | Priority | Epic |
|---|---|---|---|
| FR-1 | Users must be able to sign in with Google. | Must | E1 |
| FR-2 | The system must isolate all user-specific data, including Watchlist, Read/Unread state, and notification state, between users. | Must | E1 |
| FR-3 | Users must be able to log out. | Must | E1 |
| FR-4 | The Stock Search Universe must support eligible companies on NYSE, Nasdaq, NYSE American, and ADRs traded on those supported US exchanges, while excluding ETFs, Funds, and instruments that do not have a normal company/executive structure suitable for CEO/CFO tracking. | Must | E2 |
| FR-5 | Users must be able to search stocks by Ticker or Company Name. | Must | E2 |
| FR-6 | Users must be able to add stocks to and remove stocks from their Watchlist. | Must | E2 |
| FR-7 | The system must be Watchlist-driven: a stock's presence in the Stock Universe must not trigger proactive monitoring unless at least one user follows it. | Must | E2 |
| FR-8 | For each followed company, the system must identify the current CEO and CFO and preserve effective-dated role history sufficient to determine who held each role on a past date. | Must | E3 |
| FR-9 | Every Canonical Event must be associated with an executive who held the applicable CEO or CFO role on the Event's Primary Event Date as defined in Section 6. If the Primary Event Date uses the published-date fallback, role validation must use that fallback date and retain that fact. | Must | E3 |
| FR-10 | The system must automatically discover new CEO/CFO Public Appearances from supported sources. | Must | E4 |
| FR-11 | The system must support Adaptive Fetching so each source type can use a different fetch cadence. | Must | E4 |
| FR-12 | The system must support at least these Public Appearance types: Interview, Podcast, Conference, Fireside Chat, Keynote, and Earnings Call. | Must | E4 |
| FR-13 | Discovered content must be filtered to distinguish Candidates where the executive actually speaks or participates from content that merely mentions the executive. | Must | E5 |
| FR-14 | High-confidence Candidates may receive system approval and be auto-published as Canonical Events without manual Admin approval. | Must | E5 |
| FR-15 | Uncertain Candidates must be sent to the Admin Review Queue and must not be shown to regular users until an Admin approves or merges them. | Must | E5 |
| FR-16 | Candidates that do not qualify must be rejectable. | Must | E5 |
| FR-17 | The system must detect content that is duplicate or belongs to the same Public Appearance across one or multiple sources and combine it into exactly one Canonical Event. | Must | E5 |
| FR-18 | Full videos, clips, articles, transcripts, reposts, and related coverage for the same Appearance must be attachable as distinct Resources under one Canonical Event. | Must | E5 |
| FR-19 | Only an authorized Admin may access the Admin Review Queue or perform Approve, Reject, or Merge operations. Regular users must not be able to invoke these operations. | Must | E6 |
| FR-20 | The MVP must support one primary Admin without requiring a complex multi-level Admin permission system. | Must | E6 |
| FR-21 | When a stock becomes followed at timestamp **T**, the required historical window is the 90-calendar-day interval **[T − 90 days, T]**. Before requesting historical discovery, the system must reuse existing Global Events and previously recorded successful source/date-range coverage inside that interval. For each enabled MVP source, historical discovery must run only for portions of the required interval that are not already recorded as successfully covered by that source. | Must | E7 |
| FR-22 | Each enabled source evaluated for a required historical interval must record one per-source outcome for each requested date range: **Succeeded**, **Failed**, or **Unsupported**. The stock-level outcome must be calculated **only** by the `(S, F)` decision function in Section 7.3; no separate uncovered-segment rule may determine or override the stock-level result. Failed source/date ranges may be retried without duplicating existing Global Events or re-running date ranges already recorded as Succeeded. | Must | E7 |
| FR-23 | Historical Events and successful historical coverage records are Global Data and must be reusable across users. A later user following the same stock must not trigger historical discovery for a source/date range already recorded as Succeeded; the system must request only uncovered source/date-range segments within that user's required 90-day window. | Must | E7 |
| FR-24 | The system must continue tracking new Public Appearances after a stock is added to a Watchlist. | Must | E7 |
| FR-25 | Home must provide a Timeline View combining Public Appearances from all Watchlist stocks, ordered by Primary Event Date from newest to oldest. | Must | E8 |
| FR-26 | Home must provide a Watchlist View grouped by stock and show the number of Unread Events for each stock. In the MVP, the UI term `new` is synonymous with `unread`; there is no separate New state. | Must | E8 |
| FR-27 | Users must be able to open a Stock Timeline showing CEO/CFO Public Appearances for that company, ordered by Primary Event Date from newest to oldest by default. | Must | E8 |
| FR-28 | The Feed must support filtering between All and Unread. | Must | E8 |
| FR-29 | The Feed must support filtering by CEO or CFO. | Must | E8 |
| FR-30 | The Feed must support filtering by Event Type. | Must | E8 |
| FR-31 | Users must be able to open Event Detail. | Must | E9 |
| FR-32 | Event Detail must show Title, Company/Ticker, Executive, Role, Primary Event Date, Event Type, and Source. If a Resource Published Date differs from the Primary Event Date, the relevant Published Date must also be available for display. | Must | E9 |
| FR-33 | Event Detail should show a Short Description/Excerpt when the original source provides that metadata. | Should | E9 |
| FR-34 | Event Detail must support multiple Resources for one Event, such as Video, Article, Transcript, Clip, or related coverage. | Must | E9 |
| FR-35 | Users must be able to select Watch Original, Read Original, or Read Transcript when the corresponding Resource exists. | Must | E9 |
| FR-36 | Opening Event Detail must mark that Event as Read for that user. | Must | E10 |
| FR-37 | Selecting Watch Original, Read Original, or Read Transcript must mark that Event as Read for that user. | Must | E10 |
| FR-38 | Users must be able to manually Mark as Read and Mark as Unread. | Must | E10 |
| FR-39 | Merely scrolling past an Event in the Feed must not change its Read state. | Must | E10 |
| FR-40 | The system must show in-app indications for Unread Events, such as unread counts or badges. | Must | E10 |
| FR-41 | Core UI functionality must work on both desktop and mobile browsers according to the responsive acceptance criteria in NFR-7. | Must | E11 |

---

## 3. Non-Functional Requirements

| ID | Category | Target |
|---|---|---|
| NFR-1 | Operating Cost | The base system should target recurring operating cost of **approximately $10/month or less** under the Reference Operating Envelope in Section 8. Cost includes required hosting/runtime, database/storage, scheduler/background execution, and mandatory API/data subscriptions for the MVP. It excludes user-owned device/internet cost and optional on-demand AI/transcription. |
| NFR-2 | Cost Governance | No new service with recurring cost may be added without explicit approval. |
| NFR-3 | Precision | On the benchmark defined in Section 9, **Precision = True Positive Auto-Published Canonical Events / All Auto-Published Canonical Events**. Precision must be at least **90%**, equivalent to a False Positive rate of at most **10%**. |
| NFR-4 | Discovery Coverage | On the benchmark defined in Section 9, **Coverage = Qualifying Ground-Truth Canonical Events Discovered / All Qualifying Ground-Truth Canonical Events**. Coverage should be at least **80%**. |
| NFR-5 | Authorization & Data Isolation | Automated authorization tests must verify that a regular user cannot read, modify, or delete another user's Watchlist, Read/Unread state, or notification state; cannot access the Admin Review Queue; and cannot invoke Approve, Reject, or Merge operations. The primary Admin may perform Admin-only operations but must not bypass per-user data isolation for unrelated user-specific state. |
| NFR-6 | Watchlist Capacity | The MVP must support at least **100 watched stocks for a single user** without violating the functional behavior defined in this PRD. The Reference Operating Envelope additionally defines the cost/performance benchmark load. |
| NFR-7 | Responsive UX | The following core screens must be usable at both **360×800** and **1280×800** viewports: Sign-In, Home Timeline, Watchlist View, Stock Search/Add, Stock Timeline, Event Detail, and Admin Review Queue. Primary content and required actions must be reachable without horizontal page scrolling, clipped required actions, or layout overlap that prevents completion of the documented flow. |
| NFR-8 | UI Performance | Under the Reference Performance Dataset and Network Profile in Section 8, Home Timeline, Watchlist View, Stock Timeline, and Event Detail should achieve **p95 render-ready time ≤ 1.5 seconds**, measured from navigation/request initiation until primary content is rendered and required local UI controls are interactive. Third-party external media pages/embeds are excluded. Measure at least 30 runs after 5 warm-up runs and report the p95. |
| NFR-9 | Canonical Duplicate Resistance | On the duplicate benchmark in Section 9, content representing the same Appearance across full video, clips, article, transcript, repost, and cross-source Resources must resolve to **exactly one Canonical Event**, while distinct eligible Resources remain attachable under it. Re-fetching the same Resource must not create a duplicate Resource or Event. |
| NFR-10 | Fetch Configurability | Fetch cadence must be configurable per source without changing product behavior. |
| NFR-11 | Source Traceability | Every Canonical Event must trace back to at least one original Source/Resource. |
| NFR-12 | Data Integrity | A Canonical Event must not be created without Company, Executive, Role, Primary Event Date, and at least one Source/Resource. The record must retain whether the Primary Event Date is the actual occurrence date or the published-date fallback. |
| NFR-13 | Evidence | Claims about suitable Precision, Coverage, duplicate handling, fetch cadence, and operating cost must be backed by repeatable tests against frozen benchmark inputs or real sources, as applicable, rather than assumptions. |
| NFR-14 | Shared Monitoring Efficiency | Adding another user who follows stocks that are already being monitored must reuse existing Global discovery/backfill state and must not create duplicate per-user discovery jobs for the same company/source/window. Cost-driving discovery work should scale primarily with **unique followed stocks and source workload**, not duplicate Watchlist entries across users. |

> NFR-3 and NFR-4 remain provisional product targets until validated through the Discovery Spike.

---

## 4. Core Product Rules

### PR-1 — Precision First
Candidates the system is uncertain about must not be published to regular users merely to increase Coverage.

### PR-2 — Canonical Appearance
One Public Appearance = one Canonical Event.

The number of URLs, clips, articles, or reposts does not define the number of Events.

### PR-3 — Original Source First
The system discovers and organizes content; it does not need to copy or host original Video/Article content.

### PR-4 — Shared Discovery
Company, Executive, Public Appearance, Resource, and discovery/backfill state are Global Data where appropriate.

Watchlist, Read/Unread state, and notification state are User Data.

### PR-5 — Cheap Before Expensive
Discovery and filtering should use low-cost methods first and should not use paid AI processing by default when deterministic or local processing is sufficient.

### PR-6 — Adding Watchlist Should Be Cheap
Adding stocks or users should reuse existing Global data and monitoring whenever possible. Duplicate Watchlist entries across users must not cause duplicate discovery work.

### PR-7 — Universe Is Not Monitoring Scope
A stock being present in the Stock Search Universe does not mean it is actively monitored. Discovery and backfill must be driven by Watchlist demand.

### PR-8 — System Approval vs Admin Approval
High-confidence Candidates may be system-approved and auto-published. Uncertain Candidates require Admin approval or merge before becoming visible to regular users.

---

## 5. Public Appearance Definition

### Included

Content where the CEO/CFO actually speaks or participates, including:

- Interview
- Podcast appearance
- Earnings Call
- Investor Conference
- Technology/Industry Conference
- Fireside Chat
- Keynote
- Public Q&A
- Webcast
- Other Public Appearances that follow the same principle

### Excluded

Content does not qualify as a Public Appearance merely because an executive is mentioned, including:

- News reports about a CEO/CFO
- Analyst commentary
- Opinion articles
- News that paraphrases a CEO/CFO without an identifiable source Appearance
- Content about the company where the CEO/CFO does not participate

Related Coverage may be attached to a Canonical Event but does not create a new Event.

---

## 6. Event Date Semantics

This section closes the previous Event Date open question.

### 6.1 Primary Event Date

Each Canonical Event has one **Primary Event Date** used for:

- Timeline ordering
- 90-day backfill window inclusion
- CEO/CFO role-at-event validation
- Canonical grouping logic where date is relevant

The Primary Event Date is selected using this precedence:

1. **Actual occurrence date** — use the date the Public Appearance actually happened when a reliable source provides it.
2. **Published-date fallback** — when the actual occurrence date cannot be determined, use the earliest reliable Published Date among the original/first-party Resources associated with the Event. If no original/first-party Resource provides a date, use the earliest reliable Published Date among the available Resources.

The Event must retain which basis was used: `actual_event_date` or `published_date_fallback`.

### 6.2 Resource Published Date

Each Resource may retain its own Published Date.

If a Resource Published Date differs from the Primary Event Date, Event Detail may display both so users can distinguish when the appearance occurred from when a Resource was published.

### 6.3 Executive Role Validation

The executive must have held the applicable CEO/CFO role on the Primary Event Date.

When the Primary Event Date is based on the published-date fallback, the system must retain that limitation so later improved date evidence can trigger re-evaluation without silently rewriting history.

---

## 7. Backfill Coverage and Outcome Semantics

This section closes the remaining ambiguity from AV-03.

### 7.1 Historical Coverage Reuse

Historical backfill reuse is based on **source + company + date-range coverage**, not on an undefined freshness label.

For each source, the system must be able to determine which historical date ranges for a company are already recorded as **Succeeded**.

For a user who begins following a stock at timestamp **T**:

- Required historical window = **[T − 90 calendar days, T]**
- Existing Global Events in that window are reused immediately.
- For each enabled source, any sub-range already recorded as **Succeeded** is reused.
- Historical discovery is requested only for uncovered sub-ranges.
- A previously succeeded sub-range is not re-run merely because another user follows the same stock later.

Example:

- Existing successful coverage for Source A: March 1–May 31
- New user's required window: April 1–June 29
- Reused range: April 1–May 31
- New historical request for Source A: June 1–June 29

This rule removes the previous undefined concept of a “sufficiently fresh completed backfill.”

### 7.2 Per-Source Outcomes

For every requested source/date-range segment, record exactly one outcome:

- **Succeeded** — the source supported the requested historical segment and the discovery attempt completed successfully, including the valid result of finding zero qualifying Events.
- **Failed** — the source supports the requested historical segment, but the discovery attempt did not complete successfully.
- **Unsupported** — the source does not support historical discovery for that requested segment.

### 7.3 Stock-Level Outcome Truth Table

Stock-level backfill outcome is determined **only** by the Boolean pair `(S, F)` defined below. No other condition, including the existence or absence of uncovered or Unsupported segments, may override this mapping.

Define:

- **S = Yes** if at least one required historical source/date-range coverage record inside the required 90-day window is `Succeeded`, whether that success was reused from an earlier run or produced by the current run.
- **S = No** if no required historical coverage record inside the required 90-day window is `Succeeded`.
- **F = Yes** if at least one required historical source/date-range segment that is supported by an enabled source remains `Failed` after the current run.
- **F = No** if no supported required historical segment remains `Failed`.

Per-source `Unsupported` results do **not** create a third stock-level decision variable. They do not set `S`, do not set `F`, and do not override the table below.

The stock-level outcome is exactly:

| S | F | Stock-Level Outcome |
|---|---|---|
| Yes | No | **Complete** |
| Yes | Yes | **Partial** |
| No | Yes | **Failed** |
| No | No | **Unsupported** |

This table is the complete and authoritative stock-level decision rule.

Therefore:

- A **fully reused window** is `S = Yes, F = No` and is always **Complete**.
- `Succeeded` coverage plus any number of `Unsupported` remainder segments, with no Failed segment, is `S = Yes, F = No` and is always **Complete**.
- `Unsupported` is possible **only** when `S = No` and `F = No`.
- The absence of an uncovered segment does not imply `Unsupported`.
- The existence of an `Unsupported` segment does not imply stock-level `Unsupported`.
- `Unsupported` can never apply when any reusable or newly produced `Succeeded` coverage exists inside the required window.

Because a Boolean pair has exactly one of the four combinations above, the stock-level outcomes are mutually exclusive and exhaustive.

`Unsupported` does not mean the Stock Timeline must be empty; manually seeded or otherwise existing Global Events may exist without constituting a `Succeeded` historical coverage record.

### 7.4 Retry and Reuse

- Retry targets only source/date-range segments currently marked **Failed**.
- Retry must not re-run or invalidate a **Succeeded** segment.
- Retry must not create duplicate Global Events or duplicate Resources.
- Adding another user who follows the same stock must reuse Succeeded coverage before creating any new historical request.
- Forward discovery remains governed separately by FR-24 and Adaptive Fetching.

---

## 8. Reference Operating and Performance Envelope

This section defines the benchmark envelope for NFR-1, NFR-6, NFR-8, and NFR-14. It is a product validation envelope, not a technology-stack decision.

### 8.1 Reference Operating Load

Use the following reference load for base-system cost validation:

- Up to **5 active users**
- At least one user with **100 watched stocks**
- Up to **150 unique followed stocks globally**
- Duplicate stocks across users reuse Global discovery/backfill state
- MVP source set only
- Adaptive Fetching as configured for the MVP
- 30-day accounting period

### 8.2 Cost Included

Include recurring cost required for the base system:

- Hosting/runtime required by the selected deployment model
- Persistent database/storage
- Scheduler/background execution
- Mandatory API or data subscriptions used by base Discovery

Exclude:

- User-owned computer, electricity, and internet access
- Optional on-demand AI analysis
- Optional on-demand transcription
- Development-only tools not required to operate the deployed MVP

### 8.3 Reference Performance Dataset

For UI performance validation, use at least:

- 100 stocks in the measured user's Watchlist
- 5,000 Canonical Events in Global Data
- 1,000 Canonical Events associated with stocks in that user's Watchlist
- At least 2 Resources per Event on average
- A mix of Read and Unread Events

### 8.4 Reference Network Profile

Use a repeatable network profile of approximately:

- 20 Mbps downstream
- 5 Mbps upstream
- 50 ms round-trip latency

If the selected deployment environment cannot be tested under this exact profile, use a documented equivalent and report the deviation.

---

## 9. Validation Benchmarks

### 9.1 Discovery Benchmark Protocol

The Discovery Spike must create and freeze a benchmark dataset before final measurement.

Minimum benchmark composition:

- At least **20 companies**
- Include high-, medium-, and low-media-coverage companies
- Include both CEOs and CFOs where appearances are available
- Fixed **90-calendar-day evaluation window**
- Include Interview, Podcast, Conference, Earnings Call, Keynote/Fireside-style content where available
- Include negative examples where an executive is mentioned but does not participate
- Include duplicate/cross-source examples

The benchmark must store, for each reviewed item:

- Company
- Executive
- Role
- Primary Event Date or candidate date evidence
- Source/Resource URL
- Qualifying vs non-qualifying label
- Canonical Event group identifier for qualifying duplicate Resources
- Reviewer rationale sufficient to audit the label

If the initial 20-company set yields fewer than **100 reviewed candidate/content items**, expand the company set or time window until at least 100 reviewed items are available.

### 9.2 Ground Truth

Ground truth consists of the manually reviewed qualifying Canonical Events in the frozen benchmark.

A **Qualifying Ground-Truth Event** is an Event that meets the Public Appearance definition in Section 5 and whose executive-role eligibility is valid under Section 6.

The benchmark source set and evaluation window must be frozen before the final Precision/Coverage run so the denominator cannot be changed after seeing results.

### 9.3 Precision

For auto-published Events:

**Precision = True Positive Auto-Published Canonical Events / All Auto-Published Canonical Events**

Target: **≥ 90%**

Equivalent maximum False Positive rate: **≤ 10%**

Events sent only to Admin Review and not auto-published are not counted as auto-published positives.

### 9.4 Coverage

**Coverage = Qualifying Ground-Truth Canonical Events Discovered / All Qualifying Ground-Truth Canonical Events**

Target: **≥ 80%**

An Event counts as discovered if the system creates a matching Candidate or Canonical Event that can be mapped to the same ground-truth Canonical Event, regardless of whether it was auto-published or sent to Admin Review.

### 9.5 Duplicate Benchmark

The frozen benchmark must include groups where one Public Appearance appears as combinations of:

- Full video
- Short clips
- Article
- Transcript
- Repost
- Cross-source related Resources

Expected result for each group:

- Exactly **one Canonical Event**
- Each distinct eligible Resource attached no more than once
- Re-fetching the same Resource creates no additional Event or Resource

### 9.6 Backfill Benchmark

For selected benchmark stocks:

1. Define the follow timestamp **T**.
2. Derive the required window **[T − 90 calendar days, T]**.
3. Seed explicit pre-existing Global Events and explicit per-source coverage records.
4. Verify that historical requests are made only for source/date-range segments that require a new attempt.
5. For every fixture, calculate `S` and `F` exactly as defined in Section 7.3 and assert that the stock-level result equals the authoritative `(S, F)` table.
6. Include these mandatory fixtures:

| Fixture | S | F | Expected Stock-Level Outcome |
|---|---|---|---|
| Entire required window already covered by reusable `Succeeded` coverage; zero new requests | Yes | No | **Complete** |
| Reused/new `Succeeded` coverage plus remaining `Unsupported` segments; no Failed segment | Yes | No | **Complete** |
| No `Succeeded` coverage; every attempted/unmet requirement is `Unsupported`; no Failed segment | No | No | **Unsupported** |
| At least one `Succeeded` segment and at least one Failed supported segment | Yes | Yes | **Partial** |
| No `Succeeded` coverage and at least one Failed supported segment | No | Yes | **Failed** |

7. For the fully reused fixture, explicitly assert that `Unsupported` is **false** even though there is no uncovered segment.
8. For the `Succeeded + Unsupported` fixture, explicitly assert that stock-level `Unsupported` is **false** because `S = Yes`.
9. Retry a Failed segment and verify previously Succeeded segments are not re-run.
10. Add a second user with an overlapping 90-day window and verify reusable Succeeded coverage is reused by source/date range.
11. Verify no duplicate Global Event or Resource is created during retry or reuse.

---

## 10. Primary User Flows

### Flow 1 — Sign In

Google Sign-In  
→ Account identified  
→ User enters Home

### Flow 2 — Add Stock

Search Ticker/Company within the Stock Universe  
→ Select eligible Company  
→ Add to Watchlist  
→ Derive the required window [T − 90 days, T]  
→ Reuse existing Global Events in that window  
→ Reuse per-source Succeeded historical coverage by date range  
→ Request only uncovered source/date-range segments  
→ Show backfill outcome as Complete / Partial / Failed / Unsupported where needed  
→ Retry only Failed segments when applicable  
→ Forward tracking continues

### Flow 3 — Check What's New

Open Home  
→ Timeline View  
→ See Unread/Read Events from all Watchlist stocks, newest first  
→ Apply filters  
→ Open Event

### Flow 4 — Research One Stock

Watchlist View  
→ Select Stock  
→ Stock Timeline  
→ Review CEO/CFO Public Appearances newest first  
→ Open Event

### Flow 5 — Consume Original Content

Event Detail  
→ Watch Original / Read Original / Read Transcript  
→ Event becomes Read  
→ Open the original source

### Flow 6 — Review Uncertain Candidate

Discovery finds an Uncertain Candidate  
→ Candidate remains hidden from regular users  
→ Authorized Admin opens Admin Review Queue  
→ Approve / Reject / Merge  
→ Approved or merged Event becomes visible as appropriate

> High-confidence Candidates bypass this manual flow through system approval and auto-publication under FR-14 and PR-8.

---

## 11. Epics

### E1 — Identity & User Boundary

Allow each user to sign in with Google and keep user-specific data isolated while enforcing Admin-only review operations.

#### Rough Stories
- Google Sign-In / Logout
- Create/retrieve user profile
- Per-user data authorization
- Admin authorization boundary

### E2 — Stock Universe, Search & Watchlist

Allow users to choose supported companies and define which stocks they want to follow.

#### Rough Stories
- Stock Universe import/sync for NYSE/Nasdaq/NYSE American + ADR
- Exclude ETF/Fund and unsuitable non-company instruments
- Search by ticker/company
- Add to Watchlist
- Remove from Watchlist
- Support 100+ stocks for a user
- Watchlist state per user
- Ensure unwatched universe stocks do not trigger proactive monitoring
- Reuse monitoring when multiple users follow the same stock

### E3 — Company & Executive Directory

Maintain effective-dated relationships between companies and CEO/CFO roles.

#### Rough Stories
- Company directory
- Current CEO/CFO records
- Effective-dated executive role history
- Role-at-event validation
- Executive role change handling

### E4 — Source Discovery

Discover new content from supported sources while keeping cost low.

#### Rough Stories
- Source interface/registration
- First discovery source
- Adaptive scheduling
- Candidate creation
- Discovery telemetry/evidence

> The first MVP discovery source is intentionally not selected in the PRD.

### E5 — Validation & Canonicalization

Separate real Public Appearances from noise and group duplicate/cross-source content under a single Event.

#### Rough Stories
- Candidate pre-filter
- Executive participation validation
- Confidence classification
- System approval for high-confidence Candidates
- Duplicate/cross-source grouping
- Canonical Event creation
- Resource deduplication/grouping
- Date-basis handling

### E6 — Admin Review

Handle Uncertain Candidates the system cannot classify with high confidence.

#### Rough Stories
- Admin-only Review Queue
- Approve
- Reject
- Merge
- Review history

### E7 — Historical Backfill

Populate the 90-day historical window for newly followed stocks while reusing Global Data and recording completion semantics.

#### Rough Stories
- Derive exact [T − 90 days, T] backfill window
- Reuse existing Global Events
- Track/reuse Succeeded coverage by source + date range
- Request only uncovered source/date-range segments
- Per-source Succeeded/Failed/Unsupported outcomes
- Complete/Partial/Failed/Unsupported truth-table aggregation
- Retry only Failed segments without duplication
- Reuse overlapping historical coverage across users
- Continue forward discovery

### E8 — Home Feed & Stock Timeline

Let users see what is unread and research historical appearances by stock.

#### Rough Stories
- Combined Timeline newest first
- Watchlist View with Unread counts
- Stock Timeline newest first
- All/Unread filter
- CEO/CFO filter
- Event Type filter

### E9 — Event Detail & Original Resources

Help users understand an Event and reach its original content.

#### Rough Stories
- Event Detail
- Primary Event Date + Published Date display
- Resource list
- Original link handling
- Source-provided excerpt

### E10 — Read State & In-App Notifications

Help users distinguish Unread content from content they have already viewed.

#### Rough Stories
- Per-user Read/Unread state
- Event Detail read rule
- Original/Transcript link read rule
- Manual read/unread
- Unread counters/badges

### E11 — Responsive UX

Make core flows work well on both desktop and mobile browsers.

#### Rough Stories
- Responsive navigation
- Responsive feed/watchlist
- Responsive stock search/add
- Responsive stock timeline
- Responsive event detail
- Responsive admin review
- Performance benchmark verification

---

## 12. Out of Scope — MVP

- Proactive monitoring of every company in the NYSE/Nasdaq/NYSE American/ADR universe when no user follows it
- Tracking executives beyond CEO/CFO
- Hosting or downloading Video
- Guaranteeing 100% Public Appearance coverage
- Email notifications
- Push notifications
- AI-generated summaries
- Automatic AI analysis
- Automatic transcription for every Event
- Sentiment / Management Tone
- AI Topic extraction
- Historical statement comparison
- Full-text transcript search
- Search company by executive name
- Unlimited historical backfill
- Expensive commercial data feeds as the default
- Complex multi-admin permission system

---

## 13. Open Questions

### OQ-1 — Deployment Model

The initial deployment model is not yet selected:

- Public Web App
- Local Web App accessed through a browser

Architecture must present trade-offs before a choice is made.

### OQ-2 — Stock Universe Data Source

The Stock Universe scope is locked, but the Source of Truth is not yet selected for:

- NYSE/Nasdaq/NYSE American listings
- ADR identification
- ETF/Fund and unsuitable-instrument exclusion
- Listing and delisting changes

Coverage, freshness, licensing, and cost must be evaluated before selection.

### OQ-3 — Executive Data Source

The Source of Truth is not yet selected for:

- Current CEO
- Current CFO
- Executive changes
- Effective-dated role history

Coverage, temporal accuracy, and cost must be validated before selection.

### OQ-4 — Discovery Source Set

The actual MVP discovery sources are not yet selected.

Evaluation must consider:

- Precision
- Coverage
- API/RSS availability
- Terms/licensing
- Quota
- Cost
- Historical accessibility

### OQ-5 — Confidence Threshold

Numeric thresholds have not yet been defined for:

- System approval / auto-publish
- Admin review
- Reject

These thresholds must be calibrated from the frozen Discovery benchmark rather than guessed in the PRD.

### OQ-6 — Fetch Cadence

Adaptive Fetching is selected, but actual cadence per source is not yet defined.

It must be determined from:

- Source update frequency
- API limits
- Budget
- Observed discovery delay

---

## 14. Discovery Validation Before Architecture Lock

Because Discovery is the highest-risk product capability, the technical design and source choices for this area must not be treated as final until they are tested against the benchmark protocol in Section 9.

The Discovery Spike must report at least:

- Candidate count
- True Public Appearances
- False Positives
- Missed qualifying Events
- Precision
- Coverage
- Duplicate grouping accuracy
- Backfill Complete/Partial/Failed/Unsupported outcomes and source/date-range reuse
- Source contribution
- Discovery delay
- API/quota usage
- Estimated recurring operating cost under the Reference Operating Envelope

The results must be used to validate or revise:

- NFR-1 Operating Cost
- NFR-3 Precision
- NFR-4 Discovery Coverage
- NFR-9 Canonical Duplicate Resistance
- Source selection
- Fetch cadence
- Confidence thresholds

---

## 15. Changelog

- **0.1 — 2026-08-29:** Initial PRD generated from the validated Project Brief.
- **0.2 — 2026-08-31:** Locked the Watchlist-driven stock universe as NYSE/Nasdaq/NYSE American + ADR, excluding ETF/Fund.
- **0.3 — 2026-08-31:** Addressed independent PRD review findings AV-01 through AV-13. Added effective-dated executive roles, Primary Event Date semantics, testable 90-day backfill completion rules, repeatable Precision/Coverage/duplicate benchmarks, 100+ Watchlist capacity and operating-cost envelope, unsuitable-instrument exclusion, Admin authorization boundaries, responsive/performance acceptance criteria, and clarified auto-publish, Read Transcript, Unread/new, and Stock Timeline ordering behavior.
- **0.4 — 2026-08-31:** Focused remediation for remaining AV-03. Replaced undefined backfill freshness with deterministic source + date-range coverage reuse, added non-overlapping Complete/Partial/Failed/Unsupported truth-table semantics, and expanded backfill benchmark/retry/reuse acceptance criteria.
- **0.5 — 2026-08-31:** Final AV-03 edge-case remediation. Defined stock-level outcomes over the entire required window, explicitly made a fully reused window `Complete`, narrowed `Unsupported` to the no-success/no-failure/all-unsupported case, and added dedicated benchmark fixtures for fully reused and mixed Succeeded+Unsupported coverage.
- **0.6 — 2026-08-31:** Replaced all remaining stock-level backfill ambiguity with a single authoritative `(S, F)` Boolean decision function. Explicitly prohibited uncovered/Unsupported segments from overriding that function and added benchmark assertions proving Fully Reused → Complete and Succeeded + Unsupported → Complete.
- **1.0 — 2026-08-31:** PRD validated after independent review. All findings AV-01 through AV-13 are closed; final AV-03 Boolean decision recheck passed with no regressions.
