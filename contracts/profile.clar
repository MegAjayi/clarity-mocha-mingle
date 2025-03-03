;; User profiles and reputation
(define-map profiles principal {
  username: (string-utf8 50),
  bio: (string-utf8 500),
  reputation: uint,
  recipes: (list 100 uint)
})

(define-map usernames (string-utf8 50) principal)

;; Contract owner
(define-constant contract-owner tx-sender)

;; Read-only: Get profile details
(define-read-only (get-profile (user principal))
  (map-get? profiles user))

;; Create/update profile
(define-public (set-profile (username (string-utf8 50)) (bio (string-utf8 500)))
  (let ((existing-user (map-get? usernames username)))
    ;; Validate non-empty inputs
    (asserts! (> (len username) u0) (err u400))
    (asserts! (> (len bio) u0) (err u400))
    
    (asserts! (or (is-none existing-user) 
             (is-eq (some tx-sender) existing-user)) 
             (err u403))
    
    (map-set usernames username tx-sender)
    (print {event: "profile-updated", user: tx-sender})
    (ok (map-set profiles tx-sender {
      username: username,
      bio: bio,
      reputation: u0,
      recipes: (list)
    }))))

;; Add recipe to profile
(define-public (add-recipe (recipe-id uint))
  (let ((profile (unwrap! (map-get? profiles tx-sender) (err u404))))
    ;; Check for duplicate recipe
    (asserts! (is-none (index-of (get recipes profile) recipe-id)) (err u409))
    
    (print {event: "recipe-added-to-profile", user: tx-sender, recipe-id: recipe-id})
    (ok (map-set profiles tx-sender
      (merge profile { 
        recipes: (unwrap! (as-max-len? (append (get recipes profile) recipe-id) u100) (err u500))
      })))))

;; Add reputation points (restricted to contract owner)
(define-public (add-reputation (user principal) (points uint))
  (let ((profile (unwrap! (map-get? profiles user) (err u404))))
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (<= points u100) (err u400))
    
    (print {event: "reputation-added", user: user, points: points})
    (ok (map-set profiles user
      (merge profile { reputation: (+ (get reputation profile) points) })))))
