# Project Brief: AlphaVoice
> Version: 1.0 | Status: validated | Validated: 2026-08-31

## Problem

US stock investors who want to follow what CEOs and CFOs say directly must search across many sources such as YouTube, Investor Relations pages, podcasts, conferences, earnings calls, and news publishers. The information is fragmented, important appearances can be missed, and content where the executive actually speaks is often mixed with news that merely mentions the executive.

AlphaVoice aims to create a central place that aggregates **Public Appearances of CEOs and CFOs for stocks in a user's Watchlist**, with both a latest Feed and a historical Timeline.

Product priority:

**Precision > Coverage > Speed**

---

## Users

### Primary Users

1. **Retail US stock investors**
   - Want to know when executives of companies they follow have said something new publicly.

2. **Serious medium- and long-term investors**
   - Want to follow management communication continuously and review historical appearances.

3. **Traders**
   - Want to discover new Public Appearances from companies in their Watchlist quickly enough to investigate further.

The system supports multiple users. Each user has their own Watchlist and Read/Unread state.

---

## Success Metrics

### SM-1 — Discovery Coverage
When evaluated against a benchmark set of stocks and known Public Appearances, the system should discover at least **80%** of important Events.

> This target is provisional until validated through a real-world Discovery Spike.

### SM-2 — Precision
Candidates that the system publishes automatically to the Feed should have a False Positive rate of no more than **10%**.

Candidates the system is uncertain about must not be shown directly to users and must instead be sent to the Admin Review Queue.

### SM-3 — Reduced Manual Search
After adoption, AlphaVoice should become the user's primary starting point for checking CEO/CFO appearances for Watchlist stocks, reducing the need to routinely search multiple sources manually.

### SM-4 — Historical Usability
When a stock is added to the Watchlist, the user should be able to see discovered Public Appearances from the previous **90 days** and continue receiving newly discovered Events afterward.

### SM-5 — Operating Cost
The recurring operating cost of the base system should remain close to $0, with a target of no more than approximately **$10/month**.

Any new service that introduces recurring cost must be explicitly approved before it is added.

---

## In Scope

### 1. Authentication
- Sign in with Google
- Multiple users
- Logout
- Per-user Watchlist and Read/Unread state

### 2. Stock Universe & Watchlist

The system is **Watchlist-driven**.

Users can select stocks from the following universe:
- NYSE
- Nasdaq
- NYSE American
- ADRs traded on the supported US exchanges above

Excluded:
- ETFs
- Funds
- Instruments that do not have a normal company/executive structure suitable for CEO/CFO tracking

Users can:
- Search by **Ticker**
- Search by **Company Name**
- Add stocks to their Watchlist
- Remove stocks from their Watchlist

The Watchlist should not be designed around a limit of only a few dozen stocks and should support realistic usage of **100+ stocks**.

A stock being present in the Stock Universe does not mean the system must proactively monitor it. Discovery and backfill should be driven by stocks that are actually followed by at least one user.

### 3. Executive Scope

The MVP tracks:
- CEO
- CFO

Other C-level or senior executives are not tracked automatically in the MVP.

### 4. Public Appearance Types

The system tracks content in which the CEO or CFO speaks publicly and directly, including:
- Interview
- Podcast
- Conference
- Fireside Chat
- Keynote
- Earnings Call
- Other Public Appearance types that follow the same principle

News that merely mentions a CEO/CFO does not qualify as a Public Appearance.

### 5. Discovery

The system automatically discovers new content from free or low-cost sources first, such as:
- YouTube
- Company Investor Relations
- RSS
- Earnings / Events pages
- Other sources evaluated later

The system uses **Adaptive Fetching**:
- Free or low-cost sources may be checked more frequently
- Sources with limited quota or higher cost may be checked less frequently
- Actual fetch frequency must be determined from real-world evidence rather than assumption

### 6. Candidate Filtering

The Discovery pipeline should broadly follow:

Fetch  
→ Cheap pre-filter  
→ Candidate  
→ Validation  
→ Deduplication  
→ Canonical Event

Rule-based or local processing should be used before AI whenever practical to control cost.

### 7. Precision / Review Queue

Candidates must support at least these states:
- **High confidence** → may be published automatically
- **Uncertain** → sent to the Admin Review Queue
- **Rejected** → not shown to users

The MVP starts with one primary Admin, without preventing support for additional Admins later.

The Admin can:
- Approve
- Reject
- Merge a Candidate into an existing Event

### 8. Canonical Event

A single Public Appearance must be represented as one Canonical Event even when it has multiple Resources.

Example:

CNBC Interview — CEO
- Full Video
- Short Clips
- Original Article
- Transcript
- Related Coverage

Multiple clips from the same interview should not create duplicate full Events in the Feed.

### 9. Original Content

The system **does not need to download or host video content**.

It stores metadata and original-source links such as:
- Title
- Company / Ticker
- Executive
- Role
- Event date / Published date
- Event type
- Source
- URL
- Short description/excerpt when provided by the source

Users can open:
- Watch Original
- Read Original
- Read Transcript

when the corresponding Resource exists.

### 10. Historical Backfill

When a new stock is added to the Watchlist:
- The system attempts to show Events from the previous **90 days**
- The system continues tracking new Events afterward
- Historical Events are Global Data and are not duplicated per user
- Another user who follows the same stock can reuse already discovered Events

Loading data older than 90 days is not a default MVP behavior.

### 11. Home

The Home experience includes at least two views:

#### Timeline View
Combines Public Appearances for all stocks in the user's Watchlist and orders them newest to oldest.

#### Watchlist View
Shows stocks individually, for example:
- NVDA — 3 new
- AMD — 1 new
- MSFT — 0 new

Users can open a Stock Timeline from this view.

### 12. Stock Timeline

Displays Public Appearances of the company's CEO/CFO in chronological order.

### 13. Feed Filters

The MVP supports:
- All / Unread
- CEO / CFO
- Event Type

Example Event Types:
- Interview
- Podcast
- Conference
- Earnings Call
- Keynote

The MVP does not provide keyword search inside transcripts.

### 14. Event Detail

The Event Detail view shows at least:
- Event title
- Company / Ticker
- Executive name
- CEO / CFO role
- Event date / Published date
- Event type
- Source
- Short description/excerpt when available
- Watch Original / Read Original
- Related Sources
- Read/Unread state

### 15. Read / Unread

An Event becomes Read when:
- The user opens Event Detail, or
- The user selects Watch Original / Read Original

Users can manually:
- Mark as read
- Mark as unread

Simply scrolling past an Event in the Feed must not mark it as Read.

### 16. Notification

The MVP includes **in-app notifications only**.

Examples:
- `3 new`
- Unread badge
- New Event indicators

Email and push notifications are not included in the MVP.

### 17. Platform

The UI is web-based and must be **responsive**.

It must work well on:
- Desktop browsers
- Mobile browsers

The deployment model between a Public Web App and a Local Web App is not locked in this phase.

---

## Non-Goals

The MVP does not include:
- Proactive monitoring of every company in the NYSE/Nasdaq/NYSE American/ADR universe when no user follows it
- Tracking COO / CTO / President / EVP or other executives beyond CEO/CFO
- Downloading or hosting video content
- Guaranteeing 100% coverage of Public Appearances
- Email notifications
- Push notifications
- Automatic AI summaries
- AI topic extraction
- Management sentiment analysis
- Comparing executive statements across time
- Automatic transcript generation for every Event
- Keyword search inside transcripts
- Searching for a company by CEO/CFO name
- Unlimited historical backfill
- Expensive paid news/data infrastructure as the default

AI and transcript functionality may be added later as **on-demand** features, where cost is incurred only when a user chooses to analyze a specific Event.

---

## Constraints

### Cost
- Target recurring cost ≤ approximately $10/month
- Prefer free or low-cost sources first
- Any new recurring-cost service must be approved before use
- Adding a stock to the Watchlist should have very low incremental cost

### Discovery
The system should avoid frequently searching every CEO/CFO individually if that causes cost to grow directly with Watchlist size.

A source-centric or hybrid model should be considered, for example:

Source publishes new content  
→ Fetch Metadata  
→ Local match against CEO/CFOs from watched stocks  
→ Candidate Validation

### AI
AI should not be the first-stage filter when deterministic or local rules are sufficient.

### Data Sharing
Company / Executive / Public Appearance data is Global Data.

User-specific data includes:
- Watchlist
- Read/Unread
- Notification state

These must be separated from Global Data.

### Evidence
Fetch frequency, coverage, false-positive rate, and source suitability must be decided from real-world experiments rather than assumptions.

---

## Top Risks

### R1 — Discovery Coverage
Public Appearances are distributed across many sources, and no single API guarantees complete discovery.

### R2 — False Positives
Many news articles and videos mention CEOs/CFOs without the executive actually speaking.

### R3 — Duplicate Content
One interview may be republished as a full video, short clips, articles, and reposts.

### R4 — Source Reliability
Metadata, RSS feeds, APIs, and web pages differ significantly by source and may change over time.

### R5 — Executive Accuracy
CEO/CFO roles change, so the system must know who held a role at the relevant time.

### R6 — API / Quota / Terms
External sources may impose quota, rate limits, licensing constraints, or Terms of Service restrictions.

### R7 — Cost Creep
Paid news providers, automatic transcription, or AI processing can increase recurring cost quickly if not controlled.

### R8 — Multi-user Security
Because the MVP supports multiple users, Watchlist and user-specific state must not leak across users.

---

## Changelog

- **1.0 — 2026-08-31:** Validated Project Brief. Clarified the Watchlist-driven model and stock universe as NYSE/Nasdaq/NYSE American + ADR, excluding ETF/Fund.
