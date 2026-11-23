
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname controls) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))

; Date: 23.11.2026
; Author: Lorenzo Felix
; Filename: controls.rkt
; Purpose: converts keyboard input into aircraft pitch, roll and throttle settings, will drive the simulation in main, based on the instrumnets and physics. 
; TODO: Quit the sim implementation. 

(require sludges)
(require 2htdp/universe)
(require "model.rkt")

;; DATA DEFINITIONS
;; Aircraft, Position, Degree and Throttle are declared in model.rkt.
;; An Aircraft is
;; (make-aircraft Position Number Number Degree Number Number Number Throttle).
;; A Position is (make-Position Number Number Degree), with X east and Y north
;; in metres. Its heading agrees with the aircraft heading.
;; A Degree is a Number in [0, 360); a Throttle is an Integer in [0, 100].
;; Altitude is in metres; airspeed and vertical speed are in metres/second.
;; Positive pitch means nose-up; positive roll means right bank, in degrees.
;; KeyEvent is supplied by universe; other inputs and outputs are built-in types.
;; Existing structs are imported rather than redeclared as incompatible types.

;; Examples of each structured input type; nonzero fields expose accidental edits.
(define CONTROL-POSITION (make-Position 12 -34 123))
(define CONTROL-AIRCRAFT
  (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 45))

;; CONTROL LIMITS AND STEPS
;; These are simplified simulator input limits, not aircraft specifications.
(define MIN-PITCH -30)
(define MAX-PITCH 30)
(define MIN-ROLL -60)
(define MAX-ROLL 60)
(define PITCH-STEP 1)
(define ROLL-STEP 2)
(define THROTTLE-STEP 5)

;; Modified state variables: none. Each function returns a new Aircraft value
;; without mutating the original or advancing physics. No function is recursive,
;; so no termination argument is needed.

(: set-pitch (Aircraft Number -> Aircraft))
;; Sets nose angle in degrees, limited to [-30, 30], preserving all other fields.
(define (set-pitch plane pitch)
  (make-aircraft (aircraft-position plane)
                 (aircraft-altitude plane)
                 (aircraft-airspeed plane)
                 (aircraft-heading plane)
                 (max MIN-PITCH (min MAX-PITCH pitch))
                 (aircraft-roll plane)
                 (aircraft-vspeed plane)
                 (aircraft-throttle plane)))

(: set-roll (Aircraft Number -> Aircraft))
;; Sets right-bank angle in degrees, limited to [-60, 60], preserving other fields.
(define (set-roll plane roll)
  (make-aircraft (aircraft-position plane)
                 (aircraft-altitude plane)
                 (aircraft-airspeed plane)
                 (aircraft-heading plane)
                 (aircraft-pitch plane)
                 (max MIN-ROLL (min MAX-ROLL roll))
                 (aircraft-vspeed plane)
                 (aircraft-throttle plane)))

(: set-throttle (Aircraft Integer -> Aircraft))
;; Sets integer power percent, limited to [0, 100], preserving all other fields.
;; Integer input preserves the model's integer Throttle type.
(define (set-throttle plane percentage)
  (make-aircraft (aircraft-position plane)
                 (aircraft-altitude plane)
                 (aircraft-airspeed plane)
                 (aircraft-heading plane)
                 (aircraft-pitch plane)
                 (aircraft-roll plane)
                 (aircraft-vspeed plane)
                 (max 0 (min 100 percentage))))

(: handle-key (Aircraft KeyEvent -> Aircraft))
;; Arrows change pitch by 1 degree or roll by 2 degrees per keyboard event.
;; W/S change throttle by 5%; Space zeros pitch and roll, preserving throttle.
;; Settings persist after release. Holding a key uses operating-system repeat.
;; Unrecognised keys return the aircraft unchanged. Physics determines changes
;; in airspeed, heading, altitude and vertical speed after these control inputs.
(define (handle-key plane key)
  (cond
    [(key=? key "up") (set-pitch plane (+ (aircraft-pitch plane) PITCH-STEP))]
    [(key=? key "down") (set-pitch plane (- (aircraft-pitch plane) PITCH-STEP))]
    [(key=? key "right") (set-roll plane (+ (aircraft-roll plane) ROLL-STEP))]
    [(key=? key "left") (set-roll plane (- (aircraft-roll plane) ROLL-STEP))]
    [(or (key=? key "w") (key=? key "W"))
     (set-throttle plane (+ (aircraft-throttle plane) THROTTLE-STEP))]
    [(or (key=? key "s") (key=? key "S"))
     (set-throttle plane (- (aircraft-throttle plane) THROTTLE-STEP))]
    [(key=? key " ") (set-roll (set-pitch plane 0) 0)]
    [else plane]))

;; EXECUTABLE INPUT/OUTPUT EXAMPLES
;; Full Aircraft comparisons verify that fields outside each control are preserved.
(check-expect
 (set-pitch CONTROL-AIRCRAFT 10)
 (make-aircraft CONTROL-POSITION 2345 123 123 10 -12 -4 45))
(check-expect
 (set-pitch CONTROL-AIRCRAFT 35)
 (make-aircraft CONTROL-POSITION 2345 123 123 30 -12 -4 45))
(check-expect
 (set-pitch CONTROL-AIRCRAFT -35)
 (make-aircraft CONTROL-POSITION 2345 123 123 -30 -12 -4 45))
(check-expect
 (set-roll CONTROL-AIRCRAFT 20)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 20 -4 45))
(check-expect
 (set-roll CONTROL-AIRCRAFT 70)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 60 -4 45))
(check-expect
 (set-roll CONTROL-AIRCRAFT -70)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -60 -4 45))
(check-expect
 (set-throttle CONTROL-AIRCRAFT 75)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 75))
(check-expect
 (set-throttle CONTROL-AIRCRAFT 105)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 100))
(check-expect
 (set-throttle CONTROL-AIRCRAFT -5)
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 0))

(check-expect
 (handle-key CONTROL-AIRCRAFT "up")
 (make-aircraft CONTROL-POSITION 2345 123 123 8 -12 -4 45))
(check-expect
 (handle-key CONTROL-AIRCRAFT "down")
 (make-aircraft CONTROL-POSITION 2345 123 123 6 -12 -4 45))
(check-expect
 (handle-key CONTROL-AIRCRAFT "left")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -14 -4 45))
(check-expect
 (handle-key CONTROL-AIRCRAFT "right")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -10 -4 45))
(check-expect
 (handle-key CONTROL-AIRCRAFT "w")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 50))
(check-expect
 (handle-key CONTROL-AIRCRAFT "s")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 40))
(check-expect
 (handle-key CONTROL-AIRCRAFT "W")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 50))
(check-expect
 (handle-key CONTROL-AIRCRAFT "S")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 40))
(check-expect
 (handle-key CONTROL-AIRCRAFT " ")
 (make-aircraft CONTROL-POSITION 2345 123 123 0 0 -4 45))
(check-expect (handle-key CONTROL-AIRCRAFT "x") CONTROL-AIRCRAFT)

;; Repeated input cannot push a setting beyond its limit.
(check-expect
 (handle-key (set-pitch CONTROL-AIRCRAFT 30) "up")
 (make-aircraft CONTROL-POSITION 2345 123 123 30 -12 -4 45))
(check-expect
 (handle-key (set-pitch CONTROL-AIRCRAFT -30) "down")
 (make-aircraft CONTROL-POSITION 2345 123 123 -30 -12 -4 45))
(check-expect
 (handle-key (set-roll CONTROL-AIRCRAFT -60) "left")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -60 -4 45))
(check-expect
 (handle-key (set-roll CONTROL-AIRCRAFT 60) "right")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 60 -4 45))
(check-expect
 (handle-key (set-throttle CONTROL-AIRCRAFT 100) "w")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 100))
(check-expect
 (handle-key (set-throttle CONTROL-AIRCRAFT 0) "s")
 (make-aircraft CONTROL-POSITION 2345 123 123 7 -12 -4 0))

(provide set-pitch set-roll set-throttle handle-key)