STILLWALKS – REDISEÑO COMPLETO DEL SISTEMA DE ESENCIA
1. Objetivo del Rediseño

Tras detectar inflación grave en la economía (acumulación excesiva de Esencia, snowball exponencial y abuso del offline), se implementa un rediseño estructural del sistema clicker.

Este rediseño busca:

Reducir la inflación.

Controlar el crecimiento exponencial.

Mantener la satisfacción del progreso.

Reforzar el valor del walking loop.

Crear una economía sostenible a largo plazo.

2. Cambios Globales Fundamentales
2.1 Reducción de Producción Pasiva (Edificios)

Se reduce x10 la producción base de todos los edificios.

Los costes y escalados se mantienen.

Edificio	Producción anterior	Nueva producción
Recolector	1.0 /s	0.1 /s
Mina	5.0 /s	0.5 /s
Cantera	20.0 /s	2.0 /s
Yacimiento	75.0 /s	7.5 /s
Fábrica	250.0 /s	25.0 /s

Esto reduce el snowball pasivo sin alterar la estructura del juego.

3. Sistema de Tap

El tap ahora depende de dos variables independientes:

Fuerza de Tap → cuánto genera.

Ritmo Interior → cada cuánto puede generar.

Un tap solo genera Esencia si ha pasado el cooldown definido por Ritmo Interior.

3.1 Fuerza de Tap
Definición

Empieza en nivel 1.

El nivel coincide exactamente con la Esencia generada por cada tap válido.

No existe nivel 0.

Ejemplo
Nivel	Esencia por tap
1	1
5	5
10	10
15	15
20	20
Parámetros

Coste base: 25

Escalado: x1.5

Nivel máximo recomendado: 20 (expandible a 30 en futuro)

Desbloqueo: Nivel Explorador 1

3.2 Ritmo Interior (Rework Completo)
Nueva función

Reduce el cooldown entre taps válidos.

No multiplica esencia.
No aumenta valor por tap.
Solo reduce el tiempo entre taps efectivos.

Parámetros

Cooldown base: 3.0 segundos

Cooldown mínimo: 0.3 segundos

Niveles: 15

Coste base: 150

Escalado: x1.5

Desbloqueo: Nivel Explorador 2

Progresión
Nivel	Cooldown
1	3.0 s
2	2.8 s
3	2.6 s
4	2.4 s
5	2.2 s
6	2.0 s
7	1.8 s
8	1.6 s
9	1.4 s
10	1.2 s
11	1.0 s
12	0.8 s
13	0.6 s
14	0.45 s
15	0.3 s

Nunca puede llegar a 0.

4. Multiplicador Global – Flujo Esencial (Rebalanceado)
Nuevo diseño

20 niveles

+1% producción total por nivel

Máximo +20%

No afecta al tap

Solo afecta:

Edificios

Criaturas

Producción offline

Parámetros

Coste base: 2.500

Escalado: x1.6

Desbloqueo: Nivel Explorador 5

Ejemplo:

Nivel	Bonus Total
1	+1%
10	+10%
20	+20%

Se elimina el multiplicador exponencial anterior.

5. Sistema Offline (Reestructurado)

El sistema offline ahora está dividido en dos mejoras independientes.

Por defecto, el juego NO genera Esencia offline.

5.1 Eco Persistente (Porcentaje Offline)

Controla el porcentaje de producción generada mientras el juego está cerrado.

Niveles: 15

+1% por nivel

Máximo: 15%

Nivel 1 desbloquea la generación offline

Parámetros

Coste base: 3.000

Escalado: x1.7

Desbloqueo: Nivel Explorador 6

5.2 Memoria Persistente (Tiempo Offline)

Controla el tiempo máximo acumulable offline.

Niveles: 15

Máximo: 8 horas

Parámetros

Coste base: 2.500

Escalado: x1.6

Desbloqueo: Nivel Explorador 7

Progresión aproximada
Nivel	Tiempo máximo
1	15 min
5	1.5 h
10	5 h
15	8 h

Offline nunca puede superar 8 horas.

6. Ajustes de XP

Aumentamos la experiencia obtenida a eclosionar orbes, actualmente entre 60 y 350 y lo cambiamos a 100, 250 y 400 de xp


# 8. Desbloqueos y Límites por Nivel de Explorador

Este apartado define, para cada nivel de Explorador:
- Qué sistemas se desbloquean por primera vez
- A qué nivel máximo puede mejorarse cada sistema ya desbloqueado

---

## Nivel de Explorador 1

Desbloqueos:
- Fuerza de Tap
- Recolector (edificio pasivo)

Límites:
- Fuerza de Tap: nivel máximo 1
- Recolector: nivel máximo 1
- Ritmo Interior: bloqueado
- Flujo Esencial: bloqueado
- Eco Persistente (%): bloqueado
- Memoria Persistente (tiempo): bloqueado
- Mina / Cantera / Yacimiento / Fábrica: bloqueados

---

## Nivel de Explorador 2

Desbloqueos:
- Ritmo Interior

Límites:
- Fuerza de Tap: nivel máximo 2
- Ritmo Interior: nivel máximo 1
- Recolector: nivel máximo 2
- Resto de edificios: bloqueados
- Flujo Esencial: bloqueado
- Eco Persistente / Memoria Persistente: bloqueados

---

## Nivel de Explorador 3

Desbloqueos:
- Mina (edificio pasivo)

Límites:
- Fuerza de Tap: nivel máximo 3
- Ritmo Interior: nivel máximo 2
- Recolector: nivel máximo 3
- Mina: nivel máximo 1
- Flujo Esencial: bloqueado
- Eco Persistente / Memoria Persistente: bloqueados

---

## Nivel de Explorador 4

Desbloqueos:
- Cantera (edificio pasivo)

Límites:
- Fuerza de Tap: nivel máximo 4
- Ritmo Interior: nivel máximo 3
- Recolector: nivel máximo 4
- Mina: nivel máximo 2
- Cantera: nivel máximo 1
- Flujo Esencial: bloqueado
- Eco Persistente / Memoria Persistente: bloqueados

---

## Nivel de Explorador 5

Desbloqueos:
- Flujo Esencial (multiplicador global)

Límites:
- Fuerza de Tap: nivel máximo 5
- Ritmo Interior: nivel máximo 4
- Recolector: nivel máximo 5
- Mina: nivel máximo 3
- Cantera: nivel máximo 2
- Flujo Esencial: nivel máximo 1
- Eco Persistente / Memoria Persistente: bloqueados

---

## Nivel de Explorador 6

Desbloqueos:
- Eco Persistente (% de esencia offline)

Límites:
- Fuerza de Tap: nivel máximo 6
- Ritmo Interior: nivel máximo 5
- Recolector: nivel máximo 6
- Mina: nivel máximo 4
- Cantera: nivel máximo 3
- Flujo Esencial: nivel máximo 2
- Eco Persistente: nivel máximo 1
- Memoria Persistente: bloqueada

---

## Nivel de Explorador 7

Desbloqueos:
- Memoria Persistente (tiempo máximo offline)

Límites:
- Fuerza de Tap: nivel máximo 7
- Ritmo Interior: nivel máximo 6
- Recolector: nivel máximo 7
- Mina: nivel máximo 5
- Cantera: nivel máximo 4
- Flujo Esencial: nivel máximo 3
- Eco Persistente: nivel máximo 2
- Memoria Persistente: nivel máximo 1

---

## Nivel de Explorador 8

Desbloqueos:
- Yacimiento (edificio pasivo)

Límites:
- Fuerza de Tap: nivel máximo 8
- Ritmo Interior: nivel máximo 7
- Recolector: nivel máximo 8
- Mina: nivel máximo 6
- Cantera: nivel máximo 5
- Yacimiento: nivel máximo 1
- Flujo Esencial: nivel máximo 4
- Eco Persistente: nivel máximo 3
- Memoria Persistente: nivel máximo 2

---

## Nivel de Explorador 9

Desbloqueos:
- Orbe Experto (tienda)

Límites:
- Fuerza de Tap: nivel máximo 9
- Ritmo Interior: nivel máximo 8
- Recolector: nivel máximo 9
- Mina: nivel máximo 7
- Cantera: nivel máximo 6
- Yacimiento: nivel máximo 2
- Flujo Esencial: nivel máximo 5
- Eco Persistente: nivel máximo 4
- Memoria Persistente: nivel máximo 3

---

## Nivel de Explorador 10

Desbloqueos:
- Ninguno nuevo

Límites:
- Fuerza de Tap: nivel máximo 10
- Ritmo Interior: nivel máximo 9
- Recolector: nivel máximo 10
- Mina: nivel máximo 8
- Cantera: nivel máximo 7
- Yacimiento: nivel máximo 3
- Flujo Esencial: nivel máximo 6
- Eco Persistente: nivel máximo 5
- Memoria Persistente: nivel máximo 4

---

## Nivel de Explorador 11

Desbloqueos:
- Fábrica (edificio pasivo)

Límites:
- Fuerza de Tap: nivel máximo 11
- Ritmo Interior: nivel máximo 10
- Recolector: nivel máximo 11
- Mina: nivel máximo 9
- Cantera: nivel máximo 8
- Yacimiento: nivel máximo 4
- Fábrica: nivel máximo 1
- Flujo Esencial: nivel máximo 7
- Eco Persistente: nivel máximo 6
- Memoria Persistente: nivel máximo 5

---

## Nivel de Explorador 12+

Regla general:
- Cada nuevo nivel de Explorador:
  - Aumenta en +1 el nivel máximo de todas las mejoras y edificios
  - Hasta alcanzar sus topes globales:
    - Fuerza de Tap: nivel 20
    - Ritmo Interior: nivel 15
    - Flujo Esencial: nivel 20
    - Eco Persistente: nivel 15
    - Memoria Persistente: nivel 15


8. Resultado Esperado

Early Game:

Tap lento y estratégico.

Sin generación offline.

Poco pasivo.

Mid Game:

Ritmo mejora.

Edificios empiezan a sentirse.

Offline leve pero útil.

Late Game:

Producción estable.

Sin explosión exponencial.

Economía controlada.