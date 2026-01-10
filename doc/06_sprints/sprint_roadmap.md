# Sprint Roadmap Summary (Sprint 7-10)

## Overview

The original Sprint 7 plan has been restructured into **4 focused sprints** to systematically address the technical risks and conditional requirements identified in US-02 and US-03.

---

## Roadmap Structure

```
Sprint 7 (1 week)          Sprint 8 (2 weeks)         Sprint 9 (2 weeks)         Sprint 10 (2 weeks)
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  PoC: Native    │       │  Core Features  │       │  Video          │       │  Video          │
│  Integration    │──[VP-7]──>  on Still     │──[VP-8]──>  Processing    │──[VP-9]──>  Performance  │──[VP-10]
│                 │       │  Images         │       │  Foundation     │       │  & UX           │
└─────────────────┘       └─────────────────┘       └─────────────────┘       └─────────────────┘
     PoC only                 Full features           Functional only          Optimized
   (iOS + Android)           (Still images)           (No optimization)       (Target: <5min/1min)
```

---

## Verification Points (Go/No-Go Decisions)

| VP | Name | Criteria | Action if No-Go |
|---|---|---|---|
| **VP-7** | Native Integration | Platform Channel successfully retrieves hand landmarks (iOS & Android, <500ms) | Move US-02 to backlog; investigate alternatives |
| **VP-8** | Still Image Features | Both features work correctly on real devices | Schedule bug-fixing sprint (Sprint 8.5) |
| **VP-9** | Video Foundation | Video processing pipeline completes successfully (functional only) | Re-evaluate architecture |
| **VP-10** | Video Performance | 1-minute video processes in under 5 minutes | Present trade-offs to product owner |

---

## Sprint-by-Sprint Breakdown

### Sprint 7: PoC - Native Integration (1 week)

**Objective**: Prove MediaPipe Hands can be integrated via Platform Channels.

**Scope**:
- iOS: Swift + MediaPipe Hands SDK
- Android: Kotlin + MediaPipe Hands SDK
- Platform Channel bridge
- Performance measurement

**Deliverable**: PoC report with Go/No-Go recommendation

---

### Sprint 8: Core Features on Still Images (2 weeks)

**Objective**: Deliver fully functional privacy features for still images.

**Scope**:
- US-01: ML Kit Face Detection integration → Facial Obfuscator
- US-02: MediaPipe Hands integration → Palm Scrubber
- US-04: UI switches with state persistence

**Deliverable**: Working features on still images (iOS & Android)

---

### Sprint 9: Video Processing Foundation (2 weeks)

**Objective**: Make privacy features work on videos (functional only, no performance optimization).

**Scope**:
- Frame extraction (FFmpeg)
- Frame-by-frame processing loop
- Video re-assembly
- Basic progress indicator

**Deliverable**: Functional video processing pipeline

---

### Sprint 10: Video Performance & UX (2 weeks)

**Objective**: Optimize video processing to meet performance targets.

**Scope**:
- Performance profiling
- Parallel processing (Isolates)
- Image format optimization
- Quality/speed trade-off options
- Enhanced progress indicator

**Deliverable**: Optimized video processing (target: 1-minute video in under 5 minutes)

---

## Key Benefits of This Approach

1. **Risk Isolation**: The most uncertain element (native integration) is validated first in Sprint 7.
2. **Early Value Delivery**: Users get working features for still images in Sprint 8, even if video processing is delayed.
3. **Clear Decision Points**: Each sprint ends with a Go/No-Go decision, preventing the team from proceeding with unstable foundations.
4. **Separation of Concerns**: Functional implementation (Sprint 9) is separated from performance optimization (Sprint 10), allowing focused work.

---

## Comparison with Original Plan

| Aspect | Original Plan | Reconfigured Plan |
|---|---|---|
| Sprint Count | 1 sprint (Sprint 7) | 4 sprints (Sprint 7-10) |
| Verification | End of sprint only | After each sprint (VP-7, VP-8, VP-9, VP-10) |
| Risk Management | All risks in one sprint | Risks distributed and validated incrementally |
| Value Delivery | All-or-nothing | Incremental (still images → video functional → video optimized) |
