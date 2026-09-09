# UX Spec: AlphaVoice
> Source: `docs/01-prd.md` | Version: 1.0 | Status: validated | Validated: 2026-09-01

## 1. UX Goals

AlphaVoice should make it easy for a US-stock investor to answer two questions:

1. **What have the CEOs/CFOs of companies I follow said recently?**
2. **What has management of one specific company said over time?**

The primary mental model is a **Watchlist-driven executive-appearance timeline**, not a general news feed. Users follow companies; AlphaVoice surfaces Canonical Events where the CEO or CFO actually participates; users can then open the original source.

The UX should preserve these principles:

- **Precision > Coverage > Speed.** The interface should favor trustworthy, qualified appearances over a noisy stream.
- **One Public Appearance = one Canonical Event.** Multiple videos, articles, clips, transcripts, or related coverage belong under one Event rather than appearing as duplicate feed items.
- **Original source first.** AlphaVoice organizes and links; it does not present itself as the publisher of the original content.
- **Unread is lightweight state, not a separate content type.** In MVP, `new` and `unread` mean the same thing.
- **Watchlists may be large.** The experience must remain usable with 100+ followed stocks.
- **Backfill status must not be confused with Event availability.** Existing Events may be shown while historical checking is still running or incomplete.
- **Regular-user and Admin experiences are clearly separated.**

### 1.1 Owner-Resolved UX Decisions

The following UX decisions are locked for this draft:

1. Home opens to **Timeline View** by default.
2. Timeline history uses progressive **Load more**, not infinite scroll or page-number pagination.
3. After adding a stock, navigate directly to that stock's **Stock Timeline**.
4. Backfill status is prominent while checking or when there is a user-relevant issue; successful completion is not a permanent noisy badge.
5. Home Timeline default content filter is **All**, not Unread.
6. Removing a stock requires confirmation; after success, return to **Watchlist View**.
7. Backfill retries are handled by the system; regular users do not manage retry jobs.
8. Watchlist View sorts stocks with unread Events first, by **Unread count descending**, then **Ticker A–Z**; zero-unread stocks appear below, Ticker A–Z.
9. Admin Review Queue sorts **oldest pending first**.
10. Merge flow first presents plausible existing Canonical Events, with the ability to search/select another Event.
11. Watchlist View includes search/filter within the user's followed stocks by **Ticker or Company Name**.
12. Stock Timeline uses the same filters as Home Timeline: **All/Unread, CEO/CFO, Event Type**.
13. `Watch Original`, `Read Original`, and `Read Transcript` open the external Resource in a **new browser tab**; internal AlphaVoice navigation stays in the same tab.

---

## 2. Information Architecture

### 2.1 Primary Navigation

Regular-user navigation:

```text
Sign In
  ↓
Home
 ├─ Timeline View (default)
 │   ├─ Event Detail
 │   │   ├─ Watch Original → external source, new tab
 │   │   ├─ Read Original  → external source, new tab
 │   │   └─ Read Transcript → external source, new tab
 │   └─ Company/Ticker → Stock Timeline
 │
 ├─ Watchlist View
 │   ├─ Stock Timeline
 │   └─ Stock Search / Add
 │
 └─ Stock Search / Add
     └─ Add → Stock Timeline

Account
 └─ Logout
```

Admin-only navigation:

```text
Admin Review Queue
  └─ Admin Candidate Review
      ├─ Approve
      ├─ Reject
      └─ Merge
          ├─ Suggested existing Events
          └─ Search/select another existing Event
```

### 2.2 Screen Hierarchy

- **Sign In**
- **Home**
  - Timeline View
  - Watchlist View
- **Stock Search / Add to Watchlist**
- **Stock Timeline**
- **Event Detail**
- **Admin Review Queue** — Admin only
- **Admin Candidate Review** — Admin only

Admin entry points must not be presented to regular users.

---

## 3. User Flows

### 3.1 Google Sign-In — FR-1, FR-2

**Starting state:** Signed out.

**Steps:**
1. User opens AlphaVoice.
2. Sign-In screen explains the product purpose and presents `Continue with Google`.
3. User initiates Google Sign-In.
4. While authentication is in progress, the sign-in action enters a loading state and prevents duplicate submission.
5. On success, user enters **Home → Timeline View**.

**Success state:** Authenticated user sees only their own Watchlist and Read/Unread state.

**Edge/error paths:**
- User cancels authentication → remain on Sign-In with no error alarm.
- Authentication fails → show concise retryable error.
- Session becomes invalid later → return to Sign-In after preserving no user-specific data on the signed-out surface.

---

### 3.2 Add Stock to Watchlist — FR-4, FR-5, FR-6, FR-7, FR-21, FR-22, FR-23, FR-24

**Starting state:** Authenticated user is on Stock Search / Add.

**Steps:**
1. User searches by Ticker or Company Name.
2. Results show only eligible Stock Universe companies.
3. Results clearly distinguish already-followed stocks from addable stocks.
4. User selects `Add`.
5. The stock becomes followed.
6. Navigate immediately to that stock's **Stock Timeline**.
7. Existing reusable Global Events within the available history appear immediately.
8. If historical checking is still in progress, show `Checking the last 90 days…` without blocking Event browsing.
9. Historical status resolves to Complete, Partial, Failed, or Unsupported according to PRD semantics.
10. Forward tracking continues after follow.

**Success state:** Stock is in the user's Watchlist and its Stock Timeline is available.

**Edge/error paths:**
- No search results → show no-match state; do not suggest excluded instruments as addable.
- Stock already followed → show `Following`; do not create a duplicate Watchlist entry.
- Add operation fails → remain on search/results context and show retryable failure.
- Backfill Partial/Failed → Events already available remain visible; show that some historical appearances may be missing.
- Backfill Unsupported → explain that historical checking is not available; do not imply that the Timeline must be empty.
- System handles retries for Failed historical segments; no regular-user retry control.

---

### 3.3 Remove Stock from Watchlist — FR-6, FR-7

**Starting state:** User is viewing a followed stock or its Watchlist row.

**Steps:**
1. User chooses `Remove from Watchlist`.
2. Show confirmation:
   - stock/company being removed;
   - its Events will no longer appear in that user's Home Timeline;
   - the stock can be followed again later.
3. User confirms.
4. Remove the stock from that user's Watchlist.
5. Return to **Home → Watchlist View**.

**Success state:** Stock no longer appears in the user's Watchlist or Watchlist-driven Home Timeline.

**Edge/error paths:**
- User cancels → no change.
- Removal fails → keep stock visible and show error.
- Removal must not imply deletion of Global Events.

---

### 3.4 Check Unread Events — FR-25, FR-26, FR-28, FR-36, FR-38, FR-40

**Starting state:** User enters Home.

**Steps:**
1. Home opens to Timeline View with `All` active.
2. Unread Events have a visible unread indicator.
3. Unread total is visible where useful in navigation/filter context.
4. User may switch to `Unread`.
5. User opens an Event; that Event becomes Read.
6. Returning to an `Unread`-filtered list removes the now-read Event from the current filtered result.

**Success state:** User can distinguish and consume unread appearances without losing access to previously read Events under `All`.

**Edge/error paths:**
- No unread Events → show a positive empty state with an action to return to `All`.
- Merely scrolling past an Event never marks it Read.

---

### 3.5 Filter Feed — FR-28, FR-29, FR-30

**Starting state:** Home Timeline or Stock Timeline.

**Steps:**
1. User selects:
   - All or Unread;
   - CEO, CFO, or both;
   - one or more supported Event Types.
2. Results update to match the active filter set.
3. Active filters remain visible and removable.
4. User can reset filters to the default state.

**Default:** `All`, CEO + CFO, all Event Types.

**Success state:** Timeline shows matching Canonical Events in newest-to-oldest order.

**Edge/error paths:**
- Filter combination returns zero Events → show filter-specific empty state with `Clear filters`.
- Filter changes do not alter Read/Unread state.

---

### 3.6 Open Stock Timeline — FR-26, FR-27, FR-28, FR-29, FR-30

**Starting state:** Watchlist View, Event card, or successful Add Stock flow.

**Steps:**
1. User selects a followed stock/company.
2. Stock Timeline opens.
3. Header shows company identity and `Following`.
4. Timeline shows the company's CEO/CFO Canonical Events newest first.
5. Same filter controls as Home Timeline are available.
6. Older history is revealed with `Load more` when more Events are available.

**Success state:** User can research one followed company's executive appearances.

**Edge/error paths:**
- No Events yet → show that no qualifying appearances are currently available and, if applicable, historical checking is still underway.
- Historical status issues are shown separately from the Event empty state.

---

### 3.7 Open Event Detail — FR-31, FR-32, FR-33, FR-34, FR-36

**Starting state:** User selects an Event card.

**Steps:**
1. Navigate to Event Detail.
2. Mark the Event Read for that user.
3. Show Event identity, company, executive, role, Primary Event Date, Event Type, source information, optional excerpt, and Resources.
4. If a Resource Published Date differs from Primary Event Date, make both dates understandable.
5. User may manually mark the Event Unread.

**Success state:** User understands the Canonical Event and can choose an original Resource.

**Edge/error paths:**
- Event becomes unavailable → show an Event-unavailable error without presenting stale actions.
- Optional excerpt missing → omit it without placeholder noise.
- Resource failure must not erase the Event's other valid Resources.

---

### 3.8 Watch/Read Original Resource — FR-34, FR-35, FR-37

**Starting state:** Event Detail or an Event card action where provided.

**Steps:**
1. User selects `Watch Original`, `Read Original`, or `Read Transcript`.
2. Mark Event Read.
3. Open selected external Resource in a new browser tab.
4. Keep AlphaVoice context in the original tab.

**Success state:** User reaches the original source while preserving their AlphaVoice research position.

**Edge/error paths:**
- Resource is no longer available → show source-unavailable feedback if detected; leave other Resources usable.
- Only actions backed by an existing corresponding Resource are shown.

---

### 3.9 Mark Read / Mark Unread — FR-38, FR-39

**Starting state:** Event card or Event Detail.

**Steps:**
1. User invokes the explicit state action.
2. Update indicator and applicable unread counts.
3. If currently viewing an `Unread` filter and marking Read, remove the Event from that filtered result after the action is acknowledged.

**Success state:** User-controlled Read/Unread state is reflected consistently.

**Edge/error paths:**
- State update fails → restore prior visible state and show concise error.
- Scrolling alone never changes state.

---

### 3.10 Review Uncertain Candidate — FR-15, FR-19, FR-20

**Starting state:** Authorized Admin opens Review Queue.

**Steps:**
1. Queue displays pending Uncertain Candidates, oldest first.
2. Admin selects a Candidate.
3. Candidate Review displays decision-relevant evidence and context.
4. Admin chooses Approve, Reject, or Merge.

**Success state:** Candidate reaches an explicit reviewed outcome.

**Edge/error paths:**
- Candidate was already resolved elsewhere → explain that it is no longer pending and return to queue.
- Regular user attempts direct access → show Access Denied without Candidate data.

---

### 3.11 Approve Candidate — FR-14, FR-15, FR-19

**Starting state:** Admin Candidate Review.

**Steps:**
1. Admin verifies company, executive, role, date evidence, Event Type, source/Resource, and participation evidence.
2. Admin chooses `Approve`.
3. Confirm the action only when there is a material ambiguity or irreversible consequence; otherwise use an immediately acknowledged action with error recovery.
4. On success, Candidate leaves the pending queue and the resulting Canonical Event becomes available as appropriate.

**Success state:** Approved Candidate is no longer pending.

**Edge/error paths:**
- Required decision context is missing → do not allow silent approval; show what information is unavailable.
- Approval fails → keep Candidate pending and show error.

---

### 3.12 Reject Candidate — FR-16, FR-19

**Starting state:** Admin Candidate Review.

**Steps:**
1. Admin chooses `Reject`.
2. Because Reject removes the Candidate from publication consideration, show a confirmation dialog.
3. Admin confirms.
4. Candidate leaves the pending queue.

**Success state:** Rejected Candidate is not shown to regular users.

**Edge/error paths:**
- Admin cancels → no change.
- Reject fails → keep Candidate pending and show error.

---

### 3.13 Merge Candidate into Existing Event — FR-17, FR-18, FR-19

**Starting state:** Admin Candidate Review.

**Steps:**
1. Admin selects `Merge`.
2. Show plausible existing Canonical Event matches first.
3. Each suggestion must provide enough identity to distinguish appearances: company/ticker, executive/role, Primary Event Date, Event Type, and title/source context.
4. Admin may search/select another existing Event if the correct Event is not suggested.
5. Admin selects target Event.
6. Show a merge confirmation naming the target Event.
7. On confirmation, Candidate's eligible Resource(s) are associated with the selected Canonical Event as appropriate.

**Success state:** No duplicate Canonical Event is created for the same Public Appearance.

**Edge/error paths:**
- No plausible matches → start with search/select existing Event.
- Target Event becomes unavailable before confirmation → return to target selection.
- Merge fails → Candidate remains pending.
- The UX must not imply that two different appearances can be merged merely because they involve the same executive or date.

---

## 4. Screen Inventory

| Screen | Purpose | Key Data | Primary Actions | Related FRs |
|---|---|---|---|---|
| Sign In | Authenticate user | Product identity, Google sign-in state | Continue with Google | FR-1, FR-2 |
| Home — Timeline View | Combined appearance feed across followed stocks | Canonical Event cards, unread state, filters, dates | Open Event, filter, Load more, open Stock Timeline | FR-25, FR-28–30, FR-36–40 |
| Home — Watchlist View | Browse followed stocks and unread counts | Ticker, company, unread count, follow state | Search watchlist, open Stock Timeline, remove, add stock | FR-6, FR-26, FR-40 |
| Stock Search / Add | Find eligible companies and follow them | Ticker, company, eligibility/follow state | Search, Add | FR-4–7, FR-21–24 |
| Stock Timeline | Research one company's appearances | Company, CEO/CFO Events, unread state, filters, backfill notice | Open Event, filter, Load more, remove stock | FR-21–30, FR-36–40 |
| Event Detail | Understand one Canonical Event and its Resources | Title, company/ticker, executive, role, dates, Event Type, source, excerpt, Resources, read state | Watch/Read Original, Read Transcript, mark Read/Unread, open Stock Timeline | FR-31–39 |
| Admin Review Queue | Work pending Uncertain Candidates | Pending count, candidate identity, age, company/executive/context | Open Candidate Review | FR-15, FR-19, FR-20 |
| Admin Candidate Review | Make human review decision | Candidate evidence, source/Resource, executive participation context, date/role context, possible duplicate matches | Approve, Reject, Merge | FR-14–20 |

---

## 5. Screen States

| Screen | Loading | Empty | Error | Normal / Notes |
|---|---|---|---|---|
| Sign In | Disable duplicate sign-in action; show authentication progress | N/A | Authentication failed/cancelled messaging | Google sign-in is the primary action |
| Home — Timeline | Skeleton/placeholder for primary Event list without blocking navigation | No followed stocks → Add Stock CTA; followed stocks but no Events → no appearances yet; filtered zero → Clear filters | Retryable feed error; preserve navigation/filter shell | Default `All`; unread indicators; newest first; Load more |
| Home — Watchlist | Placeholder stock rows/counts | No followed stocks → Add Stock CTA; watchlist search no-match → clear search | Retryable Watchlist error | Unread-first sort; watchlist search; 100+ stock usability |
| Stock Search / Add | Search-progress state that keeps input usable where possible | No query → search guidance; no matches → no eligible matches | Search failure / Add failure | Search Ticker or Company Name; distinguish Following |
| Stock Timeline | Header may render before Event list; historical-check status may update independently | No Events available; distinguish from backfill status | Timeline error; separate historical coverage warning where applicable | Filters + Load more; backfill notices do not block existing Events |
| Event Detail | Event-detail placeholder; Resources may resolve as part of primary content | Optional excerpt or some Resource types may be absent; Event itself cannot be represented as a valid empty record | Event unavailable or load failure; resource-specific failure should not hide other Resources | Opening marks Read |
| Admin Review Queue | Queue skeleton | `No candidates waiting for review` | Retryable queue error | Oldest pending first; Admin only |
| Admin Candidate Review | Candidate context placeholder | Not a valid business empty state; if Candidate resolved, show resolved/not-pending state | Review action/load failure; keep decision context intact | Admin only; Approve/Reject/Merge |
| Admin access attempt by regular user | N/A | N/A | Access Denied | Must reveal no Candidate/queue contents |

---

## 6. Detailed Screen Behavior

### 6.1 Sign In

**Information hierarchy**
1. AlphaVoice identity and one-sentence value proposition.
2. `Continue with Google`.
3. Minimal sign-in/error guidance.

**Primary action:** Continue with Google.

**Responsive behavior:** Single-column layout at both viewport targets; primary action must remain visible without horizontal scrolling.

**Must not happen**
- No stock/event data is visible before successful authentication.
- No Admin controls are exposed on this screen.

---

### 6.2 Home — Timeline View

**Information hierarchy**
1. Primary navigation with Timeline active.
2. Timeline header and useful unread indication.
3. Filters.
4. Canonical Event list.
5. `Load more` after the current batch.

**Event ordering:** Primary Event Date, newest to oldest.

**Default filters:** All; CEO + CFO; all Event Types.

**Primary actions**
- Open Event Detail.
- Change filters.
- Load more.

**Secondary actions**
- Open Stock Timeline from company/ticker.
- Explicit Mark Read/Unread where surfaced without crowding the card.

**Read/unread**
- Unread Events use a clear, non-ambiguous indicator.
- Scrolling does not change state.
- Opening Event Detail marks Read.

**Responsive**
- Desktop: filters may share one horizontal control row if space permits.
- Mobile: filters wrap/stack into compact controls; no clipped labels/actions.
- Event metadata may wrap vertically, but title, company/ticker, executive/role, date, Event Type, and unread state remain reachable.

**Must not happen**
- Do not render separate feed Events for every Resource of the same appearance.
- Do not default to Unread-only.
- Do not auto-mark items Read because they entered the viewport.
- Do not use infinite scroll.

---

### 6.3 Home — Watchlist View

**Information hierarchy**
1. Watchlist header and stock count.
2. Search within Watchlist.
3. `Add stock` action.
4. Followed stock rows/cards.

**Sorting**
1. Stocks with Unread > 0.
2. Unread count descending.
3. Ticker A–Z tie-breaker.
4. Zero-unread stocks below, Ticker A–Z.

**Each stock row/card should show**
- Ticker.
- Company Name.
- Unread count when > 0.
- Clear zero-unread state without noisy `0 new` badges if space is constrained.

**Primary action:** Open Stock Timeline.

**Secondary actions:** Remove from Watchlist; Add Stock entry point.

**Responsive**
- Desktop: compact rows are preferred for scanning 100+ stocks.
- Mobile: stacked/compact cards or rows; ticker, company, unread count, and primary tap target remain visible.

**Must not happen**
- Watchlist search must search only stocks the user follows.
- Do not confuse Watchlist search with Stock Universe search.
- Do not hide a followed stock merely because its unread count is zero.

---

### 6.4 Stock Search / Add

**Information hierarchy**
1. Search input with Ticker/Company Name guidance.
2. Result list.
3. Per-result follow state/action.

**Result row/card**
- Ticker.
- Company Name.
- `Add` or `Following`.

**After Add**
- Navigate to Stock Timeline.
- Show immediately available Events.
- Show historical checking state independently.

**Must not happen**
- Excluded ETF/Fund/unsuitable instruments must not appear as addable eligible stocks.
- Adding an already-followed stock must not create a duplicate Watchlist entry.

---

### 6.5 Stock Timeline

**Information hierarchy**
1. Company / Ticker.
2. Follow state.
3. Historical coverage notice only when relevant.
4. Filters.
5. Canonical Event list.
6. Load more.

**Filters**
- All / Unread.
- CEO / CFO.
- Event Type.
- Same interaction pattern as Home Timeline.

**Backfill display**
- In progress: `Checking the last 90 days…`
- Complete: transient/low-prominence success acknowledgement; no permanent status badge required.
- Partial: `Some historical appearances may be missing.`
- Failed: `Historical checking couldn't be completed yet.` plus indication that the system will keep checking.
- Unsupported: `Historical checking isn't available for this stock.`

Existing Events remain visible for all four outcomes.

**Must not happen**
- `Unsupported` must not be presented as `No Events exist`.
- Backfill status must not replace the Event list.
- Regular users do not receive manual retry-job controls.

---

### 6.6 Event Detail

**Information hierarchy**
1. Event title.
2. Company / Ticker.
3. Executive name + CEO/CFO role.
4. Primary Event Date + Event Type.
5. Source-provided excerpt when available.
6. Resource actions/list.
7. Date/source detail for Resources when needed.
8. Read/Unread control.

**Date presentation**
- Primary Event Date is the Event's main date.
- If a Resource Published Date differs, label both clearly, e.g.:
  - `Event date: Aug 28, 2026`
  - `Published: Aug 29, 2026`
- Do not collapse the two into one ambiguous date.

**Resources**
- Present distinct Resources under the single Canonical Event.
- Use action labels based on Resource type:
  - Watch Original
  - Read Original
  - Read Transcript
- Related coverage is visually subordinate to the original/most directly consumable Resources when such distinction is available from product data.
- External Resources open in a new tab.

**Read state**
- Opening Event Detail marks Read.
- Manual Mark Unread remains available.

**Must not happen**
- Do not create a separate Event identity for each Resource.
- Do not imply AlphaVoice hosts the original media.
- Do not show Read Transcript when no transcript Resource exists.

---

### 6.7 Admin Review Queue

**Information hierarchy**
1. `Admin Review` title.
2. Pending count.
3. Oldest-pending-first queue.
4. Candidate rows/cards with enough context to choose what to inspect next.

**Candidate queue item**
- Company/Ticker.
- Executive/Role when identified.
- Candidate title.
- Candidate type/date when available.
- Source.
- Waiting age or discovered timestamp context.

**Primary action:** Open Candidate Review.

**Must not happen**
- Do not rank by an assumed numeric confidence threshold that has not been calibrated.
- Do not expose queue contents to regular users.

---

### 6.8 Admin Candidate Review

**Decision context**
- Candidate title.
- Company/Ticker.
- Executive and proposed CEO/CFO role.
- Candidate date evidence and proposed Primary Event Date/basis when available.
- Event Type.
- Source/Resource URL and source metadata.
- Excerpt/description or participation evidence available from the Candidate.
- Why the Candidate is uncertain, when such review context exists.
- Existing Canonical Event matches for duplicate/merge review.

**Confidence**
- The screen may identify the Candidate as `Uncertain` and present available evidence.
- The UX must not depend on a specific numeric confidence threshold before the Discovery benchmark calibrates it.

**Actions**
- Approve.
- Reject.
- Merge.

**Merge**
- Suggested plausible Events first.
- Search/select another Event.
- Confirmation names the selected target Event.

**Feedback**
- Success: remove resolved Candidate from pending queue and move to next/queue.
- Error: preserve Candidate context and chosen action state where safe; do not silently lose the review item.

---

## 7. Event Presentation Rules

### 7.1 Canonical Event

A feed/timeline item represents exactly one Public Appearance, regardless of how many Resources exist.

Example:

```text
NVDA · NVIDIA
Jensen Huang · CEO
CNBC Interview
Aug 28, 2026 · Interview       ● Unread

CNBC interview with NVIDIA CEO Jensen Huang
[Open Event]
```

The Event card must not repeat a full video, clip, article, and transcript as four separate Events if they belong to the same appearance.

### 7.2 Executive and Role

Display executive name together with `CEO` or `CFO`.

The role presented is the role valid for the Event's Primary Event Date according to product data. The UX must not substitute the executive's current role when historical Event data identifies another applicable role.

### 7.3 Primary Event Date

Primary Event Date is the primary chronological date used throughout Timeline ordering.

The UI does not need to expose internal date-basis terminology on every card. Event Detail may provide clarification when the product data needs to distinguish occurrence date from publication fallback.

### 7.4 Resource Published Date

If a Resource Published Date differs from Primary Event Date, Event Detail must make the difference visible for the relevant Resource.

### 7.5 Event Type

Show the Event's classified type such as Interview, Podcast, Conference, Fireside Chat, Keynote, or Earnings Call.

### 7.6 Source

Event cards may show a concise source label when useful. Event Detail must make original Resource sources identifiable.

### 7.7 Multiple Resources

Group Resources beneath one Event.

Recommended hierarchy:
1. Direct/original consumable Resources.
2. Transcript Resource when available.
3. Clips or additional Resources.
4. Related coverage.

The hierarchy must not change Canonical Event identity.

### 7.8 Read/Unread

- Unread is user-specific.
- Use one consistent unread indicator pattern across Home Timeline, Stock Timeline, and Watchlist counts.
- Opening Event Detail marks Read.
- Opening any supported original/transcript action marks Read.
- Manual Mark Read and Mark Unread are available.
- Scrolling never marks Read.

---

## 8. Watchlist & Backfill UX

### 8.1 Follow Experience

After Add:
1. The user lands on Stock Timeline.
2. Reusable existing Global Events appear immediately.
3. Historical checking for the required 90-calendar-day window is represented separately.
4. Newly discovered Events may appear as the historical process progresses or later.

The UX must not suggest that the user waits for the entire 90-day process before using the Timeline.

### 8.2 Backfill Status Language

The product-level outcomes remain exactly:

- Complete
- Partial
- Failed
- Unsupported

User-facing copy should explain impact rather than expose internal source/date-range mechanics by default.

| Product Outcome | User-Facing Meaning |
|---|---|
| Complete | Historical checking completed sufficiently under the PRD's authoritative outcome rule. Do not keep a permanent noisy status badge. |
| Partial | Some historical appearances may be missing because part of supported historical checking did not complete. |
| Failed | Historical checking has not completed successfully yet; the system will continue handling retry attempts. |
| Unsupported | Historical checking is not available for the required window under the enabled historical sources. Existing Events may still exist. |

### 8.3 Status Placement

Primary placement: near the Stock Timeline header, above filters/Event list.

The status must be visually secondary to the actual Event content unless the Timeline has no Events and the status explains why history may be incomplete.

### 8.4 Avoiding Status/Event Confusion

Never use these equivalences:

- `Complete` ≠ "all real-world appearances guaranteed found."
- `Partial` ≠ "only partial Event records are shown."
- `Failed` ≠ "the stock has no Events."
- `Unsupported` ≠ "the stock has no Events."

A stock with Unsupported historical coverage may still show existing Global Events.

### 8.5 Retry UX

Regular users do not manage source/date-range retries.

If retry activity is relevant to user understanding, use passive language such as:

`Some historical appearances may be missing. AlphaVoice will keep checking available history.`

Do not expose source jobs, segment controls, or technical retry operations in the regular-user MVP.

---

## 9. Admin Review UX

### 9.1 Review Queue

- Admin only.
- Oldest pending first.
- Show pending count.
- Provide compact candidate context for rapid triage.
- Queue must support normal/loading/empty/error states.

### 9.2 Candidate Detail

The Admin must have enough context to answer:

1. Is this actually a Public Appearance?
2. Did the identified CEO/CFO participate?
3. Is the proposed company/executive/role plausible for the relevant date?
4. What is the Event Type/date evidence?
5. Is this a new Canonical Event or another Resource for an existing Event?

### 9.3 Approve

Approve publishes/creates the resulting Canonical Event as appropriate to the product workflow.

Show immediate success acknowledgement and remove the Candidate from the pending queue.

### 9.4 Reject

Reject uses a confirmation dialog because it intentionally prevents the Candidate from being shown to regular users.

### 9.5 Merge

Merge flow:

```text
Candidate Review
   ↓
Merge
   ↓
Suggested existing Canonical Events
   ├─ choose suggested match
   └─ search/select another Event
          ↓
Confirm target Event
          ↓
Merge success
```

Suggestions must be distinguishable using Event identity, not only company/executive.

### 9.6 Permission Behavior

Regular user:
- no Admin navigation;
- no queue count;
- no Candidate information;
- direct Admin URL/access attempt → Access Denied.

MVP does not introduce multi-level Admin roles.

---

## 10. Responsive Behavior

Required targets:
- **360×800**
- **1280×800**

General rule: no required horizontal page scrolling, no clipped primary actions, and no content overlap that prevents completing a documented flow.

| Screen | 360×800 | 1280×800 |
|---|---|---|
| Sign In | Single column; prominent Google action | Centered sign-in panel/content region |
| Home Timeline | Single-column Event cards; filters wrap/stack; primary metadata prioritized | Wider feed; filter controls may share a row; maintain readable line length |
| Watchlist View | Compact rows/cards; search full width; unread count stays visible | Dense scannable rows suitable for 100+ stocks |
| Stock Search/Add | Full-width search; result rows stack action cleanly | Search + compact result list; Add/Following aligned |
| Stock Timeline | Header stacks company/follow state/status; filters wrap | Header and filters can use horizontal space; Event list stays chronologically dominant |
| Event Detail | Single-column metadata and Resource actions; full-width tap targets where needed | Metadata may use grouped rows/sections; Resource list remains clearly subordinate to Event identity |
| Admin Review Queue | Candidate cards/rows stack context; no wide table dependency | Compact queue rows/table-like layout allowed if no essential action depends on horizontal scrolling |
| Admin Candidate Review | Evidence sections stack; decision actions remain reachable; merge suggestions stack | Evidence and decision context may use multi-column grouping, but decision hierarchy remains clear |

### 10.1 Mobile Priority Rules

When space is constrained, preserve in this order:

1. Event title / Candidate title.
2. Company/Ticker.
3. Executive + Role.
4. Primary Event Date.
5. Event Type.
6. Read/Unread or review status.
7. Source.
8. Secondary metadata.

Do not hide required actions behind hover-only behavior.

---

## 11. Reusable Component Patterns

### Event Card
Represents one Canonical Event. Supports unread indicator, title, company/ticker, executive/role, date, Event Type, concise source context, and navigation to Event Detail.

### Stock Row/Card
Ticker, Company Name, unread count, open Stock Timeline. Supports compact scanning for large Watchlists.

### Unread Badge / Indicator
One consistent visual semantics across Event cards, Watchlist stock counts, and applicable navigation/filter context. `New` is not a separate state.

### Filter Control
Reusable pattern for All/Unread, CEO/CFO, and Event Type. Active state must be obvious and removable/resettable.

### Resource Link
Action label corresponds to Resource type: Watch Original, Read Original, Read Transcript. External navigation opens new tab.

### Status Indicator
For transient/history-impact states such as checking, Partial, Failed, Unsupported. Status language describes user impact before internal process.

### Confirmation Dialog
Use when an action has meaningful destructive or hard-to-reverse user impact:
- Remove Stock.
- Reject Candidate.
- Confirm Merge target.

Do not add confirmations to routine navigation or Mark Read/Unread.

### Empty State
Explains why a list is empty and provides the most relevant next action:
- no Watchlist → Add Stock;
- no unread Events → View All;
- no filtered matches → Clear filters;
- no Admin Candidates → no candidates waiting.

### Error State
Keeps user context, states what failed in user terms, and offers a retry/navigation action when appropriate. Do not expose implementation details.

---

## 12. UX Non-Goals

MVP UX does not include:

- Email notification settings or email notification flows.
- Push notification settings or push notification flows.
- AI-generated summary workflow.
- Automatic AI analysis workflow.
- Automatic transcript-generation workflow.
- Transcript keyword search.
- Search company by executive name.
- Tracking executives beyond CEO/CFO.
- Video download/hosting workflow.
- Unlimited historical backfill controls.
- A user-facing source-fetch scheduler.
- A user-facing manual backfill source/date-range retry console.
- Complex multi-admin role/permission management.
- A general news feed that mixes executive mentions with actual appearances.
- Proactive browsing/monitoring UX for every company in the Stock Universe.

---

## 13. Open UX Questions

No unresolved material owner UX decision remains for this Phase 2.5 draft.

Items intentionally deferred because they belong to later validation or Architecture rather than UX:

- Exact discovery source set.
- Numeric confidence thresholds.
- Fetch cadence.
- Stock Universe data provider.
- Executive data provider.
- Deployment model.
- Technical mechanism used to produce merge suggestions or automatic historical retries.

If a later Architecture or Discovery Spike reveals that a locked UX behavior cannot be supported within validated PRD constraints, the project should use the BMAD change/escalation workflow rather than silently changing this UX Spec.

---

## 14. FR → Screen/Flow Traceability

| FR | UX Representation |
|---|---|
| FR-1 | Sign In; Flow 3.1 |
| FR-2 | Sign In/session boundary; all user-specific Home/Watchlist/Read states; Admin forbidden state |
| FR-3 | Account navigation → Logout; returns to Sign In |
| FR-4 | Stock Search/Add eligibility behavior |
| FR-5 | Stock Search/Add by Ticker or Company Name |
| FR-6 | Add flow; Remove flow; Watchlist View |
| FR-7 | Watchlist-driven follow/unfollow mental model; no universe-wide monitoring UX |
| FR-8 | Event/Stock presentation depends on CEO/CFO identity; Admin Candidate Review role context |
| FR-9 | Event Detail role/date presentation; Admin Candidate Review date/role context |
| FR-10 | User-visible result is automatically discovered Events; no manual discovery workflow |
| FR-11 | No direct regular-user control; intentionally absent from UX |
| FR-12 | Event Type presentation and filters |
| FR-13 | Precision-first Event model; Admin Candidate Review participation evidence |
| FR-14 | High-confidence items may appear without Admin flow; Approve flow covers manual path only |
| FR-15 | Admin Review Queue; Candidate remains hidden from regular users |
| FR-16 | Admin Reject flow |
| FR-17 | Canonical Event presentation; Admin Merge flow |
| FR-18 | Event Detail Resources; Merge behavior |
| FR-19 | Admin-only navigation/actions; Access Denied |
| FR-20 | Simple Admin UX; no complex permission hierarchy |
| FR-21 | Add Stock flow; Stock Timeline 90-day history checking |
| FR-22 | Backfill outcome presentation; retries not user-managed |
| FR-23 | Immediate reuse of existing Global Events in Add/Stock Timeline UX |
| FR-24 | Followed stock remains in Watchlist-driven forward Timeline experience |
| FR-25 | Home Timeline |
| FR-26 | Home Watchlist View; unread counts |
| FR-27 | Stock Timeline |
| FR-28 | All/Unread filter on Home and Stock Timeline |
| FR-29 | CEO/CFO filter on Home and Stock Timeline |
| FR-30 | Event Type filter on Home and Stock Timeline |
| FR-31 | Event Detail |
| FR-32 | Event Detail metadata/date/source rules |
| FR-33 | Optional source-provided excerpt in Event Detail |
| FR-34 | Multiple Resources under one Event |
| FR-35 | Watch Original / Read Original / Read Transcript |
| FR-36 | Opening Event Detail marks Read |
| FR-37 | Opening supported external Resource marks Read |
| FR-38 | Manual Mark Read / Mark Unread |
| FR-39 | Scrolling never changes Read state |
| FR-40 | Unread indicators/counts across Timeline/Watchlist |
| FR-41 | Responsive behavior for all required core screens |

---

## 15. Changelog

- **0.1 — 2026-09-01:** Initial UX Spec draft from validated PRD, incorporating owner-resolved UX decisions from Phase 2.5.
- **1.0 — 2026-09-01:** Owner UX walkthrough completed with no blocking usability issues; UX Spec promoted to validated.
