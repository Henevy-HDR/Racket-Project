;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname model) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: model.rkt
; Date: 12 Nov
; Author: Chad John Pete
; Purpose: contains all the struct definitions and the program's
;          logic functions.
; TODO: comments and examples for the structs

(require sludges)

;; Use built-in Posn as Position (or define your own struct with typed fields)
(define-type Position Posn)

(define-type Degree (number-from-<to 0 360))

(define-type Throttle (integer-from-to 0 100))

;; IT IS TRHOTTLE NOT INDEXPOWER IT IS THROTTLE NOT INDEX POWER
;; memo use define-type with integer from to and enum and one of, no define yet pwease 

(define-struct aircraft [(position Position)
                         (altitude Number)
                         (airspeed Number)
                         (heading Degree)
                         (pitch Number)
                         (roll Number)
                         (vspeed Number)
                         (throttle Throttle)])

;; Use enum for specific literal values
(define-type FlightStatus (enum "flying" "crushed"))

;; Hyphenated struct name generates the CamelCase signature `WorldState`
(define-struct world-state [(aircraft Aircraft)
                            (destination Position)
                            (status FlightStatus)])

(define-type InstrumentType
  (enum "altimeter"
        "airspeed"
        "compass"
        "horizon"
        "vertical-speed"
        "throttle"))

(define-struct instrument [(type InstrumentType)
                           (position Position)
                           (size Number)]) 

; MODULE EXPORTS
(provide Aircraft Position Degree Throttle FlightStatus WorldState InstrumentType Instrument)
(provide make-aircraft aircraft?)
(provide aircraft-position aircraft-altitude)
(provide aircraft-airspeed aircraft-heading)
(provide aircraft-pitch aircraft-roll) 
(provide aircraft-vspeed aircraft-throttle)