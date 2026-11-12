;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname model) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: main.rkt
; Date: 12 Nov
; Author: Chad John Pete
; Purpose: contains all the struct definitions and the program's
;          logic functions.
; TODO: comments and examples for the structs

(define-struct position (make-posn x y))

(define degree (interval-from-to< 0 360))

(define indexpower (interval-from-to 0 100))

(define-struct aircraft [(position Position)
                         (altitude Number)
                         (airspeed Number)
                         (heading Degree)
                         (pitch Degree)
                         (roll Degree)
                         (vspeed Number)
                         (throttle Indexpower)])

(define FlightStatus (one-of "flying" "crushed"))

(define-struct WorldState ([aircraft Aircraft] [destination Position] [status FlightStatus]))



(define InstrumentType
  (one-of (enum "altimeter")
          (enum "airspeed")
          (enum "compass")
          (enum "horizon")
          (enum "vertical-speed")
          (enum "throttle")
          ))

(define-struct instrument ([type InstrumentType] [position Position] [size Number]))



