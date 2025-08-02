;; Title: WorkFlow - Next-Generation Decentralized Freelance Platform
;;
;; Summary:
;; WorkFlow transforms the gig economy by creating a transparent, secure, and 
;; decentralized marketplace where talent meets opportunity without intermediaries.
;; Built on Stacks blockchain with Bitcoin-level security guarantees.
;;
;; Description:
;; WorkFlow empowers the future of work through:
;; - Smart contract-based escrow system ensuring payment security
;; - Milestone-driven project management with automated releases  
;; - Community-governed dispute resolution mechanism
;; - Immutable reputation system building long-term trust
;; - Zero-fee direct STX transactions between parties
;; - Transparent bidding process with complete project visibility
;;
;; Leveraging Stacks Layer 2 architecture for high throughput while maintaining
;; the immutability and security of Bitcoin's base layer. Every transaction,
;; rating, and dispute resolution is permanently recorded on-chain.

;; CONSTANTS & ERROR DEFINITIONS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-JOB (err u101))
(define-constant ERR-INVALID-STATUS (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-ALREADY-BIDDED (err u104))
(define-constant ERR-DISPUTE-EXISTS (err u105))
(define-constant ERR-INVALID-RATING (err u106))
(define-constant ERR-TOO-MANY-BIDDERS (err u107))
(define-constant ERR-INVALID-INPUT (err u108))
(define-constant ERR-MILESTONE-OUT-OF-BOUNDS (err u109))
(define-constant ERR-INVALID-MILESTONES (err u110))
(define-constant ERR-RATE-LIMITED (err u111))

;; Input validation constants
(define-constant MIN-BUDGET u1000000) ;; 1 STX minimum
(define-constant MAX-BUDGET u100000000000) ;; 100,000 STX maximum
(define-constant MAX-BIDDERS u100)
(define-constant MAX-MILESTONES u10)
(define-constant MIN-TITLE-LENGTH u3)
(define-constant MAX-TITLE-LENGTH u100)
(define-constant MIN-DESCRIPTION-LENGTH u10)
(define-constant MAX-DESCRIPTION-LENGTH u500)
(define-constant MIN-PROPOSAL-LENGTH u20)
(define-constant MAX-PROPOSAL-LENGTH u500)
(define-constant MIN-REASON-LENGTH u10)
(define-constant MAX-REASON-LENGTH u500)
(define-constant MAX-DAILY-JOBS u10)
(define-constant MAX-DAILY_BIDS u50)

;; STATE VARIABLES

(define-data-var job-counter uint u0)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points

;; DATA STRUCTURES

;; Core job information and project lifecycle tracking
(define-map jobs
  { job-id: uint }
  {
    client: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    budget: uint,
    status: (string-ascii 20),
    freelancer: (optional principal),
    milestones: (list 10 uint),
    current-milestone: uint,
    created-at: uint,
  }
)

;; Proposal submissions from freelancers
(define-map bids
  {
    job-id: uint,
    bidder: principal,
  }
  {
    amount: uint,
    proposal: (string-ascii 500),
    status: (string-ascii 20),
    created-at: uint,
  }
)

;; Track all bidders for each job posting
(define-map job-bidders
  { job-id: uint }
  { bidders: (list 100 principal) }
)

;; Comprehensive user reputation system
(define-map user-ratings
  { user: principal }
  {
    total-rating: uint,
    number-of-ratings: uint,
    average-rating: uint,
  }
)

;; Dispute resolution and community governance
(define-map disputes
  { job-id: uint }
  {
    initiator: principal,
    reason: (string-ascii 500),
    votes-release: uint,
    votes-refund: uint,
    resolved: bool,
    created-at: uint,
  }
)

;; Secure escrow for payment protection
(define-map escrow
  { job-id: uint }
  {
    amount: uint,
    locked: bool,
  }
)

;; Enhanced user activity tracking with rate limiting
(define-map user-activity 
  { user: principal }
  { 
    jobs-posted-today: uint,
    bids-placed-today: uint,
    last-activity-block: uint,
    last-reset-day: uint,
  }
)

;; VALIDATION FUNCTIONS

;; Validate string input with length constraints
(define-private (validate-string 
    (input (string-ascii 500)) 
    (min-len uint) 
    (max-len uint)
  )
  (let ((str-len (len input)))
    (and 
      (>= str-len min-len)
      (<= str-len max-len)
      ;; Check for non-empty after trimming (basic check)
      (> str-len u0)
    )
  )
)

;; Validate numeric input within bounds
(define-private (validate-amount (amount uint) (min-val uint) (max-val uint))
  (and (>= amount min-val) (<= amount max-val))
)

;; Validate milestone structure
(define-private (validate-milestones (milestones (list 10 uint)) (total-budget uint))
  (let (
      (milestone-count (len milestones))
      (milestone-sum (fold + milestones u0))
    )
    (and 
      (> milestone-count u0)
      (<= milestone-count MAX-MILESTONES)
      (is-eq milestone-sum total-budget)
      (> milestone-sum u0)
      ;; Ensure no milestone is zero
      (is-eq (len (filter is-positive milestones)) milestone-count)
    )
  )
)

;; Helper function to check if value is positive
(define-private (is-positive (value uint))
  (> value u0)
)

;; Comprehensive job input validation
(define-private (validate-job-input 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (budget uint)
    (milestones (list 10 uint))
  )
  (and
    (validate-string title MIN-TITLE-LENGTH MAX-TITLE-LENGTH)
    (validate-string description MIN-DESCRIPTION-LENGTH MAX-DESCRIPTION-LENGTH)
    (validate-amount budget MIN-BUDGET MAX-BUDGET)
    (validate-milestones milestones budget)
  )
)

;; Validate bid input
(define-private (validate-bid-input 
    (job-id uint)
    (amount uint)
    (proposal (string-ascii 500))
  )
  (and
    (> job-id u0)
    (validate-amount amount MIN-BUDGET MAX-BUDGET)
    (validate-string proposal MIN-PROPOSAL-LENGTH MAX-PROPOSAL-LENGTH)
  )
)

;; Rate limiting check
(define-private (check-rate-limit (user principal) (action (string-ascii 10)))
  (let (
      (current-block stacks-block-height)
      (current-day (/ current-block u144)) ;; Assuming ~10 minute blocks, 144 blocks per day
      (activity (default-to 
        { 
          jobs-posted-today: u0,
          bids-placed-today: u0,
          last-activity-block: u0,
          last-reset-day: u0
        } 
        (map-get? user-activity { user: user })
      ))
    )
    (let (
        (reset-needed (> current-day (get last-reset-day activity)))
        (updated-activity (if reset-needed
          {
            jobs-posted-today: u0,
            bids-placed-today: u0,
            last-activity-block: current-block,
            last-reset-day: current-day
          }
          activity
        ))
      )
      (if (is-eq action "job")
        (< (get jobs-posted-today updated-activity) MAX-DAILY-JOBS)
        (< (get bids-placed-today updated-activity) MAX-DAILY_BIDS)
      )
    )
  )
)

;; Update user activity after successful action
(define-private (update-user-activity (user principal) (action (string-ascii 10)))
  (let (
      (current-block stacks-block-height)
      (current-day (/ current-block u144))
      (activity (default-to 
        { 
          jobs-posted-today: u0,
          bids-placed-today: u0,
          last-activity-block: u0,
          last-reset-day: u0
        } 
        (map-get? user-activity { user: user })
      ))
    )
    (let (
        (reset-needed (> current-day (get last-reset-day activity)))
        (base-activity (if reset-needed
          {
            jobs-posted-today: u0,
            bids-placed-today: u0,
            last-activity-block: current-block,
            last-reset-day: current-day
          }
          activity
        ))
      )
      (map-set user-activity { user: user }
        (if (is-eq action "job")
          (merge base-activity { 
            jobs-posted-today: (+ (get jobs-posted-today base-activity) u1)
          })
          (merge base-activity { 
            bids-placed-today: (+ (get bids-placed-today base-activity) u1)
          })
        )
      )
    )
  )
)

;; Job ownership verification
(define-private (is-job-participant (job-id uint) (user principal))
  (match (map-get? jobs { job-id: job-id })
    job (or 
      (is-eq user (get client job))
      (is-eq (some user) (get freelancer job))
    )
    false
  )
)

;; PROJECT MANAGEMENT FUNCTIONS

;; Create new job posting with comprehensive validation and escrow-backed funding
(define-public (post-job
    (title (string-ascii 100))
    (description (string-ascii 500))
    (budget uint)
    (milestones (list 10 uint))
  )
  (let ((job-id (+ (var-get job-counter) u1)))
    ;; Input validation
    (asserts! (validate-job-input title description budget milestones) ERR-INVALID-INPUT)
    ;; Rate limiting
    (asserts! (check-rate-limit tx-sender "job") ERR-RATE-LIMITED)
    
    ;; Transfer budget to escrow
    (try! (stx-transfer? budget tx-sender (as-contract tx-sender)))
    
    ;; Create job record with validated inputs
    (map-set jobs { job-id: job-id } {
      client: tx-sender,
      title: title,
      description: description,
      budget: budget,
      status: "open",
      freelancer: none,
      milestones: milestones,
      current-milestone: u0,
      created-at: stacks-block-height,
    })
    
    ;; Update job counter
    (var-set job-counter job-id)
    
    ;; Initialize escrow
    (map-set escrow { job-id: job-id } {
      amount: budget,
      locked: true,
    })
    
    ;; Initialize bidders list
    (map-set job-bidders { job-id: job-id } { bidders: (list) })
    
    ;; Update user activity
    (update-user-activity tx-sender "job")
    
    (ok job-id)
  )
)

;; Submit proposal for available project with enhanced validation
(define-public (place-bid
    (job-id uint)
    (amount uint)
    (proposal (string-ascii 500))
  )
  (let (
      (job (unwrap! (map-get? jobs { job-id: job-id }) ERR-INVALID-JOB))
      (current-bidders (default-to { bidders: (list) } (map-get? job-bidders { job-id: job-id })))
    )
    ;; Input validation
    (asserts! (validate-bid-input job-id amount proposal) ERR-INVALID-INPUT)
    ;; Rate limiting
    (asserts! (check-rate-limit tx-sender "bid") ERR-RATE-LIMITED)
    ;; Business logic validation
    (asserts! (is-eq (get status job) "open") ERR-INVALID-STATUS)
    (asserts!
      (is-none (map-get? bids {
        job-id: job-id,
        bidder: tx-sender,
      }))
      ERR-ALREADY-BIDDED
    )
    (asserts! (< (len (get bidders current-bidders)) MAX-BIDDERS) ERR-TOO-MANY-BIDDERS)
    
    ;; Record bid with validated inputs
    (map-set bids {
      job-id: job-id,
      bidder: tx-sender,
    } {
      amount: amount,
      proposal: proposal,
      status: "pending",
      created-at: stacks-block-height,
    })
    
    ;; Add to bidders list
    (map-set job-bidders { job-id: job-id } { 
      bidders: (unwrap! (as-max-len? (append (get bidders current-bidders) tx-sender) u100)
        ERR-TOO-MANY-BIDDERS
      ) 
    })
    
    ;; Update user activity
    (update-user-activity tx-sender "bid")
    
    (ok true)
  )
)