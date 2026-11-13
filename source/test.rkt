;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname test) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #t ((lib "sludges.rkt" "teachpack" "htdp")) #f)))

; Filename: physics-test.rkt
; Date: 12 Nov
; Author: Chadus Johnenzo Petixo
; Purpose: advances an aircraft through physics ticks and checks
;          that its state changes as expected.

(require sludges)
(require "model.rkt")
(require "physics.rkt")

; 1. TEST CONFIGURATION

(define DT (/ 1 30))

(: test-plane (Number Number Throttle -> Aircraft))
;; Creates an aircraft with the specified pitch, roll and throttle.
(define (test-plane pitch roll throttle)
  (make-aircraft (make-posn 0 0)
                 1000 140 0
                 pitch roll 0 throttle))

(define START (test-plane 0 0 100))


; 2. SIMULATION FUNCTION

(: simulate (Aircraft Integer Number -> Aircraft))
;; Advances an aircraft by a given number of ticks.
;; Assumes ticks is a non-negative integer.
(define (simulate plane ticks dt)
  (if (= ticks 0)
      plane
      (simulate (step-aircraft plane dt)
                (sub1 ticks)
                dt)))


; 3. TEST SCENARIOS

; a. Engine power
(define FULL (simulate START 30 DT))
(define HALF (simulate (test-plane 0 0 50) 30 DT))
(define IDLE (simulate (test-plane 0 0 0) 30 DT))

; b. Pitch and vertical motion
(define CLIMB (simulate (test-plane 5 0 100) 30 DT))
(define DIVE (simulate (test-plane -5 0 100) 30 DT))

; c. Banking
(define RIGHT (simulate (test-plane 0 15 50) 30 DT))
(define LEFT (simulate (test-plane 0 -15 50) 30 DT))

; d. Stall
(define SHALLOW
  (step-aircraft (test-plane 5 0 100) DT))

(define STALLED
  (step-aircraft (test-plane 30 0 100) DT))

; e. Free fall
(define STOPPED
  (make-aircraft (make-posn 0 0)
                 1000 0 0 0 45 0 0))

(define FALLING (step-aircraft STOPPED DT))

; f. Heading wraparound
(define WRAP
  (simulate
   (make-aircraft (make-posn 0 0)
                  1000 140 359 0 45 0 50)
   30 DT))

; g. Eastward flight
(define EAST
  (simulate
   (make-aircraft (make-posn 0 0)
                  1000 140 90 0 0 0 100)
   30 DT))


; 4. ADVANCED PHYSICS TESTS

; a. Simulation consistency

(check-within (simulate START 0 DT)
              START 0.000001)

(check-within (simulate START 1 DT)
              (step-aircraft START DT)
              0.000001)

(check-within (simulate START 30 DT)
              (simulate (simulate START 10 DT) 20 DT)
              0.000001)


; b. Throttle response

(check-expect
 (> (aircraft-airspeed FULL)
    (aircraft-airspeed HALF))
 #true)

(check-expect
 (> (aircraft-airspeed HALF)
    (aircraft-airspeed IDLE))
 #true)


; c. Climbing and diving

(check-expect
 (> (aircraft-altitude CLIMB)
    (aircraft-altitude FULL))
 #true)

(check-expect
 (< (aircraft-altitude DIVE)
    (aircraft-altitude FULL))
 #true)

(check-expect
 (> (aircraft-vspeed CLIMB) 0)
 #true)

(check-expect
 (< (aircraft-vspeed DIVE) 0)
 #true)


; d. Symmetrical banking

(check-expect (> (aircraft-heading RIGHT) 0) #true)
(check-expect (> (aircraft-heading LEFT) 350) #true)

(check-within
 (+ (aircraft-heading RIGHT)
    (aircraft-heading LEFT))
 360 0.001)

(check-within
 (+ (posn-x (aircraft-position RIGHT))
    (posn-x (aircraft-position LEFT)))
 0 0.001)

(check-within
 (aircraft-altitude RIGHT)
 (aircraft-altitude LEFT)
 0.001)

(check-within
 (aircraft-airspeed RIGHT)
 (aircraft-airspeed LEFT)
 0.001)


; e. Stall behavior

(check-expect
 (> (aircraft-vspeed SHALLOW)
    (aircraft-vspeed STALLED))
 #true)


; f. Free fall from rest

(check-within
 (aircraft-vspeed FALLING)
 (- (* 9.80665 DT))
 0.001)

(check-within
 (aircraft-altitude FALLING)
 (- 1000 (* 9.80665 DT DT))
 0.001)

(check-expect (aircraft-heading FALLING) 0)


; g. Heading normalization

(check-expect
 (> (aircraft-heading WRAP) 0)
 #true)

(check-expect
 (< (aircraft-heading WRAP) 10)
 #true)


; h. Coordinate system

(check-within
 (posn-x (aircraft-position EAST))
 (posn-y (aircraft-position FULL))
 0.001)

(check-within
 (posn-y (aircraft-position EAST))
 0 0.001)


; i. Numerical timestep convergence

(define COARSE (simulate START 30 (/ 1 30)))
(define FINE (simulate START 60 (/ 1 60)))

(check-within
 (aircraft-airspeed COARSE)
 (aircraft-airspeed FINE)
 0.01)

(check-within
 (aircraft-altitude COARSE)
 (aircraft-altitude FINE)
 0.05)

(check-within
 (posn-y (aircraft-position COARSE))
 (posn-y (aircraft-position FINE))
 0.1)


; j. Physical invariants

(: valid-motion? (Aircraft -> Boolean))
;; Checks basic velocity and heading constraints.
(define (valid-motion? plane)
  (and (>= (aircraft-airspeed plane) 0)
       (>= (aircraft-heading plane) 0)
       (< (aircraft-heading plane) 360)
       (<= (abs (aircraft-vspeed plane))
           (+ (aircraft-airspeed plane) 0.000001))))

(check-expect
 (andmap valid-motion?
         (list FULL HALF IDLE CLIMB DIVE
               RIGHT LEFT STALLED FALLING WRAP))
 #true)


; 5. RESULTS

(list
 (list "Full throttle speed" (aircraft-airspeed FULL))
 (list "Idle speed" (aircraft-airspeed IDLE))
 (list "Climb altitude" (aircraft-altitude CLIMB))
 (list "Dive altitude" (aircraft-altitude DIVE))
 (list "Right heading" (aircraft-heading RIGHT))
 (list "Left heading" (aircraft-heading LEFT))
 (list "Stalled vertical speed" (aircraft-vspeed STALLED)))
