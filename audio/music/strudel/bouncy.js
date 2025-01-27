stack(
  note("[c4 e4] [g4 c5] [b4 g4] [e4 c4]")
    .s("square")
    .gain(0.35)
    .cutoff(2000)
    .decay(0.05)
    .sustain(0),
    
  note("c3 [~ c3] g3 [~ g3]")
    .s("triangle")
    .gain(0.3)
    .cutoff(1200),
    
  note("c2 [~ c2] g2 [~ g2]")
    .s("sawtooth")
    .gain(0.25)
    .cutoff(600),
    
  stack(
    s("bd*2, [~ hh]*4").gain(0.4),
    s("[~ cp]*2").gain(0.3),
    s("~ sd ~ sd").gain(0.35)
  )
)
.slow(2)
.cpm(85)
.room(0.2)
