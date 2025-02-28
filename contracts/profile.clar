;; User profiles and reputation
(define-map profiles principal {
  username: (string-utf8 50),
  bio: (string-utf8 500),
  reputation: uint,
  recipes: (list 100 uint)
})

(define-map usernames (string-utf8 50) principal)

;; Read-only: Get profile details
(define-read-only (get-profile (user principal))
  (map-get? profiles user))

;; Create/update profile
(define-public (set-profile (username (string-utf8 50)) (bio (string-utf8 500)))
  (let ((existing-user (map-get? usernames username)))
    (asserts! (or (is-none existing-user) 
                 (is-eq (some tx-sender) existing-user)) 
             (err u403))
    (map-set usernames username tx-sender)
    (ok (map-set profiles tx-sender {
      username: username,
      bio: bio,
      reputation: u0,
      recipes: (list)
    }))))

;; Add recipe to profile
(define-public (add-recipe (recipe-id uint))
  (let ((profile (unwrap! (map-get? profiles tx-sender) (err u404))))
    (ok (map-set profiles tx-sender
      (merge profile { 
        recipes: (unwrap! (as-max-len? (append (get recipes profile) recipe-id) u100) (err u500))
      })))))

;; Add reputation points
(define-public (add-reputation (user principal) (points uint))
  (let ((profile (unwrap! (map-get? profiles user) (err u404))))
    (asserts! (<= points u100) (err u400))
    (ok (map-set profiles user
      (merge profile { reputation: (+ (get reputation profile) points) })))))
