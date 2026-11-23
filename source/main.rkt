;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname main) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))

; Filename: main.rkt
; Date: 23.11.2026
; Author: Lorenzo Felix
; Purpose: contains the main program logic, manages the world state,
;          and coordinates the physics engine with the simulation.
; TODO: implement event handlers, world updates, and integration.
; Purpose: launches the cockpit, advances physics and handles keyboard controls.

(require sludges)
(require 2htdp/universe)
(require "model.rkt")
(require "physics.rkt")
(require "render.rkt")
(require "controls.rkt")

;; DATA DEFINITIONS
;; Aircraft and its Position structure are declared in model.rkt.
;; An Aircraft is
;; (make-aircraft Position Number Number Degree Number Number Number Throttle).
;; A Position is (make-Position Number Number Degree), with X east and Y north
;; in metres. Degree is a Number in [0, 360); Throttle is an Integer in [0, 100].
;; Altitude is metres, speeds are metres/second, and pitch and roll are degrees.
;; The aircraft itself is the big-bang world; no additional struct is needed.

;; INITIAL CONDITIONS
;; Edit this aircraft to choose the starting flight conditions.
;; Position heading must agree with the aircraft heading.
(define INITIAL-POSITION (make-Position 0 0 0))
(define INITIAL-CONDITION
  (make-aircraft INITIAL-POSITION
                 1000    ;altitude in metres
                 140     ;airspeed in metres/second
                 0       ;heading: north
                 0       ;pitch: level attitude
                 0       ;roll: wings level
                 0       ;vertical speed in metres/second
                 50))    ;throttle percent

;; DT : Number
;; Advances 1/30 second of simulated flight per tick, requesting 30 ticks/second.
(define DT (/ 1 30))

;; Modified state variables: none. Handlers return aircraft values; big-bang
;; manages the current world by replacing it with each handler's result.
;; These functions are non-recursive, so no termination arguments are needed.

(: update-world (Aircraft -> Aircraft))
;; Advances the aircraft by one fixed physics timestep, preserving control settings.
(define (update-world plane)
  (step-aircraft plane DT))

(define INITIAL_POSITION (make-degree-coordinate 0 0))
(: ground-reached? (Aircraft -> Boolean))
;; Ends the airborne simulation at or below zero altitude.
;; This is a stopping condition, not a takeoff or landing model.
(define (ground-reached? plane)
  (<= (aircraft-altitude plane) 0))

;; EXECUTABLE INPUT/OUTPUT EXAMPLES
(define FREEFALL-EXAMPLE
  (make-aircraft INITIAL-POSITION 1000 0 0 0 0 0 0))
(define GROUND-EXAMPLE
  (make-aircraft INITIAL-POSITION 0 0 0 0 0 0 0))

;; From rest with no thrust or lift, one tick applies gravitational acceleration.
(check-within
 (update-world FREEFALL-EXAMPLE)
 (make-aircraft INITIAL-POSITION
                (- 1000 (* 9.80665 DT DT))
                (* 9.80665 DT)
                0 0 0 (- (* 9.80665 DT)) 0)
 0.000001)
(check-expect (ground-reached? INITIAL-CONDITION) #false)
(check-expect (ground-reached? GROUND-EXAMPLE) #true)
(check-expect
 (ground-reached? (make-aircraft INITIAL-POSITION -1 0 0 0 0 0 0))
 #true)

;; START SIMULATOR
;; Run this file in DrRacket to open the cockpit at INITIAL-CONDITION.
;; Arrows control pitch/roll, W/S control throttle, and Space levels attitude.
;; Close the window to finish; reaching ground level also stops physics updates.
(big-bang INITIAL-CONDITION
  (name "Flight simulator")
  (on-tick update-world DT) ;tiki tiki phonk
  (on-key handle-key)
  (to-draw render-cockpit)
  (stop-when ground-reached?))
