# Sentient Black Hole Simulator

## Stars

Stars have 3 attributes: Type, Mass, Elemental composition

### Main Sequence Star

Initial type.

Changes own elemtnal composition acording to fusion chain: H He C Ne O Si Fe

When fusion fuel runs out triggers **explosion:supernova**, turns into **black hole** or **neutron star** depends on mass

If mass very high turns into giant star.

### Giant Star

same as main sequence star but density much lower (larger collision)

### Black Hole

all previous mass become **element:singularity_matter**

all incoming mass first go into **accretion disk** then gradually become **singularity_matter**. Only elements in accretion disk can grant effects.

relatively small collision but large mass.

moves slowly and almost always trigger **merge** on collision with other bodies.

### Neutron Star

same as black hole but use **electron_denenerate_matter**

moves faster and on collision, triggers **split** more often than **merge**.

## Collisions

When two bodies collide, they may **split** or **merge**.

Faster collision speed = more likely to split

If merge, then smaller body merges into larger body, except if smaller body is player.

If split, then new small bodies are split from larger body, and may trigger **explosion**.

## Explosions

Explosions produce **planets** of various elemental compositions

## Elements

Elements grant effects.

### Fe

Enable magnetic field?????

### Si

Enable jets??????

### etc...
