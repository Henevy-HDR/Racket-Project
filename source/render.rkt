;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname render) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: render.rkt
; Date: 22.11.2026
; Author: Lorenzo Felix
; Purpose: Acts as the main interface between the physics engine and the cockpit instruments. It converts SI units to cockpit units and draws the instruments from a single aircraft snapshot.

(require 2htdp/image)
(require "model.rkt")
(require "cockpit-instruments.rkt")

;; metres-to-feet : Number -> Number
;; Converts physics distances to the altimeter's display unit.
(define (metres-to-feet metres)
  (* metres (/ 1250 381)))

;; mps-to-knots : Number -> Number
;; Converts airspeed in metres/second to knots.
(define (mps-to-knots speed)
  (* speed (/ 900 463)))

;; mps-to-feet-per-minute : Number -> Number
;; Converts vertical speed while preserving its climb/descent sign.
(define (mps-to-feet-per-minute speed)
  (* 60 (metres-to-feet speed)))

;; render-cockpit : Aircraft -> Image
;; Draws every instrument from the same aircraft snapshot.
;; Physics retains SI units; only drawing converts to cockpit units.
(define (render-cockpit plane)
  (compose-cockpit
   (render-throttle (aircraft-throttle plane))
   (render-compass (aircraft-heading plane))
   (render-altimeter (metres-to-feet (aircraft-altitude plane)))
   (render-airspeed (mps-to-knots (aircraft-airspeed plane)))
   (render-vspeed (mps-to-feet-per-minute (aircraft-vspeed plane)))
   (render-horizon (aircraft-pitch plane) (aircraft-roll plane))))

(provide render-cockpit metres-to-feet mps-to-knots mps-to-feet-per-minute)

