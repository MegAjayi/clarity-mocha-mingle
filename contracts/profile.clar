;; User profiles and reputation
(define-map profiles principal {
  username: (string-utf8 50),
  bio: (string-utf8 500),
  reputation: uint,
  recipes: (list 100 uint)
})

;; Create/update profile
(define-public (set-profile (username (string-utf8 50)) (bio (string-utf8 500)))
  (ok (map-set profiles tx-sender {
    username: username,
    bio: bio,
    reputation: u0,
    recipes: (list)
  })))

;; Add reputation points
(define-public (add-reputation (user principal) (points uint))
  (let ((profile (unwrap! (map-get? profiles user) (err u404))))
    (ok (map-set profiles user
      (merge profile { reputation: (+ (get reputation profile) points) })))))
