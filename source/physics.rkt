;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname physics) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: physics.rkt
; Date: 12 Nov
; Author: Lorenzo Felix
; Purpose: contains the aircraft's physics calculations and updates
;          its state based on physical forces and elapsed time.
; TODO: validate the physics model and test its integration.

(require math)
(require sludges)

(require "model.rkt")

#|
FLIGHT SIMULATOR: PHYSICS ENGINE

This module updates the aircraft's physical state using the eight fields
specified in the proposal: position (X/Y), altitude, airspeed, heading,
pitch, roll, vertical speed, and throttle. The caller supplies an Aircraft
and elapsed time (dt); step-aircraft returns a new Aircraft after applying
a simplified airborne, still-air flight model.

Helper functions calculate thrust from throttle, drag and lift from
airspeed, and lift coefficient from angle of attack, including approximate
stall behavior. These forces determine horizontal and vertical acceleration;
velocity, altitude, heading, and X/Y position are then updated over dt.

Pitch, roll, and throttle remain as supplied by the caller. Distances are
measured in metres, speeds in m/s, throttle ranges from 0 to 1, and aircraft
angles are expressed in degrees (converted to radians for trigonometry).

This module performs only physics calculations. It does not handle controls,
rendering, maps, destinations, collisions, or the event loop.
|#



; 1. PHYSICAL CONSTANTS
; Based on beginner-friendly B2 spirit

(define GRAVITY 9.80665)
;; GRAVITY : Number
;; Gravitational acceleration in m/s2.

(define AIRCRAFT-MASS 125634)
;; AIRCRAFT-MASS : Number
;; Aircraft mass in kilograms.

(define MAX-THRUST (* 307.8 1000))
;; MAX-THRUST : Number
;; Maximum engine thrust in newtons.

(define DRAG-COEFFICIENT 0.0110)
;; DRAG-COEFFICIENT : Number
;; Simplified zero-lift drag coefficient.

(define AIR-DENSITY 1.225)
;; AIR-DENSITY : Number
;; Constant sea-level air density in kg/m3.

(define REFERENCE-AREA 477.52)
;; REFERENCE-AREA : Number
;; Aircraft wing reference area in m2.

(define INDUCED-DRAG-FACTOR 0.045)
;; INDUCED-DRAG-FACTOR : Number
;; Approximate induced drag factor in CD = CD0 + k * CL2.

(define ZERO-AOA-LIFT 0.2)
;; ZERO-AOA-LIFT : Number
;; Approximate lift coefficient at zero angle of attack.

(define LIFT-SLOPE 5.0)
;; LIFT-SLOPE : Number
;; Approximate change in lift coefficient per radian.

(define CRITICAL-AOA (/ (* 15 pi) 180))
;; CRITICAL-AOA : Number
;; Approximate stall angle in radians.

(define STALL-FADE-WIDTH (/ (* 15 pi) 180))
;; STALL-FADE-WIDTH : Number
;; Additional angle over which post-stall lift fades.

(define MIN-TURN-SPEED 1.0)
;; MIN-TURN-SPEED : Number
;; Horizontal speed in m/s below which heading is held fixed.


; 2. AIRCRAFT DATA

; Defined by indexpower
;; A Throttle is a Number in [0, 100].

(define-type Airspeed (number-from 0))
;; An Airspeed is a non-negative Number in m/s.

;; MEMO: 
;; An Aircraft is a
;; (make-aircraft Posn Number Airspeed Number Number Number Number Throttle).
;; position: local X (east) and Y (north), measured in metres.
;; altitude: height in metres.
;; airspeed: total air-relative speed, measured in m/s.
;; heading: clockwise from north, in degrees [0, 360).
;; pitch: nose angle above the horizon, in degrees.
;; roll: right-bank angle, in degrees.
;; vspeed: vertical velocity in m/s; positive means climbing.
;; throttle: engine setting from 0 to 1.
;; Airspeed must be at least the absolute value of vspeed.

(define INITIAL-AIRCRAFT
  (make-aircraft (make-posn 0 0) 1000 140 0 0 0 0 50))
;; INITIAL-AIRCRAFT : Aircraft
;; Example airborne aircraft for tests and integration.


; 3. FORCE CALCULATIONS

; a. Thrust Calculations
(: calculate-thrust (Throttle -> Number))
;; Computes engine thrust from throttle position (0 to 1).

(define-header (calculate-thrust 0.5) (/ MAX-THRUST 2))
(define-template (calculate-thrust throttle)
  (...throttle...MAX-THRUST...))

(define (calculate-thrust throttle)
  (* MAX-THRUST (/ throttle 100)))

(check-within (calculate-thrust 0) 0 0.001)
(check-within (calculate-thrust 50) (/ MAX-THRUST 2) 0.001)
(check-within (calculate-thrust 100) MAX-THRUST 0.001)

; b. Drag Calculations

(: calculate-drag (Airspeed -> Number))
;; Computes zero-lift aerodynamic drag in newtons.

(define-header (calculate-drag 0) 0)
(define-template (calculate-drag airspeed)
  (...airspeed...AIR-DENSITY...DRAG-COEFFICIENT...REFERENCE-AREA...))

(define (calculate-drag airspeed)
  (* 0.5 AIR-DENSITY DRAG-COEFFICIENT
     REFERENCE-AREA (sqr airspeed)))

(check-within (calculate-drag 0) 0 0.001)
(check-within (calculate-drag 10)
              (* 1/2 AIR-DENSITY DRAG-COEFFICIENT REFERENCE-AREA 100)
              0.001)
(check-within (calculate-drag 20) (* 4 (calculate-drag 10)) 0.001)

(: calculate-induced-drag (Airspeed Number -> Number))
;; Computes induced drag from airspeed and lift coefficient.

(define-header (calculate-induced-drag 0 0.5) 0)
(define-template (calculate-induced-drag airspeed lift-coefficient)
  (...airspeed...lift-coefficient...INDUCED-DRAG-FACTOR...))

(define (calculate-induced-drag airspeed lift-coefficient)
  (* 0.5 AIR-DENSITY REFERENCE-AREA (sqr airspeed)
     INDUCED-DRAG-FACTOR (sqr lift-coefficient)))

(check-within (calculate-induced-drag 0 0.5) 0 0.001)
(check-within (calculate-induced-drag 10 0) 0 0.001)
(check-within (calculate-induced-drag 20 0.5)
              (* 4 (calculate-induced-drag 10 0.5)) 0.001)

(: calculate-total-drag (Airspeed Number -> Number))
;; Adds zero-lift drag and induced drag in newtons.

(define-header (calculate-total-drag 0 0.5) 0)
(define-template (calculate-total-drag airspeed lift-coefficient)
  (...calculate-drag...calculate-induced-drag...))

(define (calculate-total-drag airspeed lift-coefficient)
  (+ (calculate-drag airspeed)
     (calculate-induced-drag airspeed lift-coefficient)))

(check-within (calculate-total-drag 0 0.5) 0 0.001)
(check-within (calculate-total-drag 10 0) (calculate-drag 10) 0.001)

; c. Lift Calculations

(: calculate-lift (Airspeed Number -> Number))
;; Computes signed aerodynamic lift in newtons.

(define-header (calculate-lift 0 0.5) 0)
(define-template (calculate-lift airspeed lift-coefficient)
  (...airspeed...lift-coefficient...AIR-DENSITY...REFERENCE-AREA...))

(define (calculate-lift airspeed lift-coefficient)
  (* 0.5 AIR-DENSITY (sqr airspeed)
     lift-coefficient REFERENCE-AREA))

(check-within (calculate-lift 0 0.5) 0 0.001)
(check-within (calculate-lift 10 0.5)
              (* 1/2 AIR-DENSITY REFERENCE-AREA 100 0.5) 0.001)
(check-within (calculate-lift 20 0.5)
              (* 4 (calculate-lift 10 0.5)) 0.001)
(check-within (calculate-lift 10 0) 0 0.001)

; d. Lift Coefficient Calculations

(: calculate-angle-of-attack (Number Number -> Number))
;; Computes angle of attack from pitch and flight-path angles.
;; Both inputs and output are in radians.

(define-header (calculate-angle-of-attack 0.2 0.1) 0.1)
(define-template (calculate-angle-of-attack pitch flight-path)
  (...pitch...flight-path...))

(define (calculate-angle-of-attack pitch flight-path)
  (- pitch flight-path))

(check-within (calculate-angle-of-attack 0.2 0.1) 0.1 0.001)

(: stalled? (Number -> Boolean))
;; Tests whether the absolute angle of attack reaches the stall angle.

(define-header (stalled? 0) #false)
(define-template (stalled? aoa)
  (...aoa...CRITICAL-AOA...))

(define (stalled? aoa)
  (>= (abs aoa) CRITICAL-AOA))

(check-expect (stalled? 0) #false)
(check-expect (stalled? CRITICAL-AOA) #true)
(check-expect (stalled? (- CRITICAL-AOA)) #true)

(: calculate-lift-coefficient (Number -> Number))
;; Approximates lift coefficient from angle of attack in radians.
;; Lift is linear before stall and fades after the stall threshold.
;; These coefficients are illustrative, not calibrated aircraft data.

(define-header (calculate-lift-coefficient 0) ZERO-AOA-LIFT)
(define-template (calculate-lift-coefficient aoa)
  (...aoa...ZERO-AOA-LIFT...LIFT-SLOPE...
   ...CRITICAL-AOA...STALL-FADE-WIDTH...))

(define (calculate-lift-coefficient aoa)
  (if (stalled? aoa)
      (* (+ ZERO-AOA-LIFT
            (* LIFT-SLOPE (max (- CRITICAL-AOA)
                                 (min CRITICAL-AOA aoa))))
         (max 0 (- 1 (/ (- (abs aoa) CRITICAL-AOA)
                        STALL-FADE-WIDTH))))
      (+ ZERO-AOA-LIFT (* LIFT-SLOPE aoa))))

(check-within (calculate-lift-coefficient 0) ZERO-AOA-LIFT 0.001)
(check-within (calculate-lift-coefficient 0.1)
              (+ ZERO-AOA-LIFT (* LIFT-SLOPE 0.1)) 0.001)
(check-within (calculate-lift-coefficient (* 2 CRITICAL-AOA)) 0 0.001)


; 4. MOTION CALCULATIONS

; a. Unit and Angle Calculations

(: degrees-to-radians (Number -> Number))
;; Converts an angle in degrees to radians.

(define-header (degrees-to-radians 180) pi)
(define-template (degrees-to-radians degrees)
  (...degrees...pi...))

(define (degrees-to-radians degrees)
  (* degrees (/ pi 180)))

(check-within (degrees-to-radians 180) pi 0.001)
(check-within (degrees-to-radians 90) (/ pi 2) 0.001)

(: radians-to-degrees (Number -> Number))
;; Converts an angle in radians to degrees.

(define-header (radians-to-degrees pi) 180)
(define-template (radians-to-degrees radians)
  (...radians...pi...))

(define (radians-to-degrees radians)
  (* radians (/ 180 pi)))

(check-within (radians-to-degrees pi) 180 0.001)

(: normalize-heading (Number -> Number))
;; Normalizes heading in degrees to [0, 360).

(define-header (normalize-heading 370) 10)
(define-template (normalize-heading heading)
  (...heading...floor...))

(define (normalize-heading heading)
  (- heading (* 360 (floor (/ heading 360)))))

(check-within (normalize-heading 370) 10 0.001)
(check-within (normalize-heading -90) 270 0.001)
(check-within (normalize-heading 360) 0 0.001)

; b. Velocity Calculations

(: calculate-horizontal-speed (Airspeed Number -> Number))
;; Calculates horizontal speed from airspeed and vertical speed.
;; Assumes horizontal motion follows the current heading.

(define-header (calculate-horizontal-speed 5 3) 4)
(define-template (calculate-horizontal-speed airspeed vspeed)
  (...airspeed...vspeed...sqrt...))

(define (calculate-horizontal-speed airspeed vspeed)
  (sqrt (max 0 (- (sqr airspeed) (sqr vspeed)))))

(check-within (calculate-horizontal-speed 5 3) 4 0.001)
(check-within (calculate-horizontal-speed 10 0) 10 0.001)
(check-within (calculate-horizontal-speed 5 5) 0 0.001)

(: calculate-flight-path-angle (Airspeed Number -> Number))
;; Computes flight-path angle in radians from airspeed and vspeed.
;; Returns zero when airspeed is zero.

(define-header (calculate-flight-path-angle 10 0) 0)
(define-template (calculate-flight-path-angle airspeed vspeed)
  (...airspeed...vspeed...asin...))

(define (calculate-flight-path-angle airspeed vspeed)
  (if (= airspeed 0)
      0
      (asin (max -1 (min 1 (/ vspeed airspeed))))))

(check-within (calculate-flight-path-angle 10 0) 0 0.001)
(check-within (calculate-flight-path-angle 10 10) (/ pi 2) 0.001)
(check-within (calculate-flight-path-angle 10 -10) (- (/ pi 2)) 0.001)

(: calculate-acceleration (Number Number -> Number))
;; Computes acceleration from a forward and opposing force.
;; Returns acceleration in m/s2.

(define-header (calculate-acceleration 200000 100000)
  (/ 100000 AIRCRAFT-MASS))
(define-template (calculate-acceleration forward opposing)
  (...forward...opposing...AIRCRAFT-MASS...))

(define (calculate-acceleration forward opposing)
  (/ (- forward opposing) AIRCRAFT-MASS))

(check-within (calculate-acceleration 100000 0)
              (/ 100000 AIRCRAFT-MASS) 0.001)
(check-within (calculate-acceleration 100000 100000) 0 0.001)
(check-within (calculate-acceleration 50000 100000)
              (/ -50000 AIRCRAFT-MASS) 0.001)

(: calculate-horizontal-acceleration
   (Number Number Number Number Number Number -> Number))
;; Computes acceleration along the horizontal direction of travel.
;; Inputs: thrust, drag, lift (N), pitch, roll and flight-path (rad).

(define-header (calculate-horizontal-acceleration 100000 50000 0 0 0 0)
  (/ 50000 AIRCRAFT-MASS))
(define-template (calculate-horizontal-acceleration thrust drag lift pitch roll flight-path)
  (...thrust...drag...lift...pitch...roll...flight-path...))

(define (calculate-horizontal-acceleration thrust drag lift pitch roll flight-path)
  (calculate-acceleration
   (* thrust (cos pitch))
   (+ (* drag (cos flight-path))
      (* lift (cos roll) (sin flight-path)))))

(check-within (calculate-horizontal-acceleration 100000 50000 0 0 0 0)
              (/ 50000 AIRCRAFT-MASS) 0.001)
(check-within (calculate-horizontal-acceleration 0 0 0 0 0 0) 0 0.001)

(: calculate-vertical-acceleration
   (Number Number Number Number Number Number -> Number))
;; Computes vertical acceleration from thrust, drag, lift and weight.
;; Inputs: thrust, drag, lift (N), pitch, roll and flight-path (rad).

(define-header (calculate-vertical-acceleration 0 0 0 0 0 0)
  (- GRAVITY))
(define-template (calculate-vertical-acceleration thrust drag lift pitch roll flight-path)
  (...thrust...drag...lift...pitch...roll...flight-path...GRAVITY...))

(define (calculate-vertical-acceleration thrust drag lift pitch roll flight-path)
  (- (calculate-acceleration
      (+ (* thrust (sin pitch))
         (* lift (cos roll) (cos flight-path)))
      (* drag (sin flight-path)))
     GRAVITY))

(check-within (calculate-vertical-acceleration 0 0 0 0 0 0)
              (- GRAVITY) 0.001)
(check-within (calculate-vertical-acceleration 0 0
               (* AIRCRAFT-MASS GRAVITY) 0 0 0)
              0 0.001)

(: calculate-turn-rate (Number Number Number -> Number))
;; Computes heading change in radians/s from horizontal speed,
;; lift and roll (radians). Turns are suspended near zero speed.

(define-header (calculate-turn-rate 100 0 0) 0)
(define-template (calculate-turn-rate horizontal-speed lift roll)
  (...horizontal-speed...lift...roll...MIN-TURN-SPEED...))

(define (calculate-turn-rate horizontal-speed lift roll)
  (if (< horizontal-speed MIN-TURN-SPEED)
      0
      (/ (* lift (sin roll))
         (* AIRCRAFT-MASS horizontal-speed))))

(check-within (calculate-turn-rate 100 100000 0) 0 0.001)
(check-expect (> (calculate-turn-rate 100 100000 0.2) 0) #true)
(check-within (calculate-turn-rate 0 100000 0.2) 0 0.001)

; c. State Update Calculations

(: update-airspeed (Airspeed Number Number -> Airspeed))
;; Advances a non-negative speed component with acceleration and time.
;; The aircraft's total airspeed is recomputed from its velocity components.

(define-header (update-airspeed 50 2 0.5) 51)
(define-template (update-airspeed speed acceleration dt)
  (...speed...acceleration...dt...))

(define (update-airspeed speed acceleration dt)
  (max 0 (+ speed (* acceleration dt))))

(check-within (update-airspeed 50 2 0.5) 51 0.001)
(check-within (update-airspeed 50 -4 0.5) 48 0.001)
(check-within (update-airspeed 2 -5 1) 0 0.001)

(: update-vertical-speed (Number Number Number -> Number))
;; Advances vertical speed with vertical acceleration and time.

(define-header (update-vertical-speed 5 -2 1) 3)
(define-template (update-vertical-speed vspeed acceleration dt)
  (...vspeed...acceleration...dt...))

(define (update-vertical-speed vspeed acceleration dt)
  (+ vspeed (* acceleration dt)))

(check-within (update-vertical-speed 5 -2 1) 3 0.001)
(check-within (update-vertical-speed 0 (- GRAVITY) 1)
              (- GRAVITY) 0.001)

(: update-altitude (Number Number Number -> Number))
;; Advances altitude from vertical speed and elapsed time.
;; Terrain collision handling belongs to the world simulation.

(define-header (update-altitude 100 5 2) 110)
(define-template (update-altitude altitude vspeed dt)
  (...altitude...vspeed...dt...))

(define (update-altitude altitude vspeed dt)
  (+ altitude (* vspeed dt)))

(check-within (update-altitude 100 5 2) 110 0.001)
(check-within (update-altitude 100 -5 2) 90 0.001)

(: update-heading (Number Number Number -> Number))
;; Advances heading (degrees) using turn rate (radians/s) and time.

(define-header (update-heading 350 (/ pi 18) 2) 10)
(define-template (update-heading heading turn-rate dt)
  (...heading...turn-rate...dt...normalize-heading...))

(define (update-heading heading turn-rate dt)
  (normalize-heading (+ heading (* (radians-to-degrees turn-rate) dt))))

(check-within (update-heading 350 (/ pi 18) 2) 10 0.001)
(check-within (update-heading 30 0 1) 30 0.001)

(: update-position (Posn Number Number Number -> Posn))
;; Updates local X (east) and Y (north) position in metres.
;; Heading is in degrees; horizontal speed is in m/s.

(define-header (update-position (make-posn 0 0) 10 0 1)
  (make-posn 0 10))
(define-template (update-position position horizontal-speed heading dt)
  (...posn-x...posn-y...horizontal-speed...heading...dt...))

(define (update-position position horizontal-speed heading dt)
  (make-posn
   (+ (posn-x position)
      (* horizontal-speed (sin (degrees-to-radians heading)) dt))
   (+ (posn-y position)
      (* horizontal-speed (cos (degrees-to-radians heading)) dt))))

(check-within (posn-x (update-position (make-posn 0 0) 10 0 1))
              0 0.001)
(check-within (posn-y (update-position (make-posn 0 0) 10 0 1))
              10 0.001)
(check-within (posn-x (update-position (make-posn 0 0) 10 90 1))
              10 0.001)
(check-within (posn-y (update-position (make-posn 0 0) 10 90 1))
              0 0.001)


; 5. AIRCRAFT PHYSICS STEP

(: step-aircraft (Aircraft Number -> Aircraft))
;; Computes the aircraft's next state from its current state
;; and elapsed time in seconds. Returns a new Aircraft.
;; Pitch, roll and throttle are controlled by the caller.
;; Uses semi-implicit Euler integration of velocity and position.

(define-header (step-aircraft INITIAL-AIRCRAFT 0)
  INITIAL-AIRCRAFT)
(define-template (step-aircraft aircraft dt)
  (...aircraft-position...aircraft-altitude...aircraft-airspeed...
   ...aircraft-heading...aircraft-pitch...aircraft-roll...
   ...aircraft-vspeed...aircraft-throttle...
   ...calculate-thrust...calculate-total-drag...calculate-lift...
   ...calculate-horizontal-acceleration...calculate-vertical-acceleration...
   ...update-airspeed...update-vertical-speed...update-position...))

(define (step-aircraft aircraft dt)
  (local
    [(define speed (aircraft-airspeed aircraft))
     (define vspeed (aircraft-vspeed aircraft))
     (define horizontal-speed (calculate-horizontal-speed speed vspeed))
     (define flight-path (calculate-flight-path-angle speed vspeed))
     (define pitch (degrees-to-radians (aircraft-pitch aircraft)))
     (define roll (degrees-to-radians (aircraft-roll aircraft)))
     (define aoa (calculate-angle-of-attack pitch flight-path))
     (define lift-coefficient (calculate-lift-coefficient aoa))
     (define lift (calculate-lift speed lift-coefficient))
     (define thrust (calculate-thrust (aircraft-throttle aircraft)))
     (define drag (calculate-total-drag speed lift-coefficient))
     (define horizontal-acceleration
       (calculate-horizontal-acceleration
        thrust drag lift pitch roll flight-path))
     (define vertical-acceleration
       (calculate-vertical-acceleration
        thrust drag lift pitch roll flight-path))
     (define next-horizontal-speed
       (update-airspeed horizontal-speed horizontal-acceleration dt))
     (define next-vspeed
       (update-vertical-speed vspeed vertical-acceleration dt))
     (define next-speed
       (sqrt (+ (sqr next-horizontal-speed) (sqr next-vspeed))))
     (define next-heading
       (update-heading (aircraft-heading aircraft)
                       (calculate-turn-rate horizontal-speed lift roll) dt))]
    (make-aircraft
     (update-position (aircraft-position aircraft)
                      next-horizontal-speed next-heading dt)
     (update-altitude (aircraft-altitude aircraft) next-vspeed dt)
     next-speed
     next-heading
     (aircraft-pitch aircraft)
     (aircraft-roll aircraft)
     next-vspeed
     (aircraft-throttle aircraft))))

(check-within (aircraft-airspeed
               (step-aircraft INITIAL-AIRCRAFT 0))
              (aircraft-airspeed INITIAL-AIRCRAFT) 0.001)
(check-within (aircraft-altitude
               (step-aircraft INITIAL-AIRCRAFT 0))
              (aircraft-altitude INITIAL-AIRCRAFT) 0.001)
(check-within (aircraft-heading
               (step-aircraft INITIAL-AIRCRAFT 0))
              (aircraft-heading INITIAL-AIRCRAFT) 0.001)
(check-expect (aircraft-pitch (step-aircraft INITIAL-AIRCRAFT 0.1))
              (aircraft-pitch INITIAL-AIRCRAFT))
(check-expect (aircraft-roll (step-aircraft INITIAL-AIRCRAFT 0.1))
              (aircraft-roll INITIAL-AIRCRAFT))
(check-expect (aircraft-throttle (step-aircraft INITIAL-AIRCRAFT 0.1))
              (aircraft-throttle INITIAL-AIRCRAFT))
(check-expect (> (posn-y (aircraft-position
                         (step-aircraft INITIAL-AIRCRAFT 0.1))) 0)
              #true)
(check-expect
 (< (aircraft-vspeed
     (step-aircraft
      (make-aircraft (make-posn 0 0) 1000 0 0 0 0 0 0) 0.1)) 0)
 #true)
(check-expect
 (> (aircraft-heading
     (step-aircraft
      (make-aircraft (make-posn 0 0) 1000 140 0 0 20 0 50) 0.1)) 0)
 #true)


; 6. MODULE EXPORTS


; 6. MODULE EXPORTS

(provide INITIAL-AIRCRAFT)
(provide step-aircraft)
