# Tenang: design direction

Modern Minimalist + Material Design 3 + Nature Wellness + Soft Minimalism.
Dial: ENERGY 2 / RHYTHM 2 / MOTION 1.

## Identity

Tenang is a quiet daily companion, not a clinical dashboard. The interface should feel
like a calm corner of a room: warm paper, forest green ink, one clay accent, generous
space, and nothing asking for attention it has not earned.

## Palette

| Token | Hex | Use |
|---|---|---|
| canvas | #F6F4EF | app background, warm linen |
| surface | #FFFFFF | cards, sheets, nav |
| surfaceMuted | #EFEDE6 | inputs, quiet fills |
| forest | #3F6B57 | primary actions, active states |
| forestDeep | #2C4F40 | headings on tinted surfaces, snackbar |
| forestPale | #DDE9E0 | primary container, selected chips |
| clay | #B07D62 | single warm accent, sparing |
| clayDeep | #8A5A44 | clay text that must pass AA |
| ink | #1E2A25 | primary text |
| body | #4C5A54 | body text |
| muted | #5E6B65 | secondary text, still AA |
| outline | #DCD8CE | hairline borders |

Mood scale: Tenang #4F7D63, Baik #7FA588, Biasa #C9B98F, Lelah #D9A183, Berat #C08476.
Every mood is also labelled, never colour alone.

## Type

System sans (Roboto). Display 30/700, headline 24/700, title 18/600, body 15/1.6,
label 13/600, caption 12/1.4. Tight tracking only on large headings.

## Shape and depth

Radius scale 10 / 14 / 18 / 24. Cards use a hairline outline and no shadow; shadow is
reserved for the floating navigation bar and the floating action button. Radii differ by
role: inputs 14, cards 20, sheets 28, buttons 16.

## Motion

Hover and press feedback only, plus short cross-fades for state changes. No endless
loops, no floating elements. The scan screen keeps its functional scan line.

## Motif

One organic shape: a soft horizon curve, used at very low opacity in the background and
in the greeting card. It repeats, it is quiet, and it belongs to this product.

## Content rules

Mood insights only describe the user's own entries. No invented statistics, no
fabricated testimonials, no compliance claims. Empty states explain the cause and the
next action.

## Scope and verification

All primary views use the same token layer: shell and navigation, daily check-in, journal,
coping library, exercise detail and session, expression scan, and Ruang Cerita. Exercise
content was edited to remove em dashes and keep sentences plain.

The app ships light theme only. A dark theme needs its own contrast pass over the mood
scale and the camera overlay, so it is intentionally out of scope for this pass.

Verified with `flutter analyze` (no issues), `flutter test` (smoke test plus a tab layout
test at 360 logical pixels), and `flutter build apk --debug`.

