;; -----------------------------------------------------
;;  Decentralized PR Raffle Rewards Contract
;;  Description:
;;    - Monthly raffle for valid open-source PR contributors.
;;    - Admin funds the reward pool and triggers winner selection.
;;    - Random winner selected using block hash entropy.
;; -----------------------------------------------------

;; ---------------- CONSTANTS & ERRORS ------------------

(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_ROUND_NOT_ACTIVE u101)
(define-constant ERR_ALREADY_REGISTERED u102)
(define-constant ERR_NO_PARTICIPANTS u103)
(define-constant ERR_NOT_WINNER u104)
(define-constant ERR_ALREADY_DRAWN u105)
(define-constant ERR_NO_WINNER u106)

;; ---------------- DATA VARIABLES ----------------------

;; Admin who manages the raffle
(define-data-var admin principal tx-sender)

;; Current raffle round ID
(define-data-var current-round uint u1)

;; Total number of participants in the current round
(define-data-var participant-count uint u0)

;; STX amount for the current reward pool
(define-data-var reward-pool uint u0)

;; Whether a winner has been drawn for a given round
(define-map round-winner-drawn uint bool)

;; The winner of each round
(define-map winners uint principal)

;; Registered participants: {round, user} => index
(define-map participants
  { round: uint, user: principal }
  uint)

;; Reverse lookup: {round, index} => user
(define-map participant-index
  { round: uint, index: uint }
  principal)

;; ---------------- PRIVATE HELPERS ---------------------

(define-private (get-current-round)
  (var-get current-round))

;; ---------------- PUBLIC FUNCTIONS --------------------

;; Register a participant for the current raffle round
(define-public (register-entry)
  (let (
        ;; read the current round from contract storage
        (round (var-get current-round))

        ;; check whether sender already registered for this round
        (already (map-get? participants { round: round, user: tx-sender }))
       )
    (if (is-some already)
        (err ERR_ALREADY_REGISTERED)
        (let ((count (+ (var-get participant-count) u1)))
          (var-set participant-count count)
          (map-set participants { round: round, user: tx-sender } count)
          (map-set participant-index { round: round, index: count } tx-sender)
          ;; return the new participant index as success value
          (ok count)))))


;; Winner claims their reward
(define-public (claim-reward (round uint))
  (let (
        (winner (map-get? winners round))
        (amount (var-get reward-pool))
       )
    (asserts! (is-some winner) (err ERR_NO_WINNER))
    (if (is-eq (unwrap! winner (err ERR_NO_WINNER)) tx-sender)
        (begin
          (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
          (ok "Reward claimed successfully"))
        (err ERR_NOT_WINNER))))


;; ---------------- READ-ONLY FUNCTIONS ------------------

;; Get current round number
(define-read-only (get-current-round-id)
  (ok (get-current-round)))

;; Get total participants in current round
(define-read-only (get-participant-count)
  (ok (var-get participant-count)))

;; Check if a user is registered in current round
(define-read-only (is-registered (user principal))
  (ok (is-some (map-get? participants {round: (get-current-round), user: user}))))

;; Get winner of a specific round
(define-read-only (get-winner (round uint))
  (ok (map-get? winners round)))

;; Get reward pool amount
(define-read-only (get-reward-pool)
  (ok (var-get reward-pool)))
